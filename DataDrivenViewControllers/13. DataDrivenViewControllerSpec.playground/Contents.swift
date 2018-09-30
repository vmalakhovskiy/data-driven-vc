//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI

class MyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    enum Props {
        case initial
        case loading
        case loaded([Loaded])
        case error(String, () -> ())
        
        struct Loaded {
            let title: String
            let onSelect: () -> ()
        }
    }
    
    var props: Props = .initial {
        didSet {
            view.setNeedsLayout()
        }
    }
    
   var tableView: UITableView?
   var loadingView: UIActivityIndicatorView?
   var errorLabel: UILabel?
   var reloadButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView = UITableView()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView.map(view.addSubview)
        
        loadingView = UIActivityIndicatorView(style: .gray)
        loadingView?.hidesWhenStopped = true
        loadingView.map(view.addSubview)
        
        errorLabel = UILabel()
        errorLabel.map(view.addSubview)

        reloadButton = UIButton(type: .custom)
        reloadButton.map(view.addSubview)
        reloadButton?.addTarget(self, action: #selector(onReloadButtonDidTap), for: .touchUpInside)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = model.title
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .loaded(let data) = props, let model = data[safe: indexPath.row] {
            model.onSelect()
        }
    }
}

import Quick
import Nimble

class MyViewControllerSpec: QuickSpec {
    override func spec() {
        describe("MyViewController") {
            var sut: MyViewController!
            
            beforeEach {
                sut = MyViewController()
                _ = sut.view
                sut.viewDidLoad()
            }
            
            describe("when initialized") {
                it("should have all outlets sut up") {
                    expect(sut.tableView).toNot(beNil())
                    expect(sut.loadingView).toNot(beNil())
                    expect(sut.errorLabel).toNot(beNil())
                    expect(sut.reloadButton).toNot(beNil())
                }
            }
            
            describe("when selecting table view cell") {
                var correctActionCalled: Bool!
                
                beforeEach {
                    correctActionCalled = false
                    sut.props = .loaded([
                        MyViewController.Props.Loaded(title: String(), onSelect: {}),
                        MyViewController.Props.Loaded(title: String(), onSelect: { correctActionCalled = true })
                    ])
                }
                
                it("should call correct action") {
                    let indexPath = IndexPath(row: 1, section: 0)
                    sut.tableView?.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
                    sut.tableView(sut.tableView!, didSelectRowAt: indexPath)
                    
                    expect(correctActionCalled).to(beTruthy())
                }
            }
            
            describe("when tapping on reload button") {
                var correctActionCalled: Bool!
                
                beforeEach {
                    correctActionCalled = false
                    sut.props = .error("", { correctActionCalled = true })
                }
                
                it("should call correct action") {
                    sut.reloadButton?.sendActions(for: .touchUpInside)
                    
                    expect(correctActionCalled).to(beTruthy())
                }
            }
        }
    }
}

MyViewControllerSpec.defaultTestSuite.run()
