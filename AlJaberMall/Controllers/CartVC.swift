//
//  CartVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 24/02/2021.
//

import UIKit
import Foundation
import Alamofire
import JGProgressHUD
import MOLH

protocol CheckoutDelegate {
    func checkoutSuccess(msg: String)
}

extension CheckoutDelegate {
    func checkoutSuccess(msg: String) {}
}

@available(iOS 13.0, *)
class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ContinueDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var cartTable: UITableView!
    @IBOutlet weak var noCartLbl: UILabel!
    @IBOutlet weak var checkoutBtn: UIButton!
    @IBOutlet weak var viewForPicker: UIView!
    @IBOutlet weak var viewForPickerHeight: NSLayoutConstraint!
    
    var refreshControl: UIRefreshControl!
    
    var cartArray = [CartItemsModel]()
    
    var CheckoutDelegate: CheckoutDelegate?
    
    let toolBar = UIToolbar()
    let promoBar = UIToolbar()
    
    var total: Double?
    var subTotal: Double?
    var deliveryFees: String?
    
    var locationId = ""
    var senderTag = 0
    
    var deliveryFlag = "2"
    
    let paymentMethodPicker = UIPickerView()
    var recieptPickerData: [String] = [String]()
    var paymentPickerData: [String] = [String]()
    
    var recieptMethodType = ""
    var paymentMethodType = ""
    
    var order_id: String?
    
    var cartFrom: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cartTable.delegate = self
        self.cartTable.dataSource = self
        
        self.viewForPicker.isHidden = true
        
        //paymentPickerData = ["Select".localized(),"Cash".localized(), "Online".localized()]
        paymentPickerData = ["Select".localized(),"Cash".localized()]
        recieptPickerData = ["Select".localized(),"Delivery".localized(), "Pickup".localized()]
        
        self.cartTable.separatorStyle = .none
        
        self.cartTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.cartTable.backgroundColor = .white
        
        //self.checkoutBtn.applyGradient(colours: [.red, .white])
        
        self.cartTable.register(UINib(nibName: "CategorySelectCartTableCell", bundle: nil), forCellReuseIdentifier: "CategorySelectCartTableCell")
        self.cartTable.register(UINib(nibName: "DeliverToCartCell", bundle: nil), forCellReuseIdentifier: "DeliverToCartCell")
        self.cartTable.register(UINib(nibName: "PayWithCartCell", bundle: nil), forCellReuseIdentifier: "PayWithCartCell")
        self.cartTable.register(UINib(nibName: "CheckoutCartCell", bundle: nil), forCellReuseIdentifier: "CheckoutCartCell")
        
        self.navigationText(title: "Review Cart".localized())
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as? String
        
        if id != nil {
            self.getCart()
            
        } else {
            let hud = JGProgressHUD(style: .light)
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.textLabel.text = "Please login first".localized()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.5, animated: true, completion: {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.notLogin()
            })
        }
        
        self.cartTable.alwaysBounceVertical = true
        self.cartTable.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.cartTable.addSubview(refreshControl)
        
        self.createMethodPicker()
        self.createToolbar()
        self.createPromoBar()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handle(keyboardShowNotification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handle(keyboardHideNotification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc
    private func handle(keyboardShowNotification notification: Notification) {
        // 1
        print("Keyboard show notification")
        
        // 2
        if let userInfo = notification.userInfo,
            // 3
            let keyboardRectangle = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            print(keyboardRectangle.height)
            self.adjustLayoutForKeyboard(targetHeight: keyboardRectangle.height)
        }
    }
    
    @objc
    private func handle(keyboardHideNotification notification: Notification) {
        // 1
        print("Keyboard hide notification")
        
        // 2
        if let userInfo = notification.userInfo,
            // 3
            let keyboardRectangle = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            print(keyboardRectangle.height)
            self.adjustLayoutForKeyboard(targetHeight: 0)
        }
    }
    
    func adjustLayoutForKeyboard(targetHeight: CGFloat) {
        self.cartTable.contentInset.bottom = targetHeight
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.senderTag = textField.tag
        
        if textField.tag != 2 {
            self.viewForPicker.isHidden = false
            self.viewForPickerHeight.constant = self.view.frame.height - self.paymentMethodPicker.frame.height
            self.paymentMethodPicker.reloadComponent(0)
            self.paymentMethodPicker.selectRow(0, inComponent: 0, animated: false)
            
        } else {
            
           // adjustLayoutForKeyboard(targetHeight: self.cartTable.frame.size.height)
        }
        
    }
    
    
    
    func createMethodPicker() {
        
        self.paymentMethodPicker.delegate = self
        
        //Customizations
        self.paymentMethodPicker.backgroundColor = .white
    }
    
    func createToolbar() {
        toolBar.sizeToFit()
        
        //Customizations
        toolBar.barTintColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1)
        toolBar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(self.dismissKeyboardd))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
    }
    
    func createPromoBar() {
        promoBar.sizeToFit()
        
        //Customizations
        promoBar.barTintColor = UIColor(red: 184/255, green: 22/255, blue: 43/255, alpha: 1)
        promoBar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(self.promoDone))
        
        promoBar.setItems([doneButton], animated: false)
        promoBar.isUserInteractionEnabled = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.senderTag == 0 {
            return paymentPickerData.count
        } else {
            return recieptPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.senderTag == 0 {
            return paymentPickerData[row]
        } else {
            return recieptPickerData[row]
        }
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPath = IndexPath(row: self.cartArray.count, section: 0)
        let cell = self.cartTable.cellForRow(at: indexPath) as! PayWithCartCell
        if self.senderTag == 0 {
            cell.paymentMethodLbl.text = self.paymentPickerData[row]
            if row == 1 || row == 2 {
                self.paymentMethodType = String(row)
            } else {
                self.paymentMethodType = ""
            }
        } else {
            cell.recieptMethodLbl.text = self.recieptPickerData[row]
            if row == 1 || row == 2 {
                self.recieptMethodType = String(row)
                self.deliveryFlag = String(row)
            } else {
                self.recieptMethodType = ""
                self.deliveryFlag = "2"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Regular", size: 20)
        
        if senderTag == 0 {
            label.text = self.paymentPickerData[row]
            
        } else {
            label.text = self.recieptPickerData[row]
        }
        
        return label
    }
    
    @objc func dismissKeyboardd() {
        view.endEditing(true)
        self.viewForPicker.isHidden = true
        self.cartTable.reloadData()
        
        if self.senderTag != 0 {
            self.cartArray.removeAll()
            self.cartTable.reloadData()
            self.getCart()
        }
    }
    
    @objc func didPullToRefresh() {
        self.cartArray.removeAll()
        self.cartTable.reloadData()
        self.getCart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorWhite()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cartArray.count + 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == self.cartArray.count + 1 {
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyBoard.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
            vc.ContinueDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func locationAction() {
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as? Int
        
        if id != nil {
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyBoard.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
            vc.ContinueDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showMustLoginHud()
        }
    }
    
    @objc func promoDone() {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.cartArray.count {
            var cell = self.cartTable.dequeueReusableCell(withIdentifier: "PayWithCartCell") as? PayWithCartCell
            
            if cell == nil {
                let nib: [Any] = Bundle.main.loadNibNamed("PayWithCartCell", owner: self, options: nil)!
                cell = nib[0] as? PayWithCartCell
            }
            
            if self.total != nil {
                cell?.totalLbl.text = String(self.total!)
            }
            
            if self.subTotal != nil {
                cell?.subTotalLbl.text = String(self.subTotal!)
            }
            
            if self.deliveryFees != nil {
                cell?.deliveryLbl.text = self.deliveryFees
            }
            
            cell?.recieptMethodTxt.delegate = self
            cell?.paymentMethodTxt.delegate = self
            
            cell?.paymentMethodTxt.inputView = self.paymentMethodPicker
            cell?.recieptMethodTxt.inputView = self.paymentMethodPicker
            cell?.recieptMethodTxt.inputAccessoryView = toolBar
            cell?.paymentMethodTxt.inputAccessoryView = toolBar
            
            cell?.applyBtn.addTarget(self, action: #selector(self.checkPromoCode), for: .touchUpInside)
            
            cell?.promoTxt.delegate = self
            
            
            cell?.promoTxt.inputAccessoryView = promoBar
            
            return cell!
            
        } else if indexPath.row == self.cartArray.count + 1 {
            var cell = self.cartTable.dequeueReusableCell(withIdentifier: "DeliverToCartCell") as? DeliverToCartCell
            
            if cell == nil {
                let nib: [Any] = Bundle.main.loadNibNamed("DeliverToCartCell", owner: self, options: nil)!
                cell = nib[0] as? DeliverToCartCell
            }
            
            cell?.locationBtn.addTarget(self, action: #selector(self.locationAction), for: .touchUpInside)
            
            return cell!
            
        } else if indexPath.row == self.cartArray.count + 2 {
            var cell = self.cartTable.dequeueReusableCell(withIdentifier: "CheckoutCartCell") as? CheckoutCartCell
            
            if cell == nil {
                let nib: [Any] = Bundle.main.loadNibNamed("CheckoutCartCell", owner: self, options: nil)!
                cell = nib[0] as? CheckoutCartCell
            }
            
            cell?.checkoutBtn.addTarget(self, action: #selector(self.checkoutAction), for: .touchUpInside)
            
            return cell!
            
        } else {
            var cell = self.cartTable.dequeueReusableCell(withIdentifier: "CategorySelectCartTableCell") as? CategorySelectCartTableCell
            
            if cell == nil {
                let nib: [Any] = Bundle.main.loadNibNamed("CategorySelectCartTableCell", owner: self, options: nil)!
                cell = nib[0] as? CategorySelectCartTableCell
            }
            
            //cell?.favouriteImg.isHidden = true
            cell?.addToCartView.isHidden = false
            
            cell?.nameLbl.text = self.cartArray[indexPath.row].title
            
            cell?.plusBtn.tag = indexPath.row
            cell?.minusBtn.tag = indexPath.row
            
            cell?.plusBtn.addTarget(self, action: #selector(self.plusAction(sender:)), for: .touchUpInside)
            cell?.minusBtn.addTarget(self, action: #selector(self.minusAction(sender:)), for: .touchUpInside)
            
            if self.cartArray[indexPath.row].quantity != nil {
                cell?.quantityLbl.text = String(self.cartArray[indexPath.row].quantity!)
            }
            
            cell?.priceLbl.text = self.cartArray[indexPath.row].unit_price
            
            cell?.weightLbl.text = self.cartArray[indexPath.row].total_unit_price
            
            cell?.loadingView.startAnimating()
            if let imgUrl = self.cartArray[indexPath.row].image {
                let url = URL(string: ServerConstants.BASE_URL2 + imgUrl)
                cell?.img.sd_setImage(with: url, completed: { (image, error, cachType, url) in
                    if error == nil {
                        cell?.img.image = image!
                        cell?.loadingView.stopAnimating()
                    }
                })
               }
            
            return cell!
        }
    }
    
    @objc func checkPromoCode() {
//        let defaults = UserDefaults.standard
//        let id = defaults.value(forKey: "id") as? Int
//        
//        let indexPath = IndexPath(row: self.cartArray.count, section: 0)
//        let cell = self.cartTable.cellForRow(at: indexPath) as! PayWithCartCell
//        
//        if id == nil {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.notLogin()
//            
//        } else {
//            let hud = JGProgressHUD(style: .light)
//            hud.textLabel.text = "Please Wait".localized()
//            hud.show(in: self.view)
//            
//            let checkPromoUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.CART_EXT + ServerConstants.CHECKPROMOCODE)
//            let checkPromoParam: [String: String] = [
//                "api_password": ServerConstants.API_PASSWORD,
//                "user_id": String(id!),
//                "promo_code": cell.promoTxt.text!,
//                "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
//            ]
//            
//            AF.request(checkPromoUrl!, method: .post, parameters: checkPromoParam).response { (response) in
//                if response.error == nil {
//                    do {
//                        let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
//                        
//                        if jsonObj != nil {
//                            if let status = jsonObj!["status"] as? Bool {
//                                if status == true {
//                                    if let promo_data = jsonObj!["promo_data"] as? [String: Any] {
//                                        if let total_price = promo_data["total_price"] as? Double {
//                                            DispatchQueue.main.async {
//                                                cell.subTotalLbl.text = String(total_price)
//                                            }
//                                        }
//                                        if let total_price_tax = promo_data["total_price_tax"] as? Double {
//                                            DispatchQueue.main.async {
//                                                cell.totalLbl.text = String(total_price_tax)
//                                            }
//                                        }
//                                        if let promo_amount = promo_data["promo_amount"] as? Double {
//                                            DispatchQueue.main.async {
//                                                cell.discountLbl.text = String(promo_amount)
//                                            }
//                                        }
//                                    }
//                                    
//                                    DispatchQueue.main.async {
//                                        hud.dismiss()
//                                    }
//                                    
//                                } else {
//                                    if let msg = jsonObj!["msg"] as? String {
//                                        DispatchQueue.main.async {
//                                            self.showErrorHud(msg: msg, hud: hud)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        
//                    } catch let err as NSError {
//                        print("Error: \(err)")
//                        self.serverError(hud: hud)
//                    }
//                } else {
//                    print("Error")
//                    self.internetError(hud: hud)
//                }
//            }
//        }
    }
    
    @objc func plusAction(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = self.cartTable.cellForRow(at: indexPath) as! CategorySelectCartTableCell
        let quantity = String(Int(cell.quantityLbl.text!)! + 1)
        self.updateCart(itemIndex: indexPath.row, quantity: quantity, action: "plus")
    }
    
    @objc func minusAction(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = self.cartTable.cellForRow(at: indexPath) as! CategorySelectCartTableCell
        let quantity = String(Int(cell.quantityLbl.text!)! - 1)
        self.updateCart(itemIndex: indexPath.row, quantity: quantity, action: "minus")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row != self.cartArray.count && indexPath.row != self.cartArray.count + 1 && indexPath.row != self.cartArray.count + 2 {
            if editingStyle == .delete {
                self.updateCart(itemIndex: indexPath.row, quantity: "0", action: "minus")
                
            }
            
        }
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
       if indexPath.row != self.cartArray.count && indexPath.row != self.cartArray.count + 1 && indexPath.row != self.cartArray.count + 2 {
        return UITableViewCell.EditingStyle.delete
        
        } else {
            return UITableViewCell.EditingStyle.none
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == self.cartArray.count {
            return 515
            
        } else if indexPath.row == self.cartArray.count + 1 {
            if self.recieptMethodType == "1" {
                return 217
            } else {
                return 0
            }
        } else if indexPath.row == self.cartArray.count + 2 {
            return 80
            
        } else {
            return 123
        }
    }
    
    @objc func checkoutAction() {
        if self.order_id != nil {
            let defaults = UserDefaults.standard
            let id = defaults.value(forKey: "id") as! String
            
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = "Please Wait".localized()
            hud.show(in: self.view)
            
            let checkoutUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.CHECKOUT_URL)
            let checkoutParam: [String: String] = [
                "uid": id,
                "order_id": self.order_id!
            ]
            
            AF.request(checkoutUrl!, method: .post, parameters: checkoutParam).response { (response) in
                if response.error == nil {
                    do {
                        let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                        
                        if jsonObj != nil {
                            if let msg = jsonObj!["msg"] as? [String: Any] {
                                if let status = msg["status"] as? Int {
                                    if status == 1 {
                                        if let message = msg["message"] as? String {
                                            DispatchQueue.main.async {
                                                self.order_id = nil
                                                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                                                hud.textLabel.text = message
                                                hud.dismiss(afterDelay: 1.5, animated: true, completion: {
                                                    if self.cartFrom == "1" {
                                                        self.navigationController?.popViewController(animated: true)
                                                        
                                                    } else {
                                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                                        appDelegate.isLogin()
                                                    }
                                                })
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
    }
    
    func afterCheckout() {
        let indexPath = IndexPath(row: self.cartArray.count + 1, section: 0)
        let cell = self.cartTable.cellForRow(at: indexPath) as! DeliverToCartCell
        
        cell.locationLbl.text = "No location selected".localized()
        self.locationId = ""
        
        self.recieptMethodType = ""
        self.paymentMethodType = ""
        
        let indexPath2 = IndexPath(row: self.cartArray.count, section: 0)
        let paymentCell = self.cartTable.cellForRow(at: indexPath2) as! PayWithCartCell
        self.total = 0.0
        self.subTotal = 0.0
        paymentCell.totalLbl.text = "0.0"
        paymentCell.discountLbl.text = "0.0"
        paymentCell.deliveryLbl.text = "0.0"
        paymentCell.subTotalLbl.text = "0.0"
        paymentCell.recieptMethodLbl.text = "Select".localized()
        paymentCell.paymentMethodLbl.text = "Select".localized()
        self.cartArray.removeAll()
        self.cartTable.reloadData()
    }
    
    func updateCart(itemIndex: Int, quantity: String, action: String) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)

        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String

        let addToCartUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.UpdateCart_URL)
        let addToCartParam: [String: String] = [
            "order_item_id": self.cartArray[itemIndex].order_item_id!,
            "uid": id,
            "quantity": quantity,
            "order_id": self.cartArray[itemIndex].order_id!
        ]

        AF.request(addToCartUrl!, method: .post, parameters: addToCartParam).response { (response) in
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
                                            
                                            if quantity == "0" {
                                                let indexPath = IndexPath(row: itemIndex, section: 0)
                                                self.cartArray.remove(at: indexPath.row)
                                                self.cartTable.deleteRows(at: [indexPath], with: .fade)
                                                
                                            } else {
                                                let indexPath = IndexPath(row: itemIndex, section: 0)
                                                let cell = self.cartTable.cellForRow(at: indexPath) as? CategorySelectCartTableCell
                                                cell?.weightLbl.text = String(Float(quantity)! * Float(self.cartArray[itemIndex].unit_price!)!)
                                                
                                                self.cartArray[itemIndex].total_unit_price = String(Float(quantity)! * Float(self.cartArray[itemIndex].unit_price!)!)
                                                
                                                if action == "plus" {
                                                    cell?.quantityLbl.text = String(Int((cell?.quantityLbl.text!)!)! + 1)
                                                    
                                                    let indexPath2 = IndexPath(row: self.cartArray.count, section: 0)
                                                    let paymentCell = self.cartTable.cellForRow(at: indexPath2) as? PayWithCartCell
                                                    let total = self.total! + Double(self.cartArray[indexPath.row].unit_price!)!
                                                    self.total = self.total! + Double(self.cartArray[indexPath.row].unit_price!)!
                                                    paymentCell?.totalLbl.text = String(Float(total))
                                                    
                                                } else {
                                                    cell?.quantityLbl.text = String(Int((cell?.quantityLbl.text!)!)! - 1)
                                                    let indexPath2 = IndexPath(row: self.cartArray.count, section: 0)
                                                    let paymentCell = self.cartTable.cellForRow(at: indexPath2) as? PayWithCartCell
                                                    let total = self.total! - Double(self.cartArray[indexPath.row].unit_price!)!
                                                    self.total = self.total! - Double(self.cartArray[indexPath.row].unit_price!)!
                                                    paymentCell?.totalLbl.text = String(Float(total))
                                                    
                                                }
                                            }
                                            
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
    
    func getCart() {
        //self.noCartLbl.isHidden = true
        
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String
        
        let getCartUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.GETCART_URL)
        let getCartParam: [String: String] = [
            "uid": id
        ]
        
        
        AF.request(getCartUrl!, method: .post, parameters: getCartParam).response { (response) in
            if response.error == nil {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    
                    if jsonObj != nil {
                        if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.refreshControl?.endRefreshing()
                                            self.showSuccessHud(msg: message, hud: hud)
                                        }
                                    }
                                    
                                    if let data = jsonObj!["data"] as? [String: Any] {
                                        if let order_id = data["order_id"] as? String {
                                            self.order_id = order_id
                                        }
                                        
                                        if let items = data["items"] as? [[String: Any]] {
                                            for item in items {
                                                let model = CartItemsModel(data: item)
                                                self.cartArray.append(model)
                                            }
                                            
                                            if let total_order_price = data["total_order_price"] as? String {
                                                self.total = Double(total_order_price)
                                            }
                                            
                                            DispatchQueue.main.async {
                                                self.cartTable.reloadData()
                                            }
                                        }
                                    }
                                    
                                } else {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.refreshControl?.endRefreshing()
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
                    self.refreshControl?.endRefreshing()
                }
            } else {
                print("Error")
                self.internetError(hud: hud)
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func continueComplition(location: LocationsModel) {
//        let indexPath = IndexPath(row: self.cartArray.count + 1, section: 0)
//        let cell = self.cartTable.cellForRow(at: indexPath) as! DeliverToCartCell
//        let text = location.area! + location.building_number! + "\n" + location.apartment_number! + "\n" + location.city! + "\n" + location.street!
//        cell.locationLbl.text = text
//        self.locationId = String(location.id!)
    }
    
}
