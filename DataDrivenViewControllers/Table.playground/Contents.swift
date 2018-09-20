//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI

struct Model {
    let name: String
    let version: String
    let id: Int
}

let dataSource = [
    Model(name: "iphone", version: "5", id: 5),
    Model(name: "iphone", version: "6", id: 6),
    Model(name: "iphone", version: "7", id: 7)
]

class MyViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    struct Props {
        let elements: [Element]
        
        struct Element {
            let title: String
            let description: String
            let action: () -> ()
        }
        
        static let initial = Props(elements: [])
    }
    
    private var props: Props = .initial
    
    func render(props: Props) {
        self.props = props
        view.setNeedsLayout()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props.elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard props.elements.indices.contains(indexPath.row) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let model = props.elements[indexPath.row]
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard props.elements.indices.contains(indexPath.row) else { return }
        
        let model = props.elements[indexPath.row]
        model.action()
    }
    
    private var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView.map(view.addSubview)
        tableView?.bindFrameToSuperviewBounds()
    }
}

let vc = MyViewController()
PlaygroundPage.current.liveView = prepareForLiveView(screenType: .iPhoneSE, viewController: vc).0

func makeProps(from model: Model) -> MyViewController.Props.Element {
    return MyViewController.Props.Element(
        title: model.name,
        description: model.version,
        action: { print("asking router to route to details vc with title - \(model.name), version - \(model.version)") }
    )
}

let data = dataSource.map(makeProps)
let props = MyViewController.Props(elements: data)
vc.render(props: props)
