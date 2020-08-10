//
//  ViewModelBased.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

protocol ViewModel: class {
}

protocol ViewModelBased: class {
    associatedtype ViewModel
    var viewModel: ViewModel { get set }
}

extension ViewModelBased where Self: StoryboardBased & UIViewController {
    
    static func instantiate(with viewModel: ViewModel) -> Self {
        let viewController = instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
    
}
