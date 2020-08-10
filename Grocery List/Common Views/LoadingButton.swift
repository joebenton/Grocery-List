//
//  LoadingButton.swift
//  WebiLog
//
//  Created by Joe Benton on 14/05/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

@IBDesignable
class LoadingButton: PrimaryButton {

    fileprivate var loadingIndicator: UIActivityIndicatorView?
    fileprivate var originalTitleText: String?
    fileprivate var originalTitleInsets: UIEdgeInsets?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    fileprivate func setup() {
        if let existingLoadingIndicator = loadingIndicator {
            existingLoadingIndicator.removeFromSuperview()
        }
        loadingIndicator = UIActivityIndicatorView()
        loadingIndicator?.color = UIColor.white
        loadingIndicator?.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator?.stopAnimating()
        loadingIndicator?.hidesWhenStopped = true
        addSubview(loadingIndicator!)
        loadingIndicator!.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingIndicator!.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        tintColor = UIColor(named: "zenBlue") ?? UIColor.blue
    }
    
    func toggleLoading(loading: Bool) {
        self.layoutIfNeeded()
        
        switch loading {
        case true:
            originalTitleText = titleLabel?.text
            originalTitleInsets = titleEdgeInsets
            loadingIndicator?.startAnimating()
            isEnabled = false
            setTitle("", for: .normal)
            setTitle("", for: .selected)
            setTitle("", for: .disabled)

            self.titleEdgeInsets = UIEdgeInsets(top: self.originalTitleInsets?.top ?? 0, left: 10, bottom: self.originalTitleInsets?.bottom ?? 0, right: 10)

            UIView.animate(withDuration: 0.4) {
                self.layoutIfNeeded()
            }
        case false:
            layer.removeAllAnimations()
            UIView.performWithoutAnimation {
                loadingIndicator?.stopAnimating()
                isEnabled = true
                setTitle(originalTitleText, for: .normal)
                setTitle(originalTitleText, for: .selected)
                setTitle(originalTitleText, for: .disabled)
                originalTitleText = nil
                
                if let originalTitleInsets = originalTitleInsets {
                    titleEdgeInsets = originalTitleInsets
                    self.originalTitleInsets = nil
                }
                
                self.layoutIfNeeded()
            }
        }
    }
    
    func setLoadingIndicatorColour(colour: UIColor?) {
        if let colour = colour {
            loadingIndicator?.color = colour
        } else {
            loadingIndicator?.color = UIColor.white
        }
    }
}
