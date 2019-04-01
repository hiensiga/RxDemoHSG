//
//  SearchVideoViewController.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/25/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AlamofireImage
import Moya
import SwifterSwift

class SearchVideoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    var provider: YTSearchProvider!
    
    var latestSearchText: Observable<String>!
    
    var searchController: UISearchController!
//    var ytResult: Single<YTResults<YTVideo>>?
    let rxVideos = PublishSubject<[YTVideo]>()
    
    let scopeFilter = BehaviorSubject<Int>(value: 0)
    let searchFilter = BehaviorSubject<String>(value: "")
    
    var textSearch: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupRx()
        
        searchVideo(text: textSearch)
    }
    
    func setupView() {
        
        tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: nil)
        
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            searchController.dimsBackgroundDuringPresentation = true
        }
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            searchController.hidesNavigationBarDuringPresentation = false
            navigationItem.titleView = searchController.searchBar
        }
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
//        searchController.loadViewIfNeeded()
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Type something here to search"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.barTintColor = navigationController?.navigationBar.barTintColor
        searchController.searchBar.tintColor = self.view.tintColor
        searchController.searchBar.scopeButtonTitles = ["All", "Year", "Month"]
        
    }
    
    func setupRx() {
        
        provider = YTSearchProvider(provider: MoyaProvider<YTSearchAPI>(plugins: [NetworkLoggerPlugin(verbose: true)]))
        latestSearchText = searchController.searchBar.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
        
        searchController.searchBar.rx.selectedScopeButtonIndex.bind(to: scopeFilter).disposed(by: disposeBag)
        searchController.searchBar.rx.text.orEmpty.bind(to: searchFilter).disposed(by: disposeBag)
        
        
        Observable.combineLatest(rxVideos, searchFilter, scopeFilter) { items, text, index in
            
            items.filter { video in
                let lText = text.lowercased()
                let isInTime: Bool = {
                    switch index {
                    case 0:
                        return true
                    case 1:
                        return (video.snippet?.publishedAt?.isInCurrentYear ?? false)
                    case 2:
                        return (video.snippet?.publishedAt?.isInCurrentMonth ?? false)
                    default:
                        return false
                    }
                }()
                return (lText.count > 0 ? ((video.snippet?.title.lowercased() ?? "").contains(lText) || (video.snippet?.description?.lowercased() ?? "").contains(lText)) : true)
                    && isInTime
            }
            }.bind(to: tableView.rx.items(cellIdentifier: "videoCell", cellType: YTVideoTableViewCell.self)) { (row, element, cell) in
                if let thumbnail = element.snippet?.thumbnail, let url = URL(string: thumbnail) {
                    cell.ivThumbnail.af_setImage(withURL: url)
                }
                cell.lblTitle.text = element.snippet?.title
                cell.config(element)
            }
            .disposed(by: disposeBag)
        
        /*
        Observable.combineLatest(rxVideos!, searchFilter, scopeFilter) { items, text, index in
            
            items.filter { video in
                print("> items.filter: \(text) - \(index)")
                return true
            }
            }.bind(to: tableView.rx.items(cellIdentifier: "videoCell", cellType: YTVideoTableViewCell.self)) { (row, element, cell) in
                if let thumbnail = element.thumbnail, let url = URL(string: thumbnail) {
                    cell.ivThumbnail.af_setImage(withURL: url)
                }
                cell.lblTitle.text = element.title
                cell.config(element)
            }
            .disposed(by: disposeBag)
        */
//        latestSearchText.observeOn(MainScheduler.instance).flatMapLatest { text -> Single<[String]> in
//            print("> Search text: \(text)")
//            return self.suggestion(text)
//            }.asObservable().bind(to: tableViewVideo.rx.items) { (tableView, row, item) in
//                print("> kakaka")
//                let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: IndexPath(row: row, section: 0))
//                cell.textLabel?.text = item
//                return cell
//        }.disposed(by: disposeBag)
        
//        tableViewVideo
//            .rx.itemSelected
//            .subscribe(onNext: { indexPath in
//                if self.searchBar.isFirstResponder == true {
//                    self.view.endEditing(true)
//                }
//            })
//            .disposed(by: disposeBag)
        
        
//        issueTrackerModel
//            .trackIssues()
//            .bindTo(tableView.rx.items) { (tableView, row, item) in
//                let cell = tableView.dequeueReusableCell(withIdentifier: "issueCell", for: IndexPath(row: row, section: 0))
//                cell.textLabel?.text = item.title
//
//                return cell
//            }
//            .addDisposableTo(disposeBag)
        
        // Here we tell table view that if user clicks on a cell,
        // and the keyboard is still visible, hide it
//        tableView
//            .rx.itemSelected
//            .subscribe(onNext: { indexPath in
//                if self.searchBar.isFirstResponder == true {
//                    self.view.endEditing(true)
//                }
//            })
//            .addDisposableTo(disposeBag)
    }
    
    func searchVideo(text: String) {
        let res = provider.rx_searchVideo(text).debug().flatMap({ (result) -> Single<[YTVideo]> in
            return Single.just(result.items as? [YTVideo] ?? [])
        }).catchErrorJustReturn([])
            .asObservable()
        
        res.bind(to: rxVideos).disposed(by: disposeBag)
        
//            .bind(to: tableView.rx.items(cellIdentifier: "videoCell", cellType: UITableViewCell.self)) { (row, element, cell) in
//                cell.textLabel?.text = element
//            }.disposed(by: disposeBag)
        
        /*
            rxVideos?.bind(to: tableView.rx.items(cellIdentifier: "videoCell", cellType: YTVideoTableViewCell.self)) { (row, element, cell) in
                if let thumbnail = element.thumbnail, let url = URL(string: thumbnail) {
                    cell.ivThumbnail.af_setImage(withURL: url)
                }
                cell.lblTitle.text = element.title
                cell.config(element)
            }
            .disposed(by: disposeBag)
        */
        
        
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        
//        filteredCandies = candies.filter({( candy : Candy) -> Bool in
//            let doesCategoryMatch = (scope == "All") || (candy.category == scope)
//
//            if searchBarIsEmpty() {
//                return doesCategoryMatch
//            } else {
//                return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
//            }
//        })
//        tableView.reloadData()
    }
    
    @IBAction func tapRefresh(_ sender: Any) {
        print("> tapRefresh")
        searchVideo(text: textSearch)
    }
    
}

extension SearchVideoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        // print("updateSearchResults: \(text)")
        
    }
}

extension SearchVideoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchVideoViewController: UISearchControllerDelegate {
    
}

extension SearchVideoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
