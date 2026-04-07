import SwiftUI

struct NoteListView: View {
    @EnvironmentObject private var noteStore: NoteStore

    let selectedSolarDate: Date
    let selectedLunarDate: LunarDate?

    @State private var showingEditor = false
    @State private var editingNote: CalendarNote?

    var body: some View {
        let notesForDay = noteStore.notes(for: selectedSolarDate)
        List {
            Section {
                if notesForDay.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("notes_empty_title")
                            .font(.headline)
                        Text("notes_empty_subtitle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                ForEach(notesForDay) { note in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(note.title)
                            .font(.headline)
                        if !note.content.isEmpty {
                            Text(note.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                        if note.hasReminder, let reminderDate = note.reminderDate {
                            HStack(spacing: 8) {
                                Label(reminderDate.formatted(date: .abbreviated, time: .shortened), systemImage: "bell.fill")
                                if note.isLunarRepeat {
                                    Text("notes_lunar_repeat_badge")
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.orange.opacity(0.15))
                                        .foregroundStyle(.orange)
                                        .clipShape(Capsule())
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.orange)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingNote = note
                        showingEditor = true
                    }
                }
                .onDelete(perform: delete)
            } header: {
                Text("notes_section_list")
            }
        }
        .navigationTitle("notes_list_title")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editingNote = nil
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            NoteEditorView(
                baseSolarDate: selectedSolarDate,
                baseLunarDate: selectedLunarDate,
                existingNote: editingNote
            ) { note in
                if editingNote == nil {
                    noteStore.addNote(note)
                } else {
                    noteStore.updateNote(note)
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        let notesForDay = noteStore.notes(for: selectedSolarDate)
        for index in offsets {
            guard index < notesForDay.count else { continue }
            noteStore.deleteNote(id: notesForDay[index].id)
        }
    }
}
