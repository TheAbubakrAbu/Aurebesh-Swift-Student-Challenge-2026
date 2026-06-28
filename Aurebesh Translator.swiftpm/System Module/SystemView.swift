import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        #if !os(watchOS)
        HoloCard {
            VStack {
                SettingsList()
            }
        }
        #else
        HoloCard {
            NavigationView {
                SettingsList()
                    .navigationTitle("System")
            }
        }
        #endif
    }
}

struct SettingsList: View {
    @EnvironmentObject var settings: Settings
    
    @State private var showingCredits = false
        
    var body: some View {
        List {
            Group {
                VStack(alignment: .leading) {
                    Toggle("Use \(settings.pickerStyleSelection) throughout Datapad", isOn: $settings.useAurebesh.animation(.smooth))
                        .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    
                    Text("⚠️ Enabling this will switch most of Datapad into \(settings.pickerStyleSelection), which may be difficult to read.")
                        .font(.custom("EnglishStandard", size: UIFont.preferredFont(forTextStyle: .caption2).pointSize))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                Section(header: Text("TRANSCODER SETTINGS").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                    VStack(alignment: .leading) {
                        #if !os(watchOS)
                        HStack {
                            Text("English Font")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            
                            Spacer()
                            
                            Text("TEXT PREVIEW")
                                .font(.custom(settings.englishFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                .foregroundColor(settings.accentColor.color)
                        }
                        
                        Text("English Font is only supported for Transocder and Transmit.")
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        #endif
                        
                        Picker("English Font", selection: $settings.englishFont.animation(.smooth)) {
                            Text("Standard").tag("EnglishStandard")
                            Text("Galactic").tag("EnglishGalactic")
                            Text("Canon").tag("EnglishCanon")
                        }
                        .id(settings.refreshID)
                        #if !os(watchOS)
                        .pickerStyle(.segmented)
                        #else
                        .padding(.horizontal, 8)
                        #endif
                        .conditionalGlassEffect()
                        .padding(.top, 2)
                    }
                    
                    #if os(watchOS)
                    Picker("Galactic Script", selection: $settings.aurebeshFont.animation(.smooth)) {
                        ForEach(Array(zip(aurebeshFonts.indices, aurebeshFonts)), id: \.0) { index, fontID in
                            let pretty = aurebeshFontNames[index]
                            let tag = (settings.digraph && fontID.hasPrefix("Aurebesh")) ? "\(fontID)Digraph" : fontID

                            Text(pretty).tag(tag)
                        }
                    }
                    .padding(.horizontal, 8)
                    .conditionalGlassEffect()
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(settings.pickerStyleSelection) Text Size: ")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            
                            Text("\(Int(settings.aurebeshFontSize))")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                .foregroundColor(settings.accentColor.color)
                                .padding(.leading, -6)
                        }
                        
                        Stepper(value: $settings.aurebeshFontSize.animation(.smooth), in: 15...50, step: 5) {}
                            .fixedSize()
                            .conditionalGlassEffect()
                    }
                    #else
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(settings.pickerStyleSelection) Text Size: ")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            
                            Text("\(Int(settings.aurebeshFontSize))")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                                .foregroundColor(settings.accentColor.color)
                                .padding(.leading, -6)
                            
                            Spacer()
                            
                            Stepper(value: $settings.aurebeshFontSize.animation(.smooth), in: 15...50, step: 5) {}
                                .fixedSize()
                                .conditionalGlassEffect()
                        }
                        
                        Slider(value: $settings.aurebeshFontSize.animation(.smooth), in: 15.0...50.0)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .conditionalGlassEffect()
                    }
                    #endif
                    
                    Toggle("Use System Font Size", isOn: $settings.useSystemFontSize.animation(.smooth))
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        .tint(settings.accentColor.color.opacity(0.5))
                        .onChange(of: settings.useSystemFontSize) { useSystemFontSize in
                            if useSystemFontSize {
                                settings.aurebeshFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize * 1.5
                            }
                        }
                        .onChange(of: settings.aurebeshFontSize) { newSize in
                            if newSize == UIFont.preferredFont(forTextStyle: .body).pointSize * 1.5 {
                                settings.useSystemFontSize = true
                            } else {
                                settings.useSystemFontSize = false
                            }
                        }
                    
                    VStack(alignment: .leading) {
                        Toggle("Use Aurebesh Digraphs", isOn: $settings.digraph.animation(.smooth))
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            .tint(settings.accentColor.color.opacity(0.5))
                            .onChange(of: settings.useSystemFontSize) { useSystemFontSize in
                                if useSystemFontSize {
                                    settings.aurebeshFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize * 1.5
                                }
                            }
                        
                        Text("Supported for Aurebesh only. Visit Databank to learn more.")
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                
                Section(header: Text("APPEARANCE SETTINGS").font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .body).pointSize))) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Galactic Background:")
                                .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            
                            Spacer()
                        }
                        
