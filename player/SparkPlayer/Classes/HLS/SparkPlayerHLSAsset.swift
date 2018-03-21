//
//  SparkPlayerHLSAsset.swift
//  SparkPlayer
//
//  Created by norlin on 12/03/2018.
//

import AVFoundation

enum SparkPlayerAssetError: Error {
    case NotASparkAsset
}

class SparkPlayerHLSAsset: AVURLAsset {
    private let loader: SparkPlayerLoaderDelegate
    private var originAsset: SparkPlayerHLSAsset?
    private var levels: [HolaHLSLevelInfo]?

    override init(url URL: URL, options: [String : Any]? = nil) {
        let url = HolaHLSParser.applyCDNScheme(URL, andType: .fetch)!
        loader = SparkPlayerLoaderDelegate()

        super.init(url: url, options: options)

        self.resourceLoader.setDelegate(loader, queue: SparkPlayerLoaderDelegate.queue)
    }

    private convenience init(url: URL, originAsset: SparkPlayerHLSAsset) {
        self.init(url: url)

        self.originAsset = originAsset
        self.levels = originAsset.getLevels()
    }

    func getLevels() -> [HolaHLSLevelInfo] {
        if let levels = self.levels {
            return levels
        }

        let levels = loader.getLevels()
        self.levels = levels
        return levels
    }

    func getQualityAsset(forURL url: String? = nil) -> SparkPlayerHLSAsset? {
        if let origin = self.originAsset {
            return origin.getQualityAsset(forURL: url)
        }

        // next code must only be executed for the original asset itself
        guard let _url = url else {
            return self
        }

        let levels = getLevels()
        if
            let newLevel = (levels.first{ $0.url == _url}),
            let url = URL(string: newLevel.url)
        {
            return SparkPlayerHLSAsset(url: url, originAsset: self)
        }

        return nil
    }

    func getOriginURL() -> String {
        return originAsset?.url.absoluteString ?? self.url.absoluteString
    }
}
