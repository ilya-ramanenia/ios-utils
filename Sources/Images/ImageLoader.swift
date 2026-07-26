import Foundation

/// Lightweight in-memory image loader.
/// Uses `NSCache` to avoid repeated downloads and image decoding

final class ImageLoader {
  
    private let cache = NSCache<NSURL, UIImage>()

    func image(for url: URL) async throws -> UIImage {
        if let image = cache.object(forKey: url as NSURL) {
            return image
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let image = UIImage(data: data)!
        cache.setObject(image, forKey: url as NSURL)

        return image
    }
}
