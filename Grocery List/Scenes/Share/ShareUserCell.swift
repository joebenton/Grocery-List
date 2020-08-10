//
//  ShareUserCell.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Kingfisher
import SwipeCellKit

protocol ShareUserCellDelegate: class {
    func deleteBtnPressed(listUser: ListUser)
    func linkBtnPressed(listUser: ListUser, btnRect: CGRect)
}

class ShareUserCell: SwipeTableViewCell {

    weak var shareDelegate: ShareUserCellDelegate?
    var listUser: ListUser?
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var linkBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pictureImageView.layer.cornerRadius = 20
        pictureImageView.clipsToBounds = true
        
        selectedBackgroundView = HighlightedCellView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(listUser: ListUser) {
        self.listUser = listUser
        
        switch listUser.type {
        case .pendingInvite(let invite):
            nameLabel.text = invite.name
            statusLabel.text = "Share link pending"

            linkBtn.isHidden = false
            deleteBtn.isHidden = false
            
            pictureImageView.image = UIImage(named: "ic_placeholderProfilePicture")
        case .user(let user, let acceptedInvite):
            switch user.role {
            case .owner:
                if let name = user.name, name.count > 0 {
                    nameLabel.text = "You (\(name))"
                } else {
                    nameLabel.text = "You"
                }
            case .collaborator:
                if let name = user.name, name.count > 0 {
                    nameLabel.text = name
                } else if let acceptedInvite = acceptedInvite {
                    nameLabel.text = acceptedInvite.name
                } else {
                    nameLabel.text = "(No name)"
                }
            }
            statusLabel.text = user.role.description
            
            linkBtn.isHidden = true

            switch user.role {
            case .owner:
                deleteBtn.isHidden = true
            default:
                deleteBtn.isHidden = false
            }
            
            if let profilePictureUrl = user.profilePictureUrl {
                let url = URL(string: profilePictureUrl)
                let placeholder = UIImage(named: "ic_placeholderProfilePicture")
                pictureImageView.kf.setImage(with: url, placeholder: placeholder)
            } else {
                pictureImageView.image = UIImage(named: "ic_placeholderProfilePicture")
            }
        }
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        guard let listUser = self.listUser else { return }
        shareDelegate?.deleteBtnPressed(listUser: listUser)
    }
    
    @IBAction func linkBtnPressed(_ sender: Any) {
        guard let listUser = self.listUser else { return }
        shareDelegate?.linkBtnPressed(listUser: listUser, btnRect: linkBtn.frame)
    }
    
}
