import AVKit

protocol PluginInterface {
    static var name: String! { get }
    init(config: Dictionary<String, Any>!)
    func onViewReady(controller: UIViewController!) -> Void
    func onPlayerItemChange(player: AVPlayer?, item: AVPlayerItem?) -> Void
}
