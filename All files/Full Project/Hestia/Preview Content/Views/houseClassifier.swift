//
//  houseClassifier.swift
//  Hestia
//
//  Created by Yuri Hoashi on 5/3/2025.
//

// NOT COMPLETED
import SwiftUI
import PhotosUI

/// Under testing - aiming to be able to classify a property as farmhouse, modern, or rustic.
/// Currently - failing to get the trained model to classify an uploaded image from the app
struct houseClassifier: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var prediction: String = ""
    @State private var confidence: Double = 0
    @State private var errorMessage: String?
    @State private var classifier: HouseStyleClassifier?
    
    init() {
        print("Initializing ProfileView")
        do {
            self.classifier = try HouseStyleClassifier()
            print("ProfileView: Classifier initialized successfully")
        } catch {
            print("ProfileView: Failed to initialize classifier: \(error)")
            self._errorMessage = State(initialValue: "Failed to initialize classifier: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        ZStack {
            Color("myGreen").ignoresSafeArea()
            
            VStack(spacing: 20) {
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(12)
                        .padding()
                }
                
                if !prediction.isEmpty {
                    VStack {
                        Text(prediction)
                            .font(.title2.bold())
                        Text("\(String(format: "%.1f", confidence))% confidence")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Upload House Photo", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("myLightGray"))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            print("ProfileView appeared")
            if classifier == nil {
                print("Classifier is nil on appear")
            }
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                do {
                    guard let data = try await newItem?.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else {
                        errorMessage = "Failed to load image"
                        return
                    }
                    
                    print("Image loaded successfully")
                    selectedImage = image
                    errorMessage = nil
                    prediction = ""
                    
                    guard let classifier = classifier else {
                        print("Classifier is nil when trying to classify")
                        errorMessage = "Classifier not initialized"
                        return
                    }
                    
                    classifier.classifyImage(image) { style, conf in
                        DispatchQueue.main.async {
                            print("Got classification result: \(style) (\(conf)%)")
                            prediction = style
                            confidence = conf
                            errorMessage = nil
                        }
                    }
                } catch {
                    print("Error processing image: \(error)")
                    errorMessage = "Error selecting image: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    houseClassifier()
}
