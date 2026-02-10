import SwiftUI   // مهم جدًا
import Combine   // ضروري لـ ObservableObject

final class OnboardingViewModel: ObservableObject {

    @Published var currentPage: Int = 0

    let totalPages: Int = 3

    func next() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        }
    }

    func previous() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }

    func skip() {
        currentPage = totalPages - 1
    }
}
