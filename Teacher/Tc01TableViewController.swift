//
//  Tc01TableViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 6..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Firebase
class Tc01TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var question = [Question]()
    var lastKnowContentOfsset : CGFloat = 0
    var queue = OperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        tableView.backgroundColor = UIColor.clear
        search.barTintColor = UIColor(red: 0.58, green: 0.46, blue: 0.80, alpha: 1)
        tableView.estimatedRowHeight = 1000
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        navigationItem.title = appdelegate.curCategory
        question.removeAll()
        FIRDatabase.database().reference().child("Question").observe(.childAdded, with: { (FIRDataSnapshot) in
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return question.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if question[indexPath.row].questionPic != "null" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tc01_cell", for: indexPath) as! Tc01TableViewCell
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "tc01txt_cell", for: indexPath) as! Tc01TableViewCell
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "tc05_segue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tc05_segue"{
            let contentVC = segue.destination as! Tc05ContentViewController
            let idx = sender as! IndexPath
            contentVC.writer_Uid = question[idx.row].writerUid
            contentVC.writer_Name = question[idx.row].writerName
            contentVC.content_Number = question[idx.row].contentNumber
            contentVC.write_Time = question[idx.row].writeTime
        }
    }


}
