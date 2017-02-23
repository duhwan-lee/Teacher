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
import Firebase
import Nuke
class Tc06AnswerVideoViewController: UIViewController {
    
    @IBOutlet weak var answerText: UITextView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPic: RoundedImageView!
    var question_num : String?
    var answer_num : String?
    var url : String?
    var text : String?
    var writer : String?
    @IBOutlet weak var player: BMPlayer!
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.all)

        answerText.text = text
        let user_ref=FIRDatabase.database().reference().child("Users").child(writer!)
        user_ref.observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            if let userdic = FIRDataSnapshot.value as? [String : Any]{
                self.userName.text = (userdic["name"] as? String)
                let image = userdic["profileImg"] as? String
                let url = URL(string: image!)!
                Nuke.loadImage(with: url, into: self.userPic)
                
            }
        })
        
        
        player.playWithURL(URL(string : url!)!)
        let backblock = {(result : Bool) in self.dismiss(animated: true, completion: nil)}
        player.backBlock = backblock
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   }
