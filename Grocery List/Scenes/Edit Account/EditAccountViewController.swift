//
//  EditAccountViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Kingfisher

class EditAccountViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: EditAccountViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var imagePickerController: ImagePicker?
    var overlayLoader: OverlayLoader?
    
    var keyboardAdjustBehaviour: KeyboardAdjust?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameFormFieldView: FormFieldView!
    @IBOutlet weak var locationFormFieldView: FormFieldView!
    @IBOutlet weak var profilePictureWrapper: UIView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var changeProfilePictureBtn: UIButton!
    @IBOutlet weak var saveBtn: LoadingButton!
            
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureFields()
        configureKeyboardBehaviour()
    }
    
    fileprivate func configureView() {
        profilePictureWrapper.layer.cornerRadius = profilePictureWrapper.frame.size.height / 2
        profilePictureWrapper.clipsToBounds = true
    }
    
    fileprivate func configureFields() {
        nameFormFieldView.setTitle(title: "Name")
        nameFormFieldView.setPlaceholder(placeholder: "Enter Name")
        nameFormFieldView.setContentType(type: .name)
        
        locationFormFieldView.setTitle(title: "Location")
        locationFormFieldView.setPlaceholder(placeholder: "Enter Location")
        locationFormFieldView.setContentType(type: .cityState)
    }
    
    fileprivate func configureKeyboardBehaviour() {
        keyboardAdjustBehaviour = KeyboardAdjust(scrollView: scrollView)
        keyboardAdjustBehaviour?.keyboardPadding = -((tabBarController?.tabBar.frame.size.height ?? 0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewReady()
    }
    
    func toggleSaveBtnLoading(loading: Bool) {
        saveBtn.toggleLoading(loading: loading)
    }
    
    func toggleOverlayLoading(show: Bool) {
        if let existingOverlayLoader = overlayLoader {
            existingOverlayLoader.removeFromSuperview()
            self.overlayLoader = nil
        }
        if show {
            self.overlayLoader = OverlayLoader()
            self.overlayLoader?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(self.overlayLoader!)
            self.overlayLoader?.constraintToParent(parent: view)
        }
    }
    
    func setNameField(name: String) {
        nameFormFieldView.setFieldValue(text: name)
    }
    
    func setLocationField(location: String) {
        locationFormFieldView.setFieldValue(text: location)
    }
    
    func setProfilePicture(urlString: String) {
        let url = URL(string: urlString)
        let placeholder = UIImage(named: "ic_placeholderProfilePicture")
        profilePictureImageView.kf.setImage(with: url, placeholder: placeholder)
    }
    
    func setProfilePicture(image: UIImage) {
        profilePictureImageView.image = image
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        sendTextFields()
        viewModel?.saveBtnPressed()
    }
    
    @IBAction func changeProfilePictureBtnPressed(_ sender: Any) {
        viewModel?.changeProfilePictureBtnPressed()
    }
    
    func showImagePicker() {
        imagePickerController = ImagePicker(presentationController: self, delegate: self)
        imagePickerController?.present(from: changeProfilePictureBtn)
    }
    
    fileprivate func sendTextFields() {
        viewModel?.profile?.name = nameFormFieldView.getFieldValue().trimmingCharacters(in: .whitespaces)
        viewModel?.profile?.location = locationFormFieldView.getFieldValue().trimmingCharacters(in: .whitespaces)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}

extension EditAccountViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        viewModel?.changedProfilePicture = image
    }
}
