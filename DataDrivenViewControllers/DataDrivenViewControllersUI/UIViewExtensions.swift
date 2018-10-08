//
//  UIViewExtensions.swift
//  DataDrivenViewControllersUI
//
//  Created by Vitalii Malakhovskyi on 9/18/18.
//  Copyright © 2018 Vitalii Malakhovskyi. All rights reserved.
//

import UIKit

public extension UIView {
    
    func makeTableView(delegateAndDatasource: UITableViewDataSource & UITableViewDelegate) -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = delegateAndDatasource
        tableView.delegate = delegateAndDatasource
        addSubview(tableView)
        tableView.bindFrameToSuperviewBounds()
        return tableView
    }
    
    func makeActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        return activityIndicator
    }
    
    func makeButton(title: String, centerXAnchorConstant: CGFloat = 0, target: Any, selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerXAnchorConstant).isActive = true
        button.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 50).isActive = true
        button.addTarget(target, action: selector, for: .touchUpInside)
        return button
    }
    
    func makePasswordTextView(_ delegate: UITextViewDelegate) -> UITextView {
        return makeTextView(delegate: delegate, centerYAnchorConstant: -50)
    }
    
    func makeConfirmPasswordTextView(_ delegate: UITextViewDelegate) -> UITextView {
        return makeTextView(delegate: delegate, centerYAnchorConstant: 70)
    }
    
    func makeTextView(delegate: UITextViewDelegate, centerYAnchorConstant: CGFloat) -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 35)
        addSubview(textView)
        textView.delegate = delegate
        textView.widthAnchor.constraint(equalTo: widthAnchor, constant: -50).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: centerYAnchorConstant).isActive = true
        textView.layer.borderColor = UIColor.red.cgColor
        textView.layer.borderWidth = 1
        return textView
    }
    
    func makePasswordLabel() -> UILabel {
        return makeLabel(centerYAnchorConstant: -120, text: "password:")
    }
    
    func makeConfirmPasswordLabel() -> UILabel {
        return makeLabel(centerYAnchorConstant: 10 ,text: "confirm:")
    }
    
    func makeLabel(centerXAnchorConstant: CGFloat = 0, centerYAnchorConstant: CGFloat = 0, text: String = "") -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 55)
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerXAnchorConstant).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: centerYAnchorConstant).isActive = true
        return label
    }
    
    func makeRingView() -> Ring {
        let ring = Ring(frame: CGRect(x: 60, y: 60, width: 200, height: 200))
        addSubview(ring)
        return ring
    }
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    public func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0@999-[subview]-0@999-|",
                options: [],
                metrics: nil,
                views: ["subview": self]
            )
        )
        superview.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0@999-[subview]-0@999-|",
                options: [],
                metrics: nil,
                views: ["subview": self]
            )
        )
    }
}
