import Foundation
import StoreKit

enum EntitlementTier {
    case free
    case premium
}

@MainActor
final class EntitlementsManager: ObservableObject {
    static let shared = EntitlementsManager()
    @Published private(set) var tier: EntitlementTier = .free

    private let premiumProductIDs: Set<String> = [
        "routine.premium.monthly",
        "routine.premium.annual",
        "routine.premium.lifetime"
    ]

    func refresh() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if premiumProductIDs.contains(transaction.productID) {
                tier = .premium
                return
            }
        }
        tier = .free
    }
}
