import SwiftUI

struct QuizView: View {
    @EnvironmentObject var settings: Settings
    
    @State private var started = false
    @State private var quizItems: [QuizItem] = []
    @State private var currentIndex = 0
    @State private var answerStatus: String? = nil
    @State private var correctAnswer: String? = nil
    @State private var showAnswer = false

    @State private var correctCount = 0
    @State private var incorrectCount = 0

    @State private var textInput: String = ""
    
    @State private var includeLetters = true
    @State private var includeDigraphs = false
    @State private var numberOfQuestions = aurebeshLetters.count
    
    @State private var selectedChoice: String? = nil
    
    @AppStorage("useTextFieldPicker") private var useTextFieldPicker = 2
    @State private var useTextField = false
    
    @AppStorage("useAurebeshAnswersPicker") private var useAurebeshAnswersPicker = 2
    @State private var useAurebeshAnswers = false
    
    @AppStorage("useAurebeshNames") private var useAurebeshNames = false
    
    @State private var wrongItems: [QuizItem] = []
    @State private var finished = false
    
    var aurebeshDigraphFont: String {
        if settings.aurebeshFont.contains("Aurebesh") && !settings.aurebeshFont.contains("Digraph") {
            return settings.aurebeshFont + "Digraph"
        } else {
            return settings.aurebeshFont
        }
    }
    
    func backgroundColor(for choice: String) -> Color {
        guard showAnswer else { return Color.secondary.opacity(0.1) }
        
        if choice == quizItems[currentIndex].correctName { return .green }
        if choice == selectedChoice { return .red }
        
        return Color.secondary.opacity(0.1)
    }
    
    var maxCount: Int {
        let aurebeshCount = aurebeshLetters.count
        let digraphCount = digraphLetters.count
        let hasAurebeshFont = settings.aurebeshFont.contains("Aurebesh")

        switch (includeLetters, includeDigraphs && hasAurebeshFont) {
        case (true, true): return aurebeshCount + digraphCount
        case (true, false): return aurebeshCount
        case (false, true): return digraphCount
        default: return 0
        }
    }
    
