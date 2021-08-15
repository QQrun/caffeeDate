//
//  TextViewTableViewCell.swift
//  TabBarTest
//
//  Created by Howard Sun on 2021/7/31.
//  Copyright © 2021 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    lazy var numberOfWordsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 65, green: 65, blue: 65)
        return label
    }()
    
    lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor(red: 60 / 255, green: 60 / 255, blue: 66 / 255, alpha: 0.36)
        return separator
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14, weight: .light)
        textView.textColor = .black
        textView.delegate = self
        
        return textView
    }()
    
    var maxNumberOfWords: Int = 0 {
        didSet {
            numberOfWordsLabel.text = "\(maxNumberOfWords - textView.text.count)"
        }
    }
    var section: CreateTradeViewController.Section? {
        didSet {
            updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(16)
        }
        contentView.addSubview(numberOfWordsLabel)
        numberOfWordsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-16)
        }
        contentView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func updateUI() {
        guard let section = section else { return }
        switch section {
        case .name:
            titleLabel.text = "商品名稱"
            maxNumberOfWords = 15
        case .price:
            titleLabel.text = "商品價格"
            maxNumberOfWords = 15
        case .info:
            titleLabel.text = "商品資訊"
            maxNumberOfWords = 200
        default:
            break
        }
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        numberOfWordsLabel.text = "\(maxNumberOfWords - textView.text.count)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= maxNumberOfWords
    }
}
