//
//  ContentView.swift
//  Habit Track
//
//  Created by Nikolay Simeonov on 20.06.25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    
    @Query private var habits: [HabitItem]
    @Environment(\.modelContext) private var modelContext
    @State private var showingNewHabitView = false
    
    var sortedHabits: [HabitItem] {
        let today = Calendar.current.startOfDay(for: Date())

        return habits.sorted { lhs, rhs in
            let lhsDone = lhs.completionDates.contains {
                Calendar.current.isDate($0, inSameDayAs: today)
            }
            let rhsDone = rhs.completionDates.contains {
                Calendar.current.isDate($0, inSameDayAs: today)
            }

            // Incomplete (false) should come before complete (true)
            return !lhsDone && rhsDone
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedHabits, id: \.id) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                        HStack(alignment: .center, spacing: 12) {
                            // Emoji box
                            Text(habit.emoji)
                                .font(.system(size: 28))
                                .frame(width: 48, height: 48)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                            // Title + description
                            VStack(alignment: .leading) {
                                Text(habit.title)
                                    .font(.headline)
                                Text(habit.habitDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Checkmark button
                            Button(action: {
                                withAnimation {
                                    toggleToday(for: habit)
                                }
                            }) {
                                let todayCompleted = isTodayCompleted(habit)
                                Image(systemName: todayCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                            .sensoryFeedback(.success, trigger: isTodayCompleted(habit))
                        }
                        .padding(.vertical, 4)
                        .opacity(isTodayCompleted(habit) ? 0.5 : 1.0)
                    }
                }
                .onDelete(perform: removeHabit)
            }
            .animation(.easeInOut, value: habits)
            .navigationTitle("Habit Tracker")
            .toolbar {
                Button("Add a new habit", systemImage: "plus") {
                    showingNewHabitView = true
                }
            }
            .sheet(isPresented: $showingNewHabitView) {
                NewHabitView()
            }
        }
    }
    
    func removeHabit(at offsets: IndexSet) {
        for index in offsets {
            let habitToDelete = sortedHabits[index]
            modelContext.delete(habitToDelete)
        }
    }

    func isTodayCompleted(_ item: HabitItem) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return item.completionDates.contains {
            Calendar.current.isDate($0, inSameDayAs: today)
        }
    }

    func toggleToday(for item: HabitItem) {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = item.completionDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            item.completionDates.remove(at: index)
        } else {
            item.completionDates.append(today)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: HabitItem.self, inMemory: true)
}
