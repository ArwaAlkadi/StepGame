

//
//  SteepishWidget.swift
//  SteepishWidget
//
//  Created by Aryam on 06/02/2026.
//

import WidgetKit
import SwiftUI

// MARK: - Models

enum AvatarType: String {
    case ray
    case luna
    case rosy
}

enum AvatarState: String {
    case strong
    case normal
    case fat
}

struct StepEntry: TimelineEntry {
    let date: Date

    let userAvatar: AvatarType
    let userState: AvatarState
    let userSteps: Int
    let userGoal: Int
    let userName: String

    let friendAvatar: AvatarType
    let friendState: AvatarState
    let friendSteps: Int
    let friendGoal: Int
    let friendName: String
}

// MARK: - Helpers

func avatarImageName(avatar: AvatarType, state: AvatarState) -> String {
    "\(avatar.rawValue)\(state.rawValue)"
}

// MARK: - Custom Font (Russo One)

extension Font {
    static func russo(_ size: CGFloat) -> Font {
        .custom("RussoOne-Regular", size: size)
    }
}

// MARK: - Provider

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> StepEntry {
        demoEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (StepEntry) -> Void) {
        completion(demoEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StepEntry>) -> Void) {
        let timeline = Timeline(
            entries: [demoEntry],
            policy: .after(Date().addingTimeInterval(60 * 30))
        )
        completion(timeline)
    }

    private var demoEntry: StepEntry {
        StepEntry(
            date: Date(),

            userAvatar: .luna,
            userState: .strong,
            userSteps: 2666,
            userGoal: 3000,
            userName: "Luna",

            friendAvatar: .rosy,
            friendState: .fat,
            friendSteps: 1500,
            friendGoal: 3000,
            friendName: "Rosy"
        )
    }
}

// MARK: - Player Card

struct PlayerCardView: View {

    let avatar: AvatarType
    let state: AvatarState
    let steps: Int
    let goal: Int
    let name: String

    var body: some View {
        VStack(spacing: -19) {

            // Goal
            Text("\(goal)")
                .font(.russo(40))
                .foregroundColor(Color("TextBeige"))
                .opacity(0.7)

            // Avatar
            Image(avatarImageName(avatar: avatar, state: state))
                .resizable()
                .scaledToFit()
                .frame(height: 110)
                .offset(y: -25)

            // Steps + Name
            VStack(spacing: -2) {

                HStack(spacing: 2) {
                    Image(systemName: "figure.walk")
                    Text("\(steps)")
                        .font(.russo(15))
                }

                Text(name)
                    .font(.russo(12))
            }
            .offset(y: -15)
            .foregroundColor(Color("TextBrown"))
        }
        .frame(width: 160, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("WidgetCream"))
        )
    }
}

// MARK: - Widget Entry View

struct SteepishWidgetEntryView: View {

    let entry: StepEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            content
        }
        .padding(10)
        .containerBackground(for: .widget) {
            Color("WidgetBrown")
        }
    }

    @ViewBuilder
    private var content: some View {
        if family == .systemSmall {

            PlayerCardView(
                avatar: entry.userAvatar,
                state: entry.userState,
                steps: entry.userSteps,
                goal: entry.userGoal,
                name: entry.userName
            )

        } else {

            HStack(spacing: 12) {
                PlayerCardView(
                    avatar: entry.userAvatar,
                    state: entry.userState,
                    steps: entry.userSteps,
                    goal: entry.userGoal,
                    name: entry.userName
                )

                PlayerCardView(
                    avatar: entry.friendAvatar,
                    state: entry.friendState,
                    steps: entry.friendSteps,
                    goal: entry.friendGoal,
                    name: entry.friendName
                )
            }
        }
    }
}

// MARK: - Widget

struct SteepishWidget: Widget {

    let kind: String = "SteepishWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SteepishWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Steepish")
        .description("Track steps with your character")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
