//
//  AGPhotoGalleryViewController.swift
//  AGPosterSnap
//
//  Created by Michael Liptuga on 22.06.17.
//  Copyright © 2017 Agilie. All rights reserved.
//

import UIKit

protocol AGPhotoGalleryViewControllerDelegate : class {
    func posterImage (photoGalleryViewController : AGPhotoGalleryViewController, image : UIImage)
}

class AGPhotoGalleryViewController: AGMainViewController {

    weak var delegate : AGPhotoGalleryViewControllerDelegate?
    
    lazy var photoGalleryCollectionView: AGPhotoGalleryCollectionView = { [unowned self] in
        let collectionView = AGPhotoGalleryCollectionView(frame: self.view.bounds, collectionViewLayout: nil)
            collectionView.photoGalleryDataSource = self
            collectionView.photoGalleryDelegate = self
        return collectionView
    }()
    
    var images : [UIImage] = []
    {
        didSet {
            self.photoGalleryCollectionView.reloadData()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurePhotoGalleryViewController()
        self.loadPhotos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AGPhotoGalleryViewController
{
    fileprivate func configurePhotoGalleryViewController () {
        self.view.backgroundColor = self.configurator.mainColor
        self.navigationView.doneButton.isHidden = true
        [photoGalleryCollectionView, navigationView].forEach {
            ($0 as! UIView).translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0 as! UIView)
        }
        self.setupConstraints()
    }
    
    fileprivate func loadPhotos () {
        self.view.isUserInteractionEnabled = false
        AGPhotoGalleryService.sharedInstance.imagesFromPhotoGallery() {[weak self] (images) in
            guard let `self` = self else { return }
            self.images = images
        }
    }
}

extension AGPhotoGalleryViewController : AGPhotoGalleryCollectionViewDataSource
{
    func numberOfItemsInSection (section : Int) -> Int {
        return self.images.count
    }
        
    func photoAtIndexPath (indexPath : IndexPath) -> UIImage {
        return self.images[indexPath.row]
    }
}

extension AGPhotoGalleryViewController : AGPhotoGalleryCollectionViewDelegate
{
    func selectedPhoto (atIndexPath indexPath : IndexPath) {
        let photoResizeVC = AGPhotoResizeViewController.createWithAsset(atIndex: indexPath.row)
            photoResizeVC.delegate = self
        self.present(photoResizeVC, animated: true, completion: nil)
    }
}

extension AGPhotoGalleryViewController : AGPhotoResizeViewControllerDelegate
{
    func posterImage (photoResizeViewController : AGPhotoResizeViewController, image : UIImage) {
        self.dismiss(animated: false) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.posterImage(photoGalleryViewController : self, image: image)
        }
//        self.dismiss(animated: false, completion: nil)
    }
}
