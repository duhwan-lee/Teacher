//
//  Tc06AnswerVideoViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 14..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import BMPlayer

class Tc06AnswerVideoViewController: UIViewController {
    
    var question_num : String?
    var answer_num : String?
    var url : String?
    var text : String?
  
    @IBOutlet weak var playerView: BMPlayer!
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.playWithURL(URL(string: url!)!)
        playerView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0)
        }
        playerView.backBlock = { [unowned self] (isFullScreen) in
            if isFullScreen == true {
                return
            }
            let _ = self.navigationController?.popViewController(animated: true)
        }
        BMPlayerConf.shouldAutoPlay = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
}
