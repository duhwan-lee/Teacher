//
//  Tc03ChatViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 9..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Firebase

class Tc03ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var chatChannel : String?
    var chArr = [Channel]()
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "채팅"
    loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tc03_cell", for: indexPath) as! Tc03ChatTableViewCell
        
        cell.textLabel?.text = chArr[indexPath.row].text
        if let uid = chArr[indexPath.row].uid {
            let user_ref=FIRDatabase.database().reference().child("Users").child(uid)
            user_ref.observe(.value, with: { (userSnapshot) in
                if let userdic = userSnapshot.value as? [String : Any]{
                    let name = userdic["name"] as? String
                    let image = userdic["profileImge"] as? String
                    self.chArr[indexPath.row].name = name
                    cell.textLabel?.text = name
                }
            }, withCancel: nil)

        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chArr.count
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "tc08_segue", sender: indexPath)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tc08_segue"{
            let chatVC = segue.destination as! Tc08ChatRoomViewController
            let idx = sender as! IndexPath
            chatVC.toUid = chArr[idx.row].uid
            chatVC.channel = chArr[idx.row].channel_name
            chatVC.toName = chArr[idx.row].name
        }
    }
    
    func loadData(){
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let ref = FIRDatabase.database().reference().child("Users").child(uid).child("channel")
            ref.observe(.childAdded, with: { (FIRDataSnapshot) in
                let ch = Channel()
                ch.channel_name = FIRDataSnapshot.key
                ch.uid = ch.channel_name?.replacingOccurrences(of: (FIRAuth.auth()?.currentUser?.uid)!, with: "")
                
                
                
                if let dictionary = FIRDataSnapshot.value as? [String : Any]{
                    ch.text = dictionary["lastText"] as? String
                    
                    let seconds = dictionary["lastDate"] as! Int
                    let timestampDate = NSDate(timeIntervalSince1970: TimeInterval(seconds))
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd a hh:mm:ss"
                    let timetext = dateFormatter.string(from: timestampDate as Date)
                    ch.time = timetext
                    self.chArr.append(ch)
                    self.tableview.reloadData()
                }
            }, withCancel: nil)
        }
        

    }
    
}

