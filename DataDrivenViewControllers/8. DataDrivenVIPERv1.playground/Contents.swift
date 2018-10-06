//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI

enum ViewModel {
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

protocol ViewInput: AnyObject {
    func populate(with viewModel: ViewModel)
}

protocol ViewOutput {
    func viewIsReady()
}

class Presenter: ViewOutput {
    weak var view: ViewInput?
    
    func viewIsReady() {
        view?.populate(with: .loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?.view?.populate(
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
        view?.populate(with: .loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?.view?.populate(
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

class MyViewController: UIViewController, ViewInput, UITableViewDataSource, UITableViewDelegate {
    private var tableView: UITableView?
    private var loadingView: UIActivityIndicatorView?
    private var errorLabel: UILabel?
    private var reloadButton: UIButton?
    var output: ViewOutput!
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView = UITableView()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView.map(view.addSubview)
        tableView?.bindFrameToSuperviewBounds()
        tableView?.isHidden = true
        
        loadingView = UIActivityIndicatorView(style: .gray)
        loadingView?.hidesWhenStopped = true
        loadingView?.translatesAutoresizingMaskIntoConstraints = false
        loadingView.map(view.addSubview)
        loadingView?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView?.stopAnimating()
        
        errorLabel = UILabel()
        errorLabel.map(view.addSubview)
        errorLabel?.translatesAutoresizingMaskIntoConstraints = false
        errorLabel?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorLabel?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        errorLabel?.isHidden = true
        
        reloadButton = UIButton(type: .custom)
        reloadButton?.setTitle("Reload", for: .normal)
        reloadButton?.setTitleColor(.blue, for: .normal)
        reloadButton.map(view.addSubview)
        reloadButton?.translatesAutoresizingMaskIntoConstraints = false
        reloadButton?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reloadButton?.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50).isActive = true
        reloadButton?.addTarget(self, action: #selector(onReloadButtonDidTap), for: .touchUpInside)
        reloadButton?.isHidden = true

        output.viewIsReady()
    }
    
    func populate(with viewModel: ViewModel) {
        self.viewModel = viewModel
        view.setNeedsLayout()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        switch viewModel {
        case .loading?:
            tableView?.isHidden = true
            loadingView?.startAnimating()
            errorLabel?.isHidden = true
            reloadButton?.isHidden = true
        case .users?:
            tableView?.isHidden = false
            tableView?.reloadData()
            loadingView?.stopAnimating()
            errorLabel?.isHidden = true
            reloadButton?.isHidden = true
            tableView?.reloadData()
        case .error(let errorData)?:
            tableView?.isHidden = true
            loadingView?.stopAnimating()
            errorLabel?.isHidden = false
            errorLabel?.text = errorData.description
            reloadButton?.isHidden = false
        default: break
        }
    }
    
    @objc func onReloadButtonDidTap() {
        if case .error(let errorData)? = viewModel {
            errorData.action()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .users(let data)? = viewModel {
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if case .users(let users)? = viewModel, let data = users[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = data.name
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case .users(let users)? = viewModel, let data = users[safe: indexPath.row] {
            data.action()
        }
    }
}

let controller = MyViewController()
let presenter = Presenter()
controller.output = presenter
presenter.view = controller
PlaygroundPage.current.liveView = prepareForLiveView(viewController: controller)
