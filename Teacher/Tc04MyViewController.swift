//
//  Tc04MyViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 15..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Firebase

class Tc04MyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var questionCount: UILabel!
    @IBOutlet weak var answerCount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImg: RoundedImageView!
    @IBOutlet weak var viewTop: NSLayoutConstraint!

    var anskeys = [String]()
    var modalFlag = false
    var queue = OperationQueue()
    var uid : String?
    var question = [Question]()
    var question_ans = [Question]()
    var question_qa = [Question]()
    var channelList = [String]()
    var myChannel : String?
    @IBAction func messageAction(_ sender: Any) {
    performSegue(withIdentifier: "Tc08_profile_segue", sender: nil)
    }
    
    @IBAction func segment(_ sender: Any) {
        
        let control = sender as! UISegmentedControl
        switch control.selectedSegmentIndex {
        case 0:
            question = question_qa
            tableView.reloadData()
            scrollToTop()
            
        case 1:
            question = question_ans
            tableView.reloadData()
            scrollToTop()
        default:
            question = question_qa
            tableView.reloadData()
            scrollToTop()
        }
    }
    
  
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser == nil {
            profileImg.image = nil 
            questionCount.text = "0"
            answerCount.text = "0"
            question.removeAll()
            tableView.reloadData()
        }
        
        if modalFlag {
            if uid == FIRAuth.auth()?.currentUser?.uid {
                messageButton.isEnabled = false
                messageButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
            }
            self.title = "프로필"
            navigationItem.rightBarButtonItem = nil
            modalAction(uid!)
            writeTextLoad(uid!)
            getAnswersKeys(uid!)
        }else{
            messageButton.isEnabled = false
            messageButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
            self.title = "마이 페이지"
            let user = FIRAuth.auth()?.currentUser
            userName.text = user?.displayName
            
            self.queue.addOperation {
                if let url = user?.photoURL,
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data:data) {
                    OperationQueue.main.addOperation {
                        self.profileImg.image = image
                    }
                }
            }
            if let myUid = FIRAuth.auth()?.currentUser?.uid {
                writeTextLoad(myUid)
                getAnswersKeys(myUid)
            }
        }
        

    }
    func scrollToTop() {
        if (self.tableView.numberOfSections > 0 ) {
            let top = NSIndexPath(row: Foundation.NSNotFound, section: 0)
            self.tableView.scrollToRow(at: top as IndexPath, at: .top, animated: true);
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "tc05_tc04_segue", sender: indexPath)
    }
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 1000
        tableView.rowHeight = UITableViewAutomaticDimension
        super.viewDidLoad()
        
        
    }

    func getAnswersKeys(_ uid : String){
    let ref = FIRDatabase.database().reference().child("Users").child(uid)
        ref.observe(.value, with: { (FIRDataSnapshot) in
            if let dictionary = FIRDataSnapshot.value as? [String : Any]{
                if let ans = dictionary["answer"] as? [String: Any]{
                    let strArr = Array(ans.keys)
                    
                    FIRDatabase.database().reference().child("Question").observeSingleEvent(of: .value, with: { (FIRDataSnapshot_key) in
                        if let dic_temp = FIRDataSnapshot_key.value as? [String : Any]{
                            self.question_ans.removeAll()
                            for key in strArr{
                                if let dic_ans = dic_temp[key] as? [String : Any] {
                                    let qa = Question()
                                    //qa.contentNumber = dic_ans.key
                                    qa.contentNumber = key
                                    qa.questionText = dic_ans["questionText"] as! String?
                                    qa.writerUid = dic_ans["writerUid"] as! String?
                                    qa.writerName = dic_ans["writerName"] as! String?
                                    qa.questionPic = dic_ans["questionPic"] as! String?

                                    if let tag = dic_ans["tag"] as? [String]{
                                        let joiner = " "
                                        qa.tagLabel = tag.joined(separator: joiner)
                                        qa.tag = tag
                                    }
                                    let seconds = dic_ans["writeTime"] as! Int
                                    let timestampDate = NSDate(timeIntervalSince1970: TimeInterval(seconds))
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd a hh:mm:ss"
                                    qa.writeTime = dateFormatter.string(from: timestampDate as Date)
                                    if let ans = dic_ans["answer"] as? [String: Any]{
                                        qa.answerCount = Array(ans.keys).count
                                    }
                                    self.question_ans.append(qa)
                                    DispatchQueue.main.async(execute: {
                                        self.answerCount.text = String(self.question_ans.count)
                                    })

                                }
                                
                                
                                
                                
                                
                                
                            }
                        }
                    })
                    
                }
            }
            
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return question.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if question[indexPath.row].questionPic != "null" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tc04_cell", for: indexPath) as! Tc01TableViewCell
            cell.QuestionTextLabel.text = question[indexPath.row].questionText
            cell.writerName.text = question[indexPath.row].writerName
            cell.writeTime.text = question[indexPath.row].writeTime
            if let taglabel = question[indexPath.row].tagLabel{
                cell.writeTag.text = taglabel
            }
            cell.backgroundColor = UIColor.clear
            self.queue.addOperation {
                if let url = URL(string: self.question[indexPath.row].questionPic!),
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data:data) {
                    OperationQueue.main.addOperation {
                        cell.mainImageView.image = image
                    }
                }
            }
            
            if let num = question[indexPath.row].answerCount{
                cell.answerCount.text = String(num)
            }
            
            
            
            cell.mainImageView.layer.shadowColor = UIColor.gray.cgColor
            cell.mainImageView.layer.shadowOpacity = 8
            cell.mainImageView.layer.shadowRadius = 3
            cell.mainImageView.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.shadowView.layer.shadowColor = UIColor.gray.cgColor
            cell.shadowView.layer.shadowOpacity = 8
            cell.shadowView.layer.shadowRadius = 3
            cell.shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "tc04txt_cell", for: indexPath) as! Tc01TableViewCell
            cell.QuestionTextLabel.text = question[indexPath.row].questionText
            cell.writerName.text = question[indexPath.row].writerName
            cell.writeTime.text = question[indexPath.row].writeTime
            if let taglabel = question[indexPath.row].tagLabel{
                cell.writeTag.text = taglabel
            }
            
            if let num = question[indexPath.row].answerCount{
                cell.answerCount.text = String(num)
            }
            
            
            cell.shadowView.layer.shadowColor = UIColor.gray.cgColor
            cell.shadowView.layer.shadowOpacity = 8
            cell.shadowView.layer.shadowRadius = 3
            cell.shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
            return cell
            
        }
        
        
        
        
    }

    func modalAction(_ uid : String){
        let myUid = (FIRAuth.auth()?.currentUser?.uid)!
        let user_ref=FIRDatabase.database().reference().child("Users").child(uid)
        user_ref.observe(.value, with: { (userSnapshot) in
            if let userdic = userSnapshot.value as? [String : Any]{
                let name = userdic["name"] as? String
                if let chatList = userdic["channel"] as? [String : Any] {
                    self.channelList = Array(chatList.keys)
                    if self.channelList.contains(myUid + uid){
                    self.myChannel = myUid + uid
                    }else if self.channelList.contains(uid + myUid){
                    self.myChannel = uid + myUid
                    }else{
                    self.myChannel = myUid + uid
                    }
                }else{
                    self.myChannel = myUid + uid
                }
                
                self.userName.text = name
                let image = userdic["profileImg"] as? String
                self.queue.addOperation {
                    if let url = URL(string: image!),
                        let data = try? Data(contentsOf: url),
                        let image = UIImage(data:data) {
                        OperationQueue.main.addOperation {
                            self.profileImg.image = image
                        }
                    }
                }
                
            }
        }, withCancel: nil)
    }
    

    func writeTextLoad(_ uid : String){
        question_qa.removeAll()
        question.removeAll()
        let ref = FIRDatabase.database().reference().child("Question").queryOrdered(byChild: "writerUid").queryEqual(toValue: uid)
        ref.observe(.childAdded, with: { (FIRDataSnapshot) in
            if let dictionary = FIRDataSnapshot.value as? [String : Any]{
                let qa = Question()
                qa.contentNumber = FIRDataSnapshot.key
                qa.questionText = dictionary["questionText"] as! String?
                qa.writerUid = dictionary["writerUid"] as! String?
                qa.writerName = dictionary["writerName"] as! String?
                qa.questionPic = dictionary["questionPic"] as! String?
                
                let seconds = dictionary["writeTime"] as! Int
                let timestampDate = NSDate(timeIntervalSince1970: TimeInterval(seconds))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd a hh:mm:ss"
                qa.writeTime = dateFormatter.string(from: timestampDate as Date)
                
                if let tag = dictionary["tag"] as? [String]{
                    let joiner = " "
                    qa.tagLabel = tag.joined(separator: joiner)
                    qa.tag = tag
                }
                if let ans = dictionary["answer"] as? [String: Any]{
                    print(ans)
                    qa.answerCount = Array(ans.keys).count
                }else{
                    qa.answerCount = 0
                }
                
                self.question_qa.append(qa)
                self.question.append(qa)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    self.questionCount.text = String(self.question_qa.count)
                })
                
                
            }
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Tc08_profile_segue" {
            let chatVC = segue.destination as! Tc08ChatRoomViewController
            chatVC.toUid = uid
            chatVC.channel = myChannel!
            chatVC.toName = userName.text
            chatVC.profileImg = profileImg.image
            chatVC.profileFlag = true
        }
        
        if segue.identifier == "tc05_tc04_segue" {
            let contentVC = segue.destination as! Tc05ContentViewController
            let idx = sender as! IndexPath
            contentVC.writer_Uid = question[idx.row].writerUid
            contentVC.writer_Name = question[idx.row].writerName
            contentVC.content_Number = question[idx.row].contentNumber
            contentVC.write_Time = question[idx.row].writeTime
        }
    }
}
