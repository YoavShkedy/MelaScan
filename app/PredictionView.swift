//
//  PredictionView.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 17/11/2023.
//

import Foundation
import SwiftUI

struct PredictionView: View {
    @Binding var capturedImage: UIImage?
    var prediction: String
    var recaptureAction: () -> Void
    
    var body: some View {
        ZStack {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Provide a fallback view or image here
                Text("No image available")
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.7))
            }
            
            // Display the prediction
            VStack {
                
                Spacer().frame(height: 10)
                Spacer()
                
                Text("Prediction: \(prediction)")
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding()
                
                Spacer()
                
                // Button to recapture the image
                Button("Recapture") {
                    recaptureAction()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                
                Spacer().frame(height: 10)
                
            }
        }
    }
}

struct PredictionView_Previews: PreviewProvider {
    @State static var image: UIImage? = UIImage(named: "Background")
    
    static var previews: some View {
        PredictionView(capturedImage: $image, prediction: "Prediction") {
            // Empty closure for the recapture action
        }
    }
}
