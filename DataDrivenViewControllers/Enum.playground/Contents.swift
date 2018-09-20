//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI
import UIKit

class MyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    enum Props {
        case initial
        case loading
        case loaded([Loaded])
        case error(String, () -> ())
        
        struct Loaded {
            let title: String
        }
    }
    
    private var props: Props = .initial
    
    func render(props: Props) {
        self.props = props
        view.setNeedsLayout()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .loaded(let data) = props {
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if case .loaded(let data) = props, let model = data[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = model.title
            return cell
        }
        return UITableViewCell()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
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
        case .error(let reason, _):
            tableView?.isHidden = true
            loadingView?.stopAnimating()
            errorLabel?.isHidden = false
            errorLabel?.text = reason
            reloadButton?.isHidden = false
        }
        
        tableView?.reloadData()
    }
    
    private var tableView: UITableView?
    private var loadingView: UIActivityIndicatorView?
    private var errorLabel: UILabel?
    private var reloadButton: UIButton?
    
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
    
    @objc func onReloadButtonDidTap() {
        if case .error(_, let action) = props {
            action()
        }
    }
}

let vc = MyViewController()
PlaygroundPage.current.liveView = prepareForLiveView(screenType: .iPhoneSE, viewController: vc).0

vc.render(props: MyViewController.Props.loading)

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
    vc.render(props: MyViewController.Props.error("no network connection") {
        vc.render(props: MyViewController.Props.loading)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            vc.render(
                props: MyViewController.Props.loaded(
                    [
                        MyViewController.Props.Loaded(title: "1"),
                        MyViewController.Props.Loaded(title: "2")
                    ]
                )
            )
        }
    })
}
