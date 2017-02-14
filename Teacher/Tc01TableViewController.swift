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

    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var question = [Question]()
    var lastKnowContentOfsset : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        navigationItem.title = appdelegate.curCategory
        question.removeAll()
        FIRDatabase.database().reference().child("Question").observe(.childAdded, with: { (FIRDataSnapshot) in
            print(FIRDataSnapshot)
            if let dictionary = FIRDataSnapshot.value as? [String : Any]{
                let qa = Question()
                qa.contentNumber = FIRDataSnapshot.key
                qa.questionText = dictionary["questionText"] as! String?
                qa.readCount = dictionary["readCount"] as! Int?
                qa.answerCount = dictionary["answerCount"] as! Int?
                qa.writerUid = dictionary["writerUid"] as! String?
                qa.writerName = dictionary["writerName"] as! String?
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "tc01_cell", for: indexPath)
        cell.textLabel?.text = question[indexPath.row].questionText
        cell.detailTextLabel?.text = String(describing: question[indexPath.row].answerCount)
        return cell
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
        }
    }


}
