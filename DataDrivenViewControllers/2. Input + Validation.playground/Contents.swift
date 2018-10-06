//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI
import Foundation

class MyViewController : UIViewController, UITextViewDelegate {
    struct Props {
        let password: Data
        let configrmPassword: Data
        
        static let initial = Props(
            password: .initial,
            configrmPassword: .initial
        )
        
        struct Data {
            let text: String?
            let onTextUpdate: (String) -> ()
            let error: String?
            
            static let initial = Data(
                text: nil,
                onTextUpdate: { _ in () },
                error: nil
            )
        }
    }
    
    var props: Props = .initial {
        didSet {
            view.setNeedsLayout()
        }
    }
    
    lazy var passwordLabel = view.makePasswordLabel()
    lazy var passwordTextView = view.makePasswordTextView(self)
    lazy var confirmPasswordLabel = view.makeConfirmPasswordLabel()
    lazy var confirmPasswordTextView = view.makeConfirmPasswordTextView(self)
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        passwordLabel;
        confirmPasswordLabel;
    }
    
    func textViewDidChange(_ textView: UITextView) {
        switch textView {
        case passwordTextView:
            props.password.onTextUpdate(textView.text)
        case confirmPasswordTextView:
            props.configrmPassword.onTextUpdate(textView.text)
        default: break
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        passwordTextView.text = props.password.text
        passwordTextView.layer.borderColor = props.password.error == nil
            ? UIColor.black.cgColor
            : UIColor.red.cgColor
        confirmPasswordTextView.text = props.configrmPassword.text
        confirmPasswordTextView.layer.borderColor = props.configrmPassword.error == nil
            ? UIColor.green.cgColor
            : UIColor.red.cgColor
    }
}

let vc = MyViewController()
PlaygroundPage.current.liveView = prepareForLiveView(viewController: vc)

var password = "privet"
var confirmPassword = "privet"

func makePasswordData(from text: String) -> MyViewController.Props.Data {
    return MyViewController.Props.Data(
        text: text,
        onTextUpdate: { password = $0; vc.props = makeProps() },
        error: text.count > 5 ? nil : "invalid"
    )
}

func makeConfirmPasswordData(from text: String) -> MyViewController.Props.Data {
    return MyViewController.Props.Data(
        text: text,
        onTextUpdate: { confirmPassword = $0; vc.props = makeProps() },
        error: text == password ? nil : "does not match"
    )
}

func makeProps() -> MyViewController.Props {
    return MyViewController.Props(
        password: makePasswordData(from: password),
        configrmPassword: makeConfirmPasswordData(from: confirmPassword)
    )
}

vc.props = makeProps()
