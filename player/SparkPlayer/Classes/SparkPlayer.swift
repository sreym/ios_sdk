//
//  SparkPlayer.swift
//  SparkPlayer
//
//  Created by spark on 12/02/2018.
//

import AVKit
import SparkLib

protocol SparkPlayerDelegate {
    // controls handlers
    func onPlayClick()
    func onFullscreenClick()

    // Internal interface for AVPlayer data
    func isLive() -> Bool
    func currentTime() -> CMTime
    func seekTo(_ value: CMTime)
    func canPlayFastForward() -> Bool
    func canPlaySlowForward() -> Bool
    func getRate() -> Float
    func setRate(_ rate: Float)
    func duration() -> CMTime
    func loadedTimeRanges() -> [CMTimeRange]
    func isPaused() -> Bool
    func isEnded() -> Bool
    func isSeeking() -> Bool
    func getBitrate() -> Double
    func getURL() -> String?
    func getCurrentURL() -> String?
    func getQualityList() -> [HolaHLSLevelInfo]
    func setQuality(withURL url: String?) throws
}

public class SparkPlayer: UIViewController {
    private static var observerContext = 0

    static func getResourceBundle() -> Bundle? {
        let bundle = Bundle(for: SparkPlayer.self)
        guard let bundleURL = bundle.url(forResource: "SparkPlayer", withExtension: "bundle") else {
            return nil
        }
        guard let resourceBundle = Bundle(url: bundleURL) else {
            return nil
        }

        return resourceBundle
    }

    // player handling
    private var playerLayer: AVPlayerLayer!
    private var timeObserverToken: Any?
    private var paused = true
    private var _rate: Float = 1
    private var seeking = false
    private weak var currentItem: AVPlayerItem? {
        willSet {
            unbindCurrentItem()
        }
        didSet {
            bindCurrentItem()
        }
    }

    // views handling
    private var inlineController: SparkPlayerInlineController!
    private var fullscreenController: SparkPlayerFullscreenController!
    private var fullscreen = false
    private var inlineFrame: CGRect?

    // Spark handling
    var sparkAPI: SparkAPI? {
        return SparkAPI.getAPI(nil)
    }

    var sparkProxy: SparkLibJSDelegate?

    public var player: AVPlayer? {
        willSet {
            unbindPlayerEvents()
        }
        didSet {
            setup()
        }
    }

    var activeController: SparkPlayerController {
        get {
            return fullscreen ? fullscreenController : inlineController
        }
    }

    public var allowAutoFullscreen = true
    public var limitControlsWidth = false

    func getAPI(forCustomer id: String? = nil) {

    }

