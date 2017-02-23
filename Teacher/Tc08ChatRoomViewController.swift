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
import SwiftMessages
import Nuke
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
    var queue = OperationQueue()
    var indicator : IndicatorHelper?
    var firstFlag = true
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
        imagePicker.sourceType = .photoLibrary //앨범에서 이미지 가져옴
        self.present(imagePicker, animated: true)

        
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
    
    @IBAction func selectLocation(_ sender: Any) {
        let warning = MessageView.viewFromNib(layout: .CardView)
        warning.configureTheme(.warning)
        warning.configureDropShadow()
        
        warning.configureContent(title: "알림", body: "죄송합니다. 현재 서비스 준비중입니다.", iconText: "🤔")
        warning.button?.isHidden = true
        var warningConfig = SwiftMessages.defaultConfig
        warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        SwiftMessages.show(config: warningConfig, view: warning)

    }
    
    @IBAction func showOptions(_ sender: Any) {
        self.animateExtraButtons(toHide: false)
    }
    override func viewWillAppear(_ animated: Bool) {
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
        imagePicker.delegate = self
        self.tableView.estimatedRowHeight = self.barHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        self.navigationItem.title = toName
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
                    msg.type = dictionary[self.sv.type] as? String
                    msg.url = dictionary[self.sv.url] as? String
                    
                    self.message.append(msg)
                    let idx = IndexPath(row: self.message.count-1, section: 0)
                    self.tableView.reloadData()
                    if self.firstFlag{
                        self.tableView.scrollToRow(at: idx, at: .bottom, animated: false)
                    }
                    
                    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            uploadImage(image: image)
        }
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func sendMessage(_ sender: Any) {
        if let txt = inputTextField.text {
            let timeStamp = Int(NSDate().timeIntervalSince1970)
            messageUpload(txt: txt, time: timeStamp, type : "text", url : "null")
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
            firstFlag = false
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    func uploadImage(image : UIImage){
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let filename = "chat_"+(FIRAuth.auth()?.currentUser?.uid)! + String(timestamp) + ".png"
        let storage = FIRStorage.storage().reference().child("Chat").child(filename)
        if let uploadImage = UIImagePNGRepresentation(image){
            storage.put(uploadImage, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error as Any)
                    return
                }else{
                    if let downUrl = metadata?.downloadURL()?.absoluteString{
                        self.messageUpload(txt : "null", time : timestamp, type : "photo", url : downUrl)
                        self.meUpdate(txt : "사진" , time : timestamp)
                        self.youUpdate(txt : "사진" , time : timestamp)
                    }
                    
                }
            })
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.message[indexPath.row].toUid == toUid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
                cell.clearCellData()
            if message[indexPath.row].type == "photo"{
                    cell.messageBackground.image = #imageLiteral(resourceName: "img_not_available")
                    let url = URL(string: message[indexPath.row].url!)
                    Nuke.loadImage(with: url!, into: cell.messageBackground)
                    cell.message.isHidden = true
    
            }else{
                cell.message.text = message[indexPath.row].text
            }
            
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
                cell.clearCellData()
            if message[indexPath.row].type == "photo"{
                if message[indexPath.row].image == nil {
                    if let url = URL(string: message[indexPath.row].url!){
                        queue.addOperation {
                            do {
                                let data = try Data(contentsOf: url)
                                let image = UIImage(data: data)
                                self.message[indexPath.row].image = image
                                // show image on MainThread
                                OperationQueue.main.addOperation {
                                    cell.message.isHidden = true
                                    tableView.reloadData()
                                }
                            }
                            catch let error {
                                print("Error : ", error.localizedDescription)
                            }
                        }
                    }
                    
                }else{
                    cell.messageBackground.image = message[indexPath.row].image!
                    cell.message.isHidden = true
                }
            }else{
                cell.message.text = message[indexPath.row].text
            }
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
            let navItem = UINavigationItem(title: toName!);
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
    
    func messageUpload(txt : String, time : Int, type : String, url : String){
        let ref = FIRDatabase.database().reference().child("message").child(channel!)
        let childRef = ref.childByAutoId()
        let fromUid = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let value = [ sv.text: txt, sv.toUid : toUid!, sv.fromUid : fromUid, sv.time : timeStamp, sv.type : type, sv.url : url] as [String : Any]
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



