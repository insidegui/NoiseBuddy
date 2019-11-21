//
//  KeyBoardShortcut.swift
//  NoiseBuddy
//
//  Created by Nick Hayward on 11/21/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Foundation

struct KeyBoardShortcut: Codable {
    let eventCode: UInt32
    let modifier: UInt32
    let title: String
}
