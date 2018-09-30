//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI
import Foundation

class MyViewController: UIViewController, UITextViewDelegate {
    struct Props {
        let text: String
        let onTextUpdate: (String) -> ()
        let error: Error?
        let onSelect: (() -> ())?
        
        enum Error {
            case validation(String)
            case common(String)
        }
    }
    
    var props = Props(text: String(), onTextUpdate: { _ in () }, error: nil, onSelect: nil) {
        didSet {
            view.setNeedsLayout()
        }
    }

    private var textView: UITextView?
    private var button: UIButton?
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        textView = UITextView()
        textView?.translatesAutoresizingMaskIntoConstraints = false
        textView.map(view.addSubview)
        textView?.delegate = self
        textView?.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView?.heightAnchor.constraint(equalToConstant: 200).isActive = true
        textView?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textView?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        textView?.layer.borderColor = UIColor.red.cgColor
        
        button = UIButton(type: .custom)
        button?.setTitle("Reload", for: .normal)
        button?.setTitleColor(.blue, for: .normal)
        button?.setTitleColor(.gray, for: .disabled)
        button.map(view.addSubview)
        button?.translatesAutoresizingMaskIntoConstraints = false
        button?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button?.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 120).isActive = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        textView?.layer.borderWidth = props.error != nil ? 1 : 0
        button?.isEnabled = props.onSelect != nil
    }
    
    func textViewDidChange(_ textView: UITextView) {
        props.onTextUpdate(textView.text)
    }
}

let vc = MyViewController()
PlaygroundPage.current.liveView = prepareForLiveView(screenType: .iPhoneSE, viewController: vc).0

var text = ""

vc.props = MyViewController.Props(
    text: text,
    onTextUpdate: (update),
    error: nil,
    onSelect: nil
)

func update(text: String) {
    vc.props = MyViewController.Props(
        text: text,
        onTextUpdate: (update),
        error: { text.count < 5 ? .validation("too small") : nil }(),
        onSelect: { text.count < 5 ? nil : { print("sending \(text) to server") } }()
    )
}
