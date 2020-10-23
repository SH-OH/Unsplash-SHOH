//
//  MainViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import UIKit

class MainViewController: BaseViewController {
    
    private var photoModels: [PhotoModel] = [] {
        didSet {
//            Log.osh(self.photoModels)
            self.reloadData()
        }
    }
    
    @IBOutlet private weak var listCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.listCollectionView.delegate = self
        self.listCollectionView.dataSource = self
        self.listCollectionView.register(ListCell.self)
        
        PhotoUseCase().getPhotoList(1, oldModels: self.photoModels) { [self] (resultModels) in
            self.photoModels = resultModels
        }
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.listCollectionView.reloadData()
        }
    }
    
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        Log.osh("ip : \(indexPath)")
        let cell = collectionView.dequeue(ListCell.self, for: indexPath)
        if let item = self.photoModels[safe: indexPath.item] {
            cell.configure(item)
        }
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = self.photoModels[safe: indexPath.item] else { return .zero }
        let width = collectionView.bounds.width
        let height = CGFloat(item.height) * width / CGFloat(item.width)
        return CGSize(width: width, height: height)
    }
}
