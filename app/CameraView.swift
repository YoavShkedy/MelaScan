//
//  CameraView.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 24/10/2023.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    let cameraService: CameraService
    internal var didFinishProcessingPhoto: (Result<UIImage, Error>) -> ()
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        cameraService.start(delegate: context.coordinator) { err in
            if let err = err {
                didFinishProcessingPhoto(.failure(err))
                return
            }
        }
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        viewController.view.layer.addSublayer(cameraService.previewLayer)
        cameraService.previewLayer.frame = viewController.view.bounds
        
        // Adding a pinch gesture recognizer to the view
        let pinchRecognizer = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(_:)))
        viewController.view.addGestureRecognizer(pinchRecognizer)
        
        
        return viewController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, cameraService: cameraService, didFinishProcessingPhoto: didFinishProcessingPhoto)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        let parent: CameraView
        let cameraService: CameraService
        private var didFinishProcessingPhoto: (Result<UIImage, Error>) -> ()
        
        init(_ parent: CameraView, cameraService: CameraService, didFinishProcessingPhoto: @escaping (Result<UIImage, Error>) -> ()) {
            self.parent = parent
            self.cameraService = cameraService
            self.didFinishProcessingPhoto = didFinishProcessingPhoto
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                didFinishProcessingPhoto(.failure(error))
                return
            }
            if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
                guard let resizedImage = cameraService.resizeImage(image, to: CGSize(width: 224, height: 224)) else { return <#default value#> }
                didFinishProcessingPhoto(.success(resizedImage))
            } else {
                didFinishProcessingPhoto(.failure(CustomError.customMessage("Failed to get image data")))
            }
        }
        
        // The handler for the pinch gesture recognizer
        @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            
            if pinch.state == .changed {
                let zoomFactor = device.videoZoomFactor * pinch.scale
                pinch.scale = 1 // Reset the pinch scale for the next pinch gesture change
                
                parent.cameraService.setZoomLevel(zoomFactor)
            }
        }
        
    }
    
    enum CustomError: Error {
        case customMessage(String)

        var localizedDescription: String {
            switch self {
            case .customMessage(let message):
                return message
            }
        }
    }
    
}

#Preview {
    CameraView(cameraService: CameraService(),
               didFinishProcessingPhoto: { _ in })
}
