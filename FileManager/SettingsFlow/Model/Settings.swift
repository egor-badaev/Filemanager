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

enum SettingsKey {
    static let sorting = "FileManagerSettingsSortingStyle"
    static let showSize = "FileManagerSettingShouldShowSize"
}

class Settings {

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
        }
    }

}
