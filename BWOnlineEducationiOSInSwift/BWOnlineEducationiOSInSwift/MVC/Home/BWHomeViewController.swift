//
//  BWHomeViewController.swift
//  BWOnlineEducationiOSInSwift
//
//  Created by BobWong on 2017/6/19.
//  Copyright © 2017年 BobWongStudio. All rights reserved.
//

import UIKit

let BWHomeCellId = "BWHomeCellId"

class BWHomeViewController: BWBaseViewController, UICollectionViewDataSource, BWHomeCellDelegate {

    // MARK: UI
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Data
    var dataSource: NSMutableArray?
    

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Home"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Push", style: .plain, target: self, action: #selector(push))
        
        self.collectionView.register(UINib.init(nibName: "BWHomeCell", bundle: nil), forCellWithReuseIdentifier: BWHomeCellId)
        self.setData()
        self.collectionView.reloadData()
    }
    
    // MARK: Private Method
    
    func setData() {
        let array = ["1", "2", "3"]
        
        self.dataSource = NSMutableArray.init(array: array)
    }
    
    func push() {
        let vc = BWBaseViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: System Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.dataSource != nil) ? (self.dataSource?.count)! : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: BWHomeCellId, for: indexPath) as! BWHomeCell
        cell.delegate = self
        cell.titleLabel.text = self.dataSource?.object(at: indexPath.row) as! String?
        return cell
    }
    
    // MARK: Custom Delegate
    
    func triggleHomeCellEdit() {
        print("triggleHomeCellEdit")
    }

}