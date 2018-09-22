//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI
import Foundation

class MyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    struct Props {
        let data: [Data]
        
        struct Data {
            let title: String
            let progress: String
            let image: UIImage?
        }
    }
    
    var props = Props(data: []) {
        didSet {
            view.setNeedsLayout()
        }
    }
    
    private var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView = UITableView()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView.map(view.addSubview)
        tableView?.estimatedRowHeight = 50
        tableView?.rowHeight = 50
        tableView?.bindFrameToSuperviewBounds()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let model = props.data[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = model.title
            cell.detailTextLabel?.text = model.progress
            cell.imageView?.image = model.image
            return cell
        }
        return UITableViewCell()
    }
}

let vc = MyViewController()
PlaygroundPage.current.liveView = vc//prepareForLiveView(screenType: .iPhoneSE, viewController: vc).0

func reload() {
    DispatchQueue.main.async {
        let rawData: [(String, String, UIImage?)] = [
            ("nice cat", "progress: \(Int.random(in: 1..<100))%", UIImage(named: "cat1")),
            ("super cat", "progress: \(Int.random(in: 1..<100))%", UIImage(named: "cat2")),
            ("cute dog", "progress: \(Int.random(in: 1..<100))%", UIImage(named: "dog1")),
            ("puppy", "progress: \(Int.random(in: 1..<100))%",
                UIImage(named: "dog2")),
        ]
        let data = rawData.map(MyViewController.Props.Data.init)
        vc.render(props: MyViewController.Props(data: data))
        load()
    }
}

func load() {
    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(32)) {
        reload()
    }
}

reload()

