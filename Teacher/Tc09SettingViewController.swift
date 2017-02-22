//
//  Tc09SettingViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 15..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Firebase
class Tc09SettingViewController: UITableViewController {

    
    @IBOutlet weak var LoginLabel: UILabel!
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [0, 0]{if FIRAuth.auth()?.currentUser == nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"auth_vc") as! TcAuthViewController
            vc.modalFlag = true
            self.present(vc, animated: true)
            return
            }
            let dialog = UIAlertController(title: "로그아웃 확인", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { (UIAlertAction) in
                
            })
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                try! FIRAuth.auth()!.signOut()
                self.navigationController?.popToRootViewController(animated: true)
            }
            dialog.addAction(cancelAction)
            dialog.addAction(okAction)
            
            self.present(dialog, animated: true, completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser == nil {
            LoginLabel.text = "로그인"
        }else{
            LoginLabel.text = "로그아웃"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
