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

    var isFullscreen = false

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return isFullscreen ? .landscape : .all
        }

        set {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let resourceBundle = SparkPlayer.getResourceBundle() {
            let fullscreenImage = UIImage(named: "FullscreenExit", in: resourceBundle, compatibleWith: nil)
            sparkView.fullscreenButton.setImage(fullscreenImage, for: .normal)
        }
    }
}
