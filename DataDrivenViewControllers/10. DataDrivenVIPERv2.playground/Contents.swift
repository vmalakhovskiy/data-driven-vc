//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI

enum ViewModel {
    case initial(() -> ())
    case loading
    case users([User])
    case error(Error)
    
    struct User {
        let name: String
        let age: String
        let action: () -> ()
    }
    
    struct Error {
        let description: String
        let action: () -> ()
    }
}

protocol ViewOutput {
    var viewModel: Observable<ViewModel> { get }
}

class Presenter: ViewOutput {
    private lazy var viewModelObserver = Observer<ViewModel>(
        value: .initial { [weak self] in self?.populateViewModelWithError() }
    )
    lazy var viewModel: Observable<ViewModel> = viewModelObserver
    
    func populateViewModelWithError() {
        viewModelObserver.update(with: .loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?.viewModelObserver.update(
                with: .error(
                    ViewModel.Error(
                        description: "very bad",
                        action: { self?.populateViewModelWithUsers() }
                    )
                )
            )
        }
    }
    
    func populateViewModelWithUsers() {
        viewModelObserver.update(with: .loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?.viewModelObserver.update(
                with: .users([
                    ViewModel.User(name: "vasya", age: "19.4", action: { print("performing some actions with vasya") }),
                    ViewModel.User(name: "petya", age: "19.4", action: { print("performing some actions with petya") }),
                    ViewModel.User(name: "kolya", age: "19.4", action: { print("performing some actions with kolya") }),
                    ViewModel.User(name: "anton", age: "19.4", action: { print("performing some actions with anton") })
                ])
            )
        }
    }
}

class MyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var tableView: UITableView?
    private var loadingView: UIActivityIndicatorView?
    private var errorLabel: UILabel?
    private var reloadButton: UIButton?
    var output: ViewOutput!
    
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
        
        if case .initial(let action) = output.viewModel.value {
            action()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewModel.addObserver(self) { vc, _ in vc.view.setNeedsLayout() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        output.viewModel.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        switch output.viewModel.value {
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
        case .users:
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
            errorLabel?.text = errorData.description
            reloadButton?.isHidden = false
        }
    }
    
    @objc func onReloadButtonDidTap() {
        if case .error(let errorData) = output.viewModel.value {
            errorData.action()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .users(let data) = output.viewModel.value {
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if case .users(let users) = output.viewModel.value, let data = users[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = data.name
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case .users(let users) = output.viewModel.value, let data = users[safe: indexPath.row] {
            data.action()
        }
    }
}

let controller = MyViewController()
controller.output = Presenter()
PlaygroundPage.current.liveView = controller
