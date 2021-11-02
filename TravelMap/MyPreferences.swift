//
//  MyPreferences.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/21.
//

import Foundation

class MyPreferences {
    static let defaults = UserDefaults.standard

    static var trackingState: Int {
        get {
            defaults.integer(forKey: "trackingState")
        }
        set(value) {
            defaults.set(value, forKey: "trackingState")
        }
    }

    static var trackingTime: Int {
        get {
            defaults.value(forKey: "trackingTime") as? Int ?? 150
        }
        set(value) {
            defaults.set(value, forKey: "trackingTime")
        }
    }


}
