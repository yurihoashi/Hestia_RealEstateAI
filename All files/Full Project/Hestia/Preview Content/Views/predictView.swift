//
//  personalView.swift
//  Hestia
//
//  Created by Yuri Hoashi on 1/3/2025.
//

import SwiftUI

/// This is the view where we can predict a property price based on the user inputs (i.e. property type, number of rooms, number of bathrooms, state/suburb
/// The user can find out the annual salary required to buy/rent there, as well as approximate the price of the property
struct predictView: View {
    @State private var suburbSearchQuery: String = ""
    @State private var selectedProperty: String? = ""
    @State private var numberOfRooms: Int = 1
    @State private var numberOfBathrooms: Int = 1
    @State private var selectedSuburb: String = "Choose"
    @State private var selectedState: String = "Choose"
    @State private var showStateSelection: Bool = false
    @State private var showSuburbSelection: Bool = false
    @State private var isLoading: Bool = true
    @State private var hasPredicted = false
    @State private var buttonPressed = false
    @State private var predictPressed = false
    @State private var isFetchingData = false
    
    let propertyTypes = ["House", "Apartment", "Unit House"]
    
//    // States and suburbs data
//    let stateToSuburbs: [String: [String]] = [
//        "NSW": ["Sydney", "Newcastle", "Wollongong"],
//        "VIC": ["Melbourne", "Geelong", "Ballarat"],
//        "WA": ["Perth", "Fremantle", "Mandurah"],
//        "QLD": ["Brisbane", "Gold Coast", "Cairns"],
//        "SA": ["Adelaide", "Mount Gambier", "Whyalla"],
//        "TAS": ["Hobart", "Launceston", "Devonport"],
//        "NT": ["Darwin", "Alice Springs", "Katherine"]
//    ]
//
    // State-to-suburbs dictionary (loaded from JSON)
    @State private var stateToSuburbs: [String: [String]] = [:]

    @State private var purchaseIncome = ""
    @State private var rentalIncome = ""
    @State private var priceRange = ""
    @State private var percentageChange = ""
    @State private var deepSeekResponse: String = "" // Store the predicted response here
    
    
    
