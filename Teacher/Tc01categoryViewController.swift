//
//  Tc01catogoryViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 7..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit

class Tc01categoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tc01_cate_cell")
        cell?.textLabel?.text = tc_category[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tc_category.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (UIApplication.shared.delegate as! AppDelegate).curCategory = tc_category[indexPath.row]
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        let idx = tc_category.index(of : (UIApplication.shared.delegate as! AppDelegate).curCategory)
        let indexPath = IndexPath(row: idx!, section: 0)
        tableview.selectRow(at: indexPath, animated: true, scrollPosition: .top)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
