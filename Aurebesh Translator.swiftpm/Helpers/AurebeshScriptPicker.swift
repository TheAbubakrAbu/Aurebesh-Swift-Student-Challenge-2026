import SwiftUI

struct AurebeshScriptPicker: View {
    @EnvironmentObject var settings: Settings
    
    let showBackground: Bool
    
    init(showBackground: Bool = false) {
        self.showBackground = showBackground
    }
    
    var body: some View {
        VStack {
            Picker("Picker Style", selection: $settings.pickerStyleSelection.animation(.smooth)) {
                Text("Aurebesh").tag("Aurebesh")
                Text("Mando'a").tag("Mando'a")
                Text("Outer Rim").tag("Outer Rim")
            }
            .pickerStyle(.segmented)
            .conditionalGlassEffect()
            .padding(.bottom, 2)
                
            if settings.pickerStyleSelection == "Aurebesh" {
                Picker("Aurebesh", selection: $settings.aurebeshFont.animation(.smooth)) {
                    Text("Basic").tag(settings.digraph ? "AurebeshBasicDigraph" : "AurebeshBasic")
                    Text("Core").tag(settings.digraph ? "AurebeshCoreDigraph" : "AurebeshCore")
                    Text("Droid").tag(settings.digraph ? "AurebeshDroidDigraph" : "AurebeshDroid")
                    Text("Nexus").tag(settings.digraph ? "AurebeshEquinoxDigraph" : "AurebeshEquinox")
                    Text("Cantina").tag(settings.digraph ? "AurebeshCantinaDigraph" : "AurebeshCantina")
                    Text("Pixel").tag(settings.digraph ? "AurebeshPixelDigraph" : "AurebeshPixel")
                }
                .pickerStyle(.segmented)
                .conditionalGlassEffect()
            } else if settings.pickerStyleSelection == "Mando'a" {
                Picker("Mando'a", selection: $settings.aurebeshFont.animation(.smooth)) {
                    Text("New Mando'a").tag("MandoNew")
                    Text("Old Mando'a").tag("MandoOld")
                }
                .pickerStyle(.segmented)
                .conditionalGlassEffect()
            } else if settings.pickerStyleSelection == "Outer Rim" {
                Picker("Outer Rim", selection: $settings.aurebeshFont.animation(.smooth)) {
                    Text("Basic").tag("OuterRimBasic")
                    Text("Tongue").tag("OuterRimTongue")
                    Text("Sith").tag("OuterRimSith")
                    Text("Hive").tag("OuterRimHive")
                    Text("Trade").tag("OuterRimTrade")
                    Text("Proto").tag("OuterRimProtobesh")
                }
                .pickerStyle(.segmented)
                .conditionalGlassEffect()
            }
        }
        .id(settings.refreshID)
    }
}
