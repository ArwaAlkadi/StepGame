//
//import SwiftUI
//import FirebaseFirestore
//import FirebaseAuth
//
//// dummy data
//let USE_DUMMY_DATA = true
//
//struct SetupChallengeView: View {
//    let playerName: String
//    @Environment(\.dismiss) var dismiss
//
//    @State private var challengeName: String = ""
//    @State private var selectedPeriod: ChallengePeriod = .threeDays
//    @State private var stepGoal: Double = 1000
//    @State private var selectedMode: ChallengeMode = .solo
//    @State private var showShareCodePopup = false
//    @State private var generatedJoinCode = ""
//    @State private var isCreating = false
//
//    private let maxChallengeNameLength = 20
//    private let minSteps = 1000.0
//    private let maxSteps = 500000.0
//
//    enum ChallengePeriod: String, CaseIterable {
//        case threeDays = "3 Days"
//        case week = "Week"
//        case month = "Month"
//
//        var days: Int {
//            switch self {
//            case .threeDays: return 3
//            case .week: return 7
//            case .month: return 30
//            }
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            // Modal Card
//            VStack(spacing: 0) {
//                // Header with close button
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        dismiss()
//                    }) {
//                        ZStack {
//                            Circle()
//                                .fill(Color("Light1"))
//                                .frame(width: 35, height: 35)
//
//                            Image(systemName: "xmark")
//                                .font(.system(size: 16, weight: .bold))
//                                .foregroundColor(.white)
//                        }
//                    }
//                    .padding(.trailing, 15)
//                    .padding(.top, 15)
//                }
//
//                // Title
//                Text("Create a New Challenge")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .font(.custom("RussoOne-Regular", size: 22))
//                    .foregroundColor(Color("Light1"))
//                    .padding(.top, 5)
//                    .padding(.bottom, 20)
//
//                VStack(alignment: .leading, spacing: 20) {
//
//                    // Challenge Name Input
//                    VStack(alignment: .leading, spacing: 5) {
//                        TextField("Challenge Name", text: $challengeName)
//                            .font(.custom("RussoOne-Regular", size: 15))
//                            .foregroundColor(Color("Light1"))
//                            .padding()
//                            .background(Color("Light2").opacity(0.2))
//                            .cornerRadius(23)
//                            .onChange(of: challengeName) { _, newValue in
//                                if newValue.count > maxChallengeNameLength {
//                                    challengeName = String(newValue.prefix(maxChallengeNameLength))
//                                }
//                            }
//
//                        Text("\(challengeName.count)/\(maxChallengeNameLength)")
//                            .font(.custom("RussoOne-Regular", size: 11))
//                            .foregroundColor(Color("Light1").opacity(0.6))
//                            .padding(.leading, 5)
//                    }
//
//                    // Period Selection
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Period")
//                            .font(.custom("RussoOne-Regular", size: 16))
//                            .foregroundColor(Color("Light1"))
//
//                        HStack(spacing: 12) {
//                            ForEach(ChallengePeriod.allCases, id: \.self) { period in
//                                Button(action: {
//                                    selectedPeriod = period
//                                }) {
//                                    Text(period.rawValue)
//                                        .font(.custom("RussoOne-Regular", size: 15))
//                                        .foregroundColor(selectedPeriod == period ? .white : Color("Light1"))
//                                        .frame(width: 90, height: 40)
//                                        .background(
//                                            selectedPeriod == period ? Color("Light1") : Color.white
//                                        )
//                                        .cornerRadius(20)
//                                }
//                            }
//                        }
//                    }
//
//                    // Steps Slider
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Steps")
//                            .font(.custom("RussoOne-Regular", size: 16))
//                            .foregroundColor(Color("Light1"))
//
//                        VStack(spacing: 6) {
//
//                            // MARK: UPDATED - Replaced default Slider with custom flat slider (no glass)
//                            CustomStepSlider(
//                                value: $stepGoal,
//                                min: minSteps,
//                                max: maxSteps,
//                                step: 1000,
//                                fillColor: Color("Light1"),
//                                trackColor: Color.white
//                            )
//                            .frame(height: 30)
//
//                            HStack {
//                                Text("\(Int(minSteps).formatted())")
//                                    .font(.custom("RussoOne-Regular", size: 11))
//                                    .foregroundColor(Color("Light1").opacity(0.6))
//
//                                Spacer()
//
//                                Text("\(Int(stepGoal).formatted())")
//                                    .font(.custom("RussoOne-Regular", size: 15))
//                                    .foregroundColor(Color("Light1"))
//
//                                Spacer()
//
//                                Text("\(Int(maxSteps).formatted())")
//                                    .font(.custom("RussoOne-Regular", size: 11))
//                                    .foregroundColor(Color("Light1").opacity(0.6))
//                            }
//                        }
//                    }
//
//                    // Mode Selection
//                    HStack(spacing: 25) {
//                        // Solo Mode
//                        Button(action: {
//                            selectedMode = .solo
//                        }) {
//                            HStack(spacing: 8) {
//                                Image(systemName: "person.fill")
//                                    .font(.system(size: 16))
//                                Text("Solo")
//                                    .font(.custom("RussoOne-Regular", size: 15))
//                            }
//                            .foregroundColor(selectedMode == .solo ? .white : Color("Light1"))
//                            .frame(width: 120, height: 40)
//                            .background(
//                                selectedMode == .solo ? Color("Light1") : Color.white
//                            )
//                            .cornerRadius(25)
//                        }
//
//                        // Group Mode
//                        Button(action: {
//                            selectedMode = .social
//                        }) {
//                            HStack(spacing: 8) {
//                                Image(systemName: "person.2.fill")
//                                    .font(.system(size: 16))
//                                Text("Group")
//                                    .font(.custom("RussoOne-Regular", size: 15))
//                            }
//                            .foregroundColor(selectedMode == .social ? .white : Color("Light1"))
//                            .frame(width: 120, height: 40)
//                            .background(
//                                selectedMode == .social ? Color("Light1") : Color.white
//                            )
//                            .cornerRadius(25)
//                        }
//                    }
//                    .frame(maxWidth: .infinity, alignment: .center)
//
//                    // Create Button
//                    Button(action: {
//                        Task {
//                            await createChallenge()
//                        }
//                    }) {
//                        if isCreating {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 50)
//                        } else {
//                            Text("Create")
//                                .font(.custom("RussoOne-Regular", size: 18))
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 50)
//                        }
//                    }
//                    .background(Color("Light2"))
//                    .cornerRadius(30)
//                    .disabled(challengeName.trimmingCharacters(in: .whitespaces).isEmpty || isCreating)
//                    .opacity(challengeName.trimmingCharacters(in: .whitespaces).isEmpty || isCreating ? 0.6 : 1.0)
//                    .padding(.top, 5)
//                }
//                .padding(.horizontal, 25)
//                .padding(.bottom, 25)
//            }
//            .background(Color("Light3"))
//            .cornerRadius(30)
//            .padding(.horizontal, 25)
//            .frame(maxHeight: 900)
//
//            // Share Code Popup (for group mode)
//            if showShareCodePopup {
//                ShareCodePopup(isPresented: $showShareCodePopup, joinCode: generatedJoinCode)
//            }
//        }
//        .presentationDetents([.height(550)])
//        .background(Color("Light3"))
//    }
//
//    // MARK: dummy data function
//    private func createChallenge() async {
//        // Dummy data mode - for testing without Firebase
//        if USE_DUMMY_DATA {
//            print("🎮 DUMMY MODE: Creating challenge")
//            print("Name: \(challengeName)")
//            print("Period: \(selectedPeriod.days) days")
//            print("Steps: \(Int(stepGoal))")
//            print("Mode: \(selectedMode)")
//
//            if selectedMode == .social {
//                // Generate code and show popup for group mode
//                generatedJoinCode = generateJoinCode()
//                print("Generated join code: \(generatedJoinCode)")
//                showShareCodePopup = true
//            } else {
//                // Solo mode - dismiss and go to map
//                print("Solo mode - dismissing to map")
//                dismiss()
//                // TODO: Navigate to map/game
//            }
//            return
//        }
//
//        // Your existing code stays below here
//        print("Creating challenge:")
//        print("Name: \(challengeName)")
//        print("Period: \(selectedPeriod.days) days")
//        print("Steps: \(Int(stepGoal))")
//        print("Mode: \(selectedMode)")
//
//        if selectedMode == .social {
//            generatedJoinCode = generateJoinCode()
//            showShareCodePopup = true
//        } else {
//            dismiss()
//        }
//    }
//
//    private func generateJoinCode() -> String {
//        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        return String((0..<6).map { _ in characters.randomElement()! })
//    }
//
//    private func saveChallengeToFirestore(challenge: Challenge) async throws {
//        let db = Firestore.firestore()
//
//        let challengeData: [String: Any] = [
//            "joinCode": challenge.joinCode,
//            "mode": challenge.mode,
//            "originalMode": challenge.originalMode,
//            "goalSteps": challenge.goalSteps,
//            "durationDays": challenge.durationDays,
//            "status": challenge.status,
//            "createdBy": challenge.createdBy,
//            "playerIds": challenge.playerIds,
//            "startDate": Timestamp(date: challenge.startDate),
//            "endDate": Timestamp(date: challenge.endDate),
//            "createdAt": Timestamp(date: challenge.createdAt)
//        ]
//
//        try await db.collection("challenges").addDocument(data: challengeData)
//    }
//}
//
//// MARK: UPDATED - Custom flat slider view (kept in same file, MVVM-safe)
//private struct CustomStepSlider: View {
//
//    @Binding var value: Double
//    let min: Double
//    let max: Double
//    let step: Double
//    let fillColor: Color
//    let trackColor: Color
//
//    private let trackHeight: CGFloat = 12
//    private let thumbSize: CGFloat = 34
//
//    var body: some View {
//        GeometryReader { geo in
//            let width = geo.size.width
//            let available = Swift.max(1, width - thumbSize)
//            let progress = CGFloat((value - min) / (max - min))
//            let x = progress * available
//
//            ZStack(alignment: .leading) {
//
//                // Track (background)
//                Capsule()
//                    .fill(trackColor)
//                    .frame(height: trackHeight)
//
//                // Filled part
//                Capsule()
//                    .fill(fillColor)
//                    .frame(width: x + thumbSize / 2, height: trackHeight)
//
//                // Thumb
//                Circle()
//                    .fill(fillColor)
//                    .frame(width: thumbSize, height: thumbSize)
//                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
//                    .offset(x: x)
//                    .contentShape(Rectangle())
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { g in
//                                let loc = Swift.min(
//                                    Swift.max(0, g.location.x - thumbSize / 2),
//                                    available
//                                )
//                                let raw = Double(loc / available) * (max - min) + min
//                                value = (raw / step).rounded() * step
//                            }
//                    )
//            }
//        }
//        .frame(height: thumbSize)
//        .accessibilityValue(Text("\(Int(value))"))
//    }
//}
//
//#Preview {
//    ZStack {
//        Color.gray.ignoresSafeArea()
//        SetupChallengeView(playerName: "Aisha")
//    }
//}


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// dummy data
let USE_DUMMY_DATA = true

struct SetupChallengeView: View {
    let playerName: String
    @Environment(\.dismiss) var dismiss

    @State private var challengeName: String = ""
    @State private var selectedPeriod: ChallengePeriod = .threeDays
    @State private var stepGoal: Double = 1000
    @State private var selectedMode: ChallengeMode = .solo
    @State private var showShareCodePopup = false
    @State private var generatedJoinCode = ""
    @State private var isCreating = false

    private let maxChallengeNameLength = 20
    private let minSteps = 1000.0
    private let maxSteps = 500000.0

    enum ChallengePeriod: String, CaseIterable {
        case threeDays = "3 Days"
        case week = "Week"
        case month = "Month"

        var days: Int {
            switch self {
            case .threeDays: return 3
            case .week: return 7
            case .month: return 30
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                // Header with close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color("Light1"))
                                .frame(width: 35, height: 35)

                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 15)
                    .padding(.top, 15)
                }

                // MARK: UPDATED - Title aligned with same leading as content (Period)
                Text("Create a New Challenge")
                    .font(.custom("RussoOne-Regular", size: 22))
                    .foregroundColor(Color("Light1"))
                    .padding(.leading, 25)
                    .padding(.top, 5)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 20) {

                    // Challenge Name Input
                    VStack(alignment: .leading, spacing: 5) {

                        // MARK: UPDATED - Challenge Name capsule W:350 H:52 + centered safely
                        TextField("Challenge Name", text: $challengeName)
                            .font(.custom("RussoOne-Regular", size: 15))
                            .foregroundColor(Color("Light1"))
                            .padding(.horizontal, 16)
                            .frame(width: 350, height: 52)
                            .background(Color("Light2").opacity(0.2))
                            .cornerRadius(23)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onChange(of: challengeName) { _, newValue in
                                if newValue.count > maxChallengeNameLength {
                                    challengeName = String(newValue.prefix(maxChallengeNameLength))
                                }
                            }

                        Text("\(challengeName.count)/\(maxChallengeNameLength)")
                            .font(.custom("RussoOne-Regular", size: 11))
                            .foregroundColor(Color("Light1").opacity(0.6))
                            .padding(.leading, 5)
                    }

                    // Period Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Period")
                            .font(.custom("RussoOne-Regular", size: 16))
                            .foregroundColor(Color("Light1"))

                        // MARK: UPDATED - Center Period buttons
                        HStack(spacing: 12) {
                            ForEach(ChallengePeriod.allCases, id: \.self) { period in
                                Button(action: { selectedPeriod = period }) {
                                    Text(period.rawValue)
                                        .font(.custom("RussoOne-Regular", size: 15))
                                        .foregroundColor(selectedPeriod == period ? .white : Color("Light1"))
                                        .frame(width: 90, height: 40)
                                        .background(selectedPeriod == period ? Color("Light1") : Color.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    // Steps Slider
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Steps")
                            .font(.custom("RussoOne-Regular", size: 16))
                            .foregroundColor(Color("Light1"))

                        VStack(spacing: 6) {

                            // MARK: UPDATED - Custom flat slider (no glass) + drag works always
                            CustomStepSlider(
                                value: $stepGoal,
                                min: minSteps,
                                max: maxSteps,
                                step: 1000,
                                fillColor: Color("Light1"),
                                trackColor: Color.white
                            )
                            .frame(height: 36)

                            HStack {
                                Text("\(Int(minSteps).formatted())")
                                    .font(.custom("RussoOne-Regular", size: 11))
                                    .foregroundColor(Color("Light1").opacity(0.6))

                                Spacer()

                                Text("\(Int(stepGoal).formatted())")
                                    .font(.custom("RussoOne-Regular", size: 15))
                                    .foregroundColor(Color("Light1"))

                                Spacer()

                                Text("\(Int(maxSteps).formatted())")
                                    .font(.custom("RussoOne-Regular", size: 11))
                                    .foregroundColor(Color("Light1").opacity(0.6))
                            }
                        }
                    }

                    // Mode Selection
                    HStack(spacing: 25) {

                        Button(action: { selectedMode = .solo }) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.fill").font(.system(size: 16))
                                Text("Solo").font(.custom("RussoOne-Regular", size: 15))
                            }
                            .foregroundColor(selectedMode == .solo ? .white : Color("Light1"))
                            .frame(width: 120, height: 40)
                            .background(selectedMode == .solo ? Color("Light1") : Color.white)
                            .cornerRadius(25)
                        }

                        Button(action: { selectedMode = .social }) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2.fill").font(.system(size: 16))
                                Text("Group").font(.custom("RussoOne-Regular", size: 15))
                            }
                            .foregroundColor(selectedMode == .social ? .white : Color("Light1"))
                            .frame(width: 120, height: 40)
                            .background(selectedMode == .social ? Color("Light1") : Color.white)
                            .cornerRadius(25)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    // MARK: UPDATED - Create button W:195 H:50 + centered
                    HStack {
                        Button(action: {
                            Task { await createChallenge() }
                        }) {
                            if isCreating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 195, height: 50)
                            } else {
                                Text("Create")
                                    .font(.custom("RussoOne-Regular", size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 195, height: 50)
                            }
                        }
                        .background(Color("Light2"))
                        .cornerRadius(30)
                        .disabled(challengeName.trimmingCharacters(in: .whitespaces).isEmpty || isCreating)
                        .opacity(challengeName.trimmingCharacters(in: .whitespaces).isEmpty || isCreating ? 0.6 : 1.0)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 5)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 25)
            }
            .background(Color("Light3"))
            .cornerRadius(30)
            .padding(.horizontal, 25)
            .frame(maxHeight: 900)
            // MARK: UPDATED - Stop sheet from feeling too wide
            .frame(maxWidth: 420)

            if showShareCodePopup {
                ShareCodePopup(isPresented: $showShareCodePopup, joinCode: generatedJoinCode)
            }
        }
        .presentationDetents([.height(550)])
        .background(Color("Light3"))
    }

    // MARK: dummy data function
    private func createChallenge() async {
        if USE_DUMMY_DATA {
            if selectedMode == .social {
                generatedJoinCode = generateJoinCode()
                showShareCodePopup = true
            } else {
                dismiss()
            }
            return
        }

        if selectedMode == .social {
            generatedJoinCode = generateJoinCode()
            showShareCodePopup = true
        } else {
            dismiss()
        }
    }

    private func generateJoinCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }

    private func saveChallengeToFirestore(challenge: Challenge) async throws {
        let db = Firestore.firestore()

        let challengeData: [String: Any] = [
            "joinCode": challenge.joinCode,
            "mode": challenge.mode,
            "originalMode": challenge.originalMode,
            "goalSteps": challenge.goalSteps,
            "durationDays": challenge.durationDays,
            "status": challenge.status,
            "createdBy": challenge.createdBy,
            "playerIds": challenge.playerIds,
            "startDate": Timestamp(date: challenge.startDate),
            "endDate": Timestamp(date: challenge.endDate),
            "createdAt": Timestamp(date: challenge.createdAt)
        ]

        try await db.collection("challenges").addDocument(data: challengeData)
    }
}

