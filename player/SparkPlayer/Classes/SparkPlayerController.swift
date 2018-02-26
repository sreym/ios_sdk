//
//  SparkPlayerController.swift
//  SparkPlayer
//
//  Created by spark on 13/02/2018.
//

import AVKit

class SparkPlayerController: UIViewController {
    var UINibName: String {
        get { return "SparkPlayerView" }
    }

    public override func loadView() {
        let bundle = Bundle(for: SparkPlayer.self)
        guard let bundleURL = bundle.url(forResource: "SparkPlayer", withExtension: "bundle") else {
            return super.loadView()
        }
        guard let resourceBundle = Bundle(url: bundleURL) else {
            return super.loadView()
        }
        resourceBundle.loadNibNamed(UINibName, owner: self, options: nil)
    }

    var delegate: SparkPlayerDelegate?
    var timeFormatter: DateComponentsFormatter!
    var timeFont: UIFont!
    var timeHeight: CGFloat!

    var playerLayer: AVPlayerLayer? {
        didSet {
            if let layer = self.playerLayer {
                self.view.layer.insertSublayer(layer, at: 0)
                resizePlayerLayer()
            }
        }
    }

    var seeking = false

    override func viewDidLoad() {
        super.viewDidLoad()

        timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]

        let tap = UITapGestureRecognizer(target: self, action: #selector(SparkPlayerController.onPlayerTap(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let view = getView()
        timeFont = view.currentTimeLabel.font
        timeHeight = view.currentTimeLabel.frame.height

        // update UI with player's data
        self.timeupdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let view = getView()
        view.positionSlider.setThumbState(.Normal)
    }

    func resizePlayerLayer() {
        // XXX alexeym TODO: display controls only above real video frame
        if let layer = self.playerLayer {
            layer.frame.origin = CGPoint.zero
            layer.frame.size = self.view.frame.size
        }
    }

    override func viewDidLayoutSubviews() {
        resizePlayerLayer()
    }

    func getView() -> SparkPlayerView {
        return self.view as! SparkPlayerView
    }

    func setSliderState(_ state: ThumbStates) {
        let view = getView()
        view.positionSlider.setThumbState(state)
    }

    func onSeekStart() {
        seeking = true
        let view = getView()
        view.positionSlider.setThumbState(.Highlighted)
        seeking = true
    }

    func onSeekEnd() {
        setSliderState(.Focused)
        seeking = false

        if let delegate = self.delegate {
            let view = getView()
            let time = CMTimeMakeWithSeconds(Float64(view.positionSlider.value), Int32(NSEC_PER_SEC))
            delegate.seekTo(time)
        }
    }

    func formatTime(_ time: CMTime) -> String {
        let seconds = time.seconds
        if (!time.isValid || time.isIndefinite || seconds == 0) {
            return "0:00"
        }
        let result = timeFormatter.string(from: TimeInterval(time.seconds))!
        return "\(seconds < 60 ? "0:" : "")\(result)"
    }
}

// Handling Player events
extension SparkPlayerController {
    func timeupdate() {
        guard let delegate = self.delegate else {
            return
        }

        let view = getView()
        let duration = delegate.duration()
        let currentTime = delegate.currentTime()

        if (!seeking) {
            view.positionSlider.maximumValue = Float(duration.seconds)
            view.positionSlider.value = Float(currentTime.seconds)
        }
        view.positionSlider.loaded = delegate.loadedTimeRanges()

        let durationString = formatTime(duration)
        view.durationLabel.text = durationString
        view.durationWidth.constant = durationString.width(withFont: timeFont)

        let currentTimeString = formatTime(currentTime)
        view.currentTimeLabel.text = currentTimeString
        view.currentTimeWidth.constant = currentTimeString.width(withFont: timeFont)
    }
}

// Controls handling
extension SparkPlayerController {
    @objc func onPlayerTap(_ gestureRecognizer: UITapGestureRecognizer) {
        setSliderState(.Focused)
    }

    @IBAction func onPlayButton(sender: UIButton!) {
        if let delegate = self.delegate {
            delegate.onPlayClick()
        }
    }

    @IBAction func onFsButton(sender: UIButton!) {
        if let delegate = self.delegate {
            delegate.onFullscreenClick()
        }
    }

    @IBAction func onSliderDown(sender: UISlider!) {
        onSeekStart()
    }

    @IBAction func onSliderDrag(sender: UISlider!) {
        // XXX alexeym TODO: add/update new time tooltip
    }

    @IBAction func onSliderUp(sender: UISlider!) {
        onSeekEnd()
    }
}
