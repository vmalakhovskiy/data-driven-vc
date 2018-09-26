//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI

struct Data {
    let title: String
}

protocol ViewInput: AnyObject {
    func configure(with data: [Data])
}

protocol ViewOutput {
    var view: ViewInput? { get set }
    
    func viewIsReady()
    func dataDidSelect(with data: Data)
}

protocol DataDisplayManagerInput {
    func configureTableView(_ tableView: UITableView)
    func configure(with data: [Data])
}

protocol DataDisplayManagerOutput: AnyObject {
    func dataDidSelect(with data: Data)
}

class Presenter: ViewOutput {
    weak var view: ViewInput?
    
    func viewIsReady() {
        view?.configure(with: [
            Data(title: "some data"),
            Data(title: "nobody reads that"),
            Data(title: "whatever")
        ])
    }
    
    func dataDidSelect(with data: Data) {
        print("performing some actions with \(data)")
    }
}

class MyViewController: UIViewController, ViewInput, DataDisplayManagerOutput {
    lazy var tableView = UITableView()
    var output: ViewOutput!
    var dataDisplayManager: DataDisplayManagerInput!
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)
        tableView.bindFrameToSuperviewBounds()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataDisplayManager.configureTableView(tableView)
        output.viewIsReady()
    }
    
    // MARK: ViewInput
    
    func configure(with data: [Data]) {
        dataDisplayManager.configure(with: data)
    }
    
    // MARK: DataDisplayManagerOutput
    
    func dataDidSelect(with data: Data) {
        output.dataDidSelect(with: data)
    }
}

class DataDisplayManager: NSObject, DataDisplayManagerInput, UITableViewDataSource, UITableViewDelegate {
    weak var output: DataDisplayManagerOutput?
    private var tableView: UITableView!
    private var data = [Data]()
    
    // MARK: DataDisplayManagerInput
    
    func configureTableView(_ tableView: UITableView) {
        self.tableView = tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 0
    }
    
    func configure(with data: [Data]) {
        self.data = data
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = data[safe: indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = data.title
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let data = data[safe: indexPath.row] {
            output?.dataDidSelect(with: data)
        }
    }
}

//extension DataDisplayManager: CellDelegate {
//    func commentsButtonWasTapped(_ cell: TableViewCell) {
//        guard let indexPath = tableView.indexPath(for: cell) else { return }
//        let data = data[safe: indexPath.row]
//        output?.commentsButtonWasTapped(data: data)
//    }
//
//    func shareButtonWasTapped(_ cell: TableViewCell) {
//        guard let indexPath = tableView.indexPath(for: cell) else { return }
//        let data = data[safe: indexPath.row]
//        output?.shareButtonWasTapped(data: data)
//    }
//
//    func bookmarkButtonWasTapped(_ cell: TableViewCell) {
//        guard let indexPath = tableView.indexPath(for: cell) else { return }
//        let data = data[safe: indexPath.row]
//        output?.shareButtonWasTapped(data: data)
//        output?.shareButtonWasTapped(newsPostId: viewModel.id)
//    }
//}

let presenter = Presenter()
let dataDisplayManager = DataDisplayManager()
let controller = MyViewController()
controller.output = presenter
controller.dataDisplayManager = dataDisplayManager
presenter.view = controller
dataDisplayManager.output = controller
PlaygroundPage.current.liveView = controller
