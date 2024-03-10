//
//  ContentView.swift
//  MelaScan
//
//  Created by Yoav Shkedy.
//

import SwiftUI

struct ContentView: View {
    
    @State private var capturedImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    @State private var isInfoPopoverPresented = false
    @State private var isInfoViewPresented = false
    @State private var scanHistory: [ScanRecord] = []
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                Image("Background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack{
                    
                    Spacer().frame(height: 50)
                    
                    // Reset Onboarding Button
                    Button("Reset Onboarding") {
                        UserDefaults.standard.set(false, forKey: "hasSeenWalkthrough")
                    }
                    
                    HStack {
                        
                        Text("MelaScan")
                            .font(.system(size: 44).bold())
                            .foregroundColor(Color.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
                        
                    }
                    
                    Spacer().frame(height: 35)
                    
                    Image("Mole").resizable().frame(width: 200.0, height: 200.0)
                    
                    Spacer().frame(height: 35)
                    
                    VStack {
                        
                        VStack(alignment: .leading, spacing: 10) {
                            
                            HStack {
                                
                                Text("Scan History")
                                    .font(.title2)
                                    .foregroundColor(Color.white)
                                    .bold()
                                    .padding(.leading)
                                    .padding(.top, 5)
                                
                                Spacer()
                                
                                Button(action: {
                                    self.isInfoViewPresented = true
                                }) {
                                    Image(systemName: "info.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(Color.white)
                                        .bold()
                                        .padding(.all, 10)
                                }
                                .sheet(isPresented: $isInfoViewPresented) {
                                    InfoView(isPresented: self.$isInfoViewPresented)
                                }
                            }
                            
                            ScrollView {
                                
                                if scanHistory.isEmpty {
                                    Text("Your scan history is empty.\nTake your first scan to track changes over time.")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    List(scanHistory) { record in
                                        HStack {
                                            Image(uiImage: record.image)
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            VStack(alignment: .leading) {
                                                Text(record.title)
                                                    .font(.headline)
                                                Text(record.prediction)
                                                    .font(.subheadline)
                                                Text(record.date, style: .date)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    .listStyle(PlainListStyle())
                                }
                                
                            }
                            
                        }
                        .frame(height: 200)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 70)
                        
                        Button(action: {
                            isCustomCameraViewPresented.toggle()
                        }) {
                            ZStack {
                                
                                Circle()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(Color.white.opacity(0.5))
                                
                                Circle()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color.white)
                                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                                
                                Image(systemName: "camera.fill")
                                    .resizable()
                                    .frame(width: 30, height: 24)
                                    .foregroundColor(Color.black.opacity(0.7))
                            }
                        }
                        .padding(.bottom)
                        .sheet(isPresented: $isCustomCameraViewPresented, content: {
                            CustomCameraView(capturedImage: $capturedImage)
                        })
                        
                        
                        Spacer().frame(height: 50)
                        
                    }
                }
            }
        }
    }
}

struct ScanRecord: Identifiable {
    let id = UUID()
    let title: String
    let image: UIImage
    let prediction: String
    let date: Date
}

#Preview {
    ContentView()
}