    var body: some View {
        HoloCard {
            VStack {
                if finished {
                    resultsView
                } else if !started {
                    List {
                        Group {
                            Section(header: Text("\(settings.pickerStyleSelection) TRIALS").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                                AurebeshScriptPicker()
                                
                                Spacer()
                                
                                VStack {
                                    HStack {
                                        Text("Questions: \(numberOfQuestions)")
                                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                        
                                        Spacer()
                                        
                                        Stepper(value: $numberOfQuestions.animation(.smooth), in: 3...maxCount) {}
                                            .fixedSize()
                                            .conditionalGlassEffect()
                                    }
                                    
                                    Slider(
                                        value: Binding(
                                            get: { Double(numberOfQuestions) },
                                            set: { numberOfQuestions = Int($0.rounded()) }
                                        ).animation(.smooth),
                                        in: 3...Double(maxCount)
                                    )
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .conditionalGlassEffect()
                                }
                                
                                Toggle("Include Letters", isOn: $includeLetters)
                                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                    .tint(settings.accentColor.color.opacity(0.5))
                                    .disabled({
                                        let isAurebesh = settings.aurebeshFont.contains("Aurebesh")
                                        return isAurebesh ? !includeDigraphs : true
                                    }())
                                
                                if settings.aurebeshFont.contains("Aurebesh") {
                                    Toggle("Include Digraphs", isOn: $includeDigraphs)
                                        .tint(settings.accentColor.color.opacity(0.5))
                                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                        .disabled(!includeLetters)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    HStack {
                                        Text("Answer with:")
                                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                        
                                        Spacer()
                                    }
                                    
                                    if settings.aurebeshFont.contains("Aurebesh") {
                                        Picker("", selection: $useAurebeshNames.animation(.smooth)) {
                                            Text("Name").tag(true)
                                            Text("Letter").tag(false)
                                        }
                                        .pickerStyle(.segmented)
                                        .conditionalGlassEffect()
                                    }
                                    
                                    Picker("", selection: $useAurebeshAnswersPicker.animation(.smooth)) {
                                        Text(settings.pickerStyleSelection).tag(0)
                                        Text("English").tag(1)
                                        Text("Both").tag(2)
                                    }
                                    .pickerStyle(.segmented)
                                    .conditionalGlassEffect()
                                    
                                    Picker("", selection: $useTextFieldPicker.animation(.smooth)) {
                                        Text("Text Field").tag(0)
                                        Text("Multiple Choice").tag(1)
                                        Text("Both").tag(2)
                                    }
                                    .pickerStyle(.segmented)
                                    .conditionalGlassEffect()
                                }
                                .id(settings.refreshID)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    .transparentList()
                    .padding(.horizontal, -16)
                    
                    Button(action: {
                        if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                        
                        withAnimation(.smooth) {
                            startQuiz()
                        }
                    }) {
                        Text("Begin Trials")
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.primary)
                            .conditionalGlassEffect()
                    }
                } else {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Question \(currentIndex + 1) / \(quizItems.count)")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .headline).pointSize))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                
                                DispatchQueue.main.async {
                                    withAnimation(.smooth) {
                                        started = false
                                        currentIndex = 0
                                        answerStatus = nil
                                        correctAnswer = nil
                                        showAnswer = false
                                        textInput = ""
                                    }
                                }
                            }) {
                                HStack {
                                    Text("End Trial")
                                    Image(systemName: "xmark.circle.fill")
                                }
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                .foregroundColor(.red)
                            }
                        }
                        
                        HStack {
                            Text("Correct: \(correctCount)")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            Text("Incorrect: \(incorrectCount)")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                .foregroundColor(.red)
                        }
                    }
                    
                    Spacer()
                    
                    Text(quizItems[currentIndex].symbol)
                        .font(.custom(useAurebeshAnswers ? "EnglishStandard" : aurebeshDigraphFont, size: 80))
                        .foregroundColor(settings.accentColor.color)
                        .shadow(color: settings.accentColor.color.opacity(0.25), radius: 10, x: 0.0, y: 0.0)
                        .padding()
                    
                    Text(answerStatus ?? "")
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        .foregroundColor((answerStatus ?? "").contains("Correct!") ? .green : .red)
                        .opacity(answerStatus != nil ? 1 : 0.01)
                    
                    if useTextField && !(answerStatus ?? "Correct!").contains("Correct") {
                        Text(correctAnswer ?? "")
                            .font(.custom(useAurebeshAnswers ? aurebeshDigraphFont : "EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title2).pointSize))
                            .foregroundColor((correctAnswer ?? "").contains("Correct!") ? .green : .red)
                            .opacity(answerStatus != nil ? 1 : 0.01)
                    }
                    
                    Spacer()
                    
                    if useTextField {
                        VStack(spacing: 20) {
                            if useAurebeshNames {
                                Text("Enter the correct name:")
                                    .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Enter the correct letter:")
                                    .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                    .foregroundColor(.secondary)
                            }
                            
                            CustomTextEditor(text: $textInput, aurebeshMode: useAurebeshAnswers, autocorrect: false)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(settings.accentColor.color.opacity(0.4), lineWidth: 1)
                                )
                                .disabled(showAnswer)
                                .frame(height: 75)
                        }
                    } else {
                        VStack(spacing: 20) {
                            ForEach(quizItems[currentIndex].choices, id: \.self) { choice in
                                Button(action: {
                                    if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                    
                                    withAnimation(.smooth) {
                                        selectedChoice = choice
                                        showAnswer = true
                                        let correctAnswer = quizItems[currentIndex].correctName
                                        let isCorrect = (choice == correctAnswer)
                                        
                                        answerStatus = isCorrect
                                        ? "✅ Correct!"
                                        : "❌ Incorrect!"
                                        self.correctAnswer = correctAnswer
                                        
                                        if isCorrect {
                                            correctCount += 1
                                        } else {
                                            incorrectCount += 1
                                            wrongItems.append(quizItems[currentIndex])
                                        }
                                    }
                                }) {
                                    Text(choice)
                                        .font(.custom(useAurebeshAnswers ? aurebeshDigraphFont : "EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                                        .foregroundColor(.primary)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .conditionalGlassEffect(tint: backgroundColor(for: choice))
                                }
                                .disabled(showAnswer)
                            }
                        }
                    }
                    
                    if !showAnswer && useTextField {
                        Button(action: {
                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                            withAnimation(.smooth) {
                                showAnswer = true
                                let userAnswer = textInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                                let correctAnswer = quizItems[currentIndex].correctName
                                let isCorrect = userAnswer == correctAnswer.lowercased()
                                
                                answerStatus = isCorrect
                                ? "✅ Correct!"
                                : "❌ Incorrect! The answer was:"
                                self.correctAnswer = correctAnswer
                                
                                if isCorrect {
                                    correctCount += 1
                                } else {
                                    incorrectCount += 1
                                    wrongItems.append(quizItems[currentIndex])
                                }
                            }
                        }) {
                            Text("Submit")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.primary)
                                .conditionalGlassEffect()
                        }
                        .padding(.top, 30)
                        .opacity(!showAnswer ? 1 : 0.001)
                        .disabled(showAnswer)
                    } else {
                        Button(action: {
                            if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                            
                            withAnimation(.smooth) {
                                answerStatus = nil
                                correctAnswer = nil
                                showAnswer = false
                                
                                if currentIndex + 1 < quizItems.count {
                                    currentIndex += 1
                                } else {
                                    finished = true
                                    currentIndex = 0
                                }
                                
                                if useTextField {
                                    DispatchQueue.main.async {
                                        textInput = ""
                                    }
                                }
                                
                                selectedChoice = nil
                                
                                if useTextFieldPicker == 2 {
                                    useTextField = Bool.random()
                                }
                                
                                if useAurebeshAnswersPicker == 2 {
                                    useAurebeshAnswers = Bool.random()
                                }
                            }
                        }) {
                            Text(currentIndex + 1 == quizItems.count ? "Finish" : "Next")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.primary)
                                .conditionalGlassEffect()
                        }
                        .padding(.top, 30)
                        .opacity(showAnswer ? 1 : 0.001)
                        .disabled(!showAnswer)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onChange(of: settings.aurebeshFont) { font in
            withAnimation(.smooth) {
                if !font.contains("Aurebesh") {
                    includeLetters = true
                }
                numberOfQuestions = maxCount
            }
        }
        .onChange(of: includeLetters) { _ in
            withAnimation(.smooth) {
                numberOfQuestions = maxCount
            }
        }
        .onChange(of: includeDigraphs) { _ in
            withAnimation(.smooth) {
                numberOfQuestions = maxCount
            }
        }
    }
    
    private func columnWidth(for textStyle: UIFont.TextStyle, extra: CGFloat = 4, sample: String? = nil, fontName: String? = nil) -> CGFloat {
        let sampleString = (sample ?? "M") as NSString
        let font: UIFont

        if let fontName = fontName, let customFont = UIFont(name: fontName, size: UIFont.preferredFont(forTextStyle: textStyle).pointSize) {
            font = customFont
        } else {
            font = UIFont.preferredFont(forTextStyle: textStyle)
        }

        return ceil(sampleString.size(withAttributes: [.font: font]).width) + extra
    }
    
    private var wrongGlyphWidth: CGFloat {
        columnWidth(for: .title3, extra: 0, sample: "WI", fontName: settings.aurebeshFont)
    }

    private var wrongLatinWidth: CGFloat {
        columnWidth(for: .title3, extra: 4, sample: "WW", fontName: "EnglishStandard")
    }
    
    private var wrongNameWidth: CGFloat {
        columnWidth(for: .title3, extra: 0, sample: "ZEREK ", fontName: "EnglishStandard")
    }
    
    var resultsView: some View {
        VStack(spacing: 24) {
            Text("Trials Complete!")
                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .title1).pointSize))
                .foregroundColor(settings.accentColor.color)

            Text("✅ \(correctCount) correct")
                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                .foregroundColor(.green)

            Text("❌ \(incorrectCount) incorrect")
                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                .foregroundColor(.red)

            if !wrongItems.isEmpty {
                List(wrongItems, id: \.symbol) { item in
                    HStack(alignment: .firstTextBaseline) {
                        Text(item.symbol)
                            .font(.custom(aurebeshDigraphFont, size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                            .frame(width: wrongGlyphWidth, alignment: .center)
                            .foregroundColor(settings.accentColor.color)
                        
                        Spacer()
                        
                        Text(item.correctName)
                            .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                            .frame(width: useAurebeshNames ? wrongNameWidth : wrongLatinWidth, alignment: .center)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(Color.clear)
                }
                .transparentList()
            } else {
                PerfectScoreView()
            }
            
            Spacer()

            Button(action: {
                if settings.hapticOn { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                
                withAnimation(.smooth) {
                    finished = false
                    started = false
                    wrongItems.removeAll()
                    correctCount = 0
                    incorrectCount = 0
                }
            }) {
                Text("Start Another Trial")
                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
                    .conditionalGlassEffect()
            }
        }
    }

    func startQuiz() {
        var pool: [QuizItem] = []
        
        wrongItems.removeAll()

        useTextField = switch useTextFieldPicker {
            case 0: true
            case 1: false
            default: Bool.random()
        }
        
        useAurebeshAnswers = switch useAurebeshAnswersPicker {
            case 0: true
            case 1: false
            default: Bool.random()
        }
        
        if includeLetters {
            let letters = aurebeshLetters.map {
                let answer = useAurebeshNames ? $0.name : $0.symbol
                return QuizItem(symbol: $0.symbol, correctName: answer, choices: [])
            }
            pool.append(contentsOf: letters)
        }

        if includeDigraphs && settings.aurebeshFont.contains("Aurebesh") {
            let digraphs = digraphLetters.map {
                let answer = useAurebeshNames ? $0.name : $0.symbol
                return QuizItem(symbol: $0.symbol, correctName: answer, choices: [])
            }
            pool.append(contentsOf: digraphs)
        }

        var unique = [String: QuizItem]()
        pool.forEach { unique[$0.symbol] = $0 }
        pool = Array(unique.values)

        pool.shuffle()
        let selected = pool.prefix(min(numberOfQuestions, pool.count))

        quizItems = selected.map { item in
            let distractors = pool.filter { $0.correctName != item.correctName }
                                  .map { $0.correctName }
                                  .shuffled()
                                  .prefix(3)

            let choices = ([item.correctName] + distractors).shuffled()

            return QuizItem(
                symbol: item.symbol,
                correctName: item.correctName,
                choices: Array(choices)
            )
        }

        started = true
        currentIndex = 0
        answerStatus = nil
        showAnswer = false
        correctCount = 0
        incorrectCount = 0
    }
}

struct QuizItem {
    let symbol: String
    let correctName: String
    let choices: [String]
}

struct PerfectScoreView: View {
    @EnvironmentObject var settings: Settings

    @State private var pulse = false
    @State private var angle: Double = 0

    private let rotateDuration = 1.75
    private let pulseDuration = 1.0

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                ZStack {
                    ForEach([2.4, 1.8], id: \.self) { scale in
                        Circle()
                            .stroke(
                                settings.accentColor.color.opacity(scale == 2.4 ? 0.6 : 0.4),
                                lineWidth: 4
                            )
                            .scaleEffect(pulse ? CGFloat(scale) : 0.3)
                            .opacity(pulse ? 0 : 1)
                            .animation(
                                .easeOut(duration: scale == 2.4 ? pulseDuration + 0.2 : pulseDuration)
                                    .delay(scale == 2.4 ? 0.4 : 0.1),
                                value: pulse
                            )
                    }
                    
                    settings.accentColor.image
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(angle))
                        .shadow(color: settings.accentColor.color.opacity(0.9), radius: 10)
                        .overlay {
                            settings.accentColor.image
                                .frame(width: 125, height: 125)
                                .blur(radius: 16)
                                .opacity(pulse ? 0.25 : 0.05)
                                .scaleEffect(pulse ? 1.4 : 1)
                                .animation(.easeInOut(duration: pulseDuration), value: pulse)
                        }
                }

                VStack(spacing: 6) {
                    Text("Perfect Score! Congratulations!")
                        .font(.custom(settings.aurebeshFont, size: UIFont.preferredFont(forTextStyle: .title2).pointSize))
                        .foregroundColor(settings.accentColor.color)

                    Text("Perfect Score! Congratulations!")
                        .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .headline).pointSize))
                        .foregroundColor(.primary)
                }
                .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
        .onAppear { startRotation() }
    }

    private func startRotation() {
        withAnimation(.linear(duration: rotateDuration)) { angle += 360 }

        DispatchQueue.main.asyncAfter(deadline: .now() + rotateDuration) {
            triggerPulse()
        }
    }

    private func triggerPulse() {
        pulse = true

        DispatchQueue.main.asyncAfter(deadline: .now() + pulseDuration) {
            pulse = false
            startRotation()
        }
    }
}
