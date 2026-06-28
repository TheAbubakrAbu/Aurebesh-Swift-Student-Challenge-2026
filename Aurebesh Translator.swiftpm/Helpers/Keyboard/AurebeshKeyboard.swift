import SwiftUI
import Combine
import UIKit

struct AurebeshKeyboardView: View {
    let showGlobeButton: Bool
    weak var parentController: UIInputViewController?
    
    public init(
        onKeyPress: @escaping (String) -> Void,
        onDeletePress: @escaping () -> Void,
        onSpacePress: @escaping () -> Void,
        onReturnPress: @escaping () -> Void,
        
        accentColor: Color = .primary,
        aurebeshFont: String = "AurebeshBasic",
        showCrystalScriptButton: Bool = true,
        showGlobeButton: Bool = false,
        parentController: UIInputViewController? = nil
    ) {
        self.onKeyPress = onKeyPress
        self.onDeletePress = onDeletePress
        self.onSpacePress = onSpacePress
        self.onReturnPress = onReturnPress
        
        self.accentColor = accentColor
        self.aurebeshFont = aurebeshFont
        self.showCrystalScriptButton = showCrystalScriptButton
        self.showGlobeButton = showGlobeButton
        self.parentController = parentController
        
        if showCrystalScriptButton {
            alphabetRows.append(["123", "Space", "Return"])
            numericRows.append(["abc", "Color", "Space", "Aurebesh", "Return"])
            symbolRows.append(["abc", "Color", "Space", "Aurebesh", "Return"])
        } else {
            alphabetRows.append(["123", "Space", "Return"])
            numericRows.append(["abc", "Space", "Return"])
            symbolRows.append(["abc", "Space", "Return"])
        }
    }
    
    var onKeyPress: (String) -> Void
    var onDeletePress: () -> Void
    var onSpacePress: () -> Void
    var onReturnPress: () -> Void
    
    @State var accentColor: Color
    @State var aurebeshFont: String
    var showCrystalScriptButton: Bool
    
    @AppStorage("accentColorIndex") private var accentColorIndexData: Int = 0
    @AppStorage("aurebeshFontIndex") private var aurebeshFontIndexData: Int = 0

    @State private var isShiftActive: Bool = false
    @State private var isCapsLockActive: Bool = false
    @State private var isNumeric: Bool = false
    @State private var isSymbols: Bool = false

    @State private var lastShiftTap: Date? = nil
    private let shiftTapThreshold: TimeInterval = 0.5

    @State private var autoRepeatTimer: Timer?

