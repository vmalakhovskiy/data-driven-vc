//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import ReactiveSwift
import ReactiveCocoa
import Result
import DataDrivenViewControllersUI

enum ViewModelData {
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
                    self?.mData.value = .users([
                        ViewModelData.User(name: "1", age: "2", action: { print("selected user name 1 age 2") })
                    ])
                }
            }
        )
    }
}

class MyViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var tableView: UITableView?
    private var loadingView: UIActivityIndicatorView?
    private var errorLabel: UILabel?
    private var reloadButton: UIButton?
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
        
        reactive.makeBindingTarget { (vc, _) in vc.view.setNeedsLayout() } <~ viewModel.data.producer.take(until: reactive.viewWillDisappear)
        if case .initial(let action) = viewModel.data.value {
            action()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        switch viewModel.data.value {
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
            cell.textLabel?.text = data.name
            cell.detailTextLabel?.text = data.age
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case .users(let users) = viewModel.data.value, let data = users[safe: indexPath.row] {
            data.action()
        }
    }
}

PlaygroundPage.current.liveView = prepareForLiveView(screenType: .iPhoneSE, viewController: MyViewController(viewModel: ViewModelImpl())).0
