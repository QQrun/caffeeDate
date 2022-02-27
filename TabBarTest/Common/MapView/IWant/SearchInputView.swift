//
//  SearchInputView.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/02/25.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit

private let reuseIdentifier = "SearchLocationCell"

class SearchInputView : UIView{
    
    var searchBar : UISearchBar!
    var tableView : UITableView!
    
    var expansionState : ExpansionState!
    
    enum ExpansionState {
        case NotExpanded
        case PartiallyExpanded
        case FullyExpanded
        case ExpandToSearch
    }
    
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
        
        expansionState = .NotExpanded
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
        
        
        searchBar = UISearchBar()
        searchBar.placeholder = "點擊地圖或使用搜尋選擇地點"
        searchBar.barStyle = .default
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.delegate = self
        addSubview(searchBar)
        searchBar.anchor(top: indicatorView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)

        
        tableView = UITableView()
        tableView.rowHeight = 72
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
        if sender.direction == .up {
            if expansionState == .NotExpanded{
                animationInputView(targetPosition: self.frame.origin.y - 250, completion: {(_) in
                    self.expansionState = .PartiallyExpanded
                })
            }
            if expansionState == .PartiallyExpanded{
                animationInputView(targetPosition: self.frame.origin.y - 400, completion: {(_) in
                    self.expansionState = .FullyExpanded
                })
            }
        }else{
            self.searchBar.endEditing(true)
            self.searchBar.showsCancelButton = false
            
            if expansionState == .FullyExpanded{
                animationInputView(targetPosition: self.frame.origin.y + 400, completion: {(_) in
                    self.expansionState = .PartiallyExpanded
                })
            }
            if expansionState == .PartiallyExpanded{
                animationInputView(targetPosition: self.frame.origin.y + 250, completion: {(_) in
                    self.expansionState = .NotExpanded
                })
            }
        }
    }
}

extension SearchInputView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier , for: indexPath) as! SearchLocationCell
        return cell
    }
    
    
    
    
}

extension SearchInputView: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        if expansionState == .NotExpanded{
            animationInputView(targetPosition: self.frame.origin.y - 650){
                (_) in
                self.expansionState = .FullyExpanded
            }
        }
        if expansionState == .PartiallyExpanded{
            animationInputView(targetPosition: self.frame.origin.y - 400){
                (_) in
                self.expansionState = .FullyExpanded
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        animationInputView(targetPosition: self.frame.origin.y + 400){
            (_) in
            self.expansionState = .PartiallyExpanded
        }
    }
    
}
