//
//  Tc01catogoryViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 7..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
protocol categoryDelegate : class{
    func categorySearch(cate : String)
}

class Tc01categoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate : categoryDelegate!
    let test = "abc"
    @IBOutlet weak var tableview: UITableView!
    
    var lastCate : String?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tc01_cate_cell")
        cell?.textLabel?.text = tc_category[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tc_category.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cate_temp = tc_category[indexPath.row]
        (UIApplication.shared.delegate as! AppDelegate).curCategory = cate_temp
        self.dismiss(animated: true) {
            if cate_temp != self.lastCate! {
                self.delegate?.categorySearch(cate: cate_temp)
            }
            
        }
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        lastCate = (UIApplication.shared.delegate as! AppDelegate).curCategory
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
