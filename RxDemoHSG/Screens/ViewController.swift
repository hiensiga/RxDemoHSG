//
//  ViewController.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/25/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import EVReflection

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    let provider = YTSearchProvider(provider: MoyaProvider<YTSearchAPI>(plugins: [NetworkLoggerPlugin(verbose: true)]))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // provider.searchVideos_v1(text: "vetv")
        
        
        
        
    }

    @IBAction func tapVideo(_ sender: Any) {
        provider.searchVideos_v1(text: "vetv")
    }
    
    @IBAction func tapPlaylist(_ sender: Any) {
        provider.searchPlaylists_v1(text: "vetv")
    }
    
    @IBAction func tapRxVideo(_ sender: Any) {
        provider.rx_searchVideo("vetv").debug().subscribe { (result) in
            switch result {
            case .success(let response):
                    print("> success: \(response)")
            case .error(let error):
                print("> error: \(error)")
            }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func tapRxPlaylist(_ sender: Any) {
        
        
    }
    
    @IBAction func tapGGSuggestion(_ sender: Any) {
        
        let provider = MoyaProvider<GGSuggestionAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])
        provider.rx.request(GGSuggestionAPI.searchXML("vetv")).RmapXml(to: TopLevel.self).map { (toplevel) -> [String] in
            // print("> top level: \(toplevel)")
            return toplevel.completeSuggestion.map { $0.suggestion?._data ?? "" }.filter { $0.count > 0 }
        }.subscribe { (result) in
                switch result {
                case .success(let x):
                    print("> success: \(x)")
                case .error(let error):
                    print("> error: \(error)")
                }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func tapRxPaging(_ sender: Any) {
        
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YTSearchViewController") as! YTSearchViewController
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    
}

