//
//  Created by Anton Spivak
//

import AVFoundation
import JustonUI
import SwiftyTON
import UIKit

// MARK: - CameraViewControllerDelegate

protocol CameraViewControllerDelegate: AnyObject {
    func qrViewController(
        _ viewController: CameraViewController,
        didRecognizeSchemeURL schemeURL: SchemeURL
    )
}

// MARK: - CameraViewController

class CameraViewController: UIViewController {
    // MARK: Internal

    weak var delegate: CameraViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "CameraTitle".asLocalizedKey
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .jus_backgroundPrimary

        cameraView.layer.cornerRadius = 12
        cameraView.layer.cornerCurve = .continuous

        view.addSubview(descriptionLabel)
        view.addSubview(cameraView)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate({
            descriptionLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 16)
            descriptionLabel.pin(horizontally: view, left: 16, right: 16)

            cameraView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32)
            cameraView.pin(horizontally: view, left: 16, right: 16)

            cancelButton.topAnchor.pin(to: cameraView.bottomAnchor, constant: 16)
            cancelButton.pin(horizontally: view, left: 16, right: 16)
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: cancelButton.bottomAnchor, constant: 8)
        })

        startCaptureSessionIfNeeded({ error in
            guard let error = error
            else {
                return
            }
            print(error)
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        cameraView.startLoadingAnimation(delay: 0.1, fade: false, width: 3)
        schemeURL = nil

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            present(CameraPermissionError.noCameraAccessQRCode)
        default:
            break
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraView.stopLoadingAnimation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layer?.cornerRadius = cameraView.layer.cornerRadius
        layer?.cornerCurve = cameraView.layer.cornerCurve
        layer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer?.frame = cameraView.layer.bounds
    }

    // MARK: Private

    private enum CaptureSessionError: LocalizedError {
        case noCamera

        // MARK: Internal

        var errorDescription: String? {
            switch self {
            case .noCamera:
                return "Hmm, looks like we can't fina any camera on device"
            }
        }
    }

    private let descriptionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .headline)
        $0.textColor = .jus_textPrimary
        $0.text = "CameraDescription".asLocalizedKey
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })

    private let cameraView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .jus_backgroundSecondary
    })

    private lazy var cancelButton = TeritaryButton(
        title: "CommonCancel".asLocalizedKey
            .uppercased()
    ).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(cancelButtonDidClick(_:)), for: .touchUpInside)
    })

    private var session: AVCaptureSession?
    private var layer: AVCaptureVideoPreviewLayer?
    private let queue = DispatchQueue(label: "com.juston.capture-session")
    private var schemeURL: SchemeURL?

    private func startCaptureSessionIfNeeded(_ completion: @escaping (_ error: Error?) -> Void) {
        queue.async(execute: {
            guard self.session == nil
            else {
                return
            }

            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInDualCamera,
                    .builtInWideAngleCamera,
                    .builtInTripleCamera,
                    .builtInUltraWideCamera,
                ],
                mediaType: .video,
                position: .back
            )

            guard let captureDevice = deviceDiscoverySession.devices.first
            else {
                completion(CaptureSessionError.noCamera)
                return
            }

            let output = AVCaptureMetadataOutput()
            let input: AVCaptureDeviceInput
            do {
                input = try AVCaptureDeviceInput(device: captureDevice)
            } catch {
                completion(error)
                return
            }

            let session = AVCaptureSession()
            session.addOutput(output)
            session.addInput(input)

            output.setMetadataObjectsDelegate(self, queue: self.queue)
            output.metadataObjectTypes = [.qr]

            session.startRunning()

            let layer = AVCaptureVideoPreviewLayer(session: session)

            DispatchQueue.main.async(execute: {
                self.cameraView.layer.insertSublayer(layer, at: 0)
                self.view.setNeedsLayout()
            })

            self.session = session
            self.layer = layer

            completion(nil)
        })
    }

    // MARK: Actions

    @objc
    private func cancelButtonDidClick(_ sender: UIButton) {
        hide(animated: true)
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !metadataObjects.isEmpty, self.schemeURL == nil
        else {
            return
        }

        let readableCodeObjects = metadataObjects
            .compactMap({ $0 as? AVMetadataMachineReadableCodeObject })
            .filter({ $0.type == .qr })

        guard let readableCodeObject = readableCodeObjects.first,
              let stringValue = readableCodeObject.stringValue,
              let schemeURL = SchemeURL(stringValue)
        else {
            return
        }

        self.schemeURL = schemeURL
        DispatchQueue.main.async {
            self.delegate?.qrViewController(
                self,
                didRecognizeSchemeURL: schemeURL
            )
        }
    }
}
