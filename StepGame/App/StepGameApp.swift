import SwiftUI

// MARK: - App Entry
//@main
//struct StepGameApp: App {
    @main
    struct StepGameApp: App {
        var body: some Scene {
            WindowGroup {
                NavigationStack {
                    EnterNameView()
                }
            }
        }
    }
