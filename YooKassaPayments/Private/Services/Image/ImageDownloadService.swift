import Foundation
import FunctionalSwift
import UIKit

enum ImageDownloadServiceError: Error {
    case incorrectData
}

protocol ImageDownloadService {
    func fetchImage(
        url: URL,
        completion: @escaping (Swift.Result<UIImage, Error>) -> Void
    )
    func fetchImage(url: URL) -> Promise<Error, UIImage>
    func getCachedImage(url: URL) -> UIImage?
}
