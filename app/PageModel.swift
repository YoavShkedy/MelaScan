//
//  PageModel.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 23/10/2023.
//

import Foundation

struct Page: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var description: String
    var image: String
    var tag: Int
    
    static var samplePage = Page(title: "Welcome to MelaScan!", description: "Your personal assistant for mole monitoring. Leveraging advanced technology, MelaScan helps you keep an eye on your skin's health, empowering you to be proactive about your well-being.", image: "Mole", tag: 0)
    
    static var samplePages: [Page] = [
        Page(title: "Welcome to MelaScan!", description: "Your personal assistant for mole monitoring. Leveraging advanced technology, MelaScan helps you keep an eye on your skin's health, empowering you to be proactive about your well-being.", image: "Mole", tag: 0),
        Page(title: "The Power of Early Detection", description: "Detecting skin changes early can make a significant difference. Regular monitoring and early detection can lead to better outcomes and simpler treatments. With MelaScan, you're one step ahead.", image: "BackMole1", tag: 1),
        Page(title: "Simple Steps for Clarity", description: "1. Capture a clear photo of your mole.\n2. Get instant feedback on your scan.\n3. Save your scans to track changes over time.", image: "BackMole2", tag: 2),
        Page(title: "Always Consult a Professional", description: "MelaScan is a tool for awareness and tracking. It is not a replacement for professional medical advice, diagnosis, or treatment. Always consult with a healthcare provider about any concerns.", image: "Doctor", tag: 3)
    ]
}
