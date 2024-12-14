import Foundation
import StoreKit

enum SubscriptionPlan: String, CaseIterable {
    case monthlyPlan = "monthlyPlan"
    case quarterlyPlan = "quarterlyPlan"
    case yearlyPlan = "yearlyPlan"
    
    var displayName: String {
        switch self {
        case .monthlyPlan:
            return "Monthly Plan"
        case .quarterlyPlan:
            return "Quarterly Plan"
        case .yearlyPlan:
            return "Yearly Plan"
        }
    }
    
    var description: String {
        switch self {
        case .monthlyPlan:
            return "Access all premium features monthly"
        case .quarterlyPlan:
            return "Save 15% with quarterly billing"
        case .yearlyPlan:
            return "Save 40% with annual billing"
        }
    }
}
