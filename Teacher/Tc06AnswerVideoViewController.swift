//
//  Tc06AnswerVideoViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 14..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit

class Tc06AnswerVideoViewController: UIViewController {
    var question_num : String?
    var answer_num : String?
    
    @IBAction func cancelAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
