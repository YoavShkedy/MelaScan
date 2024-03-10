//
//  PageView.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 23/10/2023.
//

import SwiftUI

struct PageView: View {
    var page: Page
    
    var body: some View {
        VStack(spacing: 20) {
            Image("\(page.image)")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding()
                .background(Color.gray.opacity(0.10))
                .cornerRadius(10)
            
            Text(page.title)
                .font(.largeTitle)
                .bold()
                .padding(.horizontal, 40)
                .multilineTextAlignment(.center)
            
            // Instruction Page
            if page.tag == 2 {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(page.description.split(separator: "\n"), id: \.self) { line in
                        NumberedTextRow(number: String(line.prefix(2)), text: String(line.dropFirst(3)))
                    }
                }
                .font(.body)
                .frame(width: 300, alignment: .leading)
                .multilineTextAlignment(.leading)
            } else {
                Text(page.description)
                    .font(.body)
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct NumberedTextRow: View {
    var number: String
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .bold()
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(page: Page.samplePage)
    }
}
