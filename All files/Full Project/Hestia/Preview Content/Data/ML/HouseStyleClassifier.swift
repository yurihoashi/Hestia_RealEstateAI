//
//  HouseStyleClassifier.swift
//  Hestia
//
//  Created by Yuri Hoashi on 3/3/2025.
//
import Vision
import CoreML
import UIKit

enum ClassifierError: Error {
    case modelLoading
    case imageConversion
    case classification
}

class HouseStyleClassifier {
    private let model: MLModel
    
    init() throws {
        print("📱 Starting classifier initialization...")
        
        // List all files in the bundle to debug
        if let resources = Bundle.main.urls(forResourcesWithExtension: "mlmodel", subdirectory: nil) {
            print("📂 Found .mlmodel files:")
            resources.forEach { print("   - \($0.lastPathComponent)") }
        } else {
            print("❌ No .mlmodel files found in bundle")
        }
        
        guard let modelURL = Bundle.main.url(forResource: "MyImageClassifier1", withExtension: "mlmodel") else {
            print("❌ MyImageClassifier1.mlmodel not found in bundle")
            throw ClassifierError.modelLoading
        }
        
        print("📱 Found model at: \(modelURL)")
        
        do {
            self.model = try MLModel(contentsOf: modelURL)
            print("✅ Model loaded successfully")
        } catch {
            print("❌ Failed to create model: \(error)")
            throw ClassifierError.modelLoading
        }
    }
    
    func classifyImage(_ image: UIImage, completion: @escaping (String, Double) -> Void) {
        print("🔍 Starting image classification...")
        
        guard let cgImage = image.cgImage else {
            print("❌ Failed to get CGImage from UIImage")
            completion("Error", 0)
            return
        }
        
        do {
            // Create Vision request
            let visionModel = try VNCoreMLModel(for: model)  // Removed configuration parameter
            
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                if let error = error {
                    print("❌ Vision request failed: \(error)")
                    completion("Error", 0)
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    print("❌ No classification results")
                    completion("Unknown", 0)
                    return
                }
                
                // Print all results for debugging
                print("🎯 Classification results:")
                results.forEach { result in
                    print("   \(result.identifier): \(result.confidence * 100)%")
                }
                
                let confidence = Double(topResult.confidence) * 100
                let style = self.formatStyleName(topResult.identifier)
                
                print("✅ Final prediction: \(style) with \(confidence)% confidence")
                completion(style, confidence)
            }
            
            // Set the correct crop and scale option
            request.imageCropAndScaleOption = .centerCrop  // This is an enum value, not a method
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            try handler.perform([request])
            
        } catch {
            print("❌ Classification error: \(error)")
            completion("Error", 0)
        }
    }
    
    private func formatStyleName(_ identifier: String) -> String {
        identifier.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
