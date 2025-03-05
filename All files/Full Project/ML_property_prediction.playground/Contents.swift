import CreateML
import Foundation

// 1. Load CSV
let dataUrl = URL(fileURLWithPath: "/Users/yurihoashi/Desktop/Hestia/Melbourne_housing.csv")

if !FileManager.default.fileExists(atPath: dataUrl.path) {
    print("❌ File not found at path: \(dataUrl.path)")
} else {
    print("✅ File found successfully")
    print("Full path: \(dataUrl.path)")
}

var data = try MLDataTable(contentsOf: dataUrl)


// 2. Preprocess
data = try data.fillMissing(columnNamed: "Price", with: MLDataValue.int(0)) //

// 3. Train Model
let model = try MLBoostedTreeRegressor(
    trainingData: data,
    targetColumn: "Price",
    featureColumns: ["Suburb", "Rooms", "Type", "Distance"],
    parameters: .init(
        maxDepth: 5,
        maxIterations: 100,
        minLossReduction: 0.1
    )
)
// 4. Evaluate - FIXED metrics access
let metrics = model.evaluation(on: data)
print("Maximum Error: \(metrics.maximumError)")
print("RMSE: \(metrics.rootMeanSquaredError)")

// 5. Save Model - FIXED metadata requirement
let metadata = MLModelMetadata(
    author: "Your Name",
    shortDescription: "House price predictor",
    version: "1.0"
)
try model.write(to: URL(fileURLWithPath: "/Users/you/Desktop/Hestia/HousePricePredictor.mlmodel"),
                 metadata: metadata) // Metadata now required

// 6. Prediction - FIXED input format
let predictionInput: [String: MLDataValueConvertible] = [
    "Suburb": "Footscray",
    "Rooms": 2,
    "Type": "unit",
    "Distance": 5.5
]


let prediction = try model.predictions(from: MLDataTable(dictionary: predictionInput))
print("Predicted Price: \(prediction[0])")
