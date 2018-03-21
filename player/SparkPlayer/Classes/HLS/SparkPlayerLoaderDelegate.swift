//
//  SparkPlayerLoaderDelegate.swift
//  SparkPlayer
//
//  Created by norlin on 12/03/2018.
//

import AVFoundation

enum SparkPlayerLoaderError: Error {
    case FetchError
    case ParseError
    case DataError
}

class SparkPlayerLoaderDelegate: NSObject {
    static let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    var canManualFetch = true

    private lazy var parser = HolaHLSParser()

    func getLevels() -> [HolaHLSLevelInfo] {
        if let levels = self.parser.getLevelsInfo() {
            return levels
        }

        return []
    }
}

extension SparkPlayerLoaderDelegate: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        return fetch(loadingRequest)
    }

    func copy(_ request: URLRequest, withURL url: URL) -> URLRequest {
        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        mutableRequest.url = url
        return mutableRequest as URLRequest
    }

    private func fetch(_ request: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = request.request.url else {
            return false
        }

        let scheme = HolaHLSParser.mapCDNScheme(url)
        let originURL = HolaHLSParser.applyOriginScheme(url)!

        var originRequest = copy(request.request, withURL: originURL)

        if let dataRequest = request.dataRequest {
            originRequest.addValue("bytes=\(dataRequest.requestedOffset)-\(dataRequest.requestedLength-1)", forHTTPHeaderField: "Range")
        }

        if (self.canManualFetch && scheme == HolaCDNScheme.fetch) {
            URLSession.shared.dataTask(with: originRequest) { (_data, _response, _error) in
                if let error = _error {
                    print(error)
                    request.finishLoading(with: error)
                    return
                }

                guard let data = _data else {
                    print(SparkPlayerLoaderError.FetchError)
                    request.finishLoading(with: SparkPlayerLoaderError.FetchError)
                    return
                }

                if
                    let response = _response,
                    let mime = response.mimeType?.lowercased()
                {
                    if (mime != "application/x-mpegurl" && mime != "application/vnd.apple.mpegurl") {
                        self.canManualFetch = false
                    }
                }

                let parsedData: Data
                if (self.canManualFetch) {
                    guard let manifest = String(data: data, encoding: .utf8) else {
                        print(SparkPlayerLoaderError.FetchError)
                        request.finishLoading(with: SparkPlayerLoaderError.FetchError)
                        return
                    }

                    guard let parsedManifest = try? self.parser.parse(url.absoluteString, andData: manifest) else {
                        print(SparkPlayerLoaderError.ParseError)
                        request.finishLoading(with: SparkPlayerLoaderError.ParseError)
                        return
                    }

                    if let dataFromManifest = parsedManifest.data(using: .utf8) {
                        parsedData = dataFromManifest
                    } else {
                        print(SparkPlayerLoaderError.DataError)
                        request.finishLoading(with: SparkPlayerLoaderError.DataError)
                        return
                    }
                    request.dataRequest?.respond(with: parsedData)
                    request.finishLoading()
                } else {
                    self.redirect(request, to: originRequest)
                }
            } .resume()
        } else {
           redirect(request, to: originRequest)
        }

        return true
    }

    private func redirect(_ request: AVAssetResourceLoadingRequest, to redirect: URLRequest) {
        request.redirect = redirect
        request.response = HTTPURLResponse(url: redirect.url!, statusCode: 302, httpVersion: nil, headerFields: nil)
        request.finishLoading()
    }
}


