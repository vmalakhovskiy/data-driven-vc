//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI

class MyViewController : UIViewController {
    private enum State {
        case initial
        case increase
        case decrease
        case still
    }
    
    private var state = State.initial
    
    enum Props {
        case initial
        case increase(Double)
        case decrease(Double)
        case still(Double)
    }
    
    let ring = Ring(frame: CGRect(x: 60, y: 60, width: 200, height: 200))
    var circleAnimator: UIViewPropertyAnimator?
    
    var props: Props = .initial {
        didSet {
            view.setNeedsLayout()
            state = {
                switch props {
                case .initial: return .initial
                case .increase: return .increase
                case .decrease: return .decrease
                case .still: return .initial
                }
            }()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        switch props {
        case .initial where state != .initial:
            ring.transform = .identity
        case .increase(let duration) where state != .increase:
            circleAnimator?.stopAnimation(true)
            circleAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
                self.ring.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
            }, completion: nil)
        case .decrease(let duration) where state != .decrease:
            circleAnimator?.stopAnimation(true)
            circleAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
                self.ring.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            }, completion: nil)
        default: break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(ring)
    }
}

let vc = MyViewController()
PlaygroundPage.current.liveView = prepareForLiveView(screenType: .iPhoneSE, viewController: vc).0

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
    .decrease(1)
]

flow.enumerated().forEach { offset, props in
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(offset)) {
        vc.props = props
    }
}
