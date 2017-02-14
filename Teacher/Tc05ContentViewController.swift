//
//  Tc05ContentViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 7..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Firebase
class Tc05ContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,CollapsibleTableViewHeaderDelegate {

    @IBOutlet weak var tableview: UITableView!
    var writer_Uid : String?
    var content_Number : String?
    var writer_Name : String?
    var queue = OperationQueue()
    var sections = [Section]()
    var ansArr = [String]()
    var typeArr = [String]()
    var keyArr = [String]()
    @IBOutlet weak var questionPic: UIImageView!
    @IBOutlet weak var qeustionText: UILabel!
    @IBOutlet weak var writerName: UILabel!
    @IBOutlet weak var writerPic: UIImageView!
    
    @IBAction func answerAction(_ sender: Any) {
        performSegue(withIdentifier: "tc07_segue", sender: content_Number)
    }
    override func viewWillAppear(_ animated: Bool) {
        FIRDatabase.database().reference().child("Question").child(content_Number!).observe(.value , with: { (FIRDataSnapshot) in
            if let dictionary = FIRDataSnapshot.value as? [String : Any]{
                self.qeustionText.text = dictionary["questionText"] as? String
                let pickStr = dictionary["questionPic"] as? String
                self.queue.addOperation {
                    if let url = URL(string: pickStr!),
                        let data = try? Data(contentsOf: url),
                        let image = UIImage(data:data) {
                        OperationQueue.main.addOperation {
                            self.questionPic.image = image
                        }
                    }
                }
                if let ans = dictionary["answer"] as? [String: Any]{
                    self.ansArr.removeAll()
                    self.typeArr.removeAll()
                    self.keyArr = Array(ans.keys)
                    for answer in ans.values {
                        let ansValue = answer as! [String : Any]
                        self.ansArr.append(ansValue["text"] as! String)
                        self.typeArr.append(ansValue["type"] as! String)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.writerName.text = writer_Name
        
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
        print(typeArr[indexPath.row])
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
        if typeArr[indexPath.row]=="video"{
        performSegue(withIdentifier: "tc06video_segue", sender: keyArr[indexPath.row])
        }else if typeArr[indexPath.row]=="photo" {
            
        }else {
            
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
            let ans_num = sender as! String
            videoVC.answer_num = ans_num
            videoVC.question_num = content_Number
        }
            
    }
}
