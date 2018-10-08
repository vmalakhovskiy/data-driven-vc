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
        let icon: String
        let onSelect: () -> ()
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
                        description: "no data",
                        action: { self?.populateViewModelWithUsers() }
                    )
                )
            )
        }
    }
    
    func populateViewModelWithUsers() {
        viewModelObserver.update(with: .loading)
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
            
        self?.viewModelObserver.update(with: .users(networkData.map(makeViewModel)))
        }
    }
}

class MyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    lazy var tableView = view.makeTableView(delegateAndDatasource: self)
    lazy var loadingView = view.makeActivityIndicatorView()
    lazy var errorLabel = view.makeLabel()
    lazy var reloadButton = view.makeButton(
        title: "Reload",
        target: self,
        selector: #selector(onReloadButtonDidTap)
    )
    var output: ViewOutput!
    
    init(output: ViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
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
            tableView.isHidden = true
            loadingView.stopAnimating()
            errorLabel.isHidden = true
            reloadButton.isHidden = true
        case .loading:
            tableView.isHidden = true
            loadingView.startAnimating()
            errorLabel.isHidden = true
            reloadButton.isHidden = true
        case .users:
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
            reloadButton.isHidden = false
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
        if case .users(let users) = output.viewModel.value, let data = users[safe: indexPath.row] {
            data.onSelect()
        }
    }
}

let controller = MyViewController(output: Presenter())
PlaygroundPage.current.liveView = prepareForLiveView(viewController: controller)
