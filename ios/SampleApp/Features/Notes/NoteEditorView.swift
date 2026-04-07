import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let baseSolarDate: Date
    let baseLunarDate: LunarDate?
    var existingNote: CalendarNote?
    var onSave: (CalendarNote) -> Void

    @State private var title: String
    @State private var content: String
    @State private var hasReminder: Bool
    @State private var reminderDate: Date
    @State private var isLunarRepeat: Bool

    init(
        baseSolarDate: Date,
        baseLunarDate: LunarDate?,
        existingNote: CalendarNote? = nil,
        onSave: @escaping (CalendarNote) -> Void
    ) {
        self.baseSolarDate = baseSolarDate
        self.baseLunarDate = baseLunarDate
        self.existingNote = existingNote
        self.onSave = onSave
        _title = State(initialValue: existingNote?.title ?? "")
        _content = State(initialValue: existingNote?.content ?? "")
        _hasReminder = State(initialValue: existingNote?.hasReminder ?? false)
        _reminderDate = State(initialValue: existingNote?.reminderDate ?? baseSolarDate)
        _isLunarRepeat = State(initialValue: existingNote?.isLunarRepeat ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("notes_section_note") {
                    TextField("notes_title_placeholder", text: $title)
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                }

                Section("notes_section_date") {
                    LabeledContent("notes_selected_solar") {
                        Text(baseSolarDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let lunar = baseLunarDate {
                        LabeledContent("notes_selected_lunar") {
                            Text("\(lunar.day)/\(lunar.month)/\(lunar.year)\(lunar.isLeapMonth ? " \(String(localized: "detail_leap_suffix"))" : "")")
                        }
                    }
                }

                Section("notes_section_reminder") {
                    Toggle("notes_enable_reminder", isOn: $hasReminder)
                    if hasReminder {
                        DatePicker("notes_reminder_time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                        Toggle("notes_repeat_lunar_yearly", isOn: $isLunarRepeat)
                            .disabled(baseLunarDate == nil)
                        Text("notes_reminder_helper")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(existingNote == nil ? "notes_new_title" : "notes_edit_title")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("notes_cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("notes_save") { saveNote() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveNote() {
        let source = existingNote ?? CalendarNote(
            title: "",
            content: "",
            solarDate: baseSolarDate,
            lunarDate: baseLunarDate
        )
        let note = CalendarNote(
            id: source.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content,
            solarDate: source.solarDate,
            lunarDate: source.lunarDate,
            hasReminder: hasReminder,
            reminderDate: hasReminder ? reminderDate : nil,
            isLunarRepeat: hasReminder ? isLunarRepeat : false,
            createdAt: source.createdAt
        )
        onSave(note)
        dismiss()
    }
}
