//
//  PredictViewController.swift
//  Hestia
//
//  Created by Yuri Hoashi on 5/3/2025.
//

import UIKit

class PredictViewController: UIViewController {

    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var suburbTextField: UITextField!
    @IBOutlet weak var propertyTypeTextField: UITextField!
    @IBOutlet weak var bedroomsTextField: UITextField!
    @IBOutlet weak var bathroomsTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the result text view
        resultTextView.text = "Please enter the details and click Get Prediction."
    }

    @IBAction func getPredictionButtonTapped(_ sender: UIButton) {
        // Get input values from text fields
        guard let state = stateTextField.text, !state.isEmpty,
              let suburb = suburbTextField.text, !suburb.isEmpty,
              let propertyType = propertyTypeTextField.text, !propertyType.isEmpty,
              let bedroomsText = bedroomsTextField.text, let bedrooms = Int(bedroomsText), bedrooms > 0,
              let bathroomsText = bathroomsTextField.text, let bathrooms = Int(bathroomsText), bathrooms > 0 else {
                  resultTextView.text = "Please fill all fields correctly."
                  return
              }
        
        // Call DeepSeekService to generate prediction
        Task {
            let prediction = await DeepSeekService.generatePrediction(state: state, suburb: suburb, propertyType: propertyType, bedrooms: bedrooms, bathrooms: bathrooms)
            
            // Update the UI with the prediction result
            DispatchQueue.main.async {
                self.resultTextView.text = prediction
            }
        }
    }
}
