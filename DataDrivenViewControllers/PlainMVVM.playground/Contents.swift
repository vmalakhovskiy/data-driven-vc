//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import ReactiveSwift
import ReactiveCocoa
import Result
import DataDrivenViewControllersUI

enum UsersError: String, Error {
    case noUsers = "no users"
    case noNetwork = "no network"
}

struct UserViewModel {
    let name: String
    let age: String
}

protocol ViewModel {
    var users: Property<[UserViewModel]> { get }
    var error: Property<UsersError?> { get }
    var load: Action<Void, [UserViewModel], UsersError> { get }
    var reload: Action<Void, [UserViewModel], UsersError> { get }
    var onSelect: Action<UserViewModel, Void, NoError> { get }
}

final class ViewModelImpl: ViewModel {
    private let mUsers = MutableProperty([UserViewModel]())
    var users: Property<[UserViewModel]> {
        return Property(mUsers)
    }
    
    private let mIsLoading = MutableProperty(false)
    var isLoading: Property<Bool> {
        return Property(mIsLoading)
    }
    
    private let mError = MutableProperty<UsersError?>(nil)
    var error: Property<UsersError?> {
        return Property(mError)
    }
    
    lazy var load: Action<Void, [UserViewModel], UsersError> = {
        return Action { [weak self] in
            return SignalProducer { [weak self] observer, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                        let error = UsersError.noNetwork
                        self?.mError.value = error
                        observer.send(error: error)
                    }
                }
                .on(started: { [weak self] in
                    self?.mError.value = nil
                    self?.mUsers.value = []
                })
        }
    }()
    
    lazy var reload: Action<Void, [UserViewModel], UsersError> = {
        return Action { [weak self] in
            return SignalProducer(value: [
                    UserViewModel(name: "vasilii", age: "19.9"),
                    UserViewModel(name: "anatolii", age: "21.5"),
                    UserViewModel(name: "vovantolii", age: "33.6")
                ])
                .on(started: { [weak self] in
                    self?.mError.value = nil
                })
                .flatMap(.latest) { [weak self] value in
                    self?.mUsers.value = value
                    return SignalProducer(value: value)
                }
                .delay(3, on: QueueScheduler.main)
        }
    }()
    
    lazy var onSelect: Action<UserViewModel, Void, NoError> = {
        return Action { [weak self] input in
            print("route to details with \(input)")
            return .empty
        }
    }()
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
        
        let isExecuting = viewModel.load.isExecuting.producer.or(viewModel.reload.isExecuting.producer)
        let isErrorOccured = viewModel.error.map { $0 != nil }.producer
        
        reloadButton?.reactive.isHidden <~ isErrorOccured.map { !$0 }.take(until: reactive.viewWillDisappear)
        loadingView?.reactive.isAnimating <~ isExecuting.take(until: reactive.viewWillDisappear)
        
        let isTableViewHidden = isExecuting.producer.or(isErrorOccured.producer)
        tableView?.reactive.isHidden <~ isTableViewHidden.take(until: reactive.viewWillDisappear)
        tableView?.reactive.reloadData <~ isTableViewHidden
            .take(until: reactive.viewWillDisappear)
            .filter { $0 == false }
            .map { _ in () }
        
        errorLabel?.reactive.isHidden <~ isTableViewHidden.map { !$0 }.take(until: reactive.viewWillDisappear)
        errorLabel?.reactive.text <~ viewModel.error.producer
            .take(until: reactive.viewWillDisappear)
            .map { $0?.rawValue }
        
        viewModel.load <~ reactive.viewWillAppear.take(until: reactive.viewWillDisappear)
        reloadButton?.reactive.pressed = CocoaAction(viewModel.reload)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = viewModel.users.value[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = data.name
            cell.detailTextLabel?.text = data.age
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.users.value[safe: indexPath.row]
            .map(viewModel.onSelect.apply)?
            .start()
    }
}

PlaygroundPage.current.liveView = prepareForLiveView(screenType: .iPhoneSE, viewController: MyViewController(viewModel: ViewModelImpl())).0
