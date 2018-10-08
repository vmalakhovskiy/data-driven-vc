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
        let icon: String
        let onSelect: () -> ()
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
                        description: "no data",
                        action: { self?.populateViewModelWithUsers() }
                    )
                )
            )
        }
    }
    
    func populateViewModelWithUsers() {
        view?.populate(with: .loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            struct Model {
                let name: String
                let icon: String
            }
            
            let networkData = [
                Model(name: "angry", icon: "👿"),
                Model(name: "crying", icon: "😿"),
                Model(name: "skull", icon: "💀"),
                Model(name: "ill", icon: "🤕"),
                Model(name: "brain", icon: "🧠"),
                Model(name: "eye", icon: "👁"),
                Model(name: "zombie", icon: "🧟‍♂️")
            ]
            
            func makeViewModel(from model: Model) -> ViewModel.User {
                return ViewModel.User(
                    name: model.name,
                    icon: model.icon,
                    onSelect: { print("go to details screen with \(model)") }
                )
            }
            
            self?.view?.populate(with: .users(networkData.map(makeViewModel)))
        }
    }
}

class MyViewController: UIViewController, ViewInput, UITableViewDataSource, UITableViewDelegate {
    lazy var tableView = view.makeTableView(delegateAndDatasource: self)
    lazy var loadingView = view.makeActivityIndicatorView()
    lazy var errorLabel = view.makeLabel()
    lazy var reloadButton = view.makeButton(
        title: "Reload",
        target: self,
        selector: #selector(onReloadButtonDidTap)
    )
    var output: ViewOutput!
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
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
            tableView.isHidden = true
            loadingView.startAnimating()
            errorLabel.isHidden = true
            reloadButton.isHidden = true
        case .users?:
            tableView.isHidden = false
            tableView.reloadData()
            loadingView.stopAnimating()
            errorLabel.isHidden = true
            reloadButton.isHidden = true
            tableView.reloadData()
        case .error(let errorData)?:
            tableView.isHidden = true
            loadingView.stopAnimating()
            errorLabel.isHidden = false
            errorLabel.text = errorData.description
            reloadButton.isHidden = false
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
        if case .users(let users)? = viewModel, let data = users[safe: indexPath.row] {
            data.onSelect()
        }
    }
}

let controller = MyViewController()
let presenter = Presenter()
controller.output = presenter
presenter.view = controller
PlaygroundPage.current.liveView = prepareForLiveView(viewController: controller)