                        Picker("Galaxy Background", selection: $settings.galaxyMode.animation(.smooth)) {
                            ForEach(GalaxyBackgroundMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .conditionalGlassEffect()
                        .id(settings.refreshID)
                        
                        if settings.galaxyMode != .offMode {
                            Picker("Starfield Style", selection: $settings.starfieldStyle.animation(.smooth)) {
                                ForEach(StarfieldStyle.allCases) { style in
                                    Text(style.rawValue).tag(style)
                                }
                            }
                            .pickerStyle(.segmented)
                            .conditionalGlassEffect()
                            .id(settings.refreshID)
                            
                            Toggle("Use white for galaxy background", isOn: Binding(
                                get: { !settings.useAccentColorGalaxy },
                                set: { settings.useAccentColorGalaxy = !$0 }
                            ).animation(.smooth))
                            .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                            .tint(settings.accentColor.color.opacity(0.5))
                            .padding(.top, 10)
                        }
                    }
                    
                    Toggle("Show Launching Screen", isOn: Binding(
                        get: { !settings.skipLaunching },
                        set: { settings.skipLaunching = !$0 }
                    ).animation(.smooth))
                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    .tint(settings.accentColor.color.opacity(0.5))
                    
                    Toggle("Haptic Feedback", isOn: $settings.hapticOn.animation(.smooth))
                        .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                        .tint(settings.accentColor.color.opacity(0.5))
                }
            }
            .listRowBackground(Color.clear)
        }
        .transparentList()
        .animation(.smooth(duration: 1.0), value: settings.accentColor.color)
        .animation(.smooth(duration: 1.0), value: settings.crystal)
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

    private var glyphWidth: CGFloat {
        columnWidth(for: .subheadline, extra: 0, sample: settings.systemFont.contains("English") ? "Contact:" : "Website:", fontName: settings.systemFont)
    }
}

struct VersionNumber: View {
    @EnvironmentObject var settings: Settings
    
    var width: CGFloat?
    
    var body: some View {
        HStack {
            if let width = width {
                Text("Version:")
                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    .foregroundColor(settings.accentColor.color)
                    .multilineTextAlignment(.leading)
                    .frame(width: width)
                
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .padding(4)
                    .padding(.horizontal, 2)
                    .font(.custom(settings.systemFont, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize))
                    .background(settings.accentColor.color.opacity(0.1))
                    .foregroundColor(settings.accentColor.color)
                    .cornerRadius(5)
                    .shadow(color: settings.accentColor.color.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(settings.accentColor.color, lineWidth: 5)
                            .shadow(color: settings.accentColor.color, radius: 10, x: 0.0, y: 0.0)
                            .blur(radius: 5)
                            .opacity(0.35)
                    )
                    .multilineTextAlignment(.leading)
                    .padding(.leading, -4)
            } else {
                Text("Version")
                
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .foregroundColor(settings.accentColor.color)
                    .padding(.leading, -4)
            }
        }
        .foregroundColor(.primary)
    }
}
