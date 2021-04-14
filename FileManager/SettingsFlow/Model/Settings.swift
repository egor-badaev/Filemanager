//
//  Settings.swift
//  FileManager
//
//  Created by Egor Badaev on 14.04.2021.
//

import Foundation

enum SortingStyle: Int, CaseIterable {
    case windows = 0
    case macos

    static func label(for style: SortingStyle) -> String {
        switch style {
        case .windows:
            return "Windows"
        case .macos:
            return "macOS / Linux"
        }
    }
}

class Settings {

    private enum SettingsKey {
        static let sorting = "FileManagerSettingsSortingStyle"
        static let showSize = "FileManagerSettingShouldShowSize"
        static let updated = "FileManagerSettingsUpdatedFlag"
    }

    static let shared: Settings = {
        let instance = Settings()
        return instance
    }()

    private init() { }

    var sorting: SortingStyle {
        get {
            if let sorting = UserDefaults.standard.object(forKey: SettingsKey.sorting) as? Int,
               let sortingStyle = SortingStyle(rawValue: sorting) {
                return sortingStyle
            } else {
                // default value
                return .windows
            }
        }

        set {
            print(type(of: self), #function, newValue)
            UserDefaults.standard.setValue(newValue.rawValue, forKey: SettingsKey.sorting)
            haveUpdates = true
        }
    }

    var showSize: Bool {
        get {
            if let showSize = UserDefaults.standard.object(forKey: SettingsKey.showSize) as? Bool {
                return showSize
            } else {
                // default value
                return true
            }
        }

        set {
            print(type(of: self), #function, newValue)
            UserDefaults.standard.setValue(newValue, forKey: SettingsKey.showSize)
            haveUpdates = true
        }

    }

    /**
     Helper flag to determine if any changes were made since the last check

     - returns:
     `true` if any of the settings were changed, `false` otherwise

     Resets on every read - use wisely (you can only catch changes once!)
     */
    var haveUpdates: Bool {
        get {
            let wereUpdated = UserDefaults.standard.bool(forKey: SettingsKey.updated)
            if wereUpdated {
                UserDefaults.standard.setValue(false, forKey: SettingsKey.updated)
            }
            return wereUpdated
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: SettingsKey.updated)
        }
    }

}