    var body: some View {
        ZStack {
            // BACKGROUND COLOR
            Color("myGreen")
                .ignoresSafeArea(edges: .all)
            
            // WHITE CONTAINER
            VStack {
                Spacer()
                Color("myLightGray")
                    .frame(maxWidth: .infinity, maxHeight: 200)
            }
            VStack {
                Spacer()
                Color(.white)
                    .frame(maxWidth: .infinity, maxHeight: 500)
                    .cornerRadius(50)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            
            
            if predictPressed {
                VStack {
                    if hasPredicted {
                        VStack {
                            Text("Prediction Completed")
                                .bold()
                                .font(.title2)
                                .foregroundColor(Color("myOrange"))
                            formattedText(deepSeekResponse) // Display the response here
                                .font(.body)
                        }
                        .padding(.top, 250)
                        
                    }
                    else if isFetchingData {
                        // Show loading effect while predicting
                        LoadingDotsView()
                            .padding(.top, 200)
                    }
                }
            }
            // SCROLLABLE CONTENT
            else {
                ScrollView {
                    VStack(spacing: 20) {
                        // PROPERTY TYPE SELECTION
                        Text("Type of Property")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                        
                        HStack {
                            ForEach(propertyTypes, id: \.self) { type in
                                Button(action: { selectedProperty = type }) {
                                    Text(type)
                                        .padding()
                                        .background(selectedProperty == type ? Color("myOrange") : Color("myGreen").opacity(0.2))
                                        .foregroundColor(selectedProperty == type ? Color(.white) : Color(.black))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        Spacer()
                        
                        // ROOM SELECTION
                        Text("Number of Rooms")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                        HStack {
                            Button(action: {
                                if numberOfRooms > 1 { numberOfRooms -= 1 }
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    buttonPressed = true
                                }
                                // Simulate reset of animation after 0.2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        buttonPressed = false
                                    }
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color("myOrange"))
                                    .frame(width: 40, height: 40)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("myOrange"), lineWidth: 3)
                                    )
                            }
                            Text("\(numberOfRooms)")
                                .font(.title2)
                                .padding(.horizontal, 10)
                            
                            Button(action: {
                                numberOfRooms += 1
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    buttonPressed = true
                                }
                                // Simulate reset of animation after 0.2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        buttonPressed = false
                                    }
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color("myOrange"))
                                    .frame(width: 40, height: 40)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("myOrange"), lineWidth: 3)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        
                        
                        // BATHROOM SELECTION
                        Text("Number of Bathrooms")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                        HStack {
                            Button(action: {
                                if numberOfBathrooms > 1 { numberOfBathrooms -= 1 }
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    buttonPressed = true
                                }
                                // Simulate reset of animation after 0.2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        buttonPressed = false
                                    }
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color("myOrange"))
                                    .frame(width: 40, height: 40)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("myOrange"), lineWidth: 3)
                                    )
                            }
                            
                            Text("\(numberOfBathrooms)")
                                .font(.title2)
                                .padding(.horizontal, 10)
                            
                            Button(action: {
                                numberOfBathrooms += 1
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    buttonPressed = true
                                }
                                // Simulate reset of animation after 0.2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        buttonPressed = false
                                    }
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color("myOrange"))
                                    .frame(width: 40, height: 40)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("myOrange"), lineWidth: 3)
                                    )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Spacer()
                        // STATE SELECTION
                        Text("State")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                        Button(action: { showStateSelection.toggle() }) {
                            Text(selectedState)
                                .padding()
                                .frame(width: 128, height: 55)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("myOrange"), lineWidth: 3)
                                )
                                .foregroundColor(selectedState == "Choose" ? Color("myDarkGray") : Color("myOrange"))
                                .opacity(isLoading ? 0.5 : 1) // Disable button when loading
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .disabled(isLoading) // Disable the button while loading
                        .sheet(isPresented: $showStateSelection) {
                            // Display state selection
                            VStack {
                                Text("Select State")
                                    .font(.title2)
                                    .bold()
                                List(stateToSuburbs.keys.sorted(), id: \.self) { state in
                                    Button(action: {
                                        selectedState = state
                                        showStateSelection.toggle()  // Close the state selection
                                        selectedSuburb = "Choose"   // Reset suburb selection
                                    }) {
                                        Text(state)
                                            .padding()
                                            .cornerRadius(10)
                                    }
                                }
                                .listStyle(.plain)
                                .bold()
                                .foregroundColor(.black)
                            }
                            .padding()
                        }
                        
                        Spacer()
                        
                        // SUBURB SELECTION
                        Text("Suburb")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                        
                        Button(action: { showSuburbSelection.toggle() }) {
                            Text(selectedSuburb)
                                .padding()
                                .frame(width: 128, height: 55)
                            //                            .background(Color("myOrange").opacity(0.2))
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("myOrange"), lineWidth: 3)
                                )
                                .foregroundColor(selectedState == "Choose" ? Color("myDarkGray") : Color("myOrange"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .sheet(isPresented: $showSuburbSelection) {
                            VStack {
                                Text("Select Suburb")
                                    .font(.title2)
                                    .bold()
                                
                                // SEARCH BAR
                                TextField("Search suburb...", text: $suburbSearchQuery)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                
                                // FILTER SUBURBS BASED ON SEARCH QUERY
                                List(stateToSuburbs[selectedState]?.filter {
                                    suburbSearchQuery.isEmpty || $0.lowercased().contains(suburbSearchQuery.lowercased())
                                } ?? [], id: \.self) { suburb in
                                    Button(action: {
                                        selectedSuburb = suburb
                                        showSuburbSelection.toggle()  // Close the sheet
                                    }) {
                                        Text(suburb)
                                            .padding()
                                    }
                                }
                                .listStyle(.plain)
                                .bold()
                                .foregroundColor(.black)
                            }
                            .padding()
                        }
                        
                        Spacer()
                        
                        HStack {
                            // Reset button
                            Button(action: {
                                print("resetted")
                                selectedProperty = ""
                                numberOfRooms = 1
                                numberOfBathrooms = 1
                                selectedSuburb = "Choose"
                                selectedState = "Choose"
                                suburbSearchQuery = ""
                                showStateSelection = false
                                showSuburbSelection = false
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                                    .frame(width: 120, height: 55)
                                    .foregroundColor(Color("myOrange"))
                                    .bold()
                            }
                            Spacer()
                            // PREDICT BUTTON
                            Button(action: {
                                predictPressed = true
                                
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    buttonPressed = true
                                }
                                // Simulate reset of animation after 0.2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        buttonPressed = false
                                    }
                                }
                                 
                                print("Selected Property: \(selectedProperty ?? "")")
                                print("Number of Rooms: \(numberOfRooms)")
                                print("Number of Bathrooms: \(numberOfBathrooms)")
                                print("State: \(selectedState)")
                                print("Suburb: \(selectedSuburb)")
                                
                                isFetchingData = true // Set a flag to indicate fetching state
                                hasPredicted = false
                                
                                Task {
                                    let response = await DeepSeekService.generatePrediction(
                                        state: selectedState,
                                        suburb: selectedSuburb,
                                        propertyType: selectedProperty ?? "House",
                                        bedrooms: numberOfRooms,
                                        bathrooms: numberOfBathrooms
                                    )
                                    
                                    // Process the response here
                                    print("DeepSeek Response:", response)
                                    isFetchingData = false
                                    hasPredicted = true
                                    // Update UI on main thread
                                    DispatchQueue.main.async {
                                        // Update the deepSeekResponse state
                                        self.deepSeekResponse = response // Display response in Text
                                        // Parse and update your state variables
                                        let parsed = parsePrediction(response: response)
                                        self.purchaseIncome = parsed.purchaseIncome
                                        self.rentalIncome = parsed.rentalIncome
                                        self.priceRange = parsed.priceRange
                                        self.percentageChange = parsed.percentageChange
                                    }
                                    
                                }
                                
                                
                                
                            }) {
                                Text("Predict")
                                    .padding()
                                    .bold()
                                    .frame(width: 128, height: 55)
                                    .background(Color("myOrange"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: 480)
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .frame(maxHeight: .infinity, alignment: .bottom)

            }
            // HOUSE IMAGE (BRING TO FRONT)
            Image("houseG")
                .resizable()
                .frame(width: 400, height: 400)
                .offset(x: 90, y: -200)
                .zIndex(1)
        }
        .onAppear {
            loadSuburbData()
        }
    }
    
    private func parsePrediction(response: String) -> (purchaseIncome: String,
                                                      rentalIncome: String,
                                                      priceRange: String,
                                                      percentageChange: String) {
        let components = response.components(separatedBy: "|")
        guard components.count == 5 else {
            return ("N/A", "N/A", "N/A", "N/A")
        }
        
        return (
            purchaseIncome: formatCurrency(components[0]),
            rentalIncome: formatCurrency(components[1]),
            priceRange: "\(formatCurrency(components[2])) - \(formatCurrency(components[3]))",
            percentageChange: "\(components[4])%"
        )
    }
    
    private func formatCurrency(_ value: String) -> String {
        guard let number = Double(value) else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? "N/A"
    }
    // Function to load JSON data
    func loadSuburbData() {
        if let url = Bundle.main.url(forResource: "suburbs_by_state", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                stateToSuburbs = decodedData
                print("Loaded JSON successfully:") // DEBUGGING LINE
                isLoading = false
            } catch {
                print("Error loading JSON:", error)
                isLoading = false
            }
        } else {
            print("suburbs_by_state.json not found")
            isLoading = false
        }
    }

    // Loading animation view with dots
    struct LoadingDotsView: View {
        @State private var animatedDots: [Bool] = [false, false, false] // Three dots
        let dotSize: CGFloat = 10
        let dotSpacing: CGFloat = 5
        let animationDuration: Double = 0.6
        
        var body: some View {
            HStack(spacing: dotSpacing) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color("myDarkGray"))
                        .frame(width: dotSize, height: dotSize)
                        .opacity(animatedDots[index] ? 1 : 0.3)
                        .animation(
                            Animation.easeInOut(duration: animationDuration)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * animationDuration / 3), value: animatedDots[index]
                        )
                }
            }
            .onAppear {
                startAnimation()
            }
        }
        
        private func startAnimation() {
            // Trigger animation changes for dots
            Timer.scheduledTimer(withTimeInterval: animationDuration / 3, repeats: true) { _ in
                self.animatedDots = self.animatedDots.map { _ in false }
                self.animatedDots[0] = true
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration / 3) {
                    self.animatedDots[1] = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2 * animationDuration / 3) {
                    self.animatedDots[2] = true
                }
            }
        }
    }
    private func formattedText(_ text: String) -> Text {
        let lines = text.components(separatedBy: .newlines)
        var result = Text("")
        
        for (index, line) in lines.enumerated() {
            var lineResult = processLine(line)
            if index != lines.count - 1 {
                lineResult = lineResult + Text("\n")
            }
            result = result + lineResult
        }
        
        return result
    }
    private func processLine(_ line: String) -> Text {
        // Handle headers with optional space after ###
        if line.hasPrefix("###") {
            let cleaned = String(line.dropFirst(3)).trimmingCharacters(in: .whitespacesAndNewlines)
            return Text(cleaned)
                .font(.title3)
                .bold()
        }
        
        // Handle lists and formatting
        return handleListItems(line)
    }
    private func handleListItems(_ line: String) -> Text {
        var modifiedLine = line
        var prefix: Text = Text("")
        
        // Handle numbered lists (e.g., "1. ..." or "1:")
        let numberedListPattern = #"^(\d+)[\.:]\s"#
        if let range = modifiedLine.range(of: numberedListPattern, options: .regularExpression) {
            let number = String(modifiedLine[range])
            prefix = Text(number)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            modifiedLine = String(modifiedLine[range.upperBound...])
        }
        // Handle bullet points (e.g., "- ...")
        else if modifiedLine.hasPrefix("- ") {
            prefix = Text("•  ")
                .fontWeight(.medium)
                .foregroundColor(.primary)
            modifiedLine = String(modifiedLine.dropFirst(2))
        }
        
        // Process bold text
        let components = modifiedLine.components(separatedBy: "**")
        var content = Text("")
        
        for (index, component) in components.enumerated() {
            content = content + Text(component)
                .fontWeight(index % 2 == 1 ? .bold : .regular)
        }
        
        return prefix + content
    }
    
//    func fetchPredictionData(_ inputData: [String: Any], completion: @escaping (String) -> Void) {
//        // This is just a placeholder function. Replace it with actual network request or model inference.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            completion("1.2 Million") // Example predicted price
//        }
//    }
}

#Preview {
    predictView()
}
