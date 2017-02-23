//
//  Tc05ContentViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 7..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Firebase
import Nuke
class Tc05ContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,CollapsibleTableViewHeaderDelegate {

    @IBOutlet weak var tableview: UITableView!
    var writer_Uid : String?
    var content_Number : String?
    var write_Time : String?
    var writer_Name : String?
    var queue = OperationQueue()
    var sections = [Section]()
    var ansArr = [String]()
    var typeArr = [String]()
    var keyArr = [String]()
    var answers = [Answer]()
    let image_recognizer = UITapGestureRecognizer()

    let recognizer = UITapGestureRecognizer()
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var questionPic: UIImageView!
    @IBOutlet weak var qeustionText: UILabel!
    @IBOutlet weak var writerName: UILabel!
    @IBOutlet weak var writerPic: RoundedImageView!
    
    @IBOutlet weak var writeTime: UILabel!
    @IBAction func answerAction(_ sender: Any) {
        if FIRAuth.auth()?.currentUser == nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"auth_vc") as! TcAuthViewController
            vc.modalFlag = true
            self.present(vc, animated: true)
            return
        }
        if (FIRAuth.auth()?.currentUser) != nil {
            performSegue(withIdentifier: "tc07_segue", sender: content_Number)
        }
        
    }
    func imageTapped(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"image_vc") as! Tc10ImageViewController
        vc.image = questionPic.image
        self.present(vc, animated: true)
    }
    
    func profileImageHasBeenTapped(){
        if FIRAuth.auth()?.currentUser == nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"auth_vc") as! TcAuthViewController
            vc.modalFlag = true
            self.present(vc, animated: true)
            return
        }
        if (FIRAuth.auth()?.currentUser) != nil {
            performSegue(withIdentifier: "tc04_segue", sender: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.writerName.text = writer_Name
        self.writeTime.text = write_Time
        writerPic.isUserInteractionEnabled = true
        self.title = "질문보기"
        recognizer.addTarget(self, action: #selector(Tc05ContentViewController.profileImageHasBeenTapped))
        writerPic.addGestureRecognizer(recognizer)
        
        questionPic.isUserInteractionEnabled = true
        image_recognizer.addTarget(self, action: #selector(Tc05ContentViewController.imageTapped))
        questionPic.addGestureRecognizer(image_recognizer)
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width , height: 1)
        topBorder.backgroundColor = UIColor.gray.cgColor
        questionPic.layer.addSublayer(topBorder)
        
        
        if let uid = writer_Uid {
            let user_ref=FIRDatabase.database().reference().child("Users").child(uid)
            user_ref.observe(.value, with: { (userSnapshot) in
                if let userdic = userSnapshot.value as? [String : Any]{
                    let image = userdic["profileImg"] as? String
                    let url = URL(string: image!)!
                    Nuke.loadImage(with: url, into: self.writerPic)}
            }, withCancel: nil)
            
        }
    
    }
    override func viewWillAppear(_ animated: Bool) {
        FIRDatabase.database().reference().child("Question").child(content_Number!).observe(.value , with: { (FIRDataSnapshot) in
            if let dictionary = FIRDataSnapshot.value as? [String : Any]{
                self.qeustionText.text = dictionary["questionText"] as? String
                
                let pickStr = dictionary["questionPic"] as? String
                if pickStr! != "null"{
                let url = URL(string: pickStr!)
                    Nuke.loadImage(with: url!, into: self.questionPic)
                }else{
                    self.cellHeight.constant = self.view.frame.height / 2
                }
                if let ans = dictionary["answer"] as? [String: Any]{
                    self.ansArr.removeAll()
                    self.typeArr.removeAll()
                    self.keyArr = Array(ans.keys)
                    for answer in ans.values {
                        let ansValue = answer as! [String : Any]
                        self.ansArr.append(ansValue["text"] as! String)
                        let answer_temp = Answer()
                        answer_temp.type = (ansValue["type"] as! String)
                        answer_temp.url = (ansValue["content"] as! String)
                        answer_temp.text = (ansValue["text"] as! String)
                        answer_temp.writer = (ansValue["writer"] as! String)
                        self.answers.append(answer_temp)
                        
                    }
                    self.sections = [Section(count : ans.count, items : self.ansArr)]
                    self.tableview.reloadData()
                }else{
                    self.sections = [Section(count : 0, items : self.ansArr)]
                    self.tableview.reloadData()
                }
                
                
            }
            
        })
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = "답변 "+String(sections[section].count)
        header.arrowLabel.text = ">"
        header.setCollapsed(sections[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].collapsed! ? 0 : 44.0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Tc05TableViewCell
        cell.answerText.text = sections[indexPath.section].items[indexPath.row]
        if answers[indexPath.row].type == "video" {
            cell.typeImage.image = #imageLiteral(resourceName: "video-player")
        }else if answers[indexPath.row].type == "photo" {
            cell.typeImage.image = #imageLiteral(resourceName: "picture")
        }else {
            cell.typeImage.image = #imageLiteral(resourceName: "justify")
        }
        //print(typeArr[indexPath.row])
        return cell
    }
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Adjust the height of the rows inside the section
        tableview.beginUpdates()
        for i in 0 ..< sections[section].items.count {
            tableview.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableview.endUpdates()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if answers[indexPath.row].type=="video"{
        performSegue(withIdentifier: "tc06video_segue", sender: indexPath.row)
        }else{
        performSegue(withIdentifier: "tc06photo_segue", sender: indexPath.row)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tc07_segue"{
            let answerVC = segue.destination as! Tc07RecordViewController
            let number = sender as! String
            answerVC.content_Number = number

        }
        
        if segue.identifier == "tc06video_segue"{
            let videoVC = segue.destination as! Tc06AnswerVideoViewController
            let idx = sender as! Int
            videoVC.answer_num = keyArr[idx]
            videoVC.question_num = content_Number
            videoVC.url = answers[idx].url
            videoVC.text = answers[idx].text
            videoVC.writer = answers[idx].writer
        }
        
        if segue.identifier == "tc06photo_segue"{
            let photoVC = segue.destination as! Tc06AnswerPhotoViewController
            let idx = sender as! Int
            photoVC.answer_num = keyArr[idx]
            photoVC.question_num = content_Number
            photoVC.url = answers[idx].url
            photoVC.text = answers[idx].text
            photoVC.type = answers[idx].type
            photoVC.writer = answers[idx].writer
        }
        
        if segue.identifier == "tc04_segue"{
            let profileVC = segue.destination as! Tc04MyViewController
            profileVC.modalFlag = true
            profileVC.uid = writer_Uid
        }
        
    }
}
