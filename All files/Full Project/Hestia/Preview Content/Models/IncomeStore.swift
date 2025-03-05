//
//  IncomeStore.swift
//  Hestia
//
//  Created by Yuri Hoashi on 5/3/2025.
//

import Foundation

/// A class responsible for loading and providing historical income data for suburbs.
/// This class loads income data from a JSON file and allows querying of income for specific suburbs and states.
class IncomeStore {
    static var suburbIncomes: [String: [String: Int]] = loadIncomeData()
    
    /// Loads the income data from a local JSON file.
    /// - Returns: A dictionary with state names as keys and suburb income data as values.
    private static func loadIncomeData() -> [String: [String: Int]] {
        guard let url = Bundle.main.url(forResource: "suburb_incomes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load json file")
            return [:]
        }
        return (try? JSONDecoder().decode([String: [String: Int]].self, from: data)) ?? [:]
    }
    
    /// Retrieves the historical income for a specific suburb and state.
    /// - Parameters:
    ///   - suburb: The name of the suburb.
    ///   - state: The name of the state.
    /// - Returns: The historical income for the suburb in the given state, or nil if not found.
    static func historicalIncomeFor(suburb: String, state: String) -> Int? {
        return suburbIncomes[state]?[suburb]
    }
}
