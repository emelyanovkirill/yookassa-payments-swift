import YooKassaPaymentsApi

enum ServiceTermsFactory {
    static func makeAttributedTermsOfService(properties: ShopProperties?) -> NSAttributedString {
        let storedConfig = ConfigMediatorAssembly.makeMediator(isLoggingEnabled: false).storedConfig()
        if let providerName = properties?.agentSchemeData?.providerName {
            return HTMLUtils.highlightHyperlinks(
                html: storedConfig.agentSchemeProviderAgreement[providerName] ??
                PaymentMethodResources.Localized.agentProviderAgreement
            )
        }
        return HTMLUtils.highlightHyperlinks(html: storedConfig.userAgreementUrl)
    }

    static func appendFeeAgreementToTerms(_ terms: NSAttributedString? = nil) -> NSAttributedString {
        let storedConfig = ConfigMediatorAssembly.makeMediator(isLoggingEnabled: false).storedConfig()
        return appendTermToTerms(terms, term: storedConfig.feeAgreement)
    }

    private static func appendTermToTerms(_ terms: NSAttributedString?, term: NSAttributedString) -> NSAttributedString {
        guard let terms = terms else { return term }
        let result = NSMutableAttributedString()
        result.append(terms)
        result.append(NSAttributedString(string: "\n"))
        result.append(term)
        return result
    }
}
