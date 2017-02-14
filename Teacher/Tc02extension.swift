//
//  Tc02extension.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 7..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit

extension Tc02QuestionViewController{
    
    func imageWithImage (sourceImage:UIImage, scaledToHeight: CGFloat) -> UIImage {
        let oldheight = sourceImage.size.height
        let scaleFactor = scaledToHeight / oldheight
        
        let newWidth = sourceImage.size.width * scaleFactor
        let newHeight = oldheight * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    //화면 상단 바 숨김
    override var prefersStatusBarHidden: Bool{
        return true
    }
    func subscribeToKeyboardNotifications() {
        //키보드 나타남
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //키보드 들어감
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

