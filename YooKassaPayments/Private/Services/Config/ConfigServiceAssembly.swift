import Foundation

enum ConfigServiceAssembly {
    static func makeService(isLoggingEnabled: Bool) -> ConfigService {
        ConfigServiceImpl(
            session: ApiSessionAssembly.makeApiSession(isLoggingEnabled: isLoggingEnabled),
            loginEnabled: isLoggingEnabled
        )
    }
}
