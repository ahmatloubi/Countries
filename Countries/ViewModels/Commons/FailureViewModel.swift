//
//  FailureViewModel.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/12/1401 AP.
//

import Foundation
import Combine

class FailureViewModel {
    
    var onRetry: () -> Void
   
    var errorMessagePublisher: AnyPublisher<String, Never> {
        errorMessageSubject.eraseToAnyPublisher()
    }
    
    var errorMessageSubject = PassthroughSubject<String, Never>()
    
    init(onRetry: @escaping () -> Void) {
        self.onRetry = onRetry
    }
    
    func setErrorMessage(message: String) {
        errorMessageSubject.send(message)
    }
}