    public override func viewDidLoad() {
        view.backgroundColor = UIColor.black

        playerLayer = AVPlayerLayer()
        if let player = self.player {
            playerLayer.player = player
        }

        inlineController = SparkPlayerInlineController()
        inlineController.delegate = self
        inlineController.playerLayer = playerLayer

        fullscreenController = SparkPlayerFullscreenController()
        fullscreenController.delegate = self

        // XXX alexeym TODO: fix transition animation
        //fullscreenController.transitioningDelegate = self

        view.autoresizesSubviews = true

        self.addChildViewController(inlineController)
        view.addSubview(inlineController.view)

        NotificationCenter.default.addObserver(self, selector: #selector(SparkPlayer.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width:CGFloat

        if (limitControlsWidth && playerLayer.videoRect.width > 0) {
            width = min(view.frame.width, playerLayer.videoRect.width)
        } else {
            width = view.frame.width
        }

        inlineController.view.frame.size = CGSize(width: width, height: view.frame.height)
        inlineController.view.center = view.center
    }

    @objc func rotated() {
        if (!allowAutoFullscreen || !UIDevice.current.orientation.isValidInterfaceOrientation || UIDevice.current.orientation == .portraitUpsideDown) {
            return
        }

        let topViewController = self.topMostViewController()
        if (!topViewController.shouldAutorotate) {
            return
        }

        if (UIDevice.current.orientation.isLandscape) {
            setFullscreen(true)
        } else {
            setFullscreen(false)
        }
    }

    func setup() {
        if let layer = self.playerLayer {
            layer.player = self.player
        }

        guard let player = self.player else {
            return
        }

        bindPlayerEvents()
    }

    func setFullscreen(_ fullscreen: Bool) {
        if (self.fullscreen == fullscreen) {
            return
        }

        if (fullscreen) {
            fullscreenController.isFullscreen = true
            self.present(fullscreenController, animated: true, completion: nil)
            fullscreenController.playerLayer = playerLayer
            fullscreenController.sparkView.setFullscreen(true)
        } else {
            fullscreenController.sparkView.setFullscreen(false)
            fullscreenController.isFullscreen = false
            fullscreenController.dismiss(animated: true, completion: nil)
            inlineController.playerLayer = playerLayer
        }

        self.fullscreen = fullscreen
    }

    func onTransitionEnded() {

    }


    func bindPlayerEvents() {
        guard let player = self.player else {
            return
        }

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (time) -> Void in
            self.activeController.timeupdate()
            self.sparkProxy?.on_timeupdate(NSNumber(value: time.seconds))
            if (self.isEnded()) {
                self.sparkProxy?.on_ended()
            }
        }

        if let item = player.currentItem {
            handlePlayerItem(item)
        }

        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: &SparkPlayer.observerContext)
        player.addObserver(self, forKeyPath: "currentItem", options: NSKeyValueObservingOptions.new, context: &SparkPlayer.observerContext)
    }

    func unbindPlayerEvents() {
        currentItem = nil

        guard let player = self.player else {
            return
        }

        if let token = self.timeObserverToken {
            player.removeTimeObserver(token)
        }

        player.removeObserver(self, forKeyPath: "rate")
        player.removeObserver(self, forKeyPath: "currentItem")
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath, context == &SparkPlayer.observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if let player = object as? AVPlayer {
            switch key {
            case "rate":
                if (player.rate == 0) {
                    onPaused()
                } else if (paused) {
                    onPlay()
                }
            case "currentItem":
                if let newItem = player.currentItem {
                    if let _ = newItem.asset as? SparkPlayerHLSAsset {
                        // do not do anything if we're switching to own item
                        return
                    }

                    handlePlayerItem(newItem)
                } else {
                    currentItem = nil
                }
            default:
                return
            }
        }

        if let item = object as? AVPlayerItem {
            switch key {
            case "status":
                if (seeking == true && item.status == .readyToPlay) {
                    onSeeked();
                }
            default:
                return
            }
        }
    }

    func handlePlayerItem(_ item: AVPlayerItem) {
        guard let asset = item.asset as? AVURLAsset else {
            print("AVURLAsset is required")
            currentItem = item
            return
        }

        let sparkAsset = SparkPlayerHLSAsset(url: asset.url)
        let sparkItem = AVPlayerItem(asset: sparkAsset)

        currentItem = sparkItem

        player?.replaceCurrentItem(with: sparkItem)
    }

    func bindCurrentItem() {
        guard let item = currentItem else {
            return
        }

        // XXX alexeym: disabled, work in progress
        if (false) {
        sparkProxy = sparkAPI?.addPlayerProxy(item)
        }
        item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: &SparkPlayer.observerContext)
    }

    func unbindCurrentItem() {
        guard let item = currentItem else {
            return
        }

        // XXX alexeym: disabled, work in progress
        if (false) {
        sparkProxy = nil
        sparkAPI?.removePlayerProxy(item)
        }
        item.removeObserver(self, forKeyPath: "status", context: &SparkPlayer.observerContext)
    }

}

extension SparkPlayer: SparkPlayerDelegate {
    func onPlayClick() {
        guard let player = self.player else {
            return
        }

        if (player.rate == 0) {
            if (isEnded()) {
                player.seek(to: kCMTimeZero)
            }
            player.rate = _rate
        } else {
            player.pause()
        }
    }

    func onFullscreenClick() {
        setFullscreen(!self.fullscreen)
    }

    func isLive() -> Bool {
        return player?.currentItem?.status == .readyToPlay && player?.currentItem?.duration.isIndefinite == true
    }

    func currentTime() -> CMTime {
        guard let player = self.player else {
            return CMTimeMakeWithSeconds(0, 1)
        }

        return player.currentTime()
    }

