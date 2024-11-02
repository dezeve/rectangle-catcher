import SwiftUI

struct ContentView: View {
    
    @State private var screenshotImage: NSImage? = nil
    @State private var screenshotTypeIndex = 0
    @State private var screenshotTypes = ["Full", "Window", "Area"]
    @State private var showScreenshotNotFoundAlert: Bool = false
    @State private var screenshotPreviewIndex = 0
    @State private var screenshotPreviewOptions = ["No", "Yes"]
    
    var body: some View {
        VStack {
            if let screenshotImage = screenshotImage {
                Image(nsImage: screenshotImage)
                    .resizable()
                    .scaledToFit()
                    .onDrag({NSItemProvider(object: screenshotImage)})
            }
            
            if screenshotImage == nil {
                Spacer()
                Text("No screenshots taken yet. For taking a screenshot, click on the \"Take a Screenshot\" button.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            HStack {
                Button("Take a Screenshot") {
                    runScreenshotProcess()
                }
                .buttonStyle(.borderedProminent)
                Button("Save Screenshot") {
                    if (screenshotImage == nil) {
                        showScreenshotNotFoundAlert = true
                    } else {
                        saveScreenshot()
                    }
                }
                .alert(isPresented: $showScreenshotNotFoundAlert) {
                    Alert(title: Text("Screenshot Not Found"), message: Text("Take a screenshot and try again"))
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(15)
            
            Text("Screenshot Settings")
                .font(.title3)
            Picker("Type:", selection: $screenshotTypeIndex) {
                ForEach(0..<3) { index in
                    Text(self.screenshotTypes[index]).tag(index)
                }
            }
                .pickerStyle(SegmentedPickerStyle())
                .padding(5)
            Picker("Display in Preview:", selection: $screenshotPreviewIndex) {
                ForEach(0..<2) { index in
                    Text(self.screenshotPreviewOptions[index]).tag(index)
                }
            }
                .pickerStyle(SegmentedPickerStyle())
                .padding(5)
        }
        .padding()
    }
    
    func runScreenshotProcess() {
        let screenshotProcess = Process()
        screenshotProcess.executableURL = URL(
            fileURLWithPath: "/usr/sbin/screencapture")
        var screenshotArguments = getScreenshotArguments()
        if (screenshotPreviewIndex == 1) {
            screenshotArguments = screenshotArguments + "P"
        }
        screenshotProcess.arguments = [screenshotArguments]
        
        do {
            try screenshotProcess.run()
            screenshotProcess.waitUntilExit()
            getScreenshotImageFromPasteboard()
        } catch {
            print("Error! Could not take screenshot: \(error)")
        }
    }
    
    func getScreenshotImageFromPasteboard() {
        guard NSPasteboard.general.canReadItem(
            withDataConformingToTypes:NSImage.imageTypes)
        else { return }
        
        guard let screenshotImage = NSImage(
            pasteboard: NSPasteboard.general)
        else { return }
        
        self.screenshotImage = screenshotImage
    }
    
    func getScreenshotArguments() -> String {
        switch screenshotTypeIndex {
        case 1:
            return "-cw"
        case 2:
            return "-cs"
        default:
            return "-c"
        }
    }
    
    func saveScreenshot() {
        let savePanel = NSSavePanel()
        
        savePanel.allowedContentTypes = [.jpeg]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = true
        savePanel.title = "Save Screenshot"
        savePanel.message = "Save screenshot to a JPEG file"
        savePanel.nameFieldLabel = "File Name"
        
        if savePanel.runModal() == .OK {
            let fileURL = savePanel.url!
            
            do {
                print(fileURL)
                let imageData = screenshotImage?.tiffRepresentation!
                try imageData?.write(to: fileURL)
            } catch {
                print("Error! Could not save screenshot: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
