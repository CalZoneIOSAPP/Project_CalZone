//
//  Tip.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/2/24.
//

import Foundation
import TipKit


struct AddMealTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("Add a Dish"))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("Tap here to add a new dish to your day."))
    }
}


struct SaveToOtherDateTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("Date Selection"))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("Tap here to select another day to save your dish."))
    }
    
}


struct SelectDateTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("Date Selection"))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("Tap here to select another day and view your statistics."))
    }
    
}


struct CurrentCaloriesTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("You are doing well!"))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("Your calorie intake for this day will be shown by this number."))
    }
    
}
