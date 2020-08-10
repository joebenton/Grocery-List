//
//  AddedItemView.swift
//  Grocery List
//
//  Created by Joe Benton on 26/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

protocol AddedItemViewDelegate: class {
    func didUpdateItem(item: CreateItem)
}

class AddedItemView: UIView {

    fileprivate var item: CreateItem?
    
    weak var delegate: AddedItemViewDelegate?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var quantityStepperView: StepperView!
    @IBOutlet weak var unitStepperView: StepperView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        xibSetup()
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
    
    func configure(item: CreateItem) {
        self.item = item
        
        itemNameLabel.text = item.name
        
        configureQuantityStepper()
        
        configureUnitTypeStepper()
    }
    
    fileprivate func configureQuantityStepper() {
        guard let item = self.item else { return }
        quantityStepperView.configure(type: .quantity(min: 1, unitLabel: item.unitType.description), defaultValue: item.quantity) { [weak self] updatedQuantity in
            self?.item?.quantity = updatedQuantity
            
            guard let updatedItem = self?.item else { return }
            self?.delegate?.didUpdateItem(item: updatedItem)
        }
    }
    
    fileprivate func configureUnitTypeStepper() {
        guard let item = self.item else { return }
        let unitTypes = UnitType.allCases.compactMap { $0.description }
        unitStepperView.configure(type: .leftRight(options: unitTypes), defaultValue: item.unitType.rawValue) { [weak self] updatedValue in
            self?.item?.unitType = UnitType(rawValue: updatedValue) ?? UnitType.pcs
            
            self?.configureQuantityStepper()
            
            guard let updatedItem = self?.item else { return }
            self?.delegate?.didUpdateItem(item: updatedItem)
        }
    }
}
