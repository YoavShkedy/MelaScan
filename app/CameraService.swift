//
//  CameraService.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 24/10/2023.
//

import Foundation
import AVFoundation
import UIKit
import Accelerate

class CameraService {
    
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    var isFlashOn: Bool = false
    var hasFlash: Bool {
        if let device = AVCaptureDevice.default(for: .video) {
            return device.hasFlash
        }
        return false
    }
    
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    var maxZoomFactor: CGFloat {
        if let device = AVCaptureDevice.default(for: .video), device.position == .back {
            return device.activeFormat.videoMaxZoomFactor
        }
        return 1.0 // No zoom available or for front camera
    }
    
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> ()) {
        self.delegate = delegate
        checkPermissions(completion: completion)
    }
    
    private func checkPermissions(completion: @escaping (Error?) -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.setupCamera(completion: completion)
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera(completion: completion)
        @unknown default:
            break
        }
    }
    
    private func setupCamera(completion: @escaping (Error?) -> ()) {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
            } catch {
                completion(error)
            }
        }
    }
    
    func capturePhoto() {
        guard let session = session, session.isRunning, let delegate = delegate else {
            print("Session is not running or delegate is nil")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        output.capturePhoto(with: settings, delegate: delegate)
    }
    
    
    func setZoomLevel(_ zoomFactor: CGFloat) {
        guard let device = session?.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.position == .back })?.device else {
            print("Unable to access the back camera.")
            return
        }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            // Clamp the zoom factor to the device's active format's min/max zoom factor.
            let newZoomFactor = min(max(zoomFactor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)
            device.videoZoomFactor = newZoomFactor
        } catch {
            print("Failed to set zoom level due to error: \(error)")
        }
    }
    
    func setFocusPoint(_ focusPoint: CGPoint) {
        guard let device = session?.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.position == .back })?.device else {
            print("Unable to access the back camera.")
            return
        }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }
            
            device.isSubjectAreaChangeMonitoringEnabled = true
        } catch {
            print("Failed to set focus point due to error: \(error)")
        }
    }
    
    func startSession() {
        if let session = self.session, !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopSession() {
        if let session = self.session, session.isRunning {
            session.stopRunning()
        }
    }
    
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil,
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                          version: 0, decode: nil, renderingIntent: .defaultIntent)

        var sourceBuffer = vImage_Buffer()
        defer { sourceBuffer.data.deallocate() }

        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, vImage_Flags(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }

        // Create a destination buffer
        let scale = UIScreen.main.scale
        let destWidth = Int(size.width * scale)
        let destHeight = Int(size.height * scale)
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer { destData.deallocate() }

        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight),
                                       width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)

        // Resize the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, vImage_Flags(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }

        // Create a CGImage from vImage_Buffer
        let resizedImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, vImage_Flags(kvImageNoFlags), &error)
        guard let resultingImage = resizedImage?.takeRetainedValue(), error == kvImageNoError else { return nil }

        return UIImage(cgImage: resultingImage, scale: scale, orientation: .up)
    }
}
