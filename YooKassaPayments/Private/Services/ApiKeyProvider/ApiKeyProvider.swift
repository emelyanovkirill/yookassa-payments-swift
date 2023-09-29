import Foundation

protocol ApiKeyProvider {
    func getSberKey() async throws -> String
}
