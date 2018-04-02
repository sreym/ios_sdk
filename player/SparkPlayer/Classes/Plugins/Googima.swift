import GoogleInteractiveMediaAds

public class GoogimaPlugin: NSObject, PluginInterface, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    static var name: String! { return "googima" }
    static private var observerContext = 0
    private var _config: Dictionary<String, Any>!
    private var _viewController: UIViewController!
    private var _contentPlayer: AVPlayer?
    private var _contentItem: AVPlayerItem?
    private var _contentPlayhead: IMAAVPlayerContentPlayhead?
    private var _adsLoader: IMAAdsLoader!
    private var _adsManager: IMAAdsManager!
    private var _pendingAdRequest = false
    
    required public init(config: Dictionary<String, Any>!) {
        super.init()
        _config = config
        _adsLoader = IMAAdsLoader(settings: nil)
        _adsLoader.delegate = self
    }
    
    func onViewReady(controller: UIViewController!) {
        self._viewController = controller
        _requestAds()
    }
    
    func onPlayerItemChange(player: AVPlayer?, item: AVPlayerItem?) {
        if (player != _contentPlayer) {
            _videoDetach()
            _playerDetach()
            _contentPlayer = player
            _contentItem = nil
            _playerAttach()
        }
        if (_contentPlayer == nil) {
            return
        }
        if (item != _contentItem) {
            _videoDetach();
            _contentItem = item
            _videoAttach()
        }
        if (_contentItem==nil) {
            return
        }
        _pendingAdRequest = true
        _requestAds()
    }
    
    private func _playerAttach() {
        if (_contentPlayer==nil) {
            return
        }
        _contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: _contentPlayer)
        _contentPlayer?.addObserver(self, forKeyPath: "rate",
            options: NSKeyValueObservingOptions.new,
            context: &GoogimaPlugin.observerContext)
    }
    
    private func _playerDetach() {
        if (_contentPlayer==nil) {
            return
        }
        _contentPlayer?.removeObserver(self, forKeyPath: "rate",
            context: &GoogimaPlugin.observerContext)
        _contentPlayhead = nil
    }
    
    private func _videoAttach(){
        if (_contentItem==nil) {
            return
        }
        NotificationCenter.default.addObserver(self,
            selector: #selector(GoogimaPlugin.contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: _contentItem)
    }
    
    private func _videoDetach(){
        if (_contentItem==nil) {
            return
        }
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: _contentItem)
    }
    
    public override func observeValue(forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?)
    {
        if (context != &GoogimaPlugin.observerContext) {
            super.observeValue(forKeyPath: keyPath, of: object, change: change,
                context: context)
            return
        }
        if let key = keyPath, object != nil {
            switch key {
            case "rate":
                _requestAds()
                break
            default: break
            }
        }
    }
    
    private func _requestAds() {
        let rate = _contentPlayer?.rate ?? 0
        if (_viewController==nil || !_pendingAdRequest || rate<=0) {
            return
        }
        _pendingAdRequest = false
        // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(
            adContainer: _viewController.view,
            companionSlots: nil)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: _config["adTagUrl"] as? String,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: _contentPlayhead,
            userContext: nil)
        _adsLoader.requestAds(with: request)
    }

    @objc func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure not to call contentComplete as a result of an ad end.
        if (notification.object as! AVPlayerItem) == _contentItem {
            _adsLoader.contentComplete()
        }
    }
    
    // MARK: - IMAAdsLoaderDelegate
    
    public func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
        _adsManager = adsLoadedData.adsManager
        _adsManager.delegate = self
        // Create ads rendering settings and tell the SDK to use the in-app browser.
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = _viewController
        // Initialize the ads manager.
        _adsManager.initialize(with: adsRenderingSettings)
    }
    
    public func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print("[googima] error loading ads: \(adErrorData.adError.message)")
        _contentPlayer?.play()
    }
    
    // MARK: - IMAAdsManagerDelegate
    
    public func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        if event.type == IMAAdEventType.LOADED {
            _adsManager.start()
        }
    }
    
    public func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        // Something went wrong with the ads manager after ads were loaded.
        // Log the error and play the content.
        print("[googima] ads manager error: \(error.message)")
        _contentPlayer?.play()
    }
    
    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        // The SDK is going to play ads, so pause the content.
        _contentPlayer?.pause()
    }
    
    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        // The SDK is done playing ads (at least for now), so resume the content.
        _contentPlayer?.play()
    }
}
