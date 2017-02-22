//
//  Tc01TableViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 6..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Firebase
class Tc01TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, categoryDelegate, UISearchBarDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var question = [Question]()
    var question_all = [Question]()
    var question_temp = [Question]()
    var question_search = [Question]()
    var queue = OperationQueue()
    var indicator : IndicatorHelper?
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil{
            let searchText : String?
            if searchBar.text?.characters.first == "#"{
                searchText = searchBar.text!
            }else{
                searchText = "#"+searchBar.text!
            }
            question_search.removeAll()
            for searchQa in question_all{
                if searchQa.tag != nil {
                    if searchQa.tag!.contains(searchText!) {
                        question_search.append(searchQa)
                    }
                }
                
            }
            question = question_search
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.reloadData()
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            question = question_all
            tableView.reloadData()
        }
    }
    
    
    func categorySearch(cate : String){
        if cate == "전체" {
            self.question = self.question_all
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }else{
            self.question_temp.removeAll()
            FIRDatabase.database().reference().child("Question").queryOrdered(byChild: "category").queryEqual(toValue: tc_category_dic[cate]!).observeSingleEvent(of: .childAdded, with: { (FIRDataSnapshot) in
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
                    
                    self.question_temp.append(qa)
                        self.question = self.question_temp
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        indicator = IndicatorHelper(view: self.view)
        indicator?.start()
    
        search.barTintColor = UIColor(red: 0.58, green: 0.46, blue: 0.80, alpha: 1)
        tableView.estimatedRowHeight = 1000
        tableView.rowHeight = UITableViewAutomaticDimension
        
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
                if let tag = dictionary["tag"] as? [String]{
                    let joiner = " "
                    qa.tagLabel = tag.joined(separator: joiner)
                    qa.tag = tag
                }
                
                self.question_all.append(qa)
                if self.appdelegate.curCategory == "전체" {
                    self.question = self.question_all
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        self.indicator?.stop()
                    })
                }
                
            }
            
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationItem.title = appdelegate.curCategory
        
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "tc01txt_cell", for: indexPath) as! Tc01TableViewCell
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "tc05_segue", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
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
        
        if segue.identifier == "Tc01cate_segue"{
            let cateVC = segue.destination as! Tc01categoryViewController
            cateVC.delegate = self
        }
    }

}
