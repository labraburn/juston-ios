//
//  Created by Anton Spivak
//

import JustonUI
import Nuke
import UIKit

class RemoteImageView: UIView {
    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        _init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }

    // MARK: Internal

    struct LoadImageParameters {
        static let `default` = LoadImageParameters(
            cornerRadius: 0,
            placeholder: nil
        )

        let cornerRadius: CGFloat
        let placeholder: UIImage?
    }

    // MARK: API

    func useImage(_ image: UIImage?) {
        clear()
        imageView.image = image
    }

    func loadImageWithURL(_ url: URL?, parameters: LoadImageParameters = .default) {
        clear()

        guard let url = url
        else {
            return
        }

        let pipeline = ImagePipeline.shared
        let request = ImageRequest(url: url)

        var options = ImageLoadingOptions(placeholder: nil)
        options.placeholder = parameters.placeholder
        options.pipeline = pipeline
        options.processors = [
            .roundedCorners(radius: parameters.cornerRadius),
        ]

        if !pipeline.cache.containsCachedImage(for: request) {
            options.transition = .fadeIn(duration: 0.21)
        }

        imageViewDownloadTask = loadImage(
            with: request,
            options: options,
            into: imageView,
            completion: { _ in }
        )
    }

    func prepareForReuse() {
        clear()
    }

    // MARK: Private

    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    private var imageViewDownloadTask: ImageTask?

    private func _init() {
        addSubview(imageView)
        imageView.pinned(edges: self)
    }

    private func clear() {
        imageViewDownloadTask?.cancel()
        imageViewDownloadTask = nil

        imageView.image = nil
    }
}
