//
//  Colors.swift
//  SparkPlayer
//
//  Created by alexeym on 02/03/2018.
//

import Foundation

internal extension UIColor {
    struct SparkPlayer {
        static let empty = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        static let loaded = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        static let filled = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        static let thumb = UIColor.SparkPlayer.filled
        static let fade = UIColor(red: 0, green: 0, blue: 0, alpha: 0.28)
        static let menuBackground = UIColor.white
        static let menuColor = UIColor(white: 32/255, alpha: 1)
        static let menuSeparator = UIColor(rgb: 0xDFE0E1)
    }
}
