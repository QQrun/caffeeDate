//
//  Util.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/09.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit

public class Util {
    
    static func quicksort_Item(_ items: [Item]) -> [Item] {
        guard items.count > 1 else { return items }
        
        let pivot = items[items.count/2].order
        var less : [Item] = []
        for item in items{
            if item.order < pivot{
                less.append(item)
            }
        }
        var equal : [Item] = []
        for item in items{
            if item.order == pivot{
                equal.append(item)
            }
        }
        var greater : [Item] = []
        for item in items{
            if item.order > pivot{
                greater.append(item)
            }
        }
        return quicksort_Item(less) + equal + quicksort_Item(greater)
    }
    
    static func quicksort_MailData(_ items: [MailData]) -> [MailData] {
        guard items.count > 1 else { return items }
        
        let formatter = DateFormatter()
        let dateFormat = "yyyyMMddHHmmss"
        formatter.dateFormat = dateFormat
        
        let pivot = Int(formatter.string(from: items[items.count/2].lastMessage.sentDate))!
        var less : [MailData] = []
        for item in items{
            if Int(formatter.string(from: item.lastMessage.sentDate))! < pivot{
                less.append(item)
            }
        }
        var equal : [MailData] = []
        for item in items{
            if Int(formatter.string(from: item.lastMessage.sentDate))! == pivot{
                equal.append(item)
            }
        }
        var greater : [MailData] = []
        for item in items{
            if Int(formatter.string(from: item.lastMessage.sentDate))! > pivot{
                greater.append(item)
            }
        }
        return quicksort_MailData(less) + equal + quicksort_MailData(greater)
    }
    
    static func customViewPresentAnimation(previousViewController:UIViewController,currentViewController:UIViewController,completion: @escaping (() -> ())) {
        
        currentViewController.view.frame = CGRect(x: currentViewController.view.frame.width, y: 0, width: currentViewController.view.frame.width, height: currentViewController.view.frame.height)
        currentViewController.view.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            previousViewController.view.frame = CGRect(x: previousViewController.view.frame.origin.x - previousViewController.view.frame.width, y: 0, width: previousViewController.view.frame.width, height: previousViewController.view.frame.height)
            currentViewController.view.alpha = 1
            currentViewController.view.frame = CGRect(x: 0, y: 0, width: currentViewController.view.frame.width, height: currentViewController.view.frame.height)
        }, completion: {_ in
            completion()
        })
        
    }
    
    static func customViewQuitAnimation(previousViewController:UIViewController,currentViewController:UIViewController,completion: @escaping (() -> ())) {
        
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            //currentViewController滑出
            currentViewController.view.frame = CGRect(x: currentViewController.view.frame.width, y: 0, width: currentViewController.view.frame.width, height: currentViewController.view.frame.height)
            //previousViewController滑入
            previousViewController.view.frame = CGRect(x: 0, y: 0, width: previousViewController.view.frame.width, height: previousViewController.view.frame.height)
            previousViewController.view.alpha = 1
        }, completion:  { _ in
            currentViewController.dismiss(animated: false, completion: nil)
            completion()
        }
        )
        
        
    }
    
    
    
}
