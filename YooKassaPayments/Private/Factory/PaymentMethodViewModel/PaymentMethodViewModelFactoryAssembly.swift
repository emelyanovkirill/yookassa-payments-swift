enum PaymentMethodViewModelFactoryAssembly {
    static func makeFactory(isLoggingEnabled: Bool) -> PaymentMethodViewModelFactory {
        return PaymentMethodViewModelFactoryImpl(
            configMediator: ConfigMediatorImpl(
                service: ConfigServiceAssembly.makeService(isLoggingEnabled: isLoggingEnabled),
                storage: KeyValueStoringAssembly.makeSettingsStorage()
            )
        )
    }
}
