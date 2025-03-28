import Foundation
import FunctionalSwift
import UIKit

final class ImageDownloadServiceImpl {

    // MARK: - Init data

    private let session: URLSession
    private let cache: ImageCache

    // MARK: - Init

    init(
        session: URLSession,
        cache: ImageCache
    ) {
        self.session = session
        self.cache = cache
    }
}

// MARK: - ImageDownloadService

extension ImageDownloadServiceImpl: ImageDownloadService {
    func fetchImage(
        url: URL,
        completion: @escaping (Swift.Result<UIImage, Error>) -> Void
    ) {
        if let image = cache.getImage(forUrl: url) {
            return completion(.success(image))
        }
        session.dataTask(with: url) { [weak self] (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let imageData = data,
                  let image = UIImage(data: imageData) else {
                completion(.failure(ImageDownloadServiceError.incorrectData))
                return
            }
            self?.cache.setImage(data: imageData, forUrl: url)
            completion(.success(image))
        }.resume()
    }

    func fetchImage(url: URL) -> Promise<Error, UIImage> {
        if let image = cache.getImage(forUrl: url) {
            return .right(image)
        }

        let promise = Promise<Error, UIImage>()

        session.dataTask(with: url) { [weak self] (data, _, error) in
            if let error = error {
                return promise.resolveLeft(error)
            }
            guard let imageData = data, let image = UIImage(data: imageData) else {
                return promise.resolveLeft(ImageDownloadServiceError.incorrectData)
            }
            self?.cache.setImage(data: imageData, forUrl: url)
            promise.resolveRight(image)
        }.resume()

        return promise
    }

    func getCachedImage(url: URL) -> UIImage? {
        cache.getImage(forUrl: url)
    }
}
