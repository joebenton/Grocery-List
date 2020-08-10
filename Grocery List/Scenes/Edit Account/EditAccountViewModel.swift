//
//  EditAccountViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class EditAccountViewModel: ViewModel {
    weak var coordinator: EditAccountCoordinator?
    weak var viewController: EditAccountViewController?

    @Injected private var authService: AuthService
    @Injected private var storageService: StorageService
    
    var profile: Profile?
    var imagePickerController: ImagePicker?
    
    var changedProfilePicture: UIImage? {
        didSet {
            profilePictureDidChange()
        }
    }
    
    init(with coordinator: EditAccountCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        getCurrentProfile()
    }
    
    fileprivate func getCurrentProfile() {
        viewController?.toggleOverlayLoading(show: true)
        
        authService.getProfile { [weak self] (result) in
            DispatchQueue.main.async {
                self?.viewController?.toggleOverlayLoading(show: false)
                
                switch result {
                case .success(let profile):
                    self?.profile = profile
                    self?.configureFields()
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Edit Profile Error", message: error.message)
                }
            }
        }
    }
    
    fileprivate func configureFields() {
        guard let profile = self.profile else { return }
        viewController?.setNameField(name: profile.name)
        viewController?.setLocationField(location: profile.location)
        
        if profile.pictureUrl.count > 0 {
            viewController?.setProfilePicture(urlString: profile.pictureUrl)
        }
    }
    
    func changeProfilePictureBtnPressed() {
        viewController?.showImagePicker()
    }
    
    func saveBtnPressed() {
        viewController?.toggleSaveBtnLoading(loading: true)
        
        saveProfilePictureIfNeeded { [weak self] (updatedProfilePictureResult) in
            switch updatedProfilePictureResult {
            case .success(let updatedProfilePictureURL):
                if let updatedProfilePictureURL = updatedProfilePictureURL {
                    self?.profile?.pictureUrl = updatedProfilePictureURL.absoluteString
                }
                guard let profile = self?.profile else { return }
                
                self?.authService.updateProfile(profile: profile) { [weak self] (result) in
                    DispatchQueue.main.async {
                        self?.viewController?.toggleSaveBtnLoading(loading: false)

                        switch result {
                        case .success:
                            self?.viewController?.showAlert(title: "Profile Saved", message: "Your profile has been updated.")
                            self?.changedProfilePicture = nil
                        case .failure(let error):
                            self?.viewController?.showAlert(title: "Edit Profile Error", message: error.message)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.toggleSaveBtnLoading(loading: false)
                    self?.viewController?.showAlert(title: "Edit Profile Error", message: error.message)
                }
            }
        }
    }
    
    func saveProfilePictureIfNeeded(completion: @escaping (Result<URL?, DisplayableError>) -> Void) {
        guard let profilePicture = changedProfilePicture else {
            completion(.success(nil))
            return
        }
        
        guard let userUid = authService.getUserUid() else {
            completion(.success(nil))
            return
        }
    
        let widthHeight:CGFloat = 500
        let cropedResizedProfilePicture = cropSquareImageAndResize(image: profilePicture, size: CGSize(width: widthHeight, height: widthHeight))
        
        guard let imageData = cropedResizedProfilePicture.jpegData(compressionQuality: 1) else { return }
        
        storageService.uploadProfilePicture(imageData: imageData, userUid: userUid) { (result) in
            switch result {
            case .success(let savedProfilePictureUrl):
                completion(.success(savedProfilePictureUrl))
            case .failure(let error):
                completion(.failure(DisplayableError(message: error.message)))
            }
        }
    }
    
    func profilePictureDidChange() {
        guard let profilePicture = self.changedProfilePicture else { return }
        viewController?.setProfilePicture(image: profilePicture)
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
}
