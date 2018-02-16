//
//  SparkPlayerView.swift
//  SparkPlayer
//
//  Created by spark on 13/02/2018.
//

import UIKit

class SparkPlayerView: UIView {

    @IBOutlet weak var fullscreenButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var positionSlider: SparkPlayerScrubber!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var currentTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationWidth: NSLayoutConstraint!
}
