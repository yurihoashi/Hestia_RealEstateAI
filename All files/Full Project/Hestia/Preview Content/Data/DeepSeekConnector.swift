//
//  DeepSeekConnector.swift
//  Hestia
//
//  Created by Yuri Hoashi on 2/3/2025.
//
import Foundation

/// The DeepSeekConnector class is an interface to communicate with the DeepSeek API, specifically to send a prompt and retrieve a chat completion response. This class is designed to interact with the DeepSeek API for natural language processing tasks.
public class DeepSeekConnector: ObservableObject {
    // Add shared singleton instance
    public static let shared = DeepSeekConnector()
    
    private let apiURL = URL(string: "https://api.deepseek.com/v1/chat/completions")
    
    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let key = config["DeepSeekAPIKey"] as? String else {
            fatalError("Missing DeepSeek API key in Config.plist")
        }
        return key
    }
    
    /// Sends a prompt to the API and processes the response.
    /// - Parameters:
    ///   - prompt: The text input to be sent to the API.
    ///   - completion: A closure that will be called with the processed response or `nil` if an error occurs.
    public func processPrompt(prompt: String, completion: @escaping (String?) -> Void) {
        guard let apiURL = apiURL else {
            print("Invalid API URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 500
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("JSON serialization failed: \(error)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error:", error)
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                completion(nil)
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Bad status code:", httpResponse.statusCode)
                print("Response body:", String(data: data ?? Data(), encoding: .utf8) ?? "No body")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("🔧 No data received")
                completion(nil)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(DeepSeekResponse.self, from: data)
                completion(response.choices.first?.message.content)
            } catch {
                print("🔧 Decoding error:", error)
                completion(nil)
            }
        }.resume()
    }
    
    /// Sends an HTTP request and returns the response data or an error.
    /// - Parameter request: The URLRequest to be executed.
    /// - Returns: A result containing either the response data if successful, or an error if the request fails or times out.
    private func executeRequest(request: URLRequest) -> Result<Data, Error> {
        let semaphore = DispatchSemaphore(value: 0)
        var resultData: Data?
        var resultError: Error?
        
        print("Sending request to:", request.url?.absoluteString ?? "nil")
        print("Using API key:", self.apiKey)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error:", error)
                resultError = error
            } else if let httpResponse = response as? HTTPURLResponse {
                print("Response status code:", httpResponse.statusCode)
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorString = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No error body"
                    print("Response body:", errorString)
                    resultError = NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "Server returned status \(httpResponse.statusCode)",
                        "ResponseBody": errorString
                    ])
                } else {
                    print("Received \(data?.count ?? 0) bytes")
                    resultData = data
                }
            }
            semaphore.signal()
        }
        task.resume()
        let timeoutResult = semaphore.wait(timeout: .now() + 20)
            
        switch timeoutResult {
        case .timedOut:
            print("Request timed out after 20 seconds")
            return .failure(NSError(domain: "Timeout", code: -1001))
        case .success:
            break
        }
        
        if let error = resultError {
            print("API Error: \(error)")
            if let nsError = error as? NSError {
                print("Response Body: \(nsError.userInfo["ResponseBody"] ?? "No body")")
            }
            return .failure(error)
        }
        guard let validData = resultData else {
            return .failure(NSError(domain: "No Data", code: 0))
        }
        return .success(validData)
    }
 
    
    
    /// Parses the API response data to extract the content of the first message.
    /// - Parameter data: The raw data received from the API response.
    /// - Returns: The content of the first message in the response, or nil if parsing fails.
    private func parseResponse(data: Data) -> String? {
        do {
            let response = try JSONDecoder().decode(DeepSeekResponse.self, from: data)
            return response.choices.first?.message.content
        } catch {
            print("Response parsing failed: \(error)")
            return nil
        }
    }
}

/// Represents the complete response from the DeepSeek API after processing a request. It contains metadata about the response, such as its unique ID, creation timestamp, and the model used. It also includes a list of choices, each of which corresponds to a possible message from the model.
struct DeepSeekResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [DeepSeekChoice]
}

/// Represents a single choice or alternative returned by the DeepSeek API. Each choice corresponds to a potential response message generated by the model. This includes the message content and metadata such as the index of the choice and the reason why the model stopped generating it.
struct DeepSeekChoice: Codable {
    let message: DeepSeekMessage
    let index: Int
    let finish_reason: String
}

/// Represents a single choice or alternative returned by the DeepSeek API. Each choice corresponds to a potential response message generated by the model. This includes the message content and metadata such as the index of the choice and the reason why the model stopped generating it.
struct DeepSeekMessage: Codable {
    let role: String
    let content: String
}
