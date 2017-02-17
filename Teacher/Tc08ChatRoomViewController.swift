//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import UIKit
import Photos
import Firebase
import CoreLocation

class Tc08ChatRoomViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {

    
    //MARK: Properties
    var toUid : String?
    var message = [Message]()
    var channel : String?
    var toName : String?
    let sv = sendValue()
    let locationManager = CLLocationManager()
    var profileFlag = false
    var profileImg : UIImage?
    
    @IBOutlet weak var viewTop: NSLayoutConstraint!
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    override var inputAccessoryView: UIView? {
        get {
            self.inputBar.frame.size.height = self.barHeight
            self.inputBar.clipsToBounds = true
            return self.inputBar
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    let imagePicker = UIImagePickerController()
    let barHeight: CGFloat = 50
    var canSendLocation = true
    @IBAction func showMessage(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
    }
    
    @IBAction func selectGallery(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func selectCamera(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    func checkLocationPermission() -> Bool {
        var state = false
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            state = true
        case .authorizedAlways:
            state = true
        default: break
        }
        return state
    }
    
    @IBAction func selectLocation(_ sender: Any) {
        self.canSendLocation = true
        self.animateExtraButtons(toHide: true)
        if self.checkLocationPermission() {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func showOptions(_ sender: Any) {
        self.animateExtraButtons(toHide: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        self.locationManager.stopUpdatingLocation()
//        if let lastLocation = locations.last {
//            if self.canSendLocation {
//                let coordinate = String(lastLocation.coordinate.latitude) + ":" + String(lastLocation.coordinate.longitude)
//        
//                self.canSendLocation = false
//            }
//        }
    }

    //MARK: Methods
    func customization() {
        self.tableView.estimatedRowHeight = self.barHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        self.navigationItem.title = toName
        //self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    //Downloads messages
    func fetchData() {
        if (FIRAuth.auth()?.currentUser?.uid) != nil {
            let ref = FIRDatabase.database().reference().child("message").child(channel!)
            ref.observe(.childAdded, with: { (FIRDataSnapshot) in
                if let dictionary = FIRDataSnapshot.value as? [String : Any]{
                    let msg = Message()
                    msg.text = dictionary[self.sv.text] as? String
                    msg.time = dictionary[self.sv.time] as? Int
                    msg.toUid = dictionary[self.sv.toUid] as? String
                    msg.fromUiD = dictionary[self.sv.fromUid] as? String
                    self.message.append(msg)
                    self.tableView.reloadData()
                }
            }, withCancel: nil)
        }
    }

    
    func animateExtraButtons(toHide: Bool)  {
        switch toHide {
        case true:
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        default:
            self.bottomConstraint.constant = -50
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        }
    }
    

    
    @IBAction func sendMessage(_ sender: Any) {
        if let txt = inputTextField.text {
            let timeStamp = Int(NSDate().timeIntervalSince1970)
            messageUpload(txt: txt, time: timeStamp)
            meUpdate(txt: txt, time: timeStamp)
            youUpdate(txt: txt, time: timeStamp)
            inputTextField.text = ""
        }
    
    }
    
    //MARK: NotificationCenter handlers
    func showKeyboard(notification: Notification) {
        if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.tableView.contentInset.bottom = height
            self.tableView.scrollIndicatorInsets.bottom = height
            if self.message.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: self.message.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }

    //MARK: Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.message.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.message[indexPath.row].toUid == toUid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
                cell.clearCellData()
                cell.message.text = message[indexPath.row].text
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
                cell.clearCellData()
                cell.message.text = message[indexPath.row].text
            return cell
            }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
    //MARK: ViewController lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if profileFlag {
            viewTop.constant = 44
            let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width , height: 44))
            self.view.addSubview(navBar);
            let navItem = UINavigationItem(title: "메세지");
            let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: #selector(back));
            navItem.leftBarButtonItem = doneItem;
            navBar.setItems([navItem], animated: false);
        }
        self.inputBar.backgroundColor = UIColor.clear
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.fetchData()
    }
    
    func messageUpload(txt : String, time : Int){
        let ref = FIRDatabase.database().reference().child("message").child(channel!)
        let childRef = ref.childByAutoId()
        let fromUid = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let value = [ sv.text: txt, sv.toUid : toUid!, sv.fromUid : fromUid, sv.time : timeStamp] as [String : Any]
        childRef.updateChildValues(value)
        
    }
    
    func meUpdate(txt : String , time : Int){
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference().child("Users").child(uid).child("channel").child(channel!)
        let value = ["lastDate":time, "lastText":txt] as [String : Any]
        ref.updateChildValues(value)
    }
    
    func youUpdate(txt : String , time : Int){
        let ref = FIRDatabase.database().reference().child("Users").child(toUid!).child("channel").child(channel!)
        let value = ["lastDate":time, "lastText":txt] as [String : Any]
        ref.updateChildValues(value)
    }

}



