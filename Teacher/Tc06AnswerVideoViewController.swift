//
//  Tc06AnswerVideoViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 14..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import BMPlayer
import NVActivityIndicatorView

class Tc06AnswerVideoViewController: UIViewController {
    
    var question_num : String?
    var answer_num : String?
    var url : String?
    var text : String?

    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   }
