//
//  Tc07RecordViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 13..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import TouchDraw
import ReplayKit
import MobileCoreServices
import Firebase

class Tc07RecordViewController: UIViewController, TouchDrawViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CustomPalettViewDelegate, RPScreenRecorderDelegate,
RPPreviewViewControllerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var borderView: UIView!
    var content_Number : String?
    var penWidth : CGFloat = 2.0
    var palett : CustomPalettView?
    var dialog : UIAlertController!
    var click = true
    var imageFlag = false
    var drawFlag = false
    let recorder = RPScreenRecorder.shared()
    let writer = (FIRAuth.auth()?.currentUser?.uid)! as String
    var indicator : IndicatorHelper?

    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var ImagecontainView: UIView!
    @IBOutlet weak var drawview: TouchDrawView!
    @IBOutlet weak var mergeView: UIView!
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var videoUpload: UIBarButtonItem!
    
    @IBAction func clearAction(_ sender: Any) {
        drawview.clearDrawing()
    }
    
    @IBAction func undoAction(_ sender: Any) {
        drawview.undo()
    }
    
    @IBAction func imageUploadAction(_ sender: Any) {
        
        if textView.text.isEmpty {
            let dialog = UIAlertController(title: "업로드 확인", message: "본문이 없습니다.\n본문을 입력해주세요", preferredStyle: .alert)
            
            
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            }
            
            dialog.addAction(okAction)
            
            self.present(dialog, animated: true, completion: nil)
            return
        }
        
        let dialog = UIAlertController(title: "업로드 확인", message: "업로드 내용을 선택해주세요", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (UIAlertAction) in
            
        }
        dialog.addAction(cancelAction)
        let okAction = UIAlertAction(title: "동영상", style: .default) { (action) in
            let imagepicker = UIImagePickerController()
            imagepicker.delegate = self
            imagepicker.mediaTypes = [kUTTypeMovie as String]
            self.present(imagepicker, animated: true, completion: nil)
        }
        let timestamp = Int(NSDate().timeIntervalSince1970)

        if !drawFlag, !imageFlag {
            let textAction = UIAlertAction(title: "텍스트", style: .default, handler: {
                (action) in
                self.indicator?.start()
                let ref = FIRDatabase.database().reference().child("Question").child(self.content_Number!).child("answer").childByAutoId()
                let value = ["text" : self.textView.text, "type" : "text", "content" : "null", "writer" : self.writer, "time" : timestamp] as [String : Any]
                ref.updateChildValues(value)
                self.indicator?.stop()
                self.dismiss(animated: true, completion: nil)
            })
            dialog.addAction(textAction)
        }else{
            let imageAction = UIAlertAction(title: "이미지", style: .default, handler: { (action) in
                self.indicator?.start()
                UIGraphicsBeginImageContext(self.mergeView.frame.size) // 이미지 context 생성
                self.mergeView.drawHierarchy(in: self.mergeView.frame, afterScreenUpdates: true) //Snapshot 촬영후 현재 context에 저장
                let mergeImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()! //현재 image context -> UIImage로 저장
                UIGraphicsEndImageContext()
                let filename = (FIRAuth.auth()?.currentUser?.uid)! + String(timestamp) + ".png"
                let storage = FIRStorage.storage().reference().child("Answer").child("Photo").child(filename)
                if let uploadImage = UIImagePNGRepresentation(mergeImage){
                    storage.put(uploadImage, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error ?? "Error")
                            return
                        }else{
                            if let downUrl = metadata?.downloadURL()?.absoluteString{
                                let ref = FIRDatabase.database().reference(fromURL: "https://teacher-d9168.firebaseio.com/").child("Question").child(self.content_Number!).child("answer").childByAutoId()
                                let value = ["text" : self.textView.text, "type" : "photo", "content" : downUrl, "writer" : self.writer, "time" : timestamp] as [String : Any]
                                ref.updateChildValues(value)
                                self.indicator?.stop()
                                self.dismiss(animated: true, completion: nil)
                            }
                            
                        }
                    })
                }
            })
            dialog.addAction(imageAction)
        }
        
        
        dialog.addAction(okAction)
        
        self.present(dialog, animated: true, completion: nil)
        return
    }
    
    @IBAction func cancelAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func recordAction(_ sender: Any) {
        if click {
            click = false
            if recorder.isAvailable {
                recordButton.image = #imageLiteral(resourceName: "stop")
                recorder.startRecording(withMicrophoneEnabled: true){err in
                    print (err.debugDescription)
                }
            }else{
                click = true
                recordButton.image = #imageLiteral(resourceName: "video-camera")
            }
        }else{
            click = true
            recordButton.image = #imageLiteral(resourceName: "video-camera")
            recorder.stopRecording{controller, err in
                guard let previewController = controller, err == nil else {
                print("Failed to stop recording")
                return
                }
                
                previewController.previewControllerDelegate = self
                if let popvc = previewController.popoverPresentationController{
                    popvc.sourceView = self.view
                }
                self.present(previewController, animated: true, completion: nil)

            }
        
        }
    }

    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        print("Finished the preview")
        
        dismiss(animated: true, completion: nil)
    }
    
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        print(activityTypes.description)
    }
    

    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        print("Screen recording availability changed")
    }
    
    
    
    func screenRecorder(_ screenRecorder: RPScreenRecorder,
                        didStopRecordingWithError error: Error,
                        previewViewController: RPPreviewViewController?) {
        print("Screen recording finished")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL]{
            print("url", videoUrl)
            dismiss(animated: true, completion: { 
                let dialog = UIAlertController(title: "업로드 확인", message: "선택한 동영상과 내용을 업로드 하시겠습니까?", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action : UIAlertAction) -> Void in
                    
                }
                
                let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                    self.indicator?.start()
                    let timestamp = Int(NSDate().timeIntervalSince1970)
                    let filename = self.content_Number!+String(timestamp)+".mov"
                    FIRStorage.storage().reference().child("Answer").child("Video").child(filename).putFile(videoUrl as! URL, metadata: nil, completion: { (metadata, error) in
                        if error != nil{
                            return
                        }
                        if let storageUrl = metadata?.downloadURL()?.absoluteString{
                        let ref = FIRDatabase.database().reference(fromURL: "https://teacher-d9168.firebaseio.com/").child("Question").child(self.content_Number!).child("answer").childByAutoId()
                            let value = ["text" : self.textView.text, "type" : "video", "content" : storageUrl, "writer" : self.writer, "time" : timestamp] as [String : Any]
                            ref.updateChildValues(value)
                            self.indicator?.stop()
                            self.dismiss(animated: true, completion: nil)

                        }
                    })
                }
                
                dialog.addAction(cancelAction)
                dialog.addAction(okAction)
                
                self.present(dialog, animated: true, completion: nil)
            })
        }
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{ //수정되지 않은 이미지 선택
                //imageView.image = image
            imageFlag = true
            if image.size.width > image.size.height{
                let newimage = imageWithImage(sourceImage: image, scaledToWidth: self.ImagecontainView.frame.width )
                let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: ImagecontainView.frame.width, height: newimage.size.height))
                imageview.image = newimage
                ImagecontainView.addSubview(imageview)
                dismiss(animated: true, completion: nil)
            }else{
                let newimage = imageWithImage(sourceImage: image, scaledToWidth: self.ImagecontainView.frame.width / 2)
                let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: ImagecontainView.frame.width / 2, height: newimage.size.height))
                imageview.image = newimage
                ImagecontainView.addSubview(imageview)
                dismiss(animated: true, completion: nil)
            }
            
        }

    }
    func keyboardWillShow(_ noti : Notification){
        
        if let rectObj = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue, textView.isFirstResponder
        {
            // 키보드 높이 가져옴
            let keyboardRect = rectObj.cgRectValue
            // 키보드 높이 만큼 화면 밀기
            self.view.frame.origin.y = 0 - keyboardRect.height
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    func subscribeToKeyboardNotifications() {
        //키보드 나타남
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //키보드 들어감
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func keyboardWillHide(_ noti : Notification){
        self.view.frame.origin.y = 0
    }
    func makeCloseButton(){
        let buttonView: UIView = UIView()
        let viewWidth: CGFloat = self.view.bounds.size.width
        let viewHeight: CGFloat = 44
        let viewRect: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        buttonView.frame = viewRect
        buttonView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        let closeButton: UIButton = UIButton(type: UIButtonType.system)
        let buttonWidth: CGFloat = 60
        let buttonHeight: CGFloat = 30
        let buttonRect: CGRect = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        closeButton.bounds = buttonRect
        let buttonMargin: CGFloat = 10
        let buttonCenterX = self.view.bounds.size.width - buttonMargin - buttonWidth / 2
        let buttonCenterY = buttonView.bounds.size.height / 2
        let buttonCenter = CGPoint(x: buttonCenterX, y: buttonCenterY)
        closeButton.center = buttonCenter
        closeButton.setTitle("Close", for: UIControlState())
        
        closeButton.addTarget(self, action: #selector(Tc07RecordViewController.closeKeyboard), for: UIControlEvents.touchUpInside)
        
        buttonView.addSubview(closeButton)
        
        self.textView.inputAccessoryView = buttonView
    }
    func closeKeyboard(){
        self.textView.resignFirstResponder()
    }
    @IBAction func imagePicAction(_ sender: Any) {
        let dialog = UIAlertController(title: "이미지 선택", message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        //let imgDownAction = UIAlertAction(title: "질문 사진", style: .default) { (action) in
        //서버에서 사진 가져오기
        
        //}
        //dialog.addAction(cameraAction)
        
        
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
    
    func setColor(color: UIColor) {
        drawview.setColor(color)
        self.dismiss(animated: true, completion: nil)
    }
    func setPenWidth(width: Float) {
        penWidth = CGFloat(width)
        drawview.setWidth(penWidth)
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //videoUpload.isEnabled = false
        drawview.delegate = self
        recorder.delegate = self

        drawview.setWidth(2.0)
        drawview.backgroundColor = UIColor(white: 1, alpha: 0.0)
        indicator = IndicatorHelper(view: self.view)
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width , height: 1)
        topBorder.backgroundColor = UIColor.gray.cgColor
        borderView.layer.addSublayer(topBorder)
        
        makeCloseButton()
        undoButton.isEnabled = false
        clearButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //화면 상단 바 숨김
    override var prefersStatusBarHidden: Bool{
        return true
    }
    func undoEnabled() {
        undoButton.isEnabled = true
    }
    
    func undoDisabled() {
        undoButton.isEnabled = false
    }
    
    func redoEnabled() {
    }
    
    func redoDisabled() {
    }
    
    func clearEnabled() {
        drawFlag = true
        clearButton.isEnabled = true
    }
    
    func clearDisabled() {
        drawFlag = false
        clearButton.isEnabled = false
    }
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }


}

