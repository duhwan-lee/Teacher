//
//  TeacherAuthViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 6..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Firebase

class TcAuthViewController: UIViewController, GIDSignInUIDelegate , GIDSignInDelegate{
    
    //@IBOutlet weak var signInButton: GIDSignInButton!
    
    @IBAction func noLoginAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"tabView")
        self.show(vc!, sender: nil)
    }
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBAction func loginAction(_ sender: Any) {
        GIDSignIn.sharedInstance().signInSilently()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                                     accessToken: (authentication?.accessToken)!)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"tabView")
            self.show(vc!, sender: nil)
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
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
