//
//  Tc10ImageViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 22..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit

class Tc10ImageViewController: UIViewController {
    var image : UIImage?
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        imageView.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        imageView.addGestureRecognizer(panGesture)
        
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenPan))
        edgeGesture.edges = .left
        self.view.addGestureRecognizer(edgeGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleScreenPan(_ gesture : UIScreenEdgePanGestureRecognizer) {
    }
    var lastScale : CGFloat?
    
    func handlePinch(_ gesture : UIPinchGestureRecognizer) {
        if gesture.state == .began {
            lastScale = gesture.scale
        }
        if let pinchView = gesture.view, gesture.state == .began || gesture.state == .changed
        {
            var currentScale = (pinchView.layer.value(forKeyPath: "transform.scale") as AnyObject).floatValue
            let kMaxScale:CGFloat = 2.0
            let kMinScale:CGFloat = 0.9
            
            var newScale = 1.0 - (lastScale! - gesture.scale)
            if let currentScale = currentScale {
                newScale = min(newScale, kMaxScale / (CGFloat)(currentScale))
                newScale = max(newScale, kMinScale / (CGFloat)(currentScale))
                pinchView.transform = pinchView.transform.scaledBy(x: newScale, y: newScale)
                gesture.scale = 1.0
                lastScale = gesture.scale
            }
        }
    }
    
    func handlePan(_ gesture : UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view!)
        imageView.transform = imageView.transform.translatedBy(x: translation.x, y: translation.y)
        // 초기화
        gesture.setTranslation(CGPoint.zero, in: gesture.view)
    }

}
