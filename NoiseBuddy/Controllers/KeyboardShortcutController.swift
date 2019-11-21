//
//  KeyboardShortcutController.swift
//  NoiseBuddy
//
//  Created by Nick Hayward on 11/20/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Foundation
import NoiseCore
import HotKey

final class KeyboardShortcutController: NSObject {
    private var toggleListeningModeHotKey: HotKey?
    
    let preferences: Preferences
    let listeningModeController: NCListeningModeStatusProvider
    
    init(listeningModeController: NCListeningModeStatusProvider, preferences: Preferences) {
        self.listeningModeController = listeningModeController
        self.preferences = preferences
        super.init()
    }

    func setup() {
        listeningModeController.startListeningForUpdates()

        NotificationCenter.default.addObserver(forName: Preferences.didChangeNotification, object: preferences, queue: .main) { [weak self] _ in
            guard let preferences = self?.preferences else { return }
            self?.updateShortcut(preferences: preferences)
        }
        
        // MARK: Initial Setup
        self.updateShortcut(preferences: self.preferences)
    }
    
    func toggleNoiseControlMode() {
        let nextMode = preferences.nextListeningMode(from: listeningModeController.listeningMode)
        
        listeningModeController.listeningMode = nextMode
    }
    
    private func updateShortcut(preferences: Preferences) {
        let keyboardShortcutToggleEnabled = preferences.keyboardShortcutToggleEnabled
        toggleListeningModeHotKey?.isPaused = preferences.keyboardShortcutPause
        
        if preferences.keyboardShortcutPause {
            return
        }
        
        // MARK: Disable Keyboard Shortcut
        if !keyboardShortcutToggleEnabled {
            toggleListeningModeHotKey = nil
            return
        }
        
        guard let keyboardShortcut = preferences.keyboardShortcut else { return }
        setupShortcut(with: keyboardShortcut)
    }
    
    private func setupShortcut(with shortcut: KeyBoardShortcut) {
        guard let keyboardShortcutKey = preferences.keyboardShortcut else { return }
        toggleListeningModeHotKey = HotKey(carbonKeyCode: keyboardShortcutKey.eventCode, carbonModifiers: keyboardShortcutKey.modifier)
        toggleListeningModeHotKey?.keyDownHandler = {
            self.toggleNoiseControlMode()
        }
    }
}