    func isEnded() -> Bool {
        guard
            let player = self.player,
            let item = self.player?.currentItem else
        {
            return false
        }

        return player.rate == 0 && item.currentTime() == item.duration
    }

    func seekTo(_ value: CMTime) {
        seeking = true
        sparkProxy?.on_seeking()
        player?.seek(to: value, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }

    func onSeeked() {
        seeking = false
        sparkProxy?.on_seeked()
    }

    func isSeeking() -> Bool {
        return seeking
    }

    func canPlayFastForward() -> Bool {
        return player?.currentItem?.canPlayFastForward ?? false
    }

    func canPlaySlowForward() -> Bool {
        return player?.currentItem?.canPlaySlowForward ?? false
    }

    func getRate() -> Float {
        return isPaused() ? _rate : (player?.rate ?? _rate)
    }

    func setRate(_ rate: Float) {
        _rate = rate
        if (!isPaused()) {
            player?.rate = _rate
        }
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

    func isPaused() -> Bool {
        guard let player = self.player else {
            return true
        }
        
        return player.rate == 0
    }

    func onPlay() {
        paused = false
        activeController.onPlayPause()
        activeController.activateView()
        sparkProxy?.on_play()
    }

    func onPaused() {
        paused = true
        activeController.onPlayPause()
        activeController.activateView()
        sparkProxy?.on_pause()
    }

    func getCurrentURL() -> String? {
        guard let asset = player?.currentItem?.asset as? AVURLAsset else {
            return nil
        }

        return asset.url.absoluteString
    }

    func getURL() -> String? {
        guard let asset = player?.currentItem?.asset as? AVURLAsset else {
            return nil
        }

        guard let sparkAsset = asset as? SparkPlayerHLSAsset else {
            return asset.url.absoluteString
        }

        return sparkAsset.getOriginURL()
    }

    func getBitrate() -> Double {
        guard
            let logs = player?.currentItem?.accessLog(),
            let lastEntry = logs.events.last
        else {
            return 0
        }

        return lastEntry.indicatedBitrate < 0 ? round(lastEntry.observedBitrate) : lastEntry.indicatedBitrate
    }

    func getQualityList() -> [HolaHLSLevelInfo] {
        guard let asset = player?.currentItem?.asset as? SparkPlayerHLSAsset else {
            return []
        }

        return asset.getLevels()
    }

    func setQuality(withURL url: String? = nil) throws {
        guard let asset = player?.currentItem?.asset as? SparkPlayerHLSAsset else {
            throw SparkPlayerAssetError.NotASparkAsset
        }

        if let newAsset = asset.getQualityAsset(forURL: url) {
            let isPaused = self.isPaused()
            player?.pause()

            let currentTime = self.currentTime()

            let newItem = AVPlayerItem(asset: newAsset)
            player?.replaceCurrentItem(with: newItem)

            self.seekTo(currentTime)

            if (!isPaused) {
                player?.rate = _rate
            }
        }
    }
}

protocol SparkPlayerTransitionDelegate {
    func didFullscreenAppear()
    func didFullscreenDismissed()
}

extension SparkPlayer: SparkPlayerTransitionDelegate {
    func didFullscreenAppear() {
        fullscreenController.isFullscreen = true
    }

    func didFullscreenDismissed() {
        onTransitionEnded()
    }
}

extension SparkPlayer: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let origin = inlineController.view.convert(inlineController.view.frame.origin, to: inlineController.view.window!.screen.fixedCoordinateSpace)
        inlineFrame = CGRect(origin: origin, size: inlineController.view.frame.size)
        return FullscreenRotationAnimator(originFrame: inlineFrame!, delegate: self)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let originFrame: CGRect
        if let inlineFrame = self.inlineFrame {
            originFrame = inlineFrame
        } else {
            originFrame = CGRect(origin: CGPoint.zero, size: inlineController.view.frame.size)
        }

        return FullscreenRotationDismissAnimator(originFrame: originFrame, delegate: self)
    }

    
}

extension SparkPlayer: SparkLibPlayerDelegate {
    /*public func get_thumbnails_delegate() -> SparkThumbnailsDelegate {

    }*/
}

// public API
public extension SparkPlayer {
    func isFullscreen() -> Bool {
        return self.fullscreen
    }
}
