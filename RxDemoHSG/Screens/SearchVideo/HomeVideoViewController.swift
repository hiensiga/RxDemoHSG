//
//  HomeVideoViewController.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/27/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import UIKit

class HomeVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        let suggestionViewController = GoogleSuggestionViewController(nibName: "GoogleSuggestionViewController", bundle: nil)
        let searchController = UISearchController(searchResultsController: suggestionViewController)
        suggestionViewController.searchController = searchController
        suggestionViewController.delegate = self
        
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
        searchController.searchResultsUpdater = suggestionViewController
        definesPresentationContext = true
        //        searchController.loadViewIfNeeded()
        
        searchController.searchBar.delegate = suggestionViewController
        searchController.searchBar.placeholder = "Type something here to search"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.barTintColor = navigationController?.navigationBar.barTintColor
        searchController.searchBar.tintColor = self.view.tintColor
        
        searchController.dimsBackgroundDuringPresentation = true
        
    }

}

extension HomeVideoViewController: UISearchControllerDelegate {
    
}

extension HomeVideoViewController {
    func pushToVideoSearch(text: String) {
        print("> pushToVideoSearch: \(text)")
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchVideoViewController") as! SearchVideoViewController
        viewController.textSearch = text
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HomeVideoViewController: SuggestionDelegate {
    func didSelected(text: String) {
        pushToVideoSearch(text: text)
    }
}
