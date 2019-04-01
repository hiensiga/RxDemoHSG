//
//  GGCompleteSuggestion.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/26/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import Foundation
import EVReflection

class GGCompleteSuggestion: EVObject {
    var suggestion: Suggestion?
}

class Suggestion: EVObject {
    var _data: String?
}

class TopLevel: EVObject {
    var completeSuggestion: [GGCompleteSuggestion] = [GGCompleteSuggestion]()
}
