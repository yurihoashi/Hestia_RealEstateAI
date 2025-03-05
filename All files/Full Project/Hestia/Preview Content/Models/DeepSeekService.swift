//
//  DeepSeekService.swift
//  Hestia
//
//  Created by Yuri Hoashi on 5/3/2025.
//

import Foundation

/// Generates a property market prediction for the years 2025, 2030, and 2040.
class DeepSeekService {
    /// - Parameters:
    ///   - state: The state where the property is located.
    ///   - suburb: The suburb where the property is located.
    ///   - propertyType: The type of property (e.g., house, apartment).
    ///   - bedrooms: The number of bedrooms in the property.
    ///   - bathrooms: The number of bathrooms in the property.
    /// - Returns: A string containing the predicted income and price range for each year (2025, 2030, 2040), formatted in a readable way.
    static func generatePrediction(state: String,
                                   suburb: String,
                                   propertyType: String,
                                   bedrooms: Int,
                                   bathrooms: Int) async -> String {
        
        let baseIncome = IncomeStore.historicalIncomeFor(suburb: suburb, state: state) ?? 0
        
        let prompt = """
            Given 2016 census data showing a median income of \(baseIncome) in \(suburb), \(state),
            estimate for 2025, 2030, and 2040 requirements for:
            - \(propertyType) with \(bedrooms) bedrooms and \(bathrooms) bathrooms
            
            Provide numerical answers only in this exact format:
            year|purchase_income|rental_income|price_range_low|price_range_high|percentage_change
            Example:
            2025|$120,000|$75,000|$800,000|$950,000|58%
            2030|$135,000|$82,000|$950,000|$1,100,000|40%
            2040|$150,000|$90,000|$1,100,000|$1,300,000|37%
            """
        
        return await withCheckedContinuation { continuation in
            DeepSeekConnector.shared.processPrompt(prompt: prompt) { response in
                if let response = response {
                    print("Raw response: \(response)") // Debugging step
                    
                    // Split the response into lines
                    let responseLines = response.split(separator: "\n")
                    
                    // Process each line
                    var parsedResponse: [String] = []
                    for line in responseLines {
                        // Split each line by the pipe symbol to extract the values
                        let components = line.split(separator: "|")
                        if components.count == 6 {
                            parsedResponse.append("\n**Year**: \(components[0])\n- Buy Income: \(components[1])/year\n- Rental Income: \(components[2])/year\n- Price Range: \(components[3])~\(components[4])\n- Percentage Change: \(components[5])")
                        } else {
                            print("Unexpected data format: \(line)")
                        }
                    }
                    
                    // Join the parsed response into a single string and return
                    let finalResponse = parsedResponse.joined(separator: "\n")
                    continuation.resume(returning: finalResponse)
                } else {
                    print("Failed to get response")
                    continuation.resume(returning: "Error: No response")
                }
            }
        }
    }
}
