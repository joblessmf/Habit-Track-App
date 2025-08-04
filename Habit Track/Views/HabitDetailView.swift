//
//  HabitDetailView.swift
//  Habit Track
//
//  Created by Nikolay Simeonov on 9.07.25.
//

import SwiftUI
import UIKit

struct HabitDetailView: View {
    var habit: HabitItem
    @State private var currentMonthDate: Date = Date()
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Text(habit.emoji)
                        .font(.system(size: 60))
                    Text(habit.title)
                        .font(.title.bold())
                    Text(habit.habitDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()

                Divider()

                // Month navigation
                HStack {
                    Button(action: {
                        changeMonth(by: -1)
                    }) {
                        Image(systemName: "chevron.left")
                    }

                    Spacer()

                    Text(currentMonthName())
                        .font(.headline)

                    Spacer()

                    Button(action: {
                        changeMonth(by: 1)
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)

                // Weekday headers
                LazyVGrid(columns: columns) {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                        Text(weekday.prefix(3)) // Mo, Tu...
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Calendar grid
                let days = generateFullMonth()

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(days.indices, id: \.self) { index in
                        if let date = days[index] {
                            let completed = isDateCompleted(date)
                               let isToday = calendar.isDateInToday(date)
                               let isFuture = date > calendar.startOfDay(for: Date())

                               Text(formattedDay(from: date))
                                   .frame(width: 32, height: 32)
                                   .background(
                                       isFuture
                                           ? Color.gray.opacity(0.1)
                                           : (completed ? Color.green.opacity(0.7) : Color.gray.opacity(0.2))
                                   )
                                   .overlay(
                                       Circle()
                                           .stroke(Color.blue, lineWidth: isToday ? 2 : 0)
                                   )
                                   .clipShape(Circle())
                                   .foregroundColor(isFuture ? .gray : .primary)
                                   .onTapGesture {
                                       if !isFuture {
                                           toggleCompletion(for: date)
                                           let generator = UIImpactFeedbackGenerator(style:.medium)
                                               generator.impactOccurred()
                                       }
                                   }
                        } else {
                            Color.clear.frame(width: 32, height: 32)
                        }
                    }
                }
                .animation(.easeInOut, value: currentMonthDate)

                // Stats
                Divider()
                Text("✅ \(habit.completionDates.count) completions")
                    .font(.subheadline)
                    .padding(.top, 4)

                if let streak = currentStreak() {
                    Text("🔥 Current streak: \(streak) day\(streak == 1 ? "" : "s")")
                        .font(.subheadline)
                }
            }
            .padding()
        }
        .navigationTitle("Habit Tracker")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Calendar Helpers

    func currentMonthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentMonthDate)
    }

    func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonthDate) {
            currentMonthDate = newMonth
        }
    }

    func generateFullMonth() -> [Date?] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: currentMonthDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonthDate)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmptyDays = (firstWeekday + 6) % 7 // Adjust for Monday = 0

        var dates: [Date?] = Array(repeating: nil, count: leadingEmptyDays)

        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }

        return dates
    }

    func formattedDay(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    func isDateCompleted(_ date: Date) -> Bool {
        habit.completionDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
    }

    func toggleCompletion(for date: Date) {
        if let index = habit.completionDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            habit.completionDates.remove(at: index)
        } else {
            habit.completionDates.append(date)
        }
    }

    func currentStreak() -> Int? {
        let sortedDates = habit.completionDates.sorted(by: >)
        guard !sortedDates.isEmpty else { return nil }

        var streak = 0
        let currentDate = calendar.startOfDay(for: Date())

        for date in sortedDates {
            let day = calendar.startOfDay(for: date)
            if calendar.isDate(currentDate, inSameDayAs: day) || calendar.isDate(currentDate.addingTimeInterval(-86400 * Double(streak)), inSameDayAs: day) {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }
}

#Preview {
    HabitDetailView(habit: HabitItem(
        id: UUID(),
        emoji: "🔥",
        title: "Workout",
        description: "Push-ups and running"
    ))
    .modelContainer(for: HabitItem.self, inMemory: true)
}
