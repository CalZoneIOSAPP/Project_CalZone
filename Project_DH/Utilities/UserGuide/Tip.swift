//
//  Tip.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/2/24.
//

import Foundation
import TipKit


// ========================================================================
// Dashboard Tips
// ========================================================================
struct WelcomeTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("Welcome to CalBite!"))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("This is your dashboard where you can monitor your daily calorie(kCal) intake."))
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


struct AddMealTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("Add a Dish"))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("Tap here to add a new dish to your day."))
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


struct ChangeWeightTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("Change your body weight."))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("After you measured your new body weight, you can change it here."))
    }
}


// ========================================================================
// Calorie Estimator Tips
// ========================================================================
struct AddMealPhotoTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("Add your delicious meal."))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("Tap here to add a dish. You can either take a photo, or upload one which you posted."))
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


struct MealTypeTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("When did you eat?"))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("We will by default select a meal type based on your time, but you can manually adjust it here."))
    }
}


struct SaveMealTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("Save your dish."))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("After you are done with adding your meal, click the save button."))
    }
}


// ========================================================================
// AI Assistant Cally Tips
// ========================================================================
struct GeneralAITip: Tip {
    var title: Text {
        Text(LocalizedStringKey("Meet your diet advisor, Cally."))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("You can ask any questions related to food, nutrition and diet."))
    }
}


struct AddChatTip: Tip {
    var title: Text {
        Text(LocalizedStringKey("New Conversation"))
    }
    
    var message: Text? {
        Text(LocalizedStringKey("Click here to add a new conversation."))
    }
}
