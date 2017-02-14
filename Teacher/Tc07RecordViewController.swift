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

class Tc07RecordViewController: UIViewController, TouchDrawViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, CustomPalettViewDelegate, RPScreenRecorderDelegate,
RPPreviewViewControllerDelegate {
    
    var content_Number : String?
    var penWidth : CGFloat = 2.0
    var palett : CustomPalettView?
    var dialog : UIAlertController!
    var textview : UITextView!
    var answer_tex : String = ""
    var click = true
    var imageFlag = false
    var drawFlag = false
    let recorder = RPScreenRecorder.shared()

    @IBOutlet weak var ImagecontainView: UIView!
    @IBOutlet weak var drawview: TouchDrawView!
    @IBOutlet weak var mergeView: UIView!
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var videoUpload: UIBarButtonItem!
    @IBAction func imageUploadAction(_ sender: Any) {
        if answer_tex == "" {
            let dialog = UIAlertController(title: "업로드 확인", message: "제목이 없습니다.\n제목을 입력해주세요", preferredStyle: .alert)
            
            
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                self.textAction("aa")
            }
            
            dialog.addAction(okAction)
            
            self.present(dialog, animated: true, completion: nil)
            return
        }
        if !drawFlag, !imageFlag {
            let dialog = UIAlertController(title: "업로드 확인", message: "텍스트만 답변하시겠습니까?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
                
            })
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                let timestamp = Int(NSDate().timeIntervalSince1970)
                let ref = FIRDatabase.database().reference(fromURL: "https://teacher-d9168.firebaseio.com/").child("Question").child(self.content_Number!).child("answer").childByAutoId()
                let value = ["text" : self.answer_tex, "type" : "text", "content" : "null", "writer" : FIRAuth.auth()?.currentUser?.uid, "time" : timestamp] as [String : Any]
                ref.updateChildValues(value)
                self.dismiss(animated: true, completion: nil)
            }
            dialog.addAction(cancelAction)
            dialog.addAction(okAction)
            
            self.present(dialog, animated: true, completion: nil)
        }else{
            
            let dialog = UIAlertController(title: "업로드 확인", message: "현재 화면으로 답변하시겠습니까?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
                
            })
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                UIGraphicsBeginImageContext(self.mergeView.frame.size) // 이미지 context 생성
                self.mergeView.drawHierarchy(in: self.mergeView.frame, afterScreenUpdates: true) //Snapshot 촬영후 현재 context에 저장
                let mergeImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()! //현재 image context -> UIImage로 저장
                UIGraphicsEndImageContext()
                let timestamp = Int(NSDate().timeIntervalSince1970)
                let filename = (FIRAuth.auth()?.currentUser?.uid)! + String(timestamp) + ".png"
                
                let storage = FIRStorage.storage().reference().child("Answer").child("Photo").child(filename)
                if let uploadImage = UIImagePNGRepresentation(mergeImage){
                    storage.put(uploadImage, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error)
                            return
                        }else{
                            if let downUrl = metadata?.downloadURL()?.absoluteString{
                                let ref = FIRDatabase.database().reference(fromURL: "https://teacher-d9168.firebaseio.com/").child("Question").child(self.content_Number!).child("answer").childByAutoId()
                                let value = ["text" : self.answer_tex, "type" : "photo", "content" : downUrl, "writer" : FIRAuth.auth()?.currentUser?.uid, "time" : timestamp] as [String : Any]
                                ref.updateChildValues(value)
                                self.dismiss(animated: true, completion: nil)
                            }
                            
                        }
                    })
                }
            }
            dialog.addAction(cancelAction)
            dialog.addAction(okAction)
            
            self.present(dialog, animated: true, completion: nil)
        }
    }
    @IBAction func vedioUploadAction(_ sender: Any) {
        if answer_tex == "" {
            let dialog = UIAlertController(title: "업로드 확인", message: "제목이 없습니다.\n제목을 입력해주세요", preferredStyle: .alert)
            
            
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                self.textAction("aa")
            }
            
            dialog.addAction(okAction)
            
            self.present(dialog, animated: true, completion: nil)
            return
        }
        let imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        imagepicker.mediaTypes = [kUTTypeMovie as String]
        present(imagepicker, animated: true, completion: nil)
    }
    @IBAction func cancelAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func recordAction(_ sender: Any) {
        if click {
            click = false
            recordButton.title = "중지"
            if recorder.isAvailable {
                recorder.startRecording(withMicrophoneEnabled: true){err in
                    print (err.debugDescription)
                }
            }else{
                click = true
                recordButton.title = "녹화"
            }
        }else{
            click = true
            recordButton.title = "녹화"
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
    
//    func previewController(previewController: RPPreviewViewController,
//                           didFinishWithActivityTypes activityTypes: Set<String>) {
//        print("Preview finished activities \(activityTypes)")
//        if activityTypes.contains("com.apple.UIKit.activity.SaveToCameraRoll") {
//            // video has saved to camera roll
//            print("a1a1a")
//            videoUpload.isEnabled = true
//        } else {
//            // cancel
//            print("b2b2b")
//            videoUpload.isEnabled = false
//        }
//    }
    func screenRecorderDidChangeAvailability(screenRecorder: RPScreenRecorder) {
        print("Screen recording availability changed")
    }
    
    
    
    func screenRecorder(screenRecorder: RPScreenRecorder,
                        didStopRecordingWithError error: NSError,
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
                    let timestamp = Int(NSDate().timeIntervalSince1970)
                    let filename = self.content_Number!+String(timestamp)+".mov"
                    FIRStorage.storage().reference().child("Answer").child("Video").child(filename).putFile(videoUrl as! URL, metadata: nil, completion: { (metadata, error) in
                        if error != nil{
                            return
                        }
                        if let storageUrl = metadata?.downloadURL()?.absoluteString{
                        let ref = FIRDatabase.database().reference(fromURL: "https://teacher-d9168.firebaseio.com/").child("Question").child(self.content_Number!).child("answer").childByAutoId()
                            let value = ["text" : self.answer_tex, "type" : "video", "content" : storageUrl, "writer" : FIRAuth.auth()?.currentUser?.uid, "time" : timestamp] as [String : Any]
                            ref.updateChildValues(value)
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
    @IBAction func imagePicAction(_ sender: Any) {
        let dialog = UIAlertController(title: "이미지 선택", message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let imgDownAction = UIAlertAction(title: "질문 사진", style: .default) { (action) in
        //서버에서 사진 가져오기
        
        }
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
    
    @IBAction func textAction(_ sender: Any) {
        dialog = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let margin:CGFloat = 8.0
        let rect = CGRect(x: margin, y: margin, width: dialog.view.bounds.size.width - margin * 4.0, height: 100.0)
        textview = UITextView(frame: rect)
        
        textview.backgroundColor = UIColor.clear
        textview.font = UIFont(name: "Helvetica", size: 15)
        
        //  customView.backgroundColor = UIColor.greenColor()
        textview.text = answer_tex
        dialog.view.addSubview(textview)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.answer_tex = self.textview.text!
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
    func setUndo(){
        drawview.undo()
    }
    func setClear(){
        drawview.clearDrawing()
        self.dismiss(animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //키보드 return값 설정
        return true
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //videoUpload.isEnabled = false
        drawview.delegate = self
        recorder.delegate = self

        drawview.setWidth(2.0)
        drawview.backgroundColor = UIColor(white: 1, alpha: 0.0)
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
        drawFlag = true
    }
    
    func clearDisabled() {
        drawFlag = false
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
