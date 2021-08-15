//
//  AddPhotosTableViewCell.swift
//  TabBarTest
//
//  Created by Howard Sun on 2021/8/1.
//  Copyright © 2021 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class AddPhotosTableViewCell: UITableViewCell {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.register(AddPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "AddPhotoCollectionViewCell")
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return collectionView
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) ?? []
        return imagePicker
    }()
    var images: [UIImage] = []
    weak var viewController: UIViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        images = []
    }
    
    func setupUI() {
        selectionStyle = .none
        collectionView.isHidden = false
    }
}

extension AddPhotosTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 96, height: 96)
    }
}

extension AddPhotosTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            viewController?.present(imagePicker, animated: true)
        }
    }
}

extension AddPhotosTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCollectionViewCell", for: indexPath) as! AddPhotoCollectionViewCell
            cell.button.isHidden = false
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
            cell.imageView.image = images[indexPath.row]
            cell.button.isHidden = false
            cell.removeImage = { [weak self] image in
                guard let self = self else { return }
                if let index = self.images.firstIndex(of: image) {
                    self.images.remove(at: index)
                    self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                }
            }
            return cell
        }
        
    }
}

extension AddPhotosTableViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let index = images.count
            images.insert(originImage, at: index)
            collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}



class AddPhotoCollectionViewCell: UICollectionViewCell {
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AddBtn")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(red: 1, green: 162, blue: 153)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 1, green: 162, blue: 153)?.cgColor
        button.isUserInteractionEnabled = false
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return button
    }()
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return imageView
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close-2"), for: .normal)
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.width.height.equalTo(22)
            make.top.equalToSuperview().offset(-6)
            make.right.equalToSuperview().offset(6)
        }
        return button
    }()
    
    var removeImage: ((UIImage) -> Void)?
    
    @objc func buttonDidTap() {
        guard let image = imageView.image else { return }
        removeImage?(image)
    }
}


