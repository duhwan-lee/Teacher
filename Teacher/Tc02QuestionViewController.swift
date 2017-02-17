//
//  Tc02QuestionViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 6..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import TouchDraw
import Firebase

class Tc02QuestionViewController: UIViewController, TouchDrawViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, CustomPalettViewDelegate {
    
    @IBOutlet weak var photoButton: UIBarButtonItem!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var mergeView: UIView!
    @IBOutlet weak var TextButton: UIBarButtonItem!
    @IBOutlet weak var ImageContainView: UIView!
    @IBOutlet weak var drawView: TouchDrawView!
    var placeholderLabel : UILabel!
    var textview : UITextView!
    var dialog : UIAlertController!
    var penWidth : CGFloat = 2.0
    var question_txt : String = ""
    var palett : CustomPalettView?
    
    @IBAction func cancleAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imagePickAction(_ sender: Any) {
        let dialog = UIAlertController(title: "이미지 선택", message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let cameraAction = UIAlertAction(title: "사진촬영", style: .default) { (action) in
            imagePicker.sourceType = .camera //사진촬영으로 이미지 가져옴
            self.present(imagePicker, animated: true)
        }
        dialog.addAction(cameraAction)
        
        
        let albumAction = UIAlertAction(title: "앨범", style: .default) { (action) in
            imagePicker.sourceType = .photoLibrary //앨범에서 이미지 가져옴
            self.present(imagePicker, animated: true)
            
        }
        dialog.addAction(albumAction)
        
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
        }
        if let popvc = dialog.popoverPresentationController{
            popvc.sourceView = self.view
        }
        dialog.addAction(cancelAction)
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //키보드 return값 설정
        tagTextField.resignFirstResponder()
        return true
    }
    
    func setColor(color: UIColor) {
        drawView.setColor(color)
        self.dismiss(animated: true, completion: nil)
    }
    func setPenWidth(width: Float) {
        penWidth = CGFloat(width)
        drawView.setWidth(penWidth)
    }
    func setUndo(){
        drawView.undo()
    }
    func setClear(){
        drawView.clearDrawing()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func drawAction(_ sender: Any) {
        dialog = UIAlertController(title: "\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
            let margin:CGFloat = 4.0
            let rect = CGRect(x: margin, y: margin, width: dialog.view.frame.size.width-(margin*6), height: 150.0)
            palett = CustomPalettView(frame: rect)

            palett?.delegate = self
            palett?.slider.value = Float(penWidth)
            dialog.view.addSubview(palett!)
            
        
        
        
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            
        }
        dialog.addAction(okAction)
        
        
        if let popvc = dialog.popoverPresentationController{
            popvc.sourceView = self.view
        }
        
        self.present(dialog, animated: true, completion: nil)
    }
    @IBAction func uploadAction(_ sender: Any) {
        
        UIGraphicsBeginImageContext(self.mergeView.frame.size) // 이미지 context 생성
        mergeView.drawHierarchy(in: self.mergeView.frame, afterScreenUpdates: true) //Snapshot 촬영후 현재 context에 저장
        let mergeImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()! //현재 image context -> UIImage로 저장
        UIGraphicsEndImageContext()
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let filename = (FIRAuth.auth()?.currentUser?.uid)! + String(timestamp) + ".png"
        let storage = FIRStorage.storage().reference().child("Question").child(filename)
        if let uploadImage = UIImagePNGRepresentation(mergeImage){
            storage.put(uploadImage, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error as Any)
                    return
                }else{
                    if let downUrl = metadata?.downloadURL()?.absoluteString{
                        let ref = FIRDatabase.database().reference(fromURL: "https://teacher-d9168.firebaseio.com/")
                        let userReference = ref.child("Question").childByAutoId()
                        let uid = (FIRAuth.auth()?.currentUser?.uid)! as String
                        let name = (FIRAuth.auth()?.currentUser?.displayName)! as String
                        let value : Dictionary = ["questionText" : self.question_txt , "writerUid": uid, "questionPic" : downUrl, "readCount" : 0, "answerCount" : 0,"writerName" : name, "writeTime": timestamp] as [String : Any]
                        userReference.updateChildValues(value)
                    }
                    
                }
            })
        }
        
        
    }
    
    @IBAction func textAction(_ sender: Any) {
        dialog = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let margin:CGFloat = 8.0
        let rect = CGRect(x: margin, y: margin, width: dialog.view.bounds.size.width - margin * 4.0, height: 100.0)
        textview = UITextView(frame: rect)
        
        textview.backgroundColor = UIColor.clear
        textview.font = UIFont(name: "Helvetica", size: 15)
    
        //  customView.backgroundColor = UIColor.greenColor()
        textview.text = question_txt
        dialog.view.addSubview(textview)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.question_txt = self.textview.text!
        }
        dialog.addAction(okAction)
        
        
        if let popvc = dialog.popoverPresentationController{
            popvc.sourceView = self.view
        }
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        photoButton.setBackgroundImage(#imageLiteral(resourceName: "photo"), for: .normal, barMetrics: .default)
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{ //수정되지 않은 이미지 선택
            if picker.sourceType == .camera { //if camera
                //imageView.image = image
                let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                    imageview.image = image
                //let imageview = UIImageView(image: image)
                
                ImageContainView.addSubview(imageview)
                dismiss(animated: true, completion: nil)
            }else{
                //imageView.image = image
                let newimage = imageWithImage(sourceImage: image, scaledToWidth: self.ImageContainView.frame.width )
                let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: ImageContainView.frame.width, height: newimage.size.height))
                imageview.image = newimage
                
                ImageContainView.addSubview(imageview)
                dismiss(animated: true, completion: nil)
            }
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.delegate = self
        drawView.setWidth(2.0)
        drawView.backgroundColor = UIColor(white: 1, alpha: 0.0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    override var shouldAutorotate: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    func keyboardWillShow(_ noti : Notification){
        
        if let rectObj = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue, tagTextField.isFirstResponder
        {
            // 키보드 높이 가져옴
            let keyboardRect = rectObj.cgRectValue
            // 키보드 높이 만큼 화면 밀기
            self.view.frame.origin.y = 0 - keyboardRect.height
        }

        else if let rectObj = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue, textview.isFirstResponder
        {
            // 키보드 높이 가져옴
            let keyboardRect = rectObj.cgRectValue
            // 키보드 높이 만큼 화면 밀기
            self.view.frame.origin.y = 0 - keyboardRect.height
            self.dialog.view.frame.origin.y = keyboardRect.height
        }    }
    
    func keyboardWillHide(_ noti : Notification){
        self.view.frame.origin.y = 0
    }

    
    func undoEnabled() {
    palett?.undoButton.isEnabled = true
    }
    
    func undoDisabled() {
    palett?.undoButton.isEnabled = false
    }
    
    func redoEnabled() {
    }
    
    func redoDisabled() {
    }
    
    func clearEnabled() {
    }
    
    func clearDisabled() {
    }
    
}
