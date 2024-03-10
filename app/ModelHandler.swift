//
//  ModelHandler.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 14/11/2023.
//

import UIKit
import Foundation
import TensorFlowLite

class ModelHandler {
    private var interpreter: Interpreter?
    private var labels: [String] = []
    
    init() {
        loadModel()
        labels = loadLabels()
    }
    
    private func loadModel() {
        guard let modelPath = Bundle.main.path(forResource: "model", ofType: "tflite") else {
            fatalError("Failed to load the model from the app bundle.")
        }
        
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter?.allocateTensors()
        } catch let error {
            fatalError("Failed to create the interpreter with error: \(error.localizedDescription)")
        }
    }
}

extension ModelHandler {
    
    func processImage(_ image: UIImage) -> Data? {
        guard let buffer = image.resized(to: CGSize(width: 224, height: 224))?.normalize() else {
            return nil
        }
        return pixelBufferToData(pixelBuffer: buffer)
    }
    
    func predict(image: UIImage) -> String? {
        guard let imageData = processImage(image),
              let interpreter = interpreter else {
            return nil
        }
        
        do {
            try interpreter.copy(imageData, toInputAt: 0)
            try interpreter.invoke()
            
            let outputTensor = try interpreter.output(at: 0)
            let results: [Float] = [Float](unsafeData: outputTensor.data) ?? []
            
            guard let firstResult = results.first else { return nil }
            let maxIndex = firstResult == 1.0 ? 1 : 0
            return labels[maxIndex]
        } catch {
            print("Error during model inference: \(error)")
            return nil
        }
    }
    
    func pixelBufferToData(pixelBuffer: CVPixelBuffer) -> Data? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            return nil
        }
        let size = CVPixelBufferGetDataSize(pixelBuffer)
        return Data(bytes: baseAddress, count: size)
    }
    
}

extension UIImage {
    
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func normalize() -> CVPixelBuffer? {
        let width = 224
        let height = 224
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32ARGB, nil, &pixelBuffer)
        guard status == kCVReturnSuccess, let imageBuffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly) }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: CVPixelBufferGetBaseAddress(imageBuffer),
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(imageBuffer),
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return removeAlphaChannel(from: imageBuffer)
    }
    
    func removeAlphaChannel(from pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let oldBaseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        var newPixelBuffer: CVPixelBuffer?
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(value: true),
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(value: true)
        ]
        let status = CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_24RGB, options as CFDictionary, &newPixelBuffer)
        
        guard status == kCVReturnSuccess, let unwrappedNewPixelBuffer = newPixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(unwrappedNewPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let newBaseAddress = CVPixelBufferGetBaseAddress(unwrappedNewPixelBuffer)
        
        for row in 0..<height {
            let oldPixel = oldBaseAddress!.assumingMemoryBound(to: UInt8.self).advanced(by: row * bytesPerRow)
            let newPixel = newBaseAddress!.assumingMemoryBound(to: UInt8.self).advanced(by: row * CVPixelBufferGetBytesPerRow(unwrappedNewPixelBuffer))
            for column in 0..<width {
                let oldPixelOffset = oldPixel + column * 4 // 4 bytes per pixel in ARGB
                let newPixelOffset = newPixel + column * 3 // 3 bytes per pixel in RGB
                
                // Copy RGB values
                newPixelOffset[0] = oldPixelOffset[1] // Red
                newPixelOffset[1] = oldPixelOffset[2] // Green
                newPixelOffset[2] = oldPixelOffset[3] // Blue
            }
        }
        
        CVPixelBufferUnlockBaseAddress(unwrappedNewPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return newPixelBuffer
    }
    
    private func decomposeColor(_ color: UInt32) -> (UInt8, UInt8, UInt8, UInt8) {
        let r = UInt8((color >> 24) & 255)
        let g = UInt8((color >> 16) & 255)
        let b = UInt8((color >> 8) & 255)
        let a = UInt8((color >> 0) & 255)
        return (r, g, b, a)
    }
    
    private func recomposeColor(r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> UInt32 {
        return (UInt32(r) << 24) | (UInt32(g) << 16) | (UInt32(b) << 8) | UInt32(a)
    }
}


extension Array where Element: FloatingPoint {
    init?(unsafeData: Data) {
        let count = unsafeData.count / MemoryLayout<Element>.size
        self = unsafeData.withUnsafeBytes {
            .init($0.bindMemory(to: Element.self).prefix(count))
        }
    }
}

extension ModelHandler {
    func loadLabels() -> [String] {
        guard let labelPath = Bundle.main.path(forResource: "labels", ofType: "txt") else {
            fatalError("Labels file not found.")
        }
        do {
            let labelContent = try String(contentsOfFile: labelPath)
            return labelContent.components(separatedBy: .newlines)
        } catch {
            fatalError("Error loading labels: \(error)")
        }
    }
}

