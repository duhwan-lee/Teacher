//
//  CustomPalettView.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 7..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Foundation

@objc protocol CustomPalettViewDelegate {
    func setColor(color : UIColor)
    func setPenWidth(width : Float)
}

@IBDesignable
class CustomPalettView: UIView {
    weak var delegate : CustomPalettViewDelegate?
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet var view: UIView!
    override init(frame : CGRect){
        super.init(frame : frame)
        UINib(nibName: "CustomPalettView", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "CustomPalettView", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
        
    }
    
  
    @IBOutlet weak var slider: UISlider!
    @IBAction func BlackAction(_ sender: Any) {
        self.delegate?.setColor(color: .black)
    }
    @IBAction func BlueAction(_ sender: Any) {
        self.delegate?.setColor(color: .blue)
    }
    @IBAction func RedAction(_ sender: Any) {
        self.delegate?.setColor(color: .red )
    }
    @IBAction func YellowAction(_ sender: Any) {
        self.delegate?.setColor(color: .yellow )
    }
    @IBAction func GreenAction(_ sender: Any) {
        self.delegate?.setColor(color: .green )
    }
    @IBAction func sliderAction(_ sender: Any) {
        self.delegate?.setPenWidth(width: slider.value)
    }
   

}
