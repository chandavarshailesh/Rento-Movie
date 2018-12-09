//
//  LoaderViewController.swift
//  RentoMovie
//
//  Created by Shailesh.Chandavar on 07/12/18.
//  Copyright © 2018 Shailesh.Chandavar. All rights reserved.
//

import UIKit

/// LoaderViewController shows a loader with circular animaion and could be used for config.

class LoaderViewController: UIViewController {
    
    @IBOutlet weak var circularLoaderView: CircularLoaderView!
    @IBOutlet weak var overlayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayleftConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayRightConstraint: NSLayoutConstraint!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLoader()
    }

    //loader animation
    fileprivate func animateLoader() {
        circularLoaderView.animationDelegate = self
        circularLoaderView.revealInDuration(animationDuration: 1.8)
        animateOverlay()
    }
    
    fileprivate func animateOverlay() {
   [overlayTopConstraint,overlayBottomConstraint,overlayleftConstraint,overlayRightConstraint].forEach { $0?.constant = 0.0}
        
        UIView.animate(withDuration: 1.8) { [weak self] in
            guard let `self` = self else {return}
            self.view.layoutIfNeeded()
        }
    }
    
    //Home screen will be show only after circular animation gets completed
    fileprivate func showMovieListViewController() {
        performSegue(withIdentifier: SegueIdentifier.movieListScreen.rawValue, sender: nil)
    }
    
}


extension LoaderViewController: CAAnimationDelegate {
   
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            showMovieListViewController()
        }
    }
}
