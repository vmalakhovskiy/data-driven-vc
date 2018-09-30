//: A UIKit based Playground for presenting user interface
  
import UIKit
import Foundation
import PlaygroundSupport
import DataDrivenViewControllersUI

class MyViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private enum State {
        case initial
        case nonInitial
    }
    
    private var state = State.initial
    
    struct Props: Equatable {
        let elements: [[Element]]
        let current: [Element]
        
        struct Element: Equatable {
            let title: String
            let action: () -> ()
            
            static func == (lhs: MyViewController.Props.Element, rhs: MyViewController.Props.Element) -> Bool {
                return lhs.title == rhs.title
            }
        }
        
        static let initial = Props(elements: [], current: [])
    }
    
    var props: Props = .initial {
        didSet {
            view.setNeedsLayout()
        }
    }
    
    private lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(picker)
        picker.bindFrameToSuperviewBounds()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        picker.reloadAllComponents()
        if state == .initial {
            props.current.enumerated().forEach { data in
                let (index, element) = data
                props.elements[safe: index]
                    .flatMap { $0.index(where: { $0 == element }) }
                    .map { ($0, index, true) }
                    .map(picker.selectRow)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return props.elements.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return props.elements[safe: component]?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return props.elements[safe: component]?[safe: row]?.title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        state = .nonInitial
        props.elements[safe: component]?[safe: row]?.action()
    }
}

let min = Measurement<UnitLength>(value: 0, unit: .centimeters)
let max = Measurement<UnitLength>(value: 100, unit: .centimeters)
let current = Measurement<UnitLength>(value: 50, unit: .centimeters)

private func mapInchToInt(_ value: Measurement<UnitLength>) -> Int {
    return Int(value.value)
}

private func mapFootToInt(_ value: Measurement<UnitLength>) -> Int {
    return Int(value.converted(to: .feet).value)
}

private func mapCentimeterToInt(_ value: Measurement<UnitLength>) -> Int {
    return Int(value.value)
}

let centimeters = Array(mapCentimeterToInt(min)...mapCentimeterToInt(max))
let feet = Array(mapFootToInt(min)...mapFootToInt(max))
let inches = Array(0...11)

var currentFeet = Measurement<UnitLength>(value: Double(1), unit: .feet)
var currentInch = Measurement<UnitLength>(value: Double(6), unit: .inches)
var currentCentimeter: Measurement<UnitLength>?

private func makeInchProp(from value: Int) -> MyViewController.Props.Element {
    return MyViewController.Props.Element(
        title: String(value),
        action: {
            let measure = Measurement<UnitLength>(value: Double(value), unit: .inches)
            currentInch = measure
            refresh()
        }
    )
}

private func makeFootProp(from value: Int) -> MyViewController.Props.Element {
    return MyViewController.Props.Element(
        title: String(value),
        action: {
            let measure = Measurement<UnitLength>(value: Double(value), unit: .feet)
            currentFeet = measure
            refresh()
        }
    )
}

private func makeCentimeterProp(from value: Int) -> MyViewController.Props.Element {
    return MyViewController.Props.Element(
        title: String(value),
        action: {
            let measure = Measurement<UnitLength>(value: Double(value), unit: .centimeters)
            print(measure)
        }
    )
}

let data = centimeters.map(makeCentimeterProp)
let feetData = feet.map(makeFootProp)
let inchesData = inches.map(makeInchProp)

func refresh() {
    let feetData = feet.map(makeFootProp)
    let inchesData = inches.map(makeInchProp)
    
    let props = MyViewController.Props(
        elements: [feetData, inchesData],
        current: [
            makeFootProp(from: mapFootToInt(currentFeet)),
            makeInchProp(from: mapInchToInt(currentInch))
        ]
    )
    vc.props = props
    print(currentFeet)
    print(currentInch)
}

let vc = MyViewController()
PlaygroundPage.current.liveView = prepareForLiveView(screenType: .iPhoneSE, viewController: vc).0

//let props = MyViewController.Props(elements: [feetData, inchesData], current: [feetData[2], inchesData[3]])
//vc.render(props: props)

refresh()

