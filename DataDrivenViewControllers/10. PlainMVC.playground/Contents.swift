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

class Model {
    var users: [UserViewModel] = []
    
    func loadUsers(completion: @escaping (Result<[UserViewModel], UsersError>) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            completion(.failure(.noNetwork))
        }
    }
    
    func reloadUsers(completion: @escaping (Result<[UserViewModel], UsersError>) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?.users = [
                UserViewModel(name: "vasilii", age: "19.9"),
                UserViewModel(name: "anatolii", age: "21.5"),
                UserViewModel(name: "vovantolii", age: "33.6")
            ]
            completion(.success(self?.users ?? []))
        }
    }
}

class MyViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var tableView: UITableView?
    private var loadingView: UIActivityIndicatorView?
    private var errorLabel: UILabel?
    private var reloadButton: UIButton?
    private let model: Model
    
    init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView = UITableView()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView.map(view.addSubview)
        tableView?.bindFrameToSuperviewBounds()
        
        loadingView = UIActivityIndicatorView(style: .gray)
        loadingView?.hidesWhenStopped = true
        loadingView?.translatesAutoresizingMaskIntoConstraints = false
        loadingView.map(view.addSubview)
        loadingView?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        errorLabel = UILabel()
        errorLabel.map(view.addSubview)
        errorLabel?.translatesAutoresizingMaskIntoConstraints = false
        errorLabel?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorLabel?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        reloadButton = UIButton(type: .custom)
        reloadButton?.setTitle("Reload", for: .normal)
        reloadButton?.setTitleColor(.blue, for: .normal)
        reloadButton.map(view.addSubview)
        reloadButton?.translatesAutoresizingMaskIntoConstraints = false
        reloadButton?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reloadButton?.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50).isActive = true
        reloadButton?.addTarget(self, action: #selector(onReloadButtonDidTap), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyLoadingAppearance()
        model.loadUsers { [weak self] result in
            switch result {
            case .success:
                self?.applySuccessAppearance()
            case .failure(let error):
                self?.applyErrorAppearance(with: error.rawValue)
            }
        }
    }
    
    @objc func onReloadButtonDidTap() {
        applyLoadingAppearance()
        model.reloadUsers { [weak self] result in
            switch result {
            case .success:
                self?.applySuccessAppearance()
            case .failure(let error):
                self?.applyErrorAppearance(with: error.rawValue)
            }
        }
    }
    
    private func applyLoadingAppearance() {
        tableView?.isHidden = true
        loadingView?.startAnimating()
        errorLabel?.isHidden = true
        reloadButton?.isHidden = true
    }
    
    private func applyErrorAppearance(with description: String) {
        tableView?.isHidden = true
        loadingView?.stopAnimating()
        errorLabel?.isHidden = false
        errorLabel?.text = description
        reloadButton?.isHidden = false
    }
    
    private func applySuccessAppearance() {
        tableView?.isHidden = false
        tableView?.reloadData()
        loadingView?.stopAnimating()
        errorLabel?.isHidden = true
        reloadButton?.isHidden = true
        tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = model.users[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = data.name
            return cell
        }
        return UITableViewCell()
    }
}

PlaygroundPage.current.liveView = prepareForLiveView(viewController: MyViewController(model: Model()))
