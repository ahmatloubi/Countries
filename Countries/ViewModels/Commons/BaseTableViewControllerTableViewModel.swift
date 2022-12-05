//
//  BaseTableViewControllerTableViewModel.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/12/1401 AP.
//

import Foundation
import Combine

class BaseTableViewControllerTableViewModel {
    var failureViewModel: FailureViewModel?
    
    var shouldReloadTableViewPublisher: AnyPublisher<Bool, Never> {
        shouldReloadTableViewSubject.eraseToAnyPublisher()
    }
    
    var shouldReloadTableViewSubject = PassthroughSubject<Bool,Never>()
    
    @Published var viewState: BaseTableViewControllerViewState = .loading
    
    var noItemToShowMessage: String {
        "There is no item to show"
    }
}

