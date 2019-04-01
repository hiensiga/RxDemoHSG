//
//  YTResults.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/26/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import Foundation
import ObjectMapper

struct YTResults<T: YTSearchResult>: Mappable {
    
    var kind: String?
    var etag: String?
    var nextPageToken: String?
    var prevPageToken: String?
    var regionCode: String?
    var pageInfo: YTPageInfo?
    var items: [YTSearchResult]?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        kind    <- map["kind"]
        etag    <- map["etag"]
        nextPageToken    <- map["nextPageToken"]
        prevPageToken    <- map["prevPageToken"]
        regionCode    <- map["regionCode"]
        pageInfo    <- map["pageInfo"]
        items       <- (map["items"], YTSearchResultArrayTransformType())
    }
}

struct YTPageInfo: Mappable {
    
    var totalResults: Int?
    var resultsPerPage: Int?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        totalResults    <- map["totalResults"]
        resultsPerPage  <- map["resultsPerPage"]
    }
}

class YTSearchResultArrayTransformType: TransformType {
    
    public typealias Object = [YTSearchResult]
    public typealias JSON = [[String:Any]]
    
    func transformToJSON(_ value: [YTSearchResult]?) -> [[String : Any]]? {
        if let items = value {
            var result = [[String : Any]]()
            for item in items {
                result.append(item.toJSON())
            }
            return result
        }
        return nil
    }
    
    func transformFromJSON(_ value: Any?) -> [YTSearchResult]? {
        if let items = value as? [[String: Any]] {
            var result = [YTSearchResult]()
            for item in items {
                if let id = item["id"] as? [String: Any], let kind = id["kind"] as? String {
                    if kind == "youtube#playlist", let playlist = YTPlaylist(JSON: item) {
                        result.append(playlist)
                    } else if kind == "youtube#video", let video = YTVideo(JSON: item) {
                        result.append(video)
                    }
                }
            }
            return result
        }
        return nil
    }
}
