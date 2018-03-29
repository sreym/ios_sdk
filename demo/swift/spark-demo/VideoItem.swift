//
//  VideoItem.swift
//  spark-demo
//
//  Created by alexeym on 01/03/2018.
//  Copyright © 2018 holaspark. All rights reserved.
//

import Foundation
import SparkLib

class VideoItem {

    var info: SparkVideoItem?

    init(info: SparkVideoItem) {
        self.info = info
    }

    func getUrl() -> URL {
        return (self.info?.url)!;
    }
    
    func getPoster() -> URL? {
        return self.info?.videoPoster ?? self.info?.poster ?? nil
    }

    func getTitle() -> String {
        return self.info?.title ?? self.info?.desc ?? ""
    }


    private var _poster: UIImage?
    func getPosterImage() -> UIImage? {
        if let poster = _poster {
            return poster
        }

        if
            let poster = getPoster(),
            let previewData = try? Data(contentsOf: poster)
        {
            self._poster = UIImage(data: previewData)
        } else {
            // XXX alexeym: add an error icon
        }

        return _poster
    }

    static func getVideoItems(completionHandler:
        @escaping ([VideoItem]?, Error?) -> Void) -> URLSessionDataTask?
    {
        // period priority:
        // - 1d: prefered for active customers, it will most certainly contain
        // preview-guaranteed videos
        // - 1h, 6h: fallback aimed for customers with no recent activity,
        // it enables us to quickly populate playlist with recent videos
        // through manual views (max propagation time 15min)
        // - new: last resort, list of latest videos ever known on the customer
        let periods = ["1d", "1h", "6h", "new"]
        let vnum = UserDefaults.standard.integer(forKey: "videos_per_customer")
        let hits = UInt(vnum*2) // load more as there may be incomplete results
        return SparkAPI.getAPI(nil).getPopularVideos(hits, overLast: periods)
        { (result, err) in
            if (err != nil) {
                return completionHandler(nil, err)
            }
            var playlist = [] as! [VideoItem]
            for period in periods {
                guard let period_popular = result?["customer_popular_"+period]
                    else { continue }
                var period_items = period_popular.map({ (info) -> VideoItem in
                    return VideoItem(info: info)
                })
                period_items = period_items.filter({ (item) -> Bool in
                    return item.getPoster() != nil && item.getTitle() != ""
                })
                period_items = period_items.filter({ (item) -> Bool in
                    return !playlist.contains(where: { (pitem) -> Bool in
                        return pitem.getUrl()==item.getUrl() })
                })
                let needed = vnum - playlist.count
                if (period_items.count>needed) {
                    period_items.removeSubrange(needed..<period_items.count)
                }
                print("using \(period) playlist with \(period_items.count) videos")
                playlist.append(contentsOf: period_items)
                if (playlist.count>=vnum) {
                    break
                }
            }
            return completionHandler(playlist, nil)
        }
    }
}
