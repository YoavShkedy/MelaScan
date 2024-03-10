//
//  CustomCameraView.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 24/10/2023.
//

import SwiftUI

struct CustomCameraView: View {
    
    @State private var cameraService = CameraService()
    @Binding var capturedImage: UIImage?
    @State private var isFlashOn: Bool = false
    @State private var currentZoomFactor: CGFloat = 1.0
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var prediction: String = ""
    @State private var showPredictionView = false
    
    private let modelHandler = ModelHandler()
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ZStack {
            
            if let image = capturedImage, !prediction.isEmpty {
                PredictionView(capturedImage: $capturedImage, prediction: prediction, recaptureAction: recaptureAction)
                    .edgesIgnoringSafeArea(.all)
            } else {
                CameraInterfaceView()
                CameraControlsView()
            }
        }
        .onAppear {
            cameraService.startSession()
        }
        .onDisappear {
            cameraService.stopSession()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage, modelHandler: modelHandler)
        }
        .onTapGesture { location in
            let devicePoint = cameraService.previewLayer.captureDevicePointConverted(fromLayerPoint: location)
            cameraService.setFocusPoint(devicePoint)
        }
    }
    
    private func recaptureAction() {
        // Reinitialize the camera service
        self.cameraService = CameraService()
        self.capturedImage = nil
        self.prediction = ""
        self.showPredictionView = false
        cameraService.startSession() // Restart the session
    }
    
    @ViewBuilder
    private func CameraInterfaceView() -> some View {
        CameraView(cameraService: cameraService) { result in
            switch result {
            case .success(let image):
                self.capturedImage = image
                if let predictionResult = modelHandler.predict(image: image) {
                    self.prediction = predictionResult
                    self.showPredictionView = true
                } else {
                    self.prediction = "Prediction failed"
                }
            case .failure(let error):
                print("Capture error: \(error.localizedDescription)")
            }
        }
        .gesture(MagnificationGesture()
            .onChanged { value in
                cameraService.setZoomLevel(value * currentZoomFactor)
            }
            .onEnded { value in
                currentZoomFactor = min(max(1.0, currentZoomFactor * value), cameraService.maxZoomFactor)
                cameraService.setZoomLevel(currentZoomFactor)
            }
        )
    }
    
    @ViewBuilder
    private func CameraControlsView() -> some View {
        VStack {
            HStack {
                // Exit button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 22))
                        .bold()
                        .padding(.horizontal, 5)
                        .foregroundColor(.white)
                })
                
                Spacer()
                
                // Flash button
                if cameraService.hasFlash {
                    Button(action: {
                        isFlashOn.toggle()
                        cameraService.isFlashOn = isFlashOn
                    }, label: {
                        Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 22))
                            .bold()
                            .padding(.horizontal, 5)
                            .foregroundColor(.white)
                    })
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 44)
            
            Spacer()
            
            ZStack {
                // Capture button
                Button(action: {
                    cameraService.capturePhoto()
                }, label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 66, height: 66) // White circle
                        .overlay(
                            Circle() // Ring
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 74, height: 74)
                        )
                })
                .padding(.bottom, 28)
                
                // Photo library button
                Button(action: {
                    self.isImagePickerPresented = true
                }) {
                    Image(systemName: "photo")
                        .font(.system(size: 19))
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(.trailing, 297)
                .padding(.bottom, 30)
                .bold()
                .accessibilityLabel("Photo library")
            }
        }
    }
}

#Preview {
    CustomCameraView(capturedImage: .constant(nil))
}
