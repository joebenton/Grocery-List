//
//  StorageService.swift
//  Grocery List
//
//  Created by Joe Benton on 09/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageService: NSObject {

    let storageRef = Storage.storage().reference()
    
    func uploadProfilePicture(imageData: Data, userUid: String, completion: @escaping (Result<URL, DisplayableError>) -> Void) {
        guard userUid.count > 0 else {
            completion(.failure(DisplayableError(message: "User UID not valid")))
            return
        }
        
        let filename = "profile.jpg"
        let userProfilePictureStorageRef = storageRef.child(userUid).child("profilePicture").child(filename)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = userProfilePictureStorageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(DisplayableError(message: error.localizedDescription)))
                return
            } else if let _ = metadata {
                userProfilePictureStorageRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(DisplayableError(message: error.localizedDescription)))
                    } else if let url = url {
                        completion(.success(url))
                        return
                    } else {
                        completion(.failure(DisplayableError(message: "Error getting profile picture download link")))
                    }
                }
            } else {
                completion(.failure(DisplayableError(message: "Error uploading picture")))
            }
        }
    }
}
