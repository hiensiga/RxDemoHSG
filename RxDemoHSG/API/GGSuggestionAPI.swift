//
//  GGSuggestionAPI.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/26/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import Foundation
import Moya

// http://suggestqueries.google.com/complete/search?output=toolbar&hl=en&ds=yt&q=theory
enum GGSuggestionAPI {
    case searchXML(_ text: String)
}

extension GGSuggestionAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://suggestqueries.google.com/complete")!
    }
    
    var path: String {
        return "/search"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Moya.Task {
        switch self {
        case .searchXML(let text):
            return .requestParameters(parameters: ["output": "toolbar", "hl" : "en", "q" : text, "ds" : "yt"], encoding: URLEncoding.default)
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
