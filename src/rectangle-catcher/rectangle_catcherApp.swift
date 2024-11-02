import SwiftUI

@main
struct rectangle_catcherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 320, height: 375)
        }
        .windowResizability(.contentSize)
    }
}
