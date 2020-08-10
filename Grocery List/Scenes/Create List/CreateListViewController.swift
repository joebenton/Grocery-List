//
//  CreateListViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class CreateListViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: CreateListViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var keyboardAdjustBehaviour: KeyboardAdjust!
        
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameFieldView: FormFieldView!
    @IBOutlet weak var notesFieldView: FormFieldView!
    @IBOutlet weak var vipBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var dueDateSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var dueDatePickerWrapper: UIView!
    @IBOutlet weak var createListBtn: LoadingButton!
    @IBOutlet weak var deleteListBtnWrapper: UIView!
    @IBOutlet weak var deleteListBtn: LoadingButton!
    @IBOutlet weak var shareWrapper: UIView!
    @IBOutlet weak var shareDivider: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFieldViews()
        configureKeyboardAdjustBehaviour()
        
        deleteListBtn.backgroundColor = UIColor.clear
        deleteListBtn.setTitleColor(UIColor(named: "zenRed"), for: .normal)
        deleteListBtn.setTitleColor(UIColor(named: "zenRed"), for: .selected)
        deleteListBtn.setLoadingIndicatorColour(colour: UIColor(named: "zenBlack"))
    }
    
    fileprivate func configureFieldViews() {
        nameFieldView.setType(type: .textField(maxCharacters: 30))
        nameFieldView.setTitle(title: "Name")
        nameFieldView.setPlaceholder(placeholder: "Enter Name")
        nameFieldView.fieldDelegate = self
        nameFieldView.setCapitalisationType(type: .words)
        
        notesFieldView.setType(type: .textView)
        notesFieldView.setTitle(title: "Notes")
        notesFieldView.setPlaceholder(placeholder: "Enter Notes")
        notesFieldView.fieldDelegate = self
    }
    
    fileprivate func configureKeyboardAdjustBehaviour() {
        keyboardAdjustBehaviour = KeyboardAdjust(scrollView: scrollView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewReady()
    }
    
    func toggleVipBtn(enabled: Bool) {
        switch enabled {
        case true:
            let vipImageSelected = UIImage(named: "ic_vip_selected")
            vipBtn.setImage(vipImageSelected, for: .normal)
            vipBtn.setImage(vipImageSelected, for: .selected)
        case false:
            let vipImage = UIImage(named: "ic_vip")
            vipBtn.setImage(vipImage, for: .normal)
            vipBtn.setImage(vipImage, for: .selected)
        }
    }
    
    func toggleDueDatePickerSection(show: Bool) {
        dueDatePickerWrapper.isHidden = !show
    }
    
    func setDueDateLabel(dateString: String) {
        dueDateLabel.text = dateString
    }
    
    func setDueDatePicker(date: Date) {
        dueDatePicker.setDate(date, animated: false)
    }
    
    func toggleCreateListBtnLoading(loading: Bool) {
        createListBtn.toggleLoading(loading: loading)
    }
    
    func toggleDeleteListBtnLoading(loading: Bool) {
        view.isUserInteractionEnabled = !loading
        deleteListBtn.toggleLoading(loading: loading)
    }
    
    func setNameField(name: String) {
        nameFieldView.setFieldValue(text: name)
    }
    
    func setNotesField(notes: String) {
        notesFieldView.setFieldValue(text: notes)
    }
    
    func setDueDateSwitch(on: Bool) {
        dueDateSwitch.isOn = on
    }
    
    func setCreateBtnTitle(title: String) {
        createListBtn.setTitle(title, for: .normal)
        createListBtn.setTitle(title, for: .selected)
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func hideDeleteListBtn() {
        deleteListBtnWrapper.isHidden = true
    }
    
    func showConfirmDeleteAlert() {
        let alert = UIAlertController(title: "Delete List", message: "Are you sure you want to delete this list?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.viewModel?.deleteListConfirmed()
        }
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func hideShareBtn() {
        shareWrapper.isHidden = true
        shareDivider.isHidden = true
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        viewModel?.closeBtnPressed()
    }
    
    @IBAction func vipBtnPressed(_ sender: Any) {
        viewModel?.vipBtnPressed()
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        viewModel?.shareBtnPressed()
    }
    
    @IBAction func dueDateSwitched(_ sender: Any) {
        viewModel?.dueDateSwitched(on: dueDateSwitch.isOn)
    }
    
    @IBAction func dueDatePickerChanged(_ sender: Any) {
        viewModel?.dueDate = dueDatePicker.date
    }
    
    @IBAction func createListBtnPressed(_ sender: Any) {
        viewModel?.name = nameFieldView.getFieldValue()
        viewModel?.notes = notesFieldView.getFieldValue()
        viewModel?.createListBtnPressed()
    }
    
    @IBAction func deleteListBtnPressed(_sender: Any) {
        viewModel?.deleteListBtnPressed()
    }
}

extension CreateListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
