import SwiftUI
import Combine

// MARK: - Keyboard Observing View Modifier
/// This modifier listens for changes in the keyboard height and applies appropriate padding to the bottom of the view to ensure the content is visible when the keyboard is displayed.
/// ChatGPT acknowledgement
struct KeyboardResponsiveModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight/2)
            .animation(.easeOut(duration: 0.3), value: keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }
}

// Publisher to track the keyboard height
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification in
                guard let userInfo = notification.userInfo,
                      let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return nil
                }
                // If the keyboard is not visible, return zero
                return frame.origin.y >= UIScreen.main.bounds.height ? 0 : frame.height
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}


// MARK: - Message Model
struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    var isTyping: Bool = false
}

// MARK: - Message Bubble View
/// The message can be from the user or from another source. If it's from the user, the message is displayed immediately.
/// If it's from another source, a typing animation (with loading dots) is shown until the message content appears.
/// The message formatting also supports headers, bullet points, and bold text using special markdown-style syntax.
struct MessageBubbleView: View {
    let message: Message
    @State private var displayedText = ""
    @State private var loadingDots = ""
    @State private var isTypingAnimationActive = false

    var body: some View {
        HStack {
            if message.isUser { Spacer() }

            if message.isTyping {
                LoadingDotsView() // Show the loading dots
            } else {
                formattedText(displayedText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(message.isUser ? Color("myOrange") : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                    .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading)
                    .onAppear {
                        if !message.isUser {
                            startTypingEffect()
                        } else {
                            displayedText = message.content // Show user text instantly
                        }
                    }
            }
            if !message.isUser { Spacer() }
        }
    }
    // TEXT FORMATTING
    /// Formats the displayed text, handling markdown-style formatting like headers, bullet points, and bold text.
    /// - Parameter text: the displayed text
    /// - Returns: a formatted text for a cleaner UX, and easier read
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
    /// Processes individual lines of text, handling headers and list items.
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
    /// Handles list items like numbered or bullet-point lists.
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
    // TYPING EFFECT
    /// Starts the typing effect by gradually revealing the message content.
    private func startTypingEffect() {
        displayedText = ""
        let characters = Array(message.content)
        for (index, char) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03 * Double(index)) {
                displayedText.append(char)
            }
        }
    }
    
    // LOADING EFFECT
    /// A view displaying animated loading dots.
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
        
        /// Starts the animation of dots.
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
}
//    /// **Loading "..." Animation**
//    private func startLoadingAnimation() {
//        isTypingAnimationActive = true
//        loadingDots = ""
//        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
//            if isTypingAnimationActive {
//                loadingDots = loadingDots.count == 3 ? "" : loadingDots + "."
//            } else {
//                timer.invalidate()
//            }
//        }
//    }
//}

// MARK: - Suggested Questions View
/// Displays a horizontal list of suggested questions for the user to quickly select from. Tapping a question triggers the provided action.
struct SuggestedQuestionsView: View {
    let questions: [String]
    let onQuestionTapped: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(questions, id: \.self) { question in
                    Button(action: { onQuestionTapped(question) }) {
                        Text(question)
                            .lineLimit(1)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .foregroundColor(.black)
                            .background(Color("myOrange")).opacity(0.5)
                            .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
}

// MARK: - Input Field View
/// A text input field where users can type their questions. Includes a send button that shows a loading indicator while waiting for a response.
struct MessageInputView: View {
    @Binding var text: String
    let isLoading: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                TextField("Ask questions", text: $text)
                    .padding(.leading, 20)
                    .frame(width: 360, height: 45)
                    .cornerRadius(50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(Color("myDarkGray"), lineWidth: 3)
                    )
                
                Button(action: onSend) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("myOrange")))
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                    }
                }
                .foregroundColor(Color("myOrange"))
                .padding(.trailing, 5)
                .disabled(isLoading)
            }
        }
        .padding(.bottom, 20)
        .modifier(KeyboardResponsiveModifier())
    }
}

// MARK: - Main Chat View
/// The main chat interface where users can interact with the chatbot. Displays messages, suggested questions, and an input field for user input. Includes a background image for visual enhancement.
struct chatView: View {
    @StateObject private var connector = DeepSeekConnector()
    @State private var messages: [Message] = [
        Message(content: "G'day, I'm Hestia. How can I help you?", isUser: false)
    ]
    @State private var newMessage = ""
    @State private var isLoading = false
    
    let suggestedQuestions = [
        "How much is the rent in Melbourne City?",
        "How much is the property near Monash University?",
        "Where is a good quiet suburb to live in?",
        "Where is an affordable suburb in Melbourne?"
    ]
    
