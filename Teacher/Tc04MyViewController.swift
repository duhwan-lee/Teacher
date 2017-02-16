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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImg: RoundedImageView!
    var anskeys = [String]()
    
    
    @IBAction func segment(_ sender: Any) {
        
        let control = sender as! UISegmentedControl
        switch control.selectedSegmentIndex {
        case 0:
            if modalFlag {
                writeTextLoad(uid!)
            }else{
                if let myUid = FIRAuth.auth()?.currentUser?.uid {
                    writeTextLoad(myUid)
                }
            }
        case 1:
            ansTextLoad("abc")
        default:
            print("맑음")
        }

    
    }
    
    var modalFlag = false
    var queue = OperationQueue()
    var uid : String?
    var question = [Question]()

    
    @IBOutlet weak var viewTop: NSLayoutConstraint!
    override func viewWillAppear(_ animated: Bool) {
        if modalFlag {
            writeTextLoad(uid!)
            anskeys = getAnswersKeys(uid!)
        }else{
            if let myUid = FIRAuth.auth()?.currentUser?.uid {
            writeTextLoad(myUid)
            anskeys = getAnswersKeys(myUid)
            }
        }

    }
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 1000
        tableView.rowHeight = UITableViewAutomaticDimension

        super.viewDidLoad()
        if modalFlag {
            viewTop.constant = 44
            let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width , height: 44))
            self.view.addSubview(navBar);
            let navItem = UINavigationItem(title: "프로필");
            let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: #selector(back));
            navItem.leftBarButtonItem = doneItem;
            navBar.setItems([navItem], animated: false);
            modalAction(uid!)
        }else{
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
        }
    }
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    func getAnswersKeys(_ uid : String) -> [String]{
    var strArr = [String]()
    let ref = FIRDatabase.database().reference().child("Users").child(uid)
        ref.observe(.value, with: { (FIRDataSnapshot) in
            if let dictionary = FIRDataSnapshot.value as? [String : Any]{
                if let ans = dictionary["answer"] as? [String: Any]{
                    strArr = Array(ans.keys)
                }
            }
            
        })
    
    return strArr
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
            //
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
        
        let user_ref=FIRDatabase.database().reference().child("Users").child(uid)
        user_ref.observe(.value, with: { (userSnapshot) in
            if let userdic = userSnapshot.value as? [String : Any]{
                let name = userdic["name"] as? String
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
    
    func ansTextLoad(_ uid : String){
        let value = ["-KcqNmHeKxui-O8cp3dG", "123"]
        let ref = FIRDatabase.database().reference().child("Question").queryOrderedByKey()
        //.queryEqual(toValue: value)
        ref.observe(.childAdded, with: { (FIRDataSnapshot) in
            print(FIRDataSnapshot)
        })
    }
    func writeTextLoad(_ uid : String){
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
                
                
                if let ans = dictionary["answer"] as? [String: Any]{
                    qa.answerCount = Array(ans.keys).count
                }
                
                self.question.append(qa)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
                
            }
        })
    }
}
