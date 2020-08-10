//
//  EditItemViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class EditItemViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: EditItemViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var keyboardAdjustBehaviour: KeyboardAdjust!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameFieldView: FormFieldView!
    @IBOutlet weak var quantityStepperView: StepperView!
    @IBOutlet weak var unitStepperView: StepperView!
    @IBOutlet weak var saveItemBtn: LoadingButton!
    @IBOutlet weak var deleteItemBtn: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFieldViews()
        configureStepperViews()
        configureKeyboardAdjustBehaviour()
        
        deleteItemBtn.backgroundColor = UIColor.clear
        deleteItemBtn.setTitleColor(UIColor(named: "zenRed"), for: .normal)
        deleteItemBtn.setTitleColor(UIColor(named: "zenRed"), for: .selected)
        deleteItemBtn.setLoadingIndicatorColour(colour: UIColor(named: "zenBlack"))
    }
    
    fileprivate func configureFieldViews() {
        nameFieldView.setTitle(title: "Name")
        nameFieldView.setPlaceholder(placeholder: "Enter item name")
        nameFieldView.setKeyboardReturnKeyType(type: .done)
        nameFieldView.fieldDelegate = self
        nameFieldView.setCapitalisationType(type: .words)
        
        nameFieldView.setFieldValue(text: viewModel?.item?.name ?? "")
    }
    
    fileprivate func configureStepperViews() {
        configureQuantityStepper()
        configureUnitStepper()
    }
    
    fileprivate func configureKeyboardAdjustBehaviour() {
        keyboardAdjustBehaviour = KeyboardAdjust(scrollView: scrollView)
    }
    
    fileprivate func configureQuantityStepper() {
        let label = viewModel?.item?.unitType.description ?? ""
        let quantity = viewModel?.item?.quantity ?? 1
        quantityStepperView.configure(type: .quantity(min: 1, unitLabel: label), defaultValue: quantity) { (newQuantity) in
            self.viewModel?.item?.quantity = newQuantity
        }
    }
    
    fileprivate func configureUnitStepper() {
        let unit = viewModel?.item?.unitType.rawValue ?? 0
        let unitTypes = UnitType.allCases.compactMap { $0.description }
        unitStepperView.configure(type: .leftRight(options: unitTypes), defaultValue: unit) { (newUnitType) in
            self.viewModel?.item?.unitType = UnitType(rawValue: newUnitType) ?? .pcs
            self.configureQuantityStepper()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.viewReady()
    }
    
    func toggleSaveItemBtnLoading(loading: Bool) {
        saveItemBtn.toggleLoading(loading: loading)
    }
    
    func toggleDeleteItemBtnLoading(loading: Bool) {
        view.isUserInteractionEnabled = !loading
        deleteItemBtn.toggleLoading(loading: loading)
    }

    
    func setNameField(name: String) {
        nameFieldView.setFieldValue(text: name)
    }
    
    func showConfirmDeleteAlert() {
        let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.viewModel?.deleteItemConfirmed()
        }
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc @IBAction func cancelBtnPressed(_ sender: Any) {
        viewModel?.cancelBtnPressed()
    }
    
    @IBAction func saveItemBtnPressed(_ sender: Any) {
        viewModel?.item?.name = nameFieldView.getFieldValue()
        viewModel?.saveItemBtnPressed()
    }
    
    @IBAction func deleteItemBtnPressed(_ sender: Any) {
        viewModel?.deleteItemBtnPressed()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}

extension EditItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
