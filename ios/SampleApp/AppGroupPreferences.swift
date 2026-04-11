//
//  AppGroupPreferences.swift
//  Key–value store in the App Group **container** (plist file). Avoids `UserDefaults(suiteName:)`, which
//  still hits CFPreferences and can log “CFPrefsPlistSource… Container: (null)… detaching from cfprefsd”.
//

import Foundation

enum AppGroupPreferences {
    private static let ioLock = NSLock()
    private static let plistName = "LunarYearShared.plist"

    private static var plistURL: URL? {
        guard let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedConfig.appGroupId) else {
            return nil
        }
        let support = base.appendingPathComponent("Library/Application Support", isDirectory: true)
        if !FileManager.default.fileExists(atPath: support.path) {
            try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        }
        return support.appendingPathComponent(plistName, isDirectory: false)
    }

    private static func readDictionary() -> [String: Any] {
        guard let url = plistURL, FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let obj = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let dict = obj as? [String: Any] else {
            return [:]
        }
        return dict
    }

    private static func writeDictionary(_ dict: [String: Any]) {
        guard let url = plistURL else { return }
        guard let data = try? PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0) else {
            return
        }
        let tmp = url.appendingPathExtension("tmp")
        do {
            try data.write(to: tmp, options: .atomic)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            try FileManager.default.moveItem(at: tmp, to: url)
        } catch {
            try? FileManager.default.removeItem(at: tmp)
        }
    }

    static func object(forKey key: String) -> Any? {
        ioLock.lock()
        defer { ioLock.unlock() }
        return readDictionary()[key]
    }

    static func string(forKey key: String) -> String? {
        object(forKey: key) as? String
    }

    static func double(forKey key: String) -> Double? {
        guard let v = object(forKey: key) else { return nil }
        if let d = v as? Double { return d }
        if let n = v as? NSNumber { return n.doubleValue }
        return nil
    }

    static func set(_ value: Any?, forKey key: String) {
        ioLock.lock()
        defer { ioLock.unlock() }
        var dict = readDictionary()
        if let value {
            dict[key] = value
        } else {
            dict.removeValue(forKey: key)
        }
        writeDictionary(dict)
    }

    static func removeObject(forKey key: String) {
        set(nil, forKey: key)
    }
}
