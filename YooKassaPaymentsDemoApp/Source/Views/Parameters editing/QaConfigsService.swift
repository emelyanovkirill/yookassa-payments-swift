import Foundation

final class QaConfigsService {

    typealias Shop = (shopId: String?, gatewayId: String?, clientKey: String?)

    private let hostname = UserDefaults.standard.string(forKey: DevHostService.Keys.devHostname.name) ?? "appb2b1"
    private let isDevHost = UserDefaults.standard.bool(forKey: DevHostService.Keys.devHostKey.name)
    private var configContent: [String: Any] = [:]

    init() {
        Task {
            try await self.load()
        }
    }
    
    func load() async throws {
        let task = Task {
            guard
                let url = Bundle.main.url(forResource: "QaConfigs", withExtension: "plist"),
                let data = NSDictionary(contentsOf: url) as? [String: Any]
            else { return self.configContent }
            
            return data
        }
        let value = await task.value
        self.configContent = value
    }
    
    var selectedHostShops: Array<[String: String]> {
        let scheme = isDevHost ? hostname : "prod"
        let hostData = configContent[scheme] as? [String: Any]
        return hostData?["shops"] as? Array<[String : String]> ?? []
    }
    
    var shopIds: [String] {
        selectedHostShops.compactMap { $0["shopId"] }
    }
    
    var gatewayIds: [String] {
        selectedHostShops.compactMap { $0["gatewayId"] }
    }
    
    var clientKeys: [String] {
        selectedHostShops.compactMap { $0["clientApplicationKey"] }
    }
    
    func getShop(shopId: String) -> Shop? {
        guard let data = selectedHostShops.filter({ $0["shopId"] == shopId }).first
        else {
            assertionFailure("Shops data in QaConfigs.plist for shop(\(shopId) not filled")
            return nil
        }
        return Shop(
            shopId: data["shopId"],
            gatewayId: data["gatewayId"],
            clientKey: data["clientApplicationKey"]
        )
    }
}
