//
//  YTVideo.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/25/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import Foundation
import ObjectMapper

/* refs:
    https://stackoverflow.com/questions/43269448/objectmapper-how-to-map-different-object-based-on-json
*/

let ytDateFormatter = DateFormatter(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", locale: "") // ISO 8601

class YTSearchResult: Mappable {
    
    var kind: String = ""
    var etag: String?
    var id: YTId?
    var snippet: YTSnippet?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        kind <- map["kind"]
        etag <- map["etag"]
        id <- map["id"]
        snippet <- map["snippet"]
        
    }
}

struct YTSnippet: Mappable {
    
    var title: String = ""
    var publishedAt: Date?
    var channelId: String?
    var description: String?
    var channelTitle: String?
    var thumbnail: String?
    var liveBroadcastContent: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        title <- map["title"]
        publishedAt <- (map["publishedAt"], DateFormatterTransform(dateFormatter: ytDateFormatter))
        channelId <- map["channelId"]
        description <- map["description"]
        channelTitle <- map["channelTitle"]
        thumbnail <- map["thumbnails.medium.url"]
        liveBroadcastContent <- map["liveBroadcastContent"]
    }
}

struct YTId: Mappable {
    
    var kind: String = ""
    var videoId: String?
    var playlistId: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        kind <- map["kind"]
        videoId   <- map["videoId"]
        playlistId   <- map["playlistId"]
    }
}

class YTVideo: YTSearchResult {
    
    var videoId: String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        videoId <- map["id.videoId"]
    }
}

class YTPlaylist: YTSearchResult {
    
    var playlistId: String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        playlistId <- map["id.playlistId"]
    }
}


// DATA SAMPLE
/*
 {
 "kind": "youtube#searchResult",
 "etag": "\"XpPGQXPnxQJhLgs6enD_n8JR4Qk/PgFrYlF5gzR7TquNnQhqWi3NFDM\"",
 "id": {
 "kind": "youtube#video",
 "videoId": "jprkgEPrcDY"
 },
 "snippet": {
 "publishedAt": "2018-10-15T16:44:50.000Z",
 "channelId": "UCHKuLpFy9q8XDp0i9WNHkDw",
 "title": "Chung Kết Thế Giới 2018 | Vòng Bảng [Ngày 6]",
 "description": "Vietnam Esports TV giữ bản quyền toàn bộ nội dung. Vietnam eSports TV là kênh truyền hình thể thao điện tử số 1 tại Việt Nam phát sóng trực tiếp hàng ngày...",
 "thumbnails": {
 "default": {
 "url": "https://i.ytimg.com/vi/jprkgEPrcDY/default.jpg",
 "width": 120,
 "height": 90
 },
 "medium": {
 "url": "https://i.ytimg.com/vi/jprkgEPrcDY/mqdefault.jpg",
 "width": 320,
 "height": 180
 },
 "high": {
 "url": "https://i.ytimg.com/vi/jprkgEPrcDY/hqdefault.jpg",
 "width": 480,
 "height": 360
 }
 },
 "channelTitle": "Vietnam Esports TV",
 "liveBroadcastContent": "none"
 }
 },
 
 {
 "kind": "youtube#searchResult",
 "etag": "\"XpPGQXPnxQJhLgs6enD_n8JR4Qk/olKiqYWTQ5c9_A-zFkqU-yrlnDg\"",
 "id": {
 "kind": "youtube#playlist",
 "playlistId": "PLuYYxO0kXGgk9220UB1EzfWYXJjhBSUjy"
 },
 "snippet": {
 "publishedAt": "2017-04-28T19:38:14.000Z",
 "channelId": "UCXF4WjTCUQSmGapnNEZzbYw",
 "title": "MSI 2017",
 "description": "",
 "thumbnails": {
 "default": {
 "url": "https://i.ytimg.com/vi/k4MUcp9vH40/default.jpg",
 "width": 120,
 "height": 90
 },
 "medium": {
 "url": "https://i.ytimg.com/vi/k4MUcp9vH40/mqdefault.jpg",
 "width": 320,
 "height": 180
 },
 "high": {
 "url": "https://i.ytimg.com/vi/k4MUcp9vH40/hqdefault.jpg",
 "width": 480,
 "height": 360
 }
 },
 "channelTitle": "VETV7 ESPORTS",
 "liveBroadcastContent": "none"
 }
 },
 */
