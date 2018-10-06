//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI
import Foundation

class MyViewController : UIViewController {
    struct Props {
        let title: String
        let onLeft: (() -> ())?
        let onCenter: (() -> ())?
        let onRight: (() -> ())?
        
        static let initial = Props(title: String(), onLeft: nil, onCenter: nil, onRight: nil)
    }
    
    var props: Props = Props.initial {
        didSet {
            view.setNeedsLayout()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        label.text = props.title
        leftButton.isEnabled = props.onLeft != nil
        centerButton.isEnabled = props.onCenter != nil
        rightButton.isEnabled = props.onRight != nil
    }
    
    lazy var label = view.makeLabel()
    lazy var leftButton = view.makeButton(
        title: "Police",
        centerXAnchorConstant: -75,
        target: self,
        selector: #selector(onLeftButtonDidTap)
    )
    
    lazy var centerButton = view.makeButton(
        title: "Teacher",
        centerXAnchorConstant: 0,
        target: self,
        selector: #selector(onCenterButtonDidTap)
    )
    
    lazy var rightButton = view.makeButton(
        title: "Doctor",
        centerXAnchorConstant: 75,
        target: self,
        selector: #selector(onRightButtonDidTap)
    )

    @objc func onLeftButtonDidTap() {
        props.onLeft?()
    }
    
    @objc func onCenterButtonDidTap() {
        props.onCenter?()
    }
    
    @objc func onRightButtonDidTap() {
        props.onRight?()
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
    }
    

}

let vc = MyViewController()
PlaygroundPage.current.liveView = prepareForLiveView(viewController: vc)

let police = "👮‍♂️"
let teacher = "👨‍🏫"
let doctor = "👨🏼‍⚕️"
var profession = teacher

func update(with newProfession: String) {
    profession = newProfession
    
    print(profession)
    
    vc.props = MyViewController.Props(
        title: profession,
        onLeft: police == profession ? nil : { update(with: police) },
        onCenter: teacher == profession ? nil : { update(with: teacher) },
        onRight: doctor == profession ? nil : { update(with: doctor) }
    )
}

update(with: doctor)
