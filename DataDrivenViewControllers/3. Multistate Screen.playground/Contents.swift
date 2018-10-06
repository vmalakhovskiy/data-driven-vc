//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI

class MyViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    enum Props {
        case loading
        case error(description: String, onReload: () -> ())
        case loaded([Data])
        
        struct Data {
            let name: String
            let icon: String
            let onSelect: () -> ()
        }
    }
    
    var props: Props = .loading {
        didSet {
            view.setNeedsLayout()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        switch props {
        case .loading:
            loadingView.startAnimating()
            tableView.isHidden = true
            reloadButton.isHidden = true
            errorLabel.isHidden = true
        case .error(let description, _):
            loadingView.stopAnimating()
            tableView.isHidden = true
            reloadButton.isHidden = false
            errorLabel.isHidden = false
            errorLabel.text = description
        case .loaded:
            loadingView.stopAnimating()
            tableView.isHidden = false
            reloadButton.isHidden = true
            errorLabel.isHidden = true
            tableView.reloadData()
        }
    }
    
    lazy var tableView = view.makeTableView(delegateAndDatasource: self)
    lazy var loadingView = view.makeActivityIndicatorView()
    lazy var errorLabel = view.makeLabel()
    lazy var reloadButton = view.makeButton(
        title: "Reload",
        target: self,
        selector: #selector(onReloadButtonDidTap)
    )
    
    @objc func onReloadButtonDidTap() {
        if case .error(_, let action) = props {
            action()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .loaded(let data) = props {
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if case .loaded(let data) = props, let model = data[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 35)
            cell.textLabel?.text = model.name
            cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 35)
            cell.detailTextLabel?.text = model.icon
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case .loaded(let data) = props, let model = data[safe: indexPath.row] {
            model.onSelect()
        }
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
    }
}

let vc = MyViewController()
PlaygroundPage.current.liveView = prepareForLiveView(viewController: vc)

vc.props = .loading
DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
    vc.props = .error(description: "no data", onReload: {
        vc.props = .loading
        
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
            
            
            func makePropsData(from model: Model) -> MyViewController.Props.Data {
                return MyViewController.Props.Data(
                    name: model.name,
                    icon: model.icon,
                    onSelect: { print("go to details screen with \(model)") }
                )
            }
            
            vc.props = .loaded(networkData.map(makePropsData))
        }
    })
}
