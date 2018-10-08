//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import ReactiveSwift
import Result
import DataDrivenViewControllersUI

enum ViewModelData {
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
    
protocol ViewModel {
    var data: Property<ViewModelData> { get }
}

final class ViewModelImpl: ViewModel {
    lazy var data = Property<ViewModelData>(capturing: mData)
    private lazy var mData: MutableProperty<ViewModelData> = {
        return MutableProperty<ViewModelData>(.initial { [weak self] in
            self?.mData.value = .loading
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                if let newData = (self?.makeErrorData()).map(ViewModelData.error) {
                    self?.mData.value = newData
                }
            }
        })
    }()
    
    private func makeErrorData() -> ViewModelData.Error {
        return ViewModelData.Error(
            description: "no users",
            action: { [weak self] in
                self?.mData.value = .loading
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
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
                    
                    func makeViewModel(from model: Model) -> ViewModelData.User {
                        return ViewModelData.User(
                            name: model.name,
                            icon: model.icon,
                            onSelect: { print("go to details screen with \(model)") }
                        )
                    }
                    
                    self?.mData.value = .users(networkData.map(makeViewModel))
                }
            }
        )
    }
}

class MyViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    lazy var tableView = view.makeTableView(delegateAndDatasource: self)
    lazy var loadingView = view.makeActivityIndicatorView()
    lazy var errorLabel = view.makeLabel()
    lazy var reloadButton = view.makeButton(
        title: "Reload",
        target: self,
        selector: #selector(onReloadButtonDidTap)
    )
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        viewModel.data.producer
            //don't forget to take until lifetime of view controller, or until view will disappear
            .startWithValues { [weak self] _ in
                self?.view.setNeedsLayout()
        }
        
        if case .initial(let action) = viewModel.data.value {
            action()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        switch viewModel.data.value {
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
        if case .error(let errorData) = viewModel.data.value {
            errorData.action()
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .users(let data) = viewModel.data.value {
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if case .users(let users) = viewModel.data.value, let data = users[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 35)
            cell.textLabel?.text = data.name
            cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 35)
            cell.detailTextLabel?.text = data.icon
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case .users(let users) = viewModel.data.value, let data = users[safe: indexPath.row] {
            data.onSelect()
        }
    }
}

PlaygroundPage.current.liveView = prepareForLiveView(viewController: MyViewController(viewModel: ViewModelImpl()))
