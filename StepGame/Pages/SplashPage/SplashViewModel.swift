
import SwiftUI
import Combine   // ←    
final class SplashViewModel: ObservableObject {

    @Published var showNext: Bool = false

    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showNext = true
        }
    }
}
