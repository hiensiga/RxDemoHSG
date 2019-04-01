//
//  YTSearchAPI.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/25/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import SwiftyJSON
import ObjectMapper
import Moya_ObjectMapper

struct YTSearchProvider {

    let provider: MoyaProvider<YTSearchAPI>

    // https://www.googleapis.com/youtube/v3/search?part=snippet&order=viewCount&q=vetv&type=video&key=AIzaSyDgKu2bNUnQSPjURIjIkbtzsB4djkVXUXM
    public func searchVideos_v1(text: String) {
//        return self.provider.rx.request(YTSearchEndPoint.searchVideo(text: text))
        self.provider.request(YTSearchAPI.searchVideo(text: text), completion: { (result) in
            switch result {
            case let .success(response):
                print("> moya success: \(response)")
                
                if let json = try? JSON(data: response.data) {
                    print("> json: \(json)")
                    if let dict = json.dictionaryObject {
                        let res = Mapper<YTResults<YTVideo>>().map(JSON: dict)
                        print("> res: \(res)")
                    }
                }
                
            case let .failure(error):
                print("> moya failure: \(error)")
            }
        })
    }
    
    public func searchPlaylists_v1(text: String) {
        self.provider.request(YTSearchAPI.searchPlaylist(text: text, maxResults: 2), completion: { (result) in
            switch result {
            case let .success(response):
                print("> moya success: \(response)")
                if let playlists = try? response.mapObject(YTResults<YTPlaylist>.self) {
                    print("> playlists: \(playlists)")
                }
                
            case let .failure(error):
                print("> moya failure: \(error)")
            }
        })
    }
    
    public func rx_searchVideo(_ text: String) -> Single<YTResults<YTVideo>> {
        return provider.rx.request(YTSearchAPI.searchVideo(text: text))
        .mapObject(YTResults<YTVideo>.self)
    }
    
    public func rx_searchVideoPlaylist(_ text: String, pageToken: String? = nil) -> Single<YTResults<YTSearchResult>> {
        return provider.rx.request(YTSearchAPI.searchVideoPlaylist(text: text, maxResults: 2, pageToken: pageToken))
            .mapObject(YTResults<YTSearchResult>.self)
    }
    
}
