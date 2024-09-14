//
//  ControllerModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/14/24.
//

import Foundation


/// This view model is a global controller which decides when certain actions should run.
class ControllerModel: ObservableObject {
    
    @Published var refetchMeal: Bool = false
    
    
}
