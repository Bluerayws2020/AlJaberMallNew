//
//  ProfileVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 08/03/2021.
//

import UIKit
import Alamofire
import JGProgressHUD
import Photos
import SDWebImage
import MOLH

class ProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var oldPassTxt: UITextField!
    @IBOutlet weak var newPassTxt: UITextField!
    @IBOutlet weak var confirmPassTxt: UITextField!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var phoneNoView: UIView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var oldPassTxtHeight: NSLayoutConstraint!
    @IBOutlet weak var newPassTxtHeight: NSLayoutConstraint!
    @IBOutlet weak var confirmPassTxtHeight: NSLayoutConstraint!
    @IBOutlet weak var oldPassTxtTop: NSLayoutConstraint!
    @IBOutlet weak var newPassTxtTop: NSLayoutConstraint!
    @IBOutlet weak var confirmPassTxtTop: NSLayoutConstraint!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let genderPicker = UIPickerView()
    var pickerData: [String] = [String]()
    private var datePicker: UIDatePicker?
    var imagePicker = UIImagePickerController()
    var img: UIImage?
    var genderType = ""
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createAccountBtn.layer.cornerRadius = 7
        
        self.cameraView.layer.cornerRadius = 22.5
        self.cameraView.layer.borderWidth = 1
        self.cameraView.layer.borderColor = UIColor.black.cgColor
        
        self.phoneNoView.layer.borderColor = UIColor.lightGray.cgColor
        self.phoneNoView.layer.cornerRadius = 5
        self.phoneNoView.layer.borderWidth = 1
        
        self.userView.layer.cornerRadius = 50
        self.userView.clipsToBounds = true
        self.userView.layer.borderWidth = 1
        self.userView.layer.borderColor = UIColor.black.cgColor
        
        self.imagePicker.delegate = self
        
        let defaults = UserDefaults.standard
        let social = defaults.value(forKey: "social") as! String

        if social == "1" {
            self.oldPassTxt.isHidden = true
            self.newPassTxt.isHidden = true
            self.confirmPassTxt.isHidden = true
            
            self.oldPassTxtHeight.constant = 0
            self.newPassTxtHeight.constant = 0
            self.confirmPassTxtHeight.constant = 0
            
            self.oldPassTxtTop.constant = 0
            self.newPassTxtTop.constant = 0
            self.confirmPassTxtTop.constant = 0
        }
        
        self.getProfile()
        
        self.navigationText(title: "Profile".localized())
        
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        self.getProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    func getProfile() {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String
        
        let getProfileUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.GETPROFILE_URL)
        let getProfileParam: [String: String] = [
            "uid": id,
            "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
        ]
        
        AF.request(getProfileUrl!, method: .post, parameters: getProfileParam).response { (response) in
            if response.error == nil {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    
                    if jsonObj != nil {
                        if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.showSuccessHud(msg: message, hud: hud)
                                            self.refreshControl?.endRefreshing()
                                        }
                                    }
                                    
                                    if let data = jsonObj!["data"] as? [String: Any] {
                                        if let user_name = data["user_name"] as? String {
                                            DispatchQueue.main.async {
                                                self.fullNameTxt.text = user_name
                                            }
                                        }
                                        if let phone = data["phone"] as? String {
                                            DispatchQueue.main.async {
                                                self.phoneTxt.text = phone
                                            }
                                        }
                                        if let email = data["email"] as? String {
                                            DispatchQueue.main.async {
                                                self.emailTxt.text = email
                                            }
                                        }
                                        if let user_picture = data["user_picture"] as? String {
                                            if user_picture != "" {
                                                DispatchQueue.main.async {
                                                    let url = URL(string: ServerConstants.BASE_URL2 + user_picture)
                                                    self.userImg.sd_setImage(with: url, completed: { (image, error, cachType, url) in
                                                            if error == nil {
                                                                self.userImg.image = image!
                                                            }
                                                        })
                                                }
                                            }
                                        }
                                    }
                                    
                                } else {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.showErrorHud(msg: message, hud: hud)
                                            self.refreshControl?.endRefreshing()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } catch let err as NSError {
                    print("Error: \(err)")
                    self.serverError(hud: hud)
                    self.refreshControl?.endRefreshing()
                }
            } else {
                print("Error")
                self.internetError(hud: hud)
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @IBAction func updateAction(sender: UIButton) {
        if self.oldPassTxt.text != "" {
            if self.newPassTxt.text != "" || self.confirmPassTxt.text != "" {
                if self.newPassTxt.text == self.confirmPassTxt.text {
                    self.upadteProcess()
                    
                } else {
                    if self.newPassTxt.text == "" {
                        self.showErrorHud(msg: "Please enter the new password".localized())
                    } else {
                        self.showErrorHud(msg: "Please enter confirm password correctly".localized())
                    }
                }
            } else {
                self.upadteProcess()
            }
            
        } else {
            self.showErrorHud(msg: "Please enter the old password".localized())
        }
    }
    
    func upadteProcess() {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String

        let updateUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.UPDATE_URL)
        let updateParam: [String: String] = [
            "uid": id,
            "mail": self.emailTxt.text!,
            "current_pass": self.oldPassTxt.text!,
            "pass": self.newPassTxt.text!,
            "phone": self.phoneTxt.text!,
            "name": self.fullNameTxt.text!,
            "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
        ]

        let URL = try! URLRequest(url: updateUrl!, method: .post)
        
        AF.upload(multipartFormData: { multi in
            if self.img != nil {
                let imgData = self.img!.jpegData(compressionQuality: 0.2)!
                multi.append(imgData, withName: "image", fileName: "profile.jpg")
            }
                            for (key, value) in updateParam {
                                multi.append(value.data(using: String.Encoding.utf8)!, withName: key)
                                
                            }
                        }, with: URL).responseJSON { (response) in
                            if response.error == nil {
                                do {
                                    
                                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                                    
                                    if jsonObj != nil {
                                        if let msg = jsonObj!["msg"] as? [String: Any] {
                                            if let status = msg["status"] as? Int {
                                                if status == 1 {
                                                    if let message = msg["message"] as? String {
                                                        DispatchQueue.main.async {
                                                            self.showSuccessHud(msg: message, hud: hud)
                                                        }
                                                    }
                                                    
                                                } else {
                                                    if let message = msg["message"] as? String {
                                                        DispatchQueue.main.async {
                                                            self.showErrorHud(msg: message, hud: hud)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                } catch let err as NSError {
                                    print("Error: \(err)")
                                    self.serverError(hud: hud)
                                }
                            } else {
                                print("Error")
                                self.internetError(hud: hud)
                            }
                        }
    }
    
    
    //////////////////camera//////////////////
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.editedImage] as? UIImage {
            self.userImg.image = image
            self.img = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.userImg.image = image
            self.img = image
        }

    }
    
    
    
    func openCamera()
    {
        self.checkCamera()
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "تنبيه", message: "الرجاء الذهاب الى الاعدادات للسماح بالوصول الى الكاميرا", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "نعم", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .denied:
            let alert  = UIAlertController(title: "تنبيه", message: "الرجاء الذهاب الى الاعدادات للسماح بالوصول الى الكاميرا", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "نعم", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        default:
            print("some")
        }
    }

    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addImageAction(sender: UIButton) {
        let alert = UIAlertController(title: "إختر صورة", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "الكاميرا", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "معرض الصور", style: .default, handler: { _ in
            self.openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "إلغاء", style: .cancel, handler: nil))

        /*If you want work actionsheet on ipad
        then you have to use popoverPresentationController to present the actionsheet,
        otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }

        self.present(alert, animated: true, completion: nil)
        
    }
    
}
