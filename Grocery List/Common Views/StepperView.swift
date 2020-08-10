//
//  StepperView.swift
//  Grocery List
//
//  Created by Joe Benton on 26/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

enum StepperViewType {
    case quantity(min: Int, unitLabel: String)
    case leftRight(options: Array<String>)
}

@IBDesignable
class StepperView: UIView {
    
    fileprivate var type: StepperViewType?
    
    fileprivate var stepperChangedCompletion: ((Int) -> Void)?
    fileprivate var value: Int? {
        didSet {
            valueDidChange()
        }
    }
    fileprivate var minValue: Int?
    
    var hiddenQuantityTF: UITextField?
    var hiddenQuantityTFLabel: UILabel?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        xibSetup()
    }
    
    func configure(type: StepperViewType, defaultValue: Int, stepperChangedCompletion:((Int) -> Void)?) {
        self.type = type
        self.value = defaultValue
        self.stepperChangedCompletion = stepperChangedCompletion
        
        configureView()
        updateTitleBtn()
        
        if case let StepperViewType.quantity(min, _) = type {
            minValue = min
        }
        
        endEditing(true)
    }
    
    fileprivate func xibSetup() {
        backgroundColor = UIColor.clear
        containerView = loadNib()
        containerView.frame = bounds
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        containerView.backgroundColor = UIColor.clear
    }
    
    fileprivate func configureView() {
        guard let type = self.type else { return }
        switch type {
        case .leftRight:
            let leftImage = UIImage(named: "ic_left")
            leftBtn.setImage(leftImage, for: .normal)
            leftBtn.setImage(leftImage, for: .selected)
            
            let rightImage = UIImage(named: "ic_right")
            rightBtn.setImage(rightImage, for: .normal)
            rightBtn.setImage(rightImage, for: .selected)
        case .quantity:
            let minusImage = UIImage(named: "ic_minus")
            leftBtn.setImage(minusImage, for: .normal)
            leftBtn.setImage(minusImage, for: .selected)
            
            let plusImage = UIImage(named: "ic_plus")
            rightBtn.setImage(plusImage, for: .normal)
            rightBtn.setImage(plusImage, for: .selected)
            
            hiddenQuantityTF = UITextField()
            hiddenQuantityTF?.delegate = self
            hiddenQuantityTF?.keyboardType = .decimalPad
            hiddenQuantityTF?.autocorrectionType = .no
            hiddenQuantityTF?.returnKeyType = .done
            hiddenQuantityTF?.inputAccessoryView = createToolbar()
            addSubview(hiddenQuantityTF!)
        }
    }
    
    @IBAction func leftBtnPressed(_ sender: Any) {
        guard let type = type else { return }
        guard let value = value else { return }

        switch type {
        case .quantity(let min, _):
            hiddenQuantityTF?.resignFirstResponder()
            
            self.value = max(min, value - 1)
        case .leftRight(let options):
            self.value = value > 0 ? value - 1 : options.count - 1
        }
    }
    
    @IBAction func rightBtnPressed(_ sender: Any) {
        guard let type = type else { return }
        guard let value = value else { return }

        switch type {
        case .quantity:
            hiddenQuantityTF?.resignFirstResponder()
            
            self.value = value + 1
        case .leftRight(let options):
            self.value = value < options.count - 1 ? value + 1 : 0
        }
    }
    
    @IBAction func titleBtnPressed(_ sender: Any) {
        guard case .quantity = type else { return }
        guard let value = value else { return }
        hiddenQuantityTF?.text = String(value)
        hiddenQuantityTF?.becomeFirstResponder()
    }
    
    fileprivate func valueDidChange() {
        updateTitleBtn()
        
        updateHiddenQuantityTFLabel()
        
        if let value = value {
            stepperChangedCompletion?(value)
        }
    }
    
    fileprivate func updateTitleBtn() {
        guard let type = type else { return }

        var updatedTitle = ""
        
        switch type {
        case .leftRight(let options):
            guard let value = value else { return }
            guard value < options.count else { return }
            updatedTitle = options[value]
        case .quantity(_, let unitLabel):
            let formattedValue = value != nil ? "\(value!)" : ""
            updatedTitle = "\(formattedValue) \(unitLabel)"
        }
        
        UIView.performWithoutAnimation {
            titleBtn.setTitle(updatedTitle, for: .normal)
            titleBtn.setTitle(updatedTitle, for: .selected)
            titleBtn.layoutIfNeeded()
        }
    }
    
    fileprivate func createToolbar() -> UIToolbar? {
        guard let type = type else { return nil }
        guard let value = value else { return nil }
        if case let StepperViewType.quantity(_, unitLabel) = type {
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
            toolBar.barStyle = UIBarStyle.default
            toolBar.isTranslucent = true
            toolBar.tintColor = UIColor(named: "zenBlack")
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            hiddenQuantityTFLabel = UILabel(frame: CGRect(x:0, y:0, width:200, height:21))
            hiddenQuantityTFLabel?.text = "Quantity: \(value) \(unitLabel)"
            hiddenQuantityTFLabel?.textAlignment = .center
            let toolbarTitle = UIBarButtonItem(customView: hiddenQuantityTFLabel!)
            
            toolBar.setItems([spaceButton, toolbarTitle, spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            toolBar.sizeToFit()
            return toolBar
        }
        return nil
    }
    
    fileprivate func updateHiddenQuantityTFLabel() {
        guard let type = type else { return }
        if case let StepperViewType.quantity(_, unitLabel) = type {
            let formattedValue = value != nil ? "\(value!)" : ""
            hiddenQuantityTFLabel?.text = "Quantity: \(formattedValue) \(unitLabel)"
        }
    }
    
    @objc func donePressed() {
        hiddenQuantityTF?.resignFirstResponder()
    }
}

extension StepperView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        if string.rangeOfCharacter(from: invalidCharacters) == nil {
            if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
                if updatedString.count < 4 {
                    self.value = Int(updatedString)
                    return true
                }
            }
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        let min = self.minValue ?? 1
        if text.count == 0 {
            value = min
        } else {
            let intText = Int(text) ?? min
            value = max(intText, min)
        }
    }
}
