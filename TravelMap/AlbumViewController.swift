//
//  AlbumViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/04/18.
//

import UIKit

class AlbumViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var collectionView: UICollectionView!
    var labelSize = 0
    // CollectionView item 개수
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 10
        }
        
        // CollectionView Cell의 Object
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumViewCell", for: indexPath) as! AlbumViewCell
            
            cell.albumName.text = "hello"
            cell.image.backgroundColor = UIColor.orange
            
            return cell
        }
    
    
        
        // CollectionView Cell의 Size
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            labelSize = Int("hello".height(withConstrainedWidth: collectionView.frame.width, font: UIFont.systemFont(ofSize: 17.0)))+5
            let width: CGFloat = collectionView.frame.width / 2 - 3.0
            return CGSize(width: width,height: width+CGFloat(labelSize))
        }
        
        // CollectionView Cell의 위아래 간격
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 1.0
        }
        
    
    override func viewDidLoad() {
    }
}
