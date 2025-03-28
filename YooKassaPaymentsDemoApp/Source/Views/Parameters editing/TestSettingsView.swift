import SwiftUI

struct SettingsForm: Codable {
    var isDevHost: Bool
    var requestCachePolicy: UInt
    var hostname: String
    var isAuthenticationChallengeIgnored: Bool

    enum StorageKeys {
        static let cachePolicy = "policy_override"
    }

    static func make() -> SettingsForm {
        SettingsForm(
            isDevHost: UserDefaults.standard.bool(forKey: DevHostService.Keys.devHostKey.name),
            requestCachePolicy: (UserDefaults.standard.value(forKey: StorageKeys.cachePolicy) as? UInt) ?? UInt(999),
            hostname: UserDefaults.standard.string(forKey: DevHostService.Keys.devHostname.name) ?? "appb2b1",
            isAuthenticationChallengeIgnored: UserDefaults.standard.bool(
                forKey: DevHostService.Keys.authenticationChallengeIgnoredKey.name
            )
        )
    }
}

@MainActor
class TestSettingsStore: ObservableObject {
    @Published var form: SettingsForm = SettingsForm.make() {
        didSet {
            print(form)
            updateDefaults()
        }
    }

    private func updateDefaults() {
        UserDefaults.standard.set(form.isDevHost, forKey: DevHostService.Keys.devHostKey.name)
        UserDefaults.standard.set(form.hostname, forKey: DevHostService.Keys.devHostname.name)
        switch form.requestCachePolicy {
        case 999:
            UserDefaults.standard.set(nil, forKey: SettingsForm.StorageKeys.cachePolicy)
        default:
            UserDefaults.standard.set(form.requestCachePolicy, forKey: SettingsForm.StorageKeys.cachePolicy)
        }
        UserDefaults.standard.set(
            form.isAuthenticationChallengeIgnored, forKey: DevHostService.Keys.authenticationChallengeIgnoredKey.name
        )
    }
}

@MainActor
struct TestSettingsView: View {
    @StateObject private var store = TestSettingsStore()

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Toggle("isDevHost", isOn: $store.form.isDevHost)
                if store.form.isDevHost {
                    Text("Также, установи shop для токенизации")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                Picker("Cache policy", selection: $store.form.requestCachePolicy) {
                    Text("default").tag(UInt(999))
                    Text("reloadIgnoringLocalAndRemoteCacheData").tag(URLRequest.CachePolicy.useProtocolCachePolicy.rawValue)
                    Text("reloadIgnoringLocalCacheData").tag(URLRequest.CachePolicy.reloadIgnoringLocalCacheData.rawValue)
                    Text("reloadIgnoringLocalAndRemoteCacheData").tag(URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData.rawValue)
                    Text("returnCacheDataElseLoad").tag(URLRequest.CachePolicy.returnCacheDataElseLoad.rawValue)
                    Text("returnCacheDataDontLoad").tag(URLRequest.CachePolicy.returnCacheDataDontLoad.rawValue)
                    Text("reloadRevalidatingCacheData").tag(URLRequest.CachePolicy.reloadRevalidatingCacheData.rawValue)
                }
                Toggle("isSSLPinningIgnored", isOn: $store.form.isAuthenticationChallengeIgnored)

                if store.form.isDevHost {
                    Picker("Host", selection: $store.form.hostname) {
                        Text("appb2b1").tag("appb2b1")
                        Text("appb2b2").tag("appb2b2")
                        Text("px1").tag("px1")
                        Text("px2").tag("px2")
                        Text("px3").tag("px3")
                        Text("px4").tag("px4")
                    }
                }
            }
        }
    }
}

#Preview {
    TestSettingsView()
}

