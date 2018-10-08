//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI
import Result

enum UsersError: String, Error {
    case noUsers = "no users"
    case noNetwork = "no network"
}

struct UserViewModel {
    let name: String
    let icon: String
}

struct Model {
    func loadUsers(completion: @escaping (Result<[UserViewModel], UsersError>) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            completion(.failure(.noNetwork))
        }
    }
    
    func reloadUsers(completion: @escaping (Result<[UserViewModel], UsersError>) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            let networkData = [
                UserViewModel(name: "angry", icon: "👿"),
                UserViewModel(name: "crying", icon: "😿"),
                UserViewModel(name: "skull", icon: "💀"),
                UserViewModel(name: "ill", icon: "🤕"),
                UserViewModel(name: "brain", icon: "🧠"),
                UserViewModel(name: "eye", icon: "👁"),
                UserViewModel(name: "zombie", icon: "🧟‍♂️")
            ]
            
            completion(.success(networkData))
        }
    }
}

class MyViewController : UIViewController {
    private let model: Model
    
    init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = View(frame: UIScreen.main.bounds)
        view.backgroundColor = .white
    }
    
    func updateView(with props: View.Props) {
        if let customView = view as? View {
            customView.props = props
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView(with: .loading)
        model.loadUsers { [weak self] result in
            switch result {
            case .success(let data):
                let propsData = data.map { userModel in
                    return View.Props.Loaded(
                        name: userModel.name,
                        icon: userModel.icon,
                        onSelect: { print("go to details screen with \(userModel)") }
                    )
                }
                self?.updateView(with: .loaded(propsData))
            case .failure(let error):
                self?.updateView(
                    with: .error(
                        View.Props.Error(description: error.rawValue, action: { self?.reloadUsers() })
                    )
                )
            }
        }
    }
    
    func reloadUsers() {
        updateView(with: .loading)
        model.reloadUsers { [weak self] result in
            switch result {
            case .success(let data):
                let propsData = data.map { userModel in
                    return View.Props.Loaded(
                        name: userModel.name,
                        icon: userModel.icon,
                        onSelect: { print("go to details screen with \(userModel)") }
                    )
                }
                self?.updateView(with: .loaded(propsData))
            case .failure(let error):
                self?.updateView(
                    with: .error(
                        View.Props.Error(description: error.rawValue, action: { self?.reloadUsers() })
                    )
                )
            }
        }
    }
}

class View: UIView, UITableViewDelegate, UITableViewDataSource {
    enum Props {
        case initial
        case loading
        case loaded([Loaded])
        case error(Error)
        
        struct Loaded {
            let name: String
            let icon: String
            let onSelect: () -> ()
        }
        
        struct Error {
            let description: String
            let action: () -> ()
        }
    }
    
    var props: Props = .initial {
        didSet {
            setNeedsLayout()
        }
    }

    lazy var tableView = makeTableView(delegateAndDatasource: self)
    lazy var loadingView = makeActivityIndicatorView()
    lazy var errorLabel = makeLabel()
    lazy var reloadButton = makeButton(
        title: "Reload",
        target: self,
        selector: #selector(onReloadButtonDidTap)
    )

    override func layoutSubviews() {
        super.layoutSubviews()

        switch props {
        case .initial:
            tableView.isHidden = true
            loadingView.stopAnimating()
            errorLabel.isHidden = true
            reloadButton.isHidden = true
        case .loading:
            tableView.isHidden = true
            loadingView.startAnimating()
            errorLabel.isHidden = true
            reloadButton.isHidden = true
        case .loaded:
            tableView.isHidden = false
            tableView.reloadData()
            loadingView.stopAnimating()
            errorLabel.isHidden = true
            reloadButton.isHidden = true
            tableView.reloadData()
        case .error(let errorData):
            tableView.isHidden = true
            loadingView.stopAnimating()
            errorLabel.isHidden = false
            errorLabel.text = errorData.description
            errorLabel.setNeedsLayout()
            errorLabel.layoutIfNeeded()
            reloadButton.isHidden = false
        }
    }
    
    @objc func onReloadButtonDidTap() {
        if case .error(let errorData) = props {
            errorData.action()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .loaded(let data) = props {
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if case .loaded(let users) = props, let data = users[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 35)
            cell.textLabel?.text = data.name
            cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 35)
            cell.detailTextLabel?.text = data.icon
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case .loaded(let users) = props, let data = users[safe: indexPath.row] {
            data.onSelect()
        }
    }
}

PlaygroundPage.current.liveView = prepareForLiveView(viewController: MyViewController(model: Model()))