    private var alphabetRows: [[String]] = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        ["Shift", "z", "x", "c", "v", "b", "n", "m", "Delete"],
    ]
    
    private var numericRows: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
        ["#+=", ".", ",", "?", "!", "'", "Delete"],
    ]
    
    private var symbolRows: [[String]] = [
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
        ["123", ".", ",", "?", "!", "'", "Delete"]
    ]
    
    private var currentRows: [[String]] {
        if isSymbols {
            return symbolRows
        } else if isNumeric {
            return numericRows
        } else {
            return alphabetRows
        }
    }
    
    private func isSpecialKey(_ key: String) -> Bool {
        return [
            "Shift", "Delete", "123", "abc", "Space", "Return",
            "#+=", ".", "Color", "Aurebesh"
        ].contains(key)
    }
    
    private func displayLabel(for key: String) -> String {
        switch key {
        case "Space":
            return "space"
        case "Delete", "Shift", "123", "abc", "Return", "#+=", "Color", "Aurebesh":
            return key
        default:
            return key.lowercased()
        }
    }
    
    private func handleKeyPress(_ key: String) {
        withAnimation(.spring(duration: 0.35)) {
            switch key {
            case "Shift":
                handleShiftTap()
            case "Delete":
                onDeletePress()
            case "123":
                isNumeric = true
                isSymbols = false
                isShiftActive = false
                isCapsLockActive = false
            case "abc":
                isNumeric = false
                isSymbols = false
                isShiftActive = false
                isCapsLockActive = false
            case "#+=":
                isSymbols = true
                isNumeric = false
                isShiftActive = false
                isCapsLockActive = false
            case "Color":
                cycleAccentColor()
            case "Aurebesh":
                cycleAurebeshFont()
            case "Space":
                onSpacePress()
                if isNumeric || isSymbols {
                    isNumeric = false
                    isSymbols = false
                }
            case "Return":
                onReturnPress()
                if isNumeric || isSymbols {
                    isNumeric = false
                    isSymbols = false
                }
            default:
                let output = (isShiftActive || isCapsLockActive) ? key.uppercased() : key.lowercased()
                onKeyPress(output)
                if isShiftActive && !isCapsLockActive {
                    isShiftActive = false
                }
            }
        }
    }
    
    private func handleShiftTap() {
        let now = Date()
        withAnimation(.spring(duration: 0.35)) {
            if isCapsLockActive {
                isCapsLockActive = false
                isShiftActive = false
            } else if let lastTap = lastShiftTap, now.timeIntervalSince(lastTap) < shiftTapThreshold {
                isCapsLockActive = true
                isShiftActive = false
                lastShiftTap = nil
            } else {
                isShiftActive.toggle()
                isCapsLockActive = false
                lastShiftTap = now
            }
        }
    }
    
    private func startAutoRepeat(for key: String) {
        guard key == "Delete" else { return }
        
        autoRepeatTimer?.invalidate()
        autoRepeatTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.autoRepeatTimer?.invalidate()
            self.autoRepeatTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.onDeletePress()
            }
        }
    }
    
    private func stopAutoRepeat() {
        autoRepeatTimer?.invalidate()
        autoRepeatTimer = nil
    }
    
    @State private var accentColorIndex: Int = 0
    @State private var aurebeshFontIndex: Int = 0

    private func cycleAccentColor() {
        withAnimation(.smooth) {
            accentColorIndex = (accentColorIndex + 1) % keyAccentColors.count
            accentColorIndexData = accentColorIndex
        }
    }

    private func cycleAurebeshFont() {
        withAnimation(.smooth) {
            aurebeshFontIndex = (aurebeshFontIndex + 1) % aurebeshFonts.count
            aurebeshFontIndexData = aurebeshFontIndex
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 5
            let keyWidth = (geometry.size.width - (spacing * CGFloat(10 + 2))) / 10
            let keyHeight: CGFloat = 44

            VStack(alignment: .center, spacing: 0) {
                ForEach(Array(currentRows.enumerated()), id: \.offset) { rowIndex, row in
                    HStack(alignment: .center, spacing: 0) {
                        switch rowIndex {
                        case 0, 1:
                            if rowIndex == 1 && !isNumeric && !isSymbols {
                                Spacer()
                            }
                            ForEach(row, id: \.self) { key in
                                KeyButton(
                                    width: keyWidth,
                                    height: keyHeight,
                                    keyLabel: displayLabel(for: key),
                                    isSpecialKey: isSpecialKey(key),
                                    isShiftActive: isShiftActive,
                                    isCapsLockActive: isCapsLockActive,
                                    action: { handleKeyPress(key) },
                                    accentColorIndex: $accentColorIndex,
                                    aurebeshFontIndex: $aurebeshFontIndex,
                                    accentColorBinding: $accentColor,
                                    aurebeshFontBinding: $aurebeshFont,
                                    showCrystalScriptButton: showCrystalScriptButton
                                )
                            }
                            if rowIndex == 1 && !isNumeric && !isSymbols {
                                Spacer()
                            }
                            
                        case 2:
                            let firstKey = row.first!
                            let keyLabel = firstKey == "123" ? "1234" : displayLabel(for: firstKey)
                            KeyButton(
                                width: geometry.size.width < 500 ? keyHeight * 0.96 : keyHeight * 2,
                                height: keyHeight,
                                keyLabel: keyLabel,
                                isSpecialKey: true,
                                isShiftActive: isShiftActive,
                                isCapsLockActive: isCapsLockActive,
                                action: { handleKeyPress(firstKey) },
                                accentColorIndex: $accentColorIndex,
                                aurebeshFontIndex: $aurebeshFontIndex,
                                accentColorBinding: $accentColor,
                                aurebeshFontBinding: $aurebeshFont,
                                showCrystalScriptButton: showCrystalScriptButton
                            )
                            
                            Spacer()
                            
                            ForEach(row.dropFirst().dropLast(), id: \.self) { key in
                                KeyButton(
                                    width: (isNumeric || isSymbols) ? keyHeight : keyWidth,
                                    height: keyHeight,
                                    keyLabel: displayLabel(for: key),
                                    isSpecialKey: isSpecialKey(key),
                                    isShiftActive: isShiftActive,
                                    isCapsLockActive: isCapsLockActive,
                                    action: { handleKeyPress(key) },
                                    accentColorIndex: $accentColorIndex,
                                    aurebeshFontIndex: $aurebeshFontIndex,
                                    accentColorBinding: $accentColor,
                                    aurebeshFontBinding: $aurebeshFont,
                                    showCrystalScriptButton: showCrystalScriptButton
                                )
                            }
                            
                            Spacer()
                            
                            let lastKey = row.last!
                            KeyButton(
                                width: geometry.size.width < 500 ? keyHeight * 0.96 : keyHeight * 2,
                                height: keyHeight,
                                keyLabel: displayLabel(for: lastKey),
                                isSpecialKey: true,
                                isShiftActive: isShiftActive,
                                isCapsLockActive: isCapsLockActive,
                                action: { handleKeyPress(lastKey) },
                                accentColorIndex: $accentColorIndex,
                                aurebeshFontIndex: $aurebeshFontIndex,
                                accentColorBinding: $accentColor,
                                aurebeshFontBinding: $aurebeshFont,
                                showCrystalScriptButton: showCrystalScriptButton
                            )
                            .onPressHold {
                                startAutoRepeat(for: lastKey)
                            } onPressRelease: {
                                stopAutoRepeat()
                            }
                            
                        default:
                            let originalRow = row
                            let finalRow: [String] = {
                                guard showGlobeButton else { return originalRow }
                                if originalRow.count == 5,
                                   (originalRow[0] == "123" || originalRow[0] == "abc"),
                                   originalRow[1] == "Color",
                                   originalRow[2] == "Space",
                                   originalRow[3] == "Aurebesh",
                                   originalRow[4] == "Return"
                                {
                                    return [
                                        originalRow[0],
                                        "Globe",
                                        originalRow[1],
                                        originalRow[2],
                                        originalRow[3],
                                        originalRow[4]
                                    ]
                                } else if originalRow.count == 3,
                                      (originalRow[0] == "123" || originalRow[0] == "abc"),
                                      originalRow[1] == "Space",
                                      originalRow[2] == "Return"
                                   {
                                       return [
                                           originalRow[0],
                                           "Globe",
                                           originalRow[1],
                                           originalRow[2]
                                       ]
                                   }
                                
                                
                                return originalRow
                            }()
                            
                            HStack(alignment: .center, spacing: 4) {
                                let totalUnits = CGFloat(showGlobeButton ? 6.08 : 6)
                                let unitWidth = (geometry.size.width - spacing * 4) / totalUnits
                                let newKeyWidth = (geometry.size.width - spacing * 4) / 4
                                
                                ForEach(finalRow, id: \.self) { key in
                                    switch key {
                                        
                                    case "123", "abc":
                                        if finalRow.count == 5 {
                                            KeyButton(
                                                width: showGlobeButton ? unitWidth * 0.66 : unitWidth * 1.325,
                                                height: keyHeight - 2,
                                                keyLabel: displayLabel(for: key),
                                                isSpecialKey: isSpecialKey(key),
                                                isShiftActive: isShiftActive,
                                                isCapsLockActive: isCapsLockActive,
                                                action: { handleKeyPress(key) },
                                                accentColorIndex: $accentColorIndex,
                                                aurebeshFontIndex: $aurebeshFontIndex,
                                                accentColorBinding: $accentColor,
                                                aurebeshFontBinding: $aurebeshFont,
                                                showCrystalScriptButton: showCrystalScriptButton
                                            )
                                        } else {
                                            KeyButton(
                                                width: .infinity,
                                                height: keyHeight - 2,
                                                keyLabel: displayLabel(for: key),
                                                isSpecialKey: isSpecialKey(key),
                                                isShiftActive: isShiftActive,
                                                isCapsLockActive: isCapsLockActive,
                                                action: { handleKeyPress(key) },
                                                accentColorIndex: $accentColorIndex,
                                                aurebeshFontIndex: $aurebeshFontIndex,
                                                accentColorBinding: $accentColor,
                                                aurebeshFontBinding: $aurebeshFont,
                                                showCrystalScriptButton: showCrystalScriptButton
                                            )
                                            .padding(.leading, 2.9)
                                        }
                                        
                                    case "Globe":
                                        GlobeButton2(
                                            parentVC: parentController,
                                            width: unitWidth * 0.6,
                                            height: keyHeight - 2,
                                            accentColorIndex: $accentColorIndex
                                        )
                                        .padding(.trailing, 3)
                                        
                                    case "Color":
                                        ColorButton(
                                            width: unitWidth * 0.563,
                                            height: keyHeight - 2,
                                            color: keyAccentColors[accentColorIndex],
                                            action: cycleAccentColor,
                                            selectedAccentIndex: $accentColorIndex,
                                            persistedAccentIndex: $accentColorIndexData
                                        )
                                        
                                    case "Space":
                                        if finalRow.count == 5 {
                                            KeyButton(
                                                width: unitWidth * 2,
                                                height: keyHeight - 2,
                                                keyLabel: displayLabel(for: key),
                                                isSpecialKey: isSpecialKey(key),
                                                isShiftActive: isShiftActive,
                                                isCapsLockActive: isCapsLockActive,
                                                action: { handleKeyPress(key) },
                                                accentColorIndex: $accentColorIndex,
                                                aurebeshFontIndex: $aurebeshFontIndex,
                                                accentColorBinding: $accentColor,
                                                aurebeshFontBinding: $aurebeshFont,
                                                showCrystalScriptButton: showCrystalScriptButton
                                            )
                                        } else {
                                            KeyButton(
                                                width: newKeyWidth * 2.02,
                                                height: keyHeight - 2,
                                                keyLabel: displayLabel(for: key),
                                                isSpecialKey: isSpecialKey(key),
                                                isShiftActive: isShiftActive,
                                                isCapsLockActive: isCapsLockActive,
                                                action: { handleKeyPress(key) },
                                                accentColorIndex: $accentColorIndex,
                                                aurebeshFontIndex: $aurebeshFontIndex,
                                                accentColorBinding: $accentColor,
                                                aurebeshFontBinding: $aurebeshFont,
                                                showCrystalScriptButton: showCrystalScriptButton
                                            )
                                        }
                                        
                                    case "Aurebesh":
                                        AurebeshButton(
                                            width: unitWidth * 0.563,
                                            height: keyHeight - 2,
                                            fontName: aurebeshFonts[aurebeshFontIndex],
                                            action: cycleAurebeshFont,
                                            color: keyAccentColors[accentColorIndex],
                                            selectedFontIndex: $aurebeshFontIndex,
                                            persistedFontIndex: $aurebeshFontIndexData
                                        )
                                        
                                    case "Return":
                                        if finalRow.count == 5 {
                                            KeyButton(
                                                width: unitWidth * 1.325,
                                                height: keyHeight - 2,
                                                keyLabel: displayLabel(for: key),
                                                isSpecialKey: isSpecialKey(key),
                                                isShiftActive: isShiftActive,
                                                isCapsLockActive: isCapsLockActive,
                                                action: { handleKeyPress(key) },
                                                accentColorIndex: $accentColorIndex,
                                                aurebeshFontIndex: $aurebeshFontIndex,
                                                accentColorBinding: $accentColor,
                                                aurebeshFontBinding: $aurebeshFont,
                                                showCrystalScriptButton: showCrystalScriptButton
                                            )
                                        } else {
                                            KeyButton(
                                                width: .infinity,
                                                height: keyHeight - 2,
                                                keyLabel: displayLabel(for: key),
                                                isSpecialKey: isSpecialKey(key),
                                                isShiftActive: isShiftActive,
                                                isCapsLockActive: isCapsLockActive,
                                                action: { handleKeyPress(key) },
                                                accentColorIndex: $accentColorIndex,
                                                aurebeshFontIndex: $aurebeshFontIndex,
                                                accentColorBinding: $accentColor,
                                                aurebeshFontBinding: $aurebeshFont,
                                                showCrystalScriptButton: showCrystalScriptButton
                                            )
                                            .padding(.trailing, 2.9)
                                        }
                                        
                                    default:
                                        KeyButton(
                                            width: unitWidth,
                                            height: keyHeight - 2,
                                            keyLabel: displayLabel(for: key),
                                            isSpecialKey: isSpecialKey(key),
                                            isShiftActive: isShiftActive,
                                            isCapsLockActive: isCapsLockActive,
                                            action: { handleKeyPress(key) },
                                            accentColorIndex: $accentColorIndex,
                                            aurebeshFontIndex: $aurebeshFontIndex,
                                            accentColorBinding: $accentColor,
                                            aurebeshFontBinding: $aurebeshFont,
                                            showCrystalScriptButton: showCrystalScriptButton
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(minHeight: 217)
        .padding(.top, 3)
        .padding(.bottom, showGlobeButton ? 4 : 0)
        .onAppear {
            if showCrystalScriptButton {
                withAnimation(.smooth) {
                    accentColorIndex = accentColorIndexData
                    aurebeshFontIndex = aurebeshFontIndexData
                }
            }
        }
        .onChange(of: accentColorIndex) { new in
            accentColorIndexData = new
        }
        .onChange(of: aurebeshFontIndex) { new in
            aurebeshFontIndexData = new
        }
    }
}

struct KeyButton: View {
    let width: CGFloat
    let height: CGFloat
    let keyLabel: String
    let isSpecialKey: Bool
    let isShiftActive: Bool
    let isCapsLockActive: Bool
    var action: () -> Void
    
    @Binding var accentColorIndex: Int
    @Binding var aurebeshFontIndex: Int
    
    @Binding var accentColorBinding: Color
    @Binding var aurebeshFontBinding: String
    
    let showCrystalScriptButton: Bool
    
    var accentColor: Color {
        if showCrystalScriptButton {
            return keyAccentColors[accentColorIndex]
        } else {
            return accentColorBinding
        }
    }
    
    var aurebeshFont: String {
        if showCrystalScriptButton {
            return aurebeshFonts[aurebeshFontIndex]
        } else {
            return aurebeshFontBinding
        }
    }
        
    @State private var isPressed: Bool = false

    private var fontForKey: Font {
        if keyLabel == "1234" || keyLabel == "#+=" {
            return .custom(aurebeshFont, size: 15)
        } else {
            return .custom(aurebeshFont, size: 20)
        }
    }

    private func systemImageName(for key: String) -> String? {
        switch key {
        case "Delete":
            return "delete.backward.fill"
        case "Shift":
            if isCapsLockActive {
                return "capslock.fill"
            } else if isShiftActive {
                return "shift.fill"
            } else {
                return "shift"
            }
        case "Return":
            return "arrow.turn.down.left"
        default:
            return nil
        }
    }

    var body: some View {
        Button(action: {
            withAnimation(.smooth) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            }
        }) {
            ZStack {
                Rectangle()
                    .fill(Color.white.opacity(0.001))
                    .frame(width: width + 6, height: height + 12)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(accentColor.opacity(isPressed ? 0.4 : 0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(accentColor.opacity(0.4), lineWidth: 1)
                        )
                    
                    if isSpecialKey, let systemImage = systemImageName(for: keyLabel) {
                        Image(systemName: systemImage)
                            .font(fontForKey)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .padding(5)
                    } else {
                        let newKey = (keyLabel == "1234") ? "123" : keyLabel
                        Text(newKey)
                            .font(fontForKey)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .padding(5)
                        
                            .padding(.leading, aurebeshFont.contains("AurebeshBasic") ? 2 : 0)
                            .padding(.top, aurebeshFont.contains("AurebeshBasic") ? 2 : 0)
                        
                            .padding(.bottom, aurebeshFont.contains("AurebeshCore") ? 6 : 0)
                        
                            .padding(.bottom, aurebeshFont.contains("AurebeshCantina") ? 1 : 0)
                        
                            .padding(.top, aurebeshFont.contains("AurebeshEquinox") ? 5 : 0)
                        
                            .padding(.leading, aurebeshFont.contains("AurebeshPixel") ? 1 : 0)
                            .padding(.bottom, aurebeshFont.contains("AurebeshPixel") ? 7 : 0)
                        
                            .padding(.top, aurebeshFont.contains("Mando") ? 4 : 0)
                    }
                }
                .frame(maxWidth: width, maxHeight: height)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(duration: 0.05), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(duration: 0.05)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(duration: 0.05)) {
                        isPressed = false
                    }
                }
        )
    }
}

struct ColorButton: View {
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let action: () -> Void

    @Binding var selectedAccentIndex: Int
    @Binding var persistedAccentIndex: Int

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.smooth) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            }
        }) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.4), lineWidth: 1)
                )
                .overlay(
                    Image("Crystal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width * 0.75, height: height * 0.75)
                        .overlay {
                            LinearGradient(
                                gradient: Gradient(colors: [color]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(
                                Image("Crystal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            )
                            .opacity(0.55)
                        }
                )
                .frame(width: width, height: height)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            ForEach(keyAccentColors.indices, id: \.self) { i in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.smooth) {
                        selectedAccentIndex = i
                        persistedAccentIndex = i
                    }
                } label: {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(keyAccentColors[i])
                            .frame(width: 16, height: 16)
                        
                        Text((i < keyAccentColorNames.count) ? keyAccentColorNames[i] : "Color \(i+1)")
                        
                        if i == selectedAccentIndex {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}


struct AurebeshButton: View {
    let width: CGFloat
    let height: CGFloat
    let fontName: String
    let action: () -> Void
    let color: Color

    @Binding var selectedFontIndex: Int
    @Binding var persistedFontIndex: Int

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.smooth) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            }
        }) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.4), lineWidth: 1)
                )
                .overlay(
                    Text("a")
                        .fontWeight(.bold)
                        .font(.custom(fontName, size: 20))
                        .foregroundColor(.primary)
                        .padding(.leading, fontName.contains("AurebeshBasic") ? 2 : 0)
                        .padding(.top, fontName.contains("AurebeshBasic") ? 2 : 0)
                )
                .frame(width: width, height: height)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            ForEach(aurebeshFontNames.indices, id: \.self) { i in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.smooth) {
                        selectedFontIndex = i
                        persistedFontIndex = i
                    }
                } label: {
                    HStack {
                        if i == selectedFontIndex {
                            Image(systemName: "checkmark")
                            
                            Spacer()
                        }
                        
                        Text(aurebeshFontNames[i])
                            .font(.custom(aurebeshFonts[i], size: 16))
                    }
                }
            }
        }
    }
}

extension View {
    func onPressHold(onPress: @escaping () -> Void, onPressRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onPressRelease() }
        )
    }
}
