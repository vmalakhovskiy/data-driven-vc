//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI

class MyViewController : UIViewController {
    private var shouldUpdateState = false
    
    enum Props {
        case initial
        case increase(Double)
        case decrease(Double)
        case still(Double)
    }
    
    lazy var ring = view.makeRingView()
    var circleAnimator: UIViewPropertyAnimator?
    
    var props: Props = .initial {
        willSet {
            shouldUpdateState = {
                switch (props, newValue) {
                case (.initial, .initial): return false
                case (.increase, .increase): return false
                case (.decrease, .decrease): return false
                case (.still, .still): return false
                default: return true
                }
            }()
        }
        didSet {
            view.setNeedsLayout()
        }
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        switch (props, shouldUpdateState) {
        case (.initial, true):
            ring.transform = .identity
        case (.increase(let duration), true):
            circleAnimator?.stopAnimation(true)
            circleAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
                self.ring.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
            }, completion: nil)
        case (.decrease(let duration), true):
            circleAnimator?.stopAnimation(true)
            circleAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
                self.ring.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            }, completion: nil)
        default: break
        }
    }
}

let vc = MyViewController()
PlaygroundPage.current.liveView = prepareForLiveView(viewController: vc)

let flow: [MyViewController.Props] = [
    .increase(5),
    .increase(4),
    .increase(3),
    .increase(2),
    .increase(1),
    .still(3),
    .still(2),
    .still(1),
    .decrease(5),
    .decrease(4),
    .decrease(3),
    .decrease(2),
    .decrease(1),
    .increase(5),
    .increase(4),
    .increase(3),
    .increase(2),
    .increase(1),
    .still(3),
    .still(2),
    .still(1),
    .decrease(5),
    .decrease(4),
    .decrease(3),
    .decrease(2),
    .decrease(1),
    .increase(5),
    .increase(4),
    .increase(3),
    .increase(2),
    .increase(1),
    .still(3),
    .still(2),
    .still(1),
    .decrease(5),
    .decrease(4),
    .decrease(3),
    .decrease(2),
    .decrease(1)
]

flow.enumerated().forEach { offset, props in
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(offset)) {
        vc.props = props
    }
}
