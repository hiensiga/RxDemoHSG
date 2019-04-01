//
//  YTSearchEndPoint.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/25/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import Foundation
import Moya

// https://medium.com/swift-india/rxswift-traits-5240965c4f12

let YOUTUBE_API_KEY = "AIzaSyDgKu2bNUnQSPjURIjIkbtzsB4djkVXUXM"

public extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}

enum YTSearchAPI {
    case searchVideo(text: String)
    case searchPlaylist(text: String, maxResults: Int?)
    case searchVideoPlaylist(text: String, maxResults: Int?, pageToken: String?)
}

extension YTSearchAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.googleapis.com/youtube/v3")!
    }
    
    var path: String {
        return "/search"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        
        switch self {
        case .searchVideoPlaylist(_, _, let pageToken):
            let filename = "Search-Messi-\(pageToken ?? "")"
            return stubbedResponse(filename) ?? "".data(using: .utf8)!
        default: break
        }
        return "".data(using: .utf8)!
    }
    
    var task: Moya.Task {
        switch self {
        case .searchVideo(let text):
            return .requestParameters(parameters: ["part": "snippet", "order" : "viewCount", "q" : text, "type" : "video", "key" : YOUTUBE_API_KEY], encoding: URLEncoding.default)
        case .searchPlaylist(let text, let maxResults):
            return .requestParameters(parameters: ["part": "snippet", "order" : "viewCount", "q" : text, "type" : "playlist", "maxResults": "\(maxResults ?? 5)", "key" : YOUTUBE_API_KEY], encoding: URLEncoding.default)
        case .searchVideoPlaylist(let text, let maxResults, let pageToken):
            return .requestParameters(parameters: ["part": "snippet", "order" : "viewCount", "q" : text, "type" : "video,playlist", "maxResults": "\(maxResults ?? 5)", "pageToken": (pageToken ?? ""), "key" : YOUTUBE_API_KEY], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.queryString
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}

func stubbedResponse(_ filename: String) -> Data? {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    if let path = bundle.path(forResource: filename, ofType: "json") {
        let url = URL(fileURLWithPath: path)
        return try? Data(contentsOf: url)
    }
    return nil
}
