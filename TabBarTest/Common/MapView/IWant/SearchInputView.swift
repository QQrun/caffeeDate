//
//  SearchInputView.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/02/25.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import MapKit

private let reuseIdentifier = "SearchLocationCell"

protocol SearchInputViewDelegate{
    func handleSearch(_ searchText:String)
    func selectedAnnotation(withMapItem mapItem: MKMapItem)
    
}


class SearchInputView : UIView{
    
    var searchBar : UISearchBar!
    var tableView : UITableView!
//    var expansionState : ExpansionState!
    var delegate: SearchInputViewDelegate!
    var chooseLocationViewController: ChooseLocationViewController?
    
    var searchResults: [MKMapItem]? {
        didSet{
            tableView.reloadData()
        }
    }
    
    
//    enum ExpansionState {
//        case NotExpanded
//        case PartiallyExpanded
//    }
//
    let indicatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        configureViewComponents()
        configureGestureRecognizers()
        
//        expansionState = .NotExpanded
    }

    required init?(coder: NSCoder) {
        fatalError("init fatal")
    }
    
    func animationInputView(targetPosition:CGFloat, completion:@escaping(Bool) -> ()){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.frame.origin.y = targetPosition
        }, completion: completion)
    }
    
    func configureViewComponents(){
        backgroundColor = .surface()
        addSubview(indicatorView)
        indicatorView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 4)
        indicatorView.centerX(inView: self)
        indicatorView.alpha = 0
        
        
        searchBar = UISearchBar()
        searchBar.placeholder = "點擊地圖或使用搜尋選擇地點"
        searchBar.barStyle = .default
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.delegate = self
        addSubview(searchBar)
        searchBar.anchor(top: indicatorView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)

        
        tableView = UITableView()
        tableView.rowHeight = 50
        tableView.register(SearchLocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        addSubview(tableView)
        tableView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 100, paddingRight: 0, width: 0, height: 0)
    }
    
    func configureGestureRecognizers(){
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUp.direction = .up
        addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDown.direction = .down
        addGestureRecognizer(swipeDown)
    }
    
    @objc func handleSwipeGesture(sender: UISwipeGestureRecognizer){
//        if sender.direction == .up {
//            if expansionState == .NotExpanded{
//                print("direction.up NotExpanded")
//                animationInputView(targetPosition: self.frame.origin.y - 320, completion: {(_) in
//                    self.expansionState = .PartiallyExpanded
//                })
//            }
//        }else{
//            self.searchBar.endEditing(true)
//            self.searchBar.showsCancelButton = false
//
//            if expansionState == .PartiallyExpanded{
//                print("direction.down PartiallyExpanded")
//                animationInputView(targetPosition: self.frame.origin.y + 320, completion: {(_) in
//                    self.expansionState = .NotExpanded
//                })
//            }
//        }
    }
}

extension SearchInputView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.count ?? 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchLocationCell
        
        if let controller = chooseLocationViewController {
            cell.delegate = controller
        }
        
        if let searchResults = searchResults {
            cell.mapItem = searchResults[indexPath.row]
        }else{
            cell.mapItem = nil
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var searchResults = searchResults else { return }
        let selectedMapItem = searchResults[indexPath.row]

        delegate?.selectedAnnotation(withMapItem: selectedMapItem)

//        searchResults.remove(at: indexPath.row)
//        searchResults.insert(selectedMapItem, at: 0)
//        self.searchResults = searchResults
//
//        let firstIndexPath = IndexPath(row: 0, section: 0)

//        let cell = tableView.cellForRow(at: firstIndexPath) as! SearchCell
//        cell.animateButtonIn()
//        delegate?.addPolyline(forDestinationMapItem: selectedMapItem)

    }

    
    
    
}

extension SearchInputView: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        delegate?.handleSearch(searchText)
        
        dismissOnSearch()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
//        if expansionState == .NotExpanded{
//            animationInputView(targetPosition: self.frame.origin.y - 320){
//                (_) in
//                self.expansionState = .PartiallyExpanded
//            }
//        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissOnSearch()
    }
    
    fileprivate func dismissOnSearch() {
        print("dismissOnSearch")
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
  
//        if expansionState == .NotExpanded {
//            print("dismissOnSearch PartiallyExpanded")
//            animationInputView(targetPosition: self.frame.origin.y - 320, completion: {(_) in
//                self.expansionState = .PartiallyExpanded
//            })
//        }

    }
    
}
