//
//  NotificationCell.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Kingfisher
import SwipeCellKit

class NotificationCell: SwipeTableViewCell {

    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var newCircleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedBackgroundView = HighlightedCellView()
        
        pictureImageView.layer.cornerRadius = 20
        pictureImageView.clipsToBounds = true
        
        newCircleView.layer.cornerRadius = 5
        newCircleView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(notification: ActivityNotification) {
        titleLabel.text = notification.title
        bodyLabel.text = notification.body
        
        let date = Date(timeIntervalSince1970: TimeInterval(notification.timestamp))
        let dateFormatter = DateFormatter()
        
        if date.isInToday {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
        } else {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
        }
        
        dateLabel.text = dateFormatter.string(from: date)
        
        switch notification.type {
        case .pushNotification:
            if let profilePictureUrl = notification.changeUserPicture {
                let url = URL(string: profilePictureUrl)
                let placeholder = UIImage(named: "ic_placeholderProfilePicture")
                pictureImageView.kf.setImage(with: url, placeholder: placeholder)
            } else {
                pictureImageView.image = UIImage(named: "ic_placeholderProfilePicture")
            }
            pictureImageView.isHidden = false
        case .localNotificationListReminder:
            pictureImageView.image = nil
            pictureImageView.isHidden = true
        }
        
        if notification.opened {
            newCircleView.isHidden = true
        } else {
            newCircleView.isHidden = false
        }
    }
    
}
