//
//  Coordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

class Coordinator {
    private(set) var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?

    func start() {
        assertionFailure("not implemented")
    }

    func finish(animated: Bool = false) {
        assertionFailure("not implemented to let views disappear")
    }

    func didFinish(_ coordinator: Coordinator) {
        removeChildCoordinator(coordinator)
    }

    func addChildCoordinator(_ coordinator: Coordinator) {
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }

    func removeChildCoordinator(_ coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(of: coordinator) {
            childCoordinators.remove(at: index)
        } else {
            print("Couldn't remove coordinator: \(coordinator).")
        }
    }
}

extension Coordinator: Equatable {
    static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
        lhs === rhs
    }
}
