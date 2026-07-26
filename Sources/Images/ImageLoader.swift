import Foundation

/// Lightweight in-memory image loader.
/// Uses `NSCache` to avoid repeated downloads and image decoding


enum ImageLoaderError: Error {
    case invalidImageData
}

final class ImageLoader {

    private let cache = NSCache<NSURL, UIImage>()

    func image(for url: URL) async throws -> UIImage {
        if let image = cache.object(forKey: url as NSURL) {
            return image
        }
      
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageLoaderError.invalidImageData
        }
      
        cache.setObject(image, forKey: url as NSURL)

        return image
    }
}
