import Foundation

enum ConfigMediatorAssembly {
    static func makeMediator(isLoggingEnabled: Bool) -> ConfigMediator {
        return ConfigMediatorImpl(
            service: ConfigServiceAssembly.makeService(isLoggingEnabled: isLoggingEnabled),
            storage: KeyValueStoringAssembly.makeSettingsStorage()
        )
    }
}
