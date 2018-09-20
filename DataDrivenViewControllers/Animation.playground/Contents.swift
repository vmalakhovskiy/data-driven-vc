//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI

class MyViewController : UIViewController {
    struct Props {
        let state: State
        
        enum State: Equatable {
            case initial
            case increase(Double)
            case decrease(Double)
            case still(Double)
            
            func isSame(as state: State) -> Bool {
                switch (self, state) {
                case (.initial, .initial):
                    return true
                case (.increase, .increase):
                    return true
                case (.decrease, .decrease):
                    return true
                case (.still, .still):
                    return true
                default:
                    return false
                }
            }
        }
        
        static let initial = Props(state: .initial)
    }
    
    let ring = Ring(frame: CGRect(x: 60, y: 60, width: 200, height: 200))
    var circleAnimator: UIViewPropertyAnimator?
    
    private var props: Props = .initial
    
    func render(props: Props) {
        let shouldSetNeedsLayout = !props.state.isSame(as: self.props.state)
        self.props = props
        if shouldSetNeedsLayout {
            view.setNeedsLayout()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        switch props.state {
        case .initial:
            ring.transform = .identity
        case .increase(let duration):
            circleAnimator?.stopAnimation(true)
            circleAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [], animations: {
                self.ring.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
            }, completion: nil)
        case .decrease(let duration):
            circleAnimator?.stopAnimation(true)
            circleAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [], animations: {
                self.ring.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            }, completion: nil)
        case .still: ()
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

vc.render(props: MyViewController.Props(state: .increase(5)))

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
    vc.render(props: MyViewController.Props(state: .increase(4)))
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
    vc.render(props: MyViewController.Props(state: .increase(3)))
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
    vc.render(props: MyViewController.Props(state: .increase(2)))
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
    vc.render(props: MyViewController.Props(state: .increase(1)))
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
    vc.render(props: MyViewController.Props(state: .decrease(5)))
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6)) {
    vc.render(props: MyViewController.Props(state: .decrease(4)))
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(7)) {
    vc.render(props: MyViewController.Props(state: .decrease(3)))
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8)) {
    vc.render(props: MyViewController.Props(state: .decrease(2)))
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(9)) {
    vc.render(props: MyViewController.Props(state: .decrease(2)))
}