// MARK: UPDATED - Custom flat slider view (drag works always + drag anywhere + clamp)
private struct CustomStepSlider: View {

    @Binding var value: Double
    let min: Double
    let max: Double
    let step: Double
    let fillColor: Color
    let trackColor: Color

    private let trackHeight: CGFloat = 12
    private let thumbSize: CGFloat = 34

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let available = Swift.max(1, width - thumbSize)

            let safeValue = Swift.min(Swift.max(value, min), max)
            let progress = CGFloat((safeValue - min) / (max - min))
            let x = progress * available

            ZStack(alignment: .leading) {

                Capsule()
                    .fill(trackColor)
                    .frame(height: trackHeight)

                Capsule()
                    .fill(fillColor)
                    .frame(width: x + thumbSize / 2, height: trackHeight)

                Circle()
                    .fill(fillColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: x)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let loc = Swift.min(
                            Swift.max(0, g.location.x - thumbSize / 2),
                            available
                        )
                        let raw = Double(loc / available) * (max - min) + min
                        let snapped = (raw / step).rounded() * step
                        value = Swift.min(Swift.max(snapped, min), max)
                    }
            )
        }
        .frame(height: thumbSize)
        .accessibilityValue(Text("\(Int(value))"))
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        SetupChallengeView(playerName: "Aisha")
    }
}
