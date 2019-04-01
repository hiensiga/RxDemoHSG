//
//  GoogleSuggestionViewController.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/27/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

protocol SuggestionDelegate: class {
    func didSelected(text: String)
}


class GoogleSuggestionViewController: UIViewController {

    let textSearch = BehaviorRelay<String>(value: "")
    let disposeBag = DisposeBag()
    var provider: MoyaProvider<GGSuggestionAPI>!
    var searchBar: UISearchBar!
    weak var searchController: UISearchController?
    weak var delegate: SuggestionDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRx()
    }
    
    func setupRx() {
        provider = MoyaProvider<GGSuggestionAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])
        
        textSearch.filter { $0.count >= 3 }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance).flatMapLatest { text -> Single<[String]> in
            print("> Search text: \(text)")
            return self.suggestion(text)
            }.catchErrorJustReturn([]).asObservable().bind(to: tableView.rx.items) { (tableView, row, item) in
                var cell: UITableViewCell!
                cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell")
                if cell == nil {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "suggestionCell")
                }
                cell.textLabel?.text = item
                return cell
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { item in
//                self.pushToVideoSearch(text: item)
//                self.searchController?.searchBar.endEditing(true)
                self.delegate?.didSelected(text: item)
                self.searchController?.isActive = false
            })
            .disposed(by: disposeBag)
    }
    
    func suggestion(_ text: String) -> Single<[String]> {
        
        return provider.rx.request(GGSuggestionAPI.searchXML(text))
            .RmapXml(to: TopLevel.self)
            .map { (toplevel) -> [String] in
                return toplevel.completeSuggestion.map { $0.suggestion?._data ?? "" }.filter { $0.count > 0 }
        }
    }
}

extension GoogleSuggestionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        textSearch.accept(text)
        
        self.searchBar = searchController.searchBar
    }
}

extension GoogleSuggestionViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("> searchBarTextDidEndEditing: \(searchBar) - \(searchBar.text)")
        if let text = searchBar.text, text.count > 0 {
            self.delegate?.didSelected(text: text)
        }
    }
}
