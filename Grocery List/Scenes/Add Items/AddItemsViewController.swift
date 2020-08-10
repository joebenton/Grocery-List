//
//  AddItemsViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class AddItemsViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: AddItemsViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var keyboardAdjustBehaviour: KeyboardAdjust!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameFieldView: FormFieldView!
    @IBOutlet weak var addItemBtn: PrimaryButton!
    @IBOutlet weak var addedItemsWrapper: UIView!
    @IBOutlet weak var addedItemsStackView: UIStackView!
    @IBOutlet weak var saveItemsBtn: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFieldViews()
        configureKeyboardAdjustBehaviour()
    }
    
    fileprivate func configureFieldViews() {
        nameFieldView.setTitle(title: "Name")
        nameFieldView.setPlaceholder(placeholder: "Enter item name")
        nameFieldView.setKeyboardReturnKeyType(type: .done)
        nameFieldView.fieldDelegate = self
        nameFieldView.setCapitalisationType(type: .words)
    }
    
    fileprivate func configureKeyboardAdjustBehaviour() {
        keyboardAdjustBehaviour = KeyboardAdjust(scrollView: scrollView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.viewReady()
    }
    
    func resetNameField() {
        nameFieldView.setFieldValue(text: "")
    }
    
    func toggleAddedItemsSection(show: Bool) {
        addedItemsWrapper.isHidden = !show
    }
    
    func addItemToAddedItemsStackView(item: CreateItem) {
        if addedItemsStackView.arrangedSubviews.count > 0 {
            let dividerView = UIView()
            dividerView.backgroundColor = UIColor.init(named: "zenLightGrey")
            dividerView.translatesAutoresizingMaskIntoConstraints = false
            addedItemsStackView.addArrangedSubview(dividerView)
            dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
        let addedItemView = AddedItemView()
        addedItemsStackView.addArrangedSubview(addedItemView)
        addedItemView.configure(item: item)
        addedItemView.delegate = self
    }
    
    func toggleSaveItemsBtnLoading(loading: Bool) {
        saveItemsBtn.toggleLoading(loading: loading)
    }
    
    func hideSkipBtn() {
        navigationItem.rightBarButtonItem = nil
    }
    
    func showCancelBtn() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBtnPressed))
    }
    
    func hideBackButton() {
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func toggleSaveItemsBtnEnabled(enabled: Bool) {
        saveItemsBtn.toggleEnabled(enabled: enabled)
    }
    
    @objc @IBAction func cancelBtnPressed(_ sender: Any) {
        viewModel?.cancelBtnPressed()
    }
    
    @IBAction func addItemBtnPressed(_ sender: Any) {
        viewModel?.addItemBtnPressed(name: nameFieldView.getFieldValue())
    }
    
    @IBAction func saveItemsBtnPressed(_ sender: Any) {
        viewModel?.addItemsBtnPressed()
    }
    
    @IBAction func skipBtnPressed(_ sender: Any) {
        viewModel?.skipBtnPressed()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}

extension AddItemsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let text = textField.text, text.count > 0 {
            viewModel?.addItemBtnPressed(name: text)
        }
        
        return true
    }
}

extension AddItemsViewController: AddedItemViewDelegate {
    func didUpdateItem(item: CreateItem) {
        viewModel?.didUpdateAddedItem(item: item)
    }
}
