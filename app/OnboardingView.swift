//
//  OnboardingView.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 23/10/2023.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var pageIndex = 0
    private let pages: [Page] = Page.samplePages
    private let dotAppearance = UIPageControl.appearance()
    
    // To dismiss the view and navigate to the main content
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        TabView(selection: $pageIndex) {
            ForEach(pages) { page in
                VStack(spacing: 20) {
                    
                    Spacer(minLength: 20)
                    
                    PageView(page: page)
                    
                    Spacer(minLength: 20)
                    
                    if page == pages.last {
                        Button(action: finishOnboarding) {
                            Text("Get Started!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.cyan)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    } else {
                        Button(action: incrementPage) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.cyan)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 50) // Adjust this to provide more space for the dots
                }
                .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
                .tag(page.tag)
            }
        }
        .animation(.easeInOut, value: pageIndex)
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            dotAppearance.currentPageIndicatorTintColor = .black
            dotAppearance.pageIndicatorTintColor = .gray
        }
    }
    
    func incrementPage() {
        pageIndex += 1
    }
    
    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenWalkthrough")
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
}
