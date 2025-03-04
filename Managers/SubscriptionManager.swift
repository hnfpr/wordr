//ContentView Need Fix UI Not Similar with Design New

import Foundation
import StoreKit

class SubscriptionManager: ObservableObject {
    @Published var isPremium: Bool = false
    
    init() {
        // In a real app, you would check if the user has purchased premium
        // For now, we'll just use UserDefaults for demonstration
        self.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
    
    func upgradeToPremium() {
        // In a real app, this would trigger the StoreKit purchase flow
        // For now, we'll just set the flag directly
        self.isPremium = true
        UserDefaults.standard.set(true, forKey: "isPremium")
    }
    
    func restorePurchases() {
        // In a real app, this would restore purchases through StoreKit
        // For now, we'll just check UserDefaults
        self.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
}