//
//  SparkPlayerFullscreenController.swift
//  SparkPlayer
//
//  Created by spark on 12/02/2018.
//

import Foundation

class SparkPlayerFullscreenController: SparkPlayerController {
    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            return .fullScreen
        }

        set {}
    }

    override var modalTransitionStyle: UIModalTransitionStyle {
        get {
            return .crossDissolve
        }

        set {}
    }
}
