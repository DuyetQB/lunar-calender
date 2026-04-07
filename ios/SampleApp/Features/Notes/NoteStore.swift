import Foundation
import SwiftUI

@MainActor
final class NoteStore: ObservableObject {
    @Published var notes: [CalendarNote] = []

    private let fileURL: URL
    private let reminderService: ReminderService
    private let calendar: Calendar

    init(reminderService: ReminderService = ReminderService()) {
        self.reminderService = reminderService
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = LunarReminderConverter.vietnamTimeZone
        self.calendar = cal

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fallback = FileManager.default.temporaryDirectory
        self.fileURL = (docs ?? fallback).appendingPathComponent("calendar_notes.json")
        load()
        rescheduleAllNotes()
    }

    func addNote(_ note: CalendarNote) {
        notes.append(note)
        save()
        if note.hasReminder {
            reminderService.requestPermission()
            reminderService.schedule(note: note)
        }
    }

    func deleteNote(id: UUID) {
        guard let note = notes.first(where: { $0.id == id }) else { return }
        notes.removeAll { $0.id == id }
        save()
        reminderService.cancel(note: note)
    }

    func updateNote(_ note: CalendarNote) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        let old = notes[index]
        notes[index] = note
        save()
        reminderService.cancel(note: old)
        if note.hasReminder {
            reminderService.requestPermission()
            reminderService.schedule(note: note)
        }
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            notes = []
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        notes = (try? decoder.decode([CalendarNote].self, from: data)) ?? []
    }

    func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(notes) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func notes(for date: Date) -> [CalendarNote] {
        notes
            .filter { calendar.isDate($0.solarDate, inSameDayAs: date) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func hasNotes(on date: Date) -> Bool {
        notes.contains { calendar.isDate($0.solarDate, inSameDayAs: date) }
    }

    func hasReminders(on date: Date) -> Bool {
        notes.contains {
            $0.hasReminder &&
            $0.reminderDate != nil &&
            calendar.isDate($0.solarDate, inSameDayAs: date)
        }
    }

    func rescheduleAllNotes() {
        reminderService.requestPermission()
        for note in notes where note.hasReminder {
            reminderService.cancel(note: note)
            reminderService.schedule(note: note)
        }
    }
}
