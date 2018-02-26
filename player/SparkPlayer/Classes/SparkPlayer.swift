//
//  SparkPlayer.swift
//  SparkPlayer
//
//  Created by spark on 12/02/2018.
//

import AVKit

public class SparkPlayer: UIViewController {
    // player handling
    private var playerLayer: AVPlayerLayer!

    // views handling
    private var inlineController: SparkPlayerInlineController!
    private var fullscreenController: SparkPlayerFullscreenController!
    private var fullscreen = false

    public var player: AVPlayer? {
        didSet {
            setup()
        }
    }

    public override func loadView() {
        super.loadView()

        playerLayer = AVPlayerLayer()
        if let player = self.player {
            playerLayer.player = player
        }

        inlineController = SparkPlayerInlineController()
        inlineController.delegate = self
        inlineController.playerLayer = playerLayer

        fullscreenController = SparkPlayerFullscreenController()
        fullscreenController.delegate = self

        view.autoresizesSubviews = true

        self.addChildViewController(inlineController)
        view.addSubview(inlineController.view)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        inlineController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }

    func setup() {
        if let layer = self.playerLayer {
            layer.player = self.player
        }

        guard let player = self.player else {
            // XXX alexeym TODO: clean controllers and so on, remove previous player everywhere
            return
        }

        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            self.activeController().timeupdate()
        }
    }

    func activeController() -> SparkPlayerController {
        if (fullscreen) {
            return fullscreenController
        }

        return inlineController
    }
}


protocol SparkPlayerDelegate {
    // controls handlers
    func onPlayClick()
    func onFullscreenClick()

    // Internal interface for AVPlayer data
    func currentTime() -> CMTime
    func seekTo(_ value: CMTime)
    func duration() -> CMTime
    func loadedTimeRanges() -> [CMTimeRange]
}

extension SparkPlayer: SparkPlayerDelegate {
    func onPlayClick() {
        guard let player = self.player else {
            return
        }

        if (player.rate == 0) {
            player.play()
        } else {
            player.pause()
        }
    }

    func onFullscreenClick() {
        if (fullscreen) {
            fullscreenController.dismiss(animated: true, completion: nil)
            inlineController.playerLayer = playerLayer
        } else {
            self.present(fullscreenController, animated: true, completion: nil)
            fullscreenController.playerLayer = playerLayer
        }

        fullscreen = !fullscreen
    }

    func currentTime() -> CMTime {
        guard let player = self.player else {
            return CMTimeMakeWithSeconds(0, 1)
        }

        return player.currentTime()
    }

    func seekTo(_ value: CMTime) {
        player?.seek(to: value)
    }

    func duration() -> CMTime {
        guard let item = self.player?.currentItem else {
            return CMTimeMakeWithSeconds(0, 1)
        }

        return item.duration.isIndefinite ? CMTimeMakeWithSeconds(0, 1) : item.duration
    }

    func loadedTimeRanges() -> [CMTimeRange] {
        guard let item = self.player?.currentItem else {
            return []
        }

        return item.loadedTimeRanges.asTimeRanges
    }
}

// public API
public extension SparkPlayer {
    func isFullscreen() -> Bool {
        return self.fullscreen
    }
}

// utils
private extension Collection where Iterator.Element == NSValue {
    var asTimeRanges : [CMTimeRange] {
        return self.map({ value -> CMTimeRange in
            return value.timeRangeValue
        })
    }
}

internal extension UIColor {
    struct SparkPlayer {
        static let empty = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        static let loaded = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        static let filled = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        static let thumb = UIColor.SparkPlayer.filled
    }
}

internal extension String {
    func width(withFont font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: 1.0)
        let template = self.components(separatedBy: .decimalDigits).joined(separator: "0")
        let boundingBox = template.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
