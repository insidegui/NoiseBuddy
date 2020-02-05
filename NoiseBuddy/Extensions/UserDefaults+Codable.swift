//
//  UserDefaults+Codable.swift
//  NoiseBuddy
//
//  Created by Nick Hayward on 11/21/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Foundation

extension UserDefaults {
    func codable<T: Decodable>(forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func setEncode<T: Encodable>(_ value: T, forKey defaultName: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        set(data, forKey: defaultName)
    }
}
