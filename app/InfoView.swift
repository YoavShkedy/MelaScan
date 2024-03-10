//
//  InfoView.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 07/11/2023.
//

// InfoView.swift
import SwiftUI

struct InfoView: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        
        ZStack {
            
            Image("Background")
                .resizable()
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HStack {
                        
                        Text("About MelaScan")
                            .font(.title)
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        Spacer()
                        
                        Button(action: {
                            self.isPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 15))
                                .bold()
                                .foregroundColor(.black)
                        }
                        
                    }
                    
                    Text("MelaScan is designed to provide users with an assessment of moles using advanced machine learning techniques. By analyzing images of your moles, MelaScan predicts whether a mole could be malignant or benign.")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Divider()
                    
                    Text("Technology")
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text("Our app incorporates a robust TensorFlow Lite model, leveraging the extensive ISIC dataset, which contains over 50,000 dermatoscopic images. This dataset is globally recognized for its comprehensive collection of mole images, used to train algorithms to distinguish between benign and malignant lesions. The model's current accuracy stands at approximately 82%, representing the state-of-the-art in machine learning for dermatological predictions.")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Divider()
                    
                    Text("Disclaimer")
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text("MelaScan is a tool for informational purposes only and is not intended to replace professional medical advice, diagnosis, or treatment. The app's predictions are computed based on image data alone and should not be used as a sole diagnostic tool. Always seek the advice of your physician or another qualified health provider with any questions you may have regarding a medical condition. If you think you may have a medical emergency, call your doctor or emergency services immediately.")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Please Note:")
                            .font(.headline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Text("- Always ensure good lighting when taking pictures for accurate predictions.")
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Text("- Regular monitoring of moles is crucial, and any changes should be assessed by a healthcare professional.")
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Text("- The effectiveness of MelaScan can be augmented by users' prudent engagement and responsible use.")
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("We are constantly working to improve MelaScan:")
                            .font(.headline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Text("- Enhancing the machine learning model for better accuracy.")
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Text("- Updating the dataset with more diversified images.")
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Text("- Incorporating user feedback into the app development process.")
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
                
                HStack {
                    Spacer()
                    Text("© 2023 Yoav Shkedy. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding([.bottom, .trailing])
                }
                
            }
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(isPresented: .constant(true))
    }
}