    var body: some View {
        ZStack {
            Color("myGreen")
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 0) {
                mainContent
            }
        }
    }
    
    var mainContent: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .cornerRadius(50)

            VStack(spacing: 0) {
                chatContent
                    .padding(.top, 30)
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    var chatContent: some View {
        ZStack {
            Image("houseECO")
                .resizable()
                .frame(width: 300, height: 300)
                .opacity(0.2)
                .blur(radius: 2)
        
            VStack(spacing: 0) {
                messagesView
                
                VStack(spacing: 16) {
                    SuggestedQuestionsView(
                        questions: suggestedQuestions,
                        onQuestionTapped: sendMessage
                    )
                    
                    MessageInputView(
                        text: $newMessage,
                        isLoading: isLoading,
                        onSend: {
                            sendMessage(newMessage)
                            newMessage = ""
                        }
                    )
                }
                
                .background(Color.white)
            }
        }
    }
    
    var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 30)
                .padding(.bottom, 100)
            }
            .onChange(of: messages) { _ in
                if let last = messages.last?.id {
                    proxy.scrollTo(last, anchor: .bottom)
                }
            }
        }
    }
    
    /// Handles sending messages to the chat. Adds user messages, processes real estate-related queries with a preprompt, and handles the chatbot's response with a typing indicator. For irrelevant questions, it responds with a disclaimer about the focus on Australian real estate.
    private func sendMessage(_ message: String? = nil) {
        let content = message ?? newMessage
        guard !content.isEmpty else { return }

        // Remove the typing indicator if it exists before appending the new user message
        if let lastIndex = messages.lastIndex(where: { $0.isTyping }) {
            messages.remove(at: lastIndex)
        }

        // Add the user message instantly
        messages.append(Message(content: content, isUser: true))

        if message == nil {
            newMessage = ""
        }

        // Show "..." as a typing indicator for the bot
        let typingMessage = Message(content: "...", isUser: false, isTyping: true)
        messages.append(typingMessage)

        isLoading = true
        
        // Add preprompt for Australian real estate expert
        // chatGPT: Aussie-friendly, approachable version of a preprompt
        let preprompt = "If you think the question asked is relevant to real estate, then proceed: You’re a top-notch Aussie real estate agent with heaps of experience in the local market, property values, investment opportunities, and the legal stuff that goes with it. Your job is to give solid, clear advice to folks looking to buy, sell, or invest in real estate here in Australia. Make sure to keep it professional but friendly, just like a good mate would, and always consider the local rules and trends in the market. When possible, keep the answers short and concise. If, the question seems to be irrelevant just respond shortly and get it dismissed appropriately. Here’s the question: "
        let promptWithPreprompt = preprompt + content
        
        
        // Process the new message
        if isRealEstateQuestion(content) {
            connector.processPrompt(prompt: promptWithPreprompt) { response in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isLoading = false
                    // Remove the typing indicator after receiving a response
                    if let lastIndex = messages.lastIndex(where: { $0.isTyping }) {
                        messages.remove(at: lastIndex)
                    }
                    
                    if let response = response {
                        messages.append(Message(content: response, isUser: false))
                    } else {
                        messages.append(Message(content: "Sorry, I couldn't process your request", isUser: false))
                    }
                }
            }
        } else {
            isLoading = false // Immediately stop loading for irrelevant questions
            // Remove the typing indicator after receiving an irrelevant response
            if let lastIndex = messages.lastIndex(where: { $0.isTyping }) {
                messages.remove(at: lastIndex)
            }

            messages.append(Message(content: "I'm sorry, I can only answer questions about real estate in Australia.", isUser: false))
        }
    }

    // MARK: - Check if the message is related to Australian real estate
    /// Checks if the provided message content is related to Australian real estate based on a set of keywords.
    /// - Parameter content: The message content to check.
    /// - Returns: `true` if the content contains real estate-related keywords, `false` otherwise.
    private func isRealEstateQuestion(_ content: String) -> Bool {
        // chatGPT: keywords related to australian real estate
        let australianRealEstateKeywords = [
            "Melbourne", "Sydney", "Brisbane", "Adelaide", "Perth", "rent", "property", "suburb",
            "real estate", "house", "apartment", "buy", "sale", "market", "Monash", "Victoria", "NSW",
            "Queensland", "Australian", "Melbourne City", "affordable", "investment", "land", "townhouse",
            "unit", "real estate agent", "mortgage", "open house", "auction", "rental", "home loan",
            "interest rate", "first home buyer", "property value", "capital growth", "rental yield",
            "housing market", "new build", "off-plan", "downsizing", "upgrading", "realty", "buyer’s agent",
            "property management", "housing affordability", "home inspection", "house hunting", "buyers market",
            "sellers market", "lease", "real estate development", "region", "estate", "commercial property",
            "investment property", "residential", "house and land package", "real estate investment trust", "REIT",
            "landlord", "property portfolio", "gentrification", "urban development", "growth area", "moving",
            "house prices", "retirement village", "property tax", "capital gains tax", "property market trend",
            "home renovation", "property prices", "real estate listings", "real estate news", "real estate trends", "live", "home", "neighbourhood"
        ]
        
        // Convert content to lowercase for a case-insensitive comparison
        let lowercasedContent = content.lowercased()
        
        
        // Check if any of the keywords appear in the content
        for keyword in australianRealEstateKeywords {
            if lowercasedContent.contains(keyword.lowercased()) {
                return true
            }
        }
        return false
    }
    
}

// MARK: - Preview
#Preview {
    chatView()
}
