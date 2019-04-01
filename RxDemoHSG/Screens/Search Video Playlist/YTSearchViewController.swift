//
//  YTSearchViewController.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/28/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback
import Moya
import Result

/*
 refs: https://github.com/NoTests/RxFeedback.swift/blob/master/Examples/Examples/GithubPaginatedSearch.swift
 */
class YTSearchViewController: UIViewController {

    let disposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblErrorStatus: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        setupRxFeedback()
    }
}

extension YTSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

fileprivate typealias Feedback<State, Event> = (ObservableSchedulerContext<State>) -> Observable<Event>

extension YTSearchViewController {
    func setupRxFeedback() {
        
        let tableView = self.tableView!
        
        let configureCell = { (tableView: UITableView, row: Int, ytSearchResult: YTSearchResult) -> UITableViewCell in
            if let cell = tableView.dequeueReusableCell(withIdentifier: "YTSearchResultCell") as? YTVideoTableViewCell
            {
                cell.configCell(ytSearchResult)
                return cell
            }
            
            return UITableViewCell(style: .subtitle, reuseIdentifier: "YTSearchResultCell")
        }
        
        let triggerLoadNextPage: (Driver<YTSearchState>) -> Signal<YTSearchEvent> = { state in
            return state.flatMapLatest { state -> Signal<YTSearchEvent> in
                if state.shouldLoadNextPage {
                    return Signal.empty()
                }
                
                return tableView.rx.nearBottom
                    .skip(1)
                    .map { return YTSearchEvent.scrollingNearBottom }
            }
        }
        
        let bindUI: (Driver<YTSearchState>) -> Signal<YTSearchEvent> = bind(self) { me, state in
            let subscriptions = [
//                state.map { $0.search }.drive(me.searchBar!.rx.text),
                state.map { $0.lastError?.description }.drive(me.lblErrorStatus!.rx.textOrHide),
                state.map { $0.results }.drive(tableView.rx.items)(configureCell),
//                state.map { $0.loadNextPage?.description }.drive(me.loadNextPage!.rx.textOrHide),
                ]
            
            let events: [Signal<YTSearchEvent>] = [
                me.searchBar!.rx.text.orEmpty.changed.asSignal().filter {$0.count > 2}.debounce(1).map(YTSearchEvent.searchChanged),
                triggerLoadNextPage(state)
            ]
            
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let provider = YTSearchProvider(provider: MoyaProvider<YTSearchAPI>(stubClosure: MoyaProvider.delayedStub(3), plugins: [NetworkLoggerPlugin(verbose: true)]))

        /*
        let feedBackResponse: Feedback<YTSearchState, YTSearchEvent> = react(request: { state -> YTSearchState in
            return state
        }, effects: { state -> Observable<YTSearchEvent> in
            print(">> searchText : \(state.search) - \(state.pageToken)")
            return provider.rx_searchVideoPlaylist(state.search, pageToken: state.pageToken)
                .debug()
                .map { (result) -> YTSearchEvent in
                    return YTSearchEvent.response(Result.success(result))
                }.asObservable()
        })
 */
        let feedBackResponse: (Driver<YTSearchState>) -> Signal<YTSearchEvent> = react(request: { state -> YTSearchState? in
            return state.shouldLoadNextPage ? state : nil
        }, effects: { state -> Signal<YTSearchEvent> in
            return provider.rx_searchVideoPlaylist(state.search, pageToken: state.pageToken)
                .debug()
                .map { (result) -> YTSearchEvent in
                    return YTSearchEvent.response(Result.success(result))
                }.asSignal(onErrorRecover: { (error) -> SharedSequence<SignalSharingStrategy, YTSearchEvent> in
                    if let error = error as? AnyError {
                        return Signal.just(YTSearchEvent.response(.failure(error)))
                    }
                    return Signal.just(YTSearchEvent.response(.failure(AnyError.init(error))))
                })
//                .asSignal(onErrorRecover: { (error) -> (Signal<YTSearchEvent>) in
//                    return Signal.just(YTSearchEvent.response(Result.failure(error)))
//                })
                // .asSignal(onErrorJustReturn: YTSearchEvent.response(Result.failure()))
        })

        
        Driver.system(
            initialState: YTSearchState.empty,
            reduce: YTSearchState.reduce,
            feedback:
            // UI, user feedback
            bindUI,
            // NoUI, automatic feedback
            feedBackResponse
            )
            .drive()
            .disposed(by: disposeBag)
 
    }
}


fileprivate struct YTSearchState {
    var search: String {
        didSet {
            if search.isEmpty {
                self.shouldLoadNextPage = false
                self.results = []
                self.lastError = nil
                return
            }
            self.pageToken = nil
            self.shouldLoadNextPage = true
            self.lastError = nil
        }
    }
    
    var pageToken: String?
    var shouldLoadNextPage: Bool
    var results: [YTSearchResult]
    var lastError: AnyError?
}

extension YTSearchState: Equatable {
    public static func == (lhs: YTSearchState, rhs: YTSearchState) -> Bool {
        return lhs.search == rhs.search && lhs.pageToken == rhs.pageToken
    }
}

//fileprivate typealias SearchRepositoriesResponse = Single<YTResults<YTSearchResult>>
fileprivate typealias YTSearchResultResponse = Result<YTResults<YTSearchResult>, AnyError>


fileprivate enum YTSearchEvent {
    case searchChanged(String)
    case response(YTSearchResultResponse)
    case scrollingNearBottom
}

// transitions
extension YTSearchState {
    static var empty: YTSearchState {
        return YTSearchState(search: "", pageToken: nil, shouldLoadNextPage: true, results: [], lastError: nil)
    }
    
    static func reduce(state: YTSearchState, event: YTSearchEvent) -> YTSearchState {
        switch event {
        case .searchChanged(let search):
            var result = state
            result.search = search
            result.results = []
            return result
        case .scrollingNearBottom:
            var result = state
            result.shouldLoadNextPage = true
            return result
        case .response(.success(let response)):
            var result = state
            result.results += response.items ?? []
            result.shouldLoadNextPage = false
            result.pageToken = response.nextPageToken
            result.lastError = nil
            return result
        case .response(.failure(let error)):
            var result = state
            result.shouldLoadNextPage = false
            result.lastError = error
            return result
        }
    }
}

// CUSTOM
extension Reactive where Base: UITableView {
    
    var nearBottom: Signal<()> {
        func isNearBottomEdge(tableView: UITableView, edgeOffset: CGFloat = 20.0) -> Bool {
            return tableView.contentOffset.y + tableView.frame.size.height + edgeOffset > tableView.contentSize.height
        }
        
        return self.contentOffset.asDriver()
            .flatMap { _ in
                return isNearBottomEdge(tableView: self.base, edgeOffset: 20.0) ? Signal.just(()) : Signal.empty()
        }
    }
}

extension Reactive where Base: UILabel {
    var textOrHide: Binder<String?> {
        return Binder(base) { label, value in
            guard let value = value else {
                label.isHidden = true
                return
            }
            
            label.text = value
            label.isHidden = false
        }
    }
}
