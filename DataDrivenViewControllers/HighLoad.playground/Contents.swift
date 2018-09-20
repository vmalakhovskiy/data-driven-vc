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
    
    private var props = Props(data: [])
    
    func render(props: Props) {
        self.props = props
        view.setNeedsLayout()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let model = props.data[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = model.title
            cell.detailTextLabel?.text = model.progress
            
            cell.alpha = 1.0
            cell.backgroundColor = .white
//            cell.imageView?.image = model.image
            return cell
        }
        return UITableViewCell()
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        if let table = tableView {
//            zip(table.visibleCells, table.indexPathsForVisibleRows ?? [IndexPath]())
//                .map { ($0.0, props.data[safe: $0.1.row]) }
//                .forEach { cell, model in
//                    cell.textLabel?.text = model?.title
//                    cell.detailTextLabel?.text = model?.progress
//                }
//        }
//    }
    
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
}

let vc = MyViewController()
PlaygroundPage.current.liveView = vc//prepareForLiveView(screenType: .iPhoneSE, viewController: vc).0

func reload() {
    DispatchQueue.main.async {
        let rawData: [(String, String, UIImage?)] = [
            ("nice cat", "progress: \(Int.random(in: 1..<100))%", nil/*UIImage(named: "cat1")*/),
            ("super cat", "progress: \(Int.random(in: 1..<100))%", nil/*UIImage(named: "cat2")*/),
            ("cute dog", "progress: \(Int.random(in: 1..<100))%", nil/*UIImage(named: "dog1")*/),
            ("puppy", "progress: \(Int.random(in: 1..<100))%", nil/*UIImage(named: "dog2")*/),
        ]
        let data = rawData.map(MyViewController.Props.Data.init)
        vc.render(props: MyViewController.Props(data: data))
        load()
    }
}

func load() {
    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(50)) {
        reload()
    }
}

reload()

