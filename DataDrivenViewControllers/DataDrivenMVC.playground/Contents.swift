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
    let age: String
}

struct Model {
    func loadUsers(completion: @escaping (Result<[UserViewModel], UsersError>) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            completion(.failure(.noNetwork))
        }
    }
    
    func reloadUsers(completion: @escaping (Result<[UserViewModel], UsersError>) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            completion(.success([
                UserViewModel(name: "vasilii", age: "19.9"),
                UserViewModel(name: "anatolii", age: "21.5"),
                UserViewModel(name: "vovantolii", age: "33.6")
            ]))
        }
    }
}

class MyViewController : UIViewController {
    private let model: Model
    
    init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = View(frame: UIScreen.main.bounds)
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
                let propsData = data.map { View.Props.Loaded(title: $0.name) }
                self?.updateView(with: .loaded(propsData))
            case .failure(let error):
                self?.updateView(with: .error(error.rawValue, { self?.reloadUsers() }))
            }
        }
    }
    
    func reloadUsers() {
        updateView(with: .loading)
        model.reloadUsers { [weak self] result in
            switch result {
            case .success(let data):
                let propsData = data.map { View.Props.Loaded(title: $0.name) }
                self?.updateView(with: .loaded(propsData))
            case .failure(let error):
                self?.updateView(with: .error(error.rawValue, { self?.reloadUsers() }))
            }
        }
    }
}

class View: UIView, UITableViewDelegate, UITableViewDataSource {
    enum Props: Equatable {
        static func == (lhs: View.Props, rhs: View.Props) -> Bool {
            switch (lhs, rhs) {
            case (.initial, .initial): return true
            case (.loading, .loading): return true
            case (.loaded(let left), .loaded(let right)): return left == right
            case (.error(let left, _), .error(let right, _)): return left == right
            default: return false
            }
        }
        
        case initial
        case loading
        case loaded([Loaded])
        case error(String, () -> ())
        
        struct Loaded: Equatable {
            let title: String
        }
    }
    
    var props: Props = .initial {
        didSet {
            setNeedsLayout()
        }
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        switch props {
        case .initial:
            tableView?.isHidden = true
            loadingView?.stopAnimating()
            errorLabel?.isHidden = true
            reloadButton?.isHidden = true
        case .loading:
            tableView?.isHidden = true
            loadingView?.startAnimating()
            errorLabel?.isHidden = true
            reloadButton?.isHidden = true
        case .loaded:
            tableView?.isHidden = false
            tableView?.reloadData()
            loadingView?.stopAnimating()
            errorLabel?.isHidden = true
            reloadButton?.isHidden = true
            tableView?.reloadData()
        case .error(let errorData):
            tableView?.isHidden = true
            loadingView?.stopAnimating()
            errorLabel?.isHidden = false
            errorLabel?.text = errorData.0
            errorLabel?.layoutIfNeeded()
            reloadButton?.isHidden = false
        }
    }
    
    private var tableView: UITableView?
    private var loadingView: UIActivityIndicatorView?
    private var errorLabel: UILabel?
    private var reloadButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        tableView = UITableView()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView.map(addSubview)
        tableView?.bindFrameToSuperviewBounds()
        
        loadingView = UIActivityIndicatorView(style: .gray)
        loadingView?.hidesWhenStopped = true
        loadingView?.translatesAutoresizingMaskIntoConstraints = false
        loadingView.map(addSubview)
        loadingView?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingView?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        errorLabel = UILabel()
        errorLabel.map(addSubview)
        errorLabel?.translatesAutoresizingMaskIntoConstraints = false
        errorLabel?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        errorLabel?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        reloadButton = UIButton(type: .custom)
        reloadButton?.setTitle("Reload", for: .normal)
        reloadButton?.setTitleColor(.blue, for: .normal)
        reloadButton.map(addSubview)
        reloadButton?.translatesAutoresizingMaskIntoConstraints = false
        reloadButton?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        reloadButton?.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 50).isActive = true
        reloadButton?.addTarget(self, action: #selector(onReloadButtonDidTap), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onReloadButtonDidTap() {
        if case .error(_ ,let reload) = props {
            reload()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .loaded(let data) = props {
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if case .loaded(let users) = props, let data = users[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = data.title
            return cell
        }
        return UITableViewCell()
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController(model: Model())
