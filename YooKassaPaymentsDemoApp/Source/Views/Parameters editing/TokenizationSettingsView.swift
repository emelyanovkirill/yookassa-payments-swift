import YooKassaPayments
import SwiftUI

@MainActor
struct TokenizationFormView: View {

    @StateObject var store = FormStoreFactory.tokenization
    let qaConfigService = QaConfigsService()

    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
    
    let isDevHost = UserDefaults.standard.bool(forKey: DevHostService.Keys.devHostKey.name)

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section() {
                    Picker("shopId:", selection: $store.form.shopId) {
                        ForEach(qaConfigService.shopIds, id: \.self) {
                            Text("\($0)").tag("\($0)")
                        }
                    }
                    .onChange(of: $store.form.shopId) { newValue in
                        guard let gatewayId = qaConfigService.getShop(shopId: newValue.wrappedValue)?.gatewayId,
                              let clientKey = qaConfigService.getShop(shopId: newValue.wrappedValue)?.clientKey
                        else { return }
                        store.form.gatewayId = gatewayId
                        store.form.clientApplicationKey = clientKey
                    }
                    FormEditableTextView(name: "gatewayId (соответствует shopId)", text: $store.form.gatewayId)
                    FormEditableTextView(name: "clientApplicationKey (соответствует shopId)", text: $store.form.clientApplicationKey)
                    FormEditableTextView(name: "shopName", text: $store.form.shopName)
                    FormEditableTextView(name: "purchaceDescription", text: $store.form.purchaseDescription)
                    FormEditableTextView(name: "userPhoneNumber", text: $store.form.userPhoneNumber)
                    FormEditableTextView(name: "moneyAuthClientId", text: $store.form.moneyAuthClientId)
                    FormEditableTextView(name: "customerId", text: $store.form.customerId)
                    FormEditableTextView(name: "returnUrl", text: $store.form.returnUrl)
                    FormEditableTextView(name: "applicationScheme", text: $store.form.applicationScheme)
                    Toggle("isLoggingEnabled", isOn: $store.form.isLoggingEnabled)
                }
                Section(header: Text("amount")) {
                    TextField(value: $store.form.amount.amount, format: .currency(code: store.form.amount.currency.rawValue)) {
                        Text("amount")
                    }
                    .disableAutocorrection(true)
                    .border(.tertiary)
                    .frame(minHeight: 38)
                    .font(.callout)
                    .onSubmit {
                        print(store.form.amount)
                    }
                    Picker("Currency:", selection: $store.form.amount.currency) {
                        Text("rub").tag(Currency.rub)
                        Text("usd").tag(Currency.usd)
                        Text("eur").tag(Currency.eur)
                    }
                }
                Section() {
                    Text("tokenizationSettings - paymentMethodTypes").font(.caption).foregroundStyle(.tertiary)
                    Toggle("bankCard", isOn: $store.form.tokenizationSettings.paymentMethodTypes.bind(.bankCard))
                    Toggle("yoomoney", isOn: $store.form.tokenizationSettings.paymentMethodTypes.bind(.yooMoney))
                    Toggle("sberbank", isOn: $store.form.tokenizationSettings.paymentMethodTypes.bind(.sberbank))
                    Toggle("sbp", isOn: $store.form.tokenizationSettings.paymentMethodTypes.bind(.sbp))
                }

                Section() {
                    Text("testModeSettings").font(.caption).foregroundStyle(.tertiary)
                    Toggle("test mode enabled", isOn: $store.form.testModeSettings.enabled)
                    Toggle("paymentAuthorizationPassed", isOn: $store.form.testModeSettings.paymentAuthorizationPassed)
                    Toggle("enablePaymentError", isOn: $store.form.testModeSettings.enablePaymentError)
                    TextField(value: $store.form.testModeSettings.cardsCount, format: .number) {
                        Text("amount")
                    }
                    .disableAutocorrection(true)
                    .border(.tertiary)
                    .frame(minHeight: 38)
                    .font(.callout)
                    .onSubmit {
                        print(store.form.testModeSettings.cardsCount)
                    }
                }

                Section() {
                    Text("customizationSettings").font(.caption).foregroundStyle(.tertiary)
                    Toggle("showYooKassaLogo", isOn: $store.form.customizationSettings.showYooKassaLogo)

                    ColorPicker("mainScheme", selection: $store.form.color)
                }

            }
        }.background(Color(.secondaryLabel))
    }
}

struct FormEditableTextView: View {
    let name: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
            TextEditor(text: $text)
                .disableAutocorrection(true)
                .border(.tertiary)
                .frame(minHeight: 38)
                .font(.callout)
            Spacer()
        }
    }
}

#Preview {
    TokenizationFormView()
}

extension Currency: Hashable {}

extension Binding: Equatable where Value: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Binding where Value: OptionSet, Value == Value.Element {
    func bindedValue(_ options: Value) -> Bool {
        return wrappedValue.contains(options)
    }

    func bind(
        _ options: Value,
        animate: Bool = false
    ) -> Binding<Bool> {
        return .init { () -> Bool in
            self.wrappedValue.contains(options)
        } set: { newValue in
            let body = {
                if newValue {
                    self.wrappedValue.insert(options)
                } else {
                    self.wrappedValue.remove(options)
                }
            }
            guard animate else {
                body()
                return
            }
            withAnimation {
                body()
            }
        }
    }
}
