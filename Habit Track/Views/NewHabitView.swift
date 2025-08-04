//
//  NewHabitView.swift
//  Habit Track
//
//  Created by Nikolay Simeonov on 21.06.25.
//

import SwiftUI
import SwiftData

struct NewHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var emoji = ""
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        TextField("", text: $emoji)
                            .frame(width: 70, height: 70)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 45))
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.gray.opacity(0.3), lineWidth: 1)
                            )
                            .onChange(of: emoji) { oldValue, newValue in
                                emoji = extractFirstEmoji(from: newValue)
                            }
                            .keyboardType(.default)
                            .disableAutocorrection(true)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                } header: {
                    Label("Pick an emoji", systemImage: "face.smiling")
                        .font(.headline)
                }

                Section {
                    TextField("Habit title", text: $title)
                    TextField("Habit description", text: $description)
                } header: {
                    Label("Habit details", systemImage: "square.and.pencil")
                        .font(.headline)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = HabitItem(
                            id: UUID(),
                            emoji: emoji,
                            title: title.trimmingCharacters(in: .whitespaces),
                            description: description.trimmingCharacters(in: .whitespaces)
                        )
                        modelContext.insert(item)
                        dismiss()
                    }
                    .disabled(emoji.trimmingCharacters(in: .whitespaces).isEmpty ||
                              title.trimmingCharacters(in: .whitespaces).isEmpty ||
                              description.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    func extractFirstEmoji(from text: String) -> String {
        for scalar in text.unicodeScalars {
            if scalar.properties.isEmoji && (scalar.properties.isEmojiPresentation || scalar.value > 0x238C) {
                return String(scalar)
            }
        }
        return ""
    }
}

#Preview {
    NewHabitView()
        .modelContainer(for: HabitItem.self, inMemory: true)
}
