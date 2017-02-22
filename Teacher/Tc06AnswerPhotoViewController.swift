//
//  Tc06AnswerPhotoViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 15..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Firebase

class Tc06AnswerPhotoViewController: UIViewController {
    var question_num : String?
    var answer_num : String?
    var url : String?
    var text : String?
    var type : String?
    var writer : String?
    var queue = OperationQueue()
    
    @IBOutlet weak var answerText: UITextView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: RoundedImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var AnswerImage: UIImageView!
    @IBAction func cancelAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if type == "text"{
            imageHeight.constant = 0
        }else{
            self.queue.addOperation {
                if let url_temp = URL(string: self.url!),
                    let data = try? Data(contentsOf: url_temp),
                    let image = UIImage(data:data) {
                    OperationQueue.main.addOperation {
                        self.AnswerImage.image = image
                    }
                }
            }
        }
        answerText.text = text
        let user_ref=FIRDatabase.database().reference().child("Users").child(writer!)
        user_ref.observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            if let userdic = FIRDataSnapshot.value as? [String : Any]{
                self.userName.text = userdic["name"] as! String
                let image = userdic["profileImg"] as? String
                self.queue.addOperation {
                    if let url = URL(string: image!),
                        let data = try? Data(contentsOf: url),
                        let image = UIImage(data:data) {
                        OperationQueue.main.addOperation {
                            self.userImage.image = image
                        }
                    }
                }
                
                
            }
        })
        
        
        
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
