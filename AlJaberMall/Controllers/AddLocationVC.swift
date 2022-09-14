//
//  AddLocationVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 25/02/2021.
//

import UIKit
import Alamofire
import JGProgressHUD
import CoreLocation
import MOLH

protocol ContinueDelegate {
    func continueComplition(location: LocationsModel)
}

extension ContinueDelegate {
    func continueComplition(location: LocationsModel) {}
}

class AddLocationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, confirmDelegate {

    @IBOutlet weak var locationTable: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var cityTxt: UITextField!
    @IBOutlet weak var areaTxt: UITextField!
    @IBOutlet weak var buildingNoTxt: UITextField!
    @IBOutlet weak var aptNoTxt: UITextField!
    @IBOutlet weak var streetTxt: UITextField!
    
    @IBOutlet weak var noDataLbl: UILabel!
    
    var ContinueDelegate: ContinueDelegate?
    var locaionsArray = [LocationsModel]()
    var locationSelected = LocationsModel()
    var lat = ""
    var long = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataLbl.isHidden = true
        self.locationTable.delegate = self
        self.locationTable.dataSource = self
        self.locationTable.register(UINib(nibName: "LocationsCell", bundle: nil), forCellReuseIdentifier: "LocationsCell")
        self.locationTable.separatorStyle = .none
        
        self.saveBtn.layer.cornerRadius = 25
        self.continueBtn.layer.cornerRadius = 25
        
        self.getLocations()
        
        self.navigationText(title: "Add Location".localized())
        
        self.cityTxt.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locaionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.locationTable.cellForRow(at: indexPath) as? LocationsCell
        cell?.contentView.backgroundColor = .clear
        cell?.nameLbl.textColor = .black
        cell?.radioImg.tintColor = .black
        cell?.deleteImg.tintColor = .black
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.locationTable.cellForRow(at: indexPath) as? LocationsCell
        cell?.contentView.backgroundColor = UIColor(red: 228/255, green: 156/255, blue: 46/255, alpha: 1)
        cell?.nameLbl.textColor = .white
        cell?.radioImg.tintColor = .white
        cell?.deleteImg.tintColor = .white
        
        if self.locationSelected.profile_id == self.locaionsArray[indexPath.row].profile_id {
            self.locationTable.deselectRow(at: indexPath, animated: true)
            self.clearAction()
            self.saveBtn.setTitle("Save", for: .normal)
            let cell = self.locationTable.cellForRow(at: indexPath) as? LocationsCell
            cell?.contentView.backgroundColor = .clear
            cell?.nameLbl.textColor = .black
            cell?.radioImg.tintColor = .black
            cell?.deleteImg.tintColor = .black
            
        } else {
            self.cityTxt.text = self.locaionsArray[indexPath.row].city
            self.areaTxt.text = self.locaionsArray[indexPath.row].area
            self.buildingNoTxt.text = self.locaionsArray[indexPath.row].buildNum
            self.aptNoTxt.text = self.locaionsArray[indexPath.row].buildNum
            self.streetTxt.text = self.locaionsArray[indexPath.row].streetnum
            self.locationSelected = self.locaionsArray[indexPath.row]
            self.saveBtn.setTitle("Update", for: .normal)
        }
    }
    
    func clearAction() {
        self.cityTxt.text = ""
        self.areaTxt.text = ""
        self.buildingNoTxt.text = ""
        self.aptNoTxt.text = ""
        self.streetTxt.text = ""
        self.locationSelected = LocationsModel()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.locationTable.dequeueReusableCell(withIdentifier: "LocationsCell") as? LocationsCell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("LocationsCell", owner: self, options: nil)!
            cell = nib[0] as? LocationsCell
        }
        
        if self.locationSelected.profile_id == self.locaionsArray[indexPath.row].profile_id {
            cell?.contentView.backgroundColor = UIColor(red: 228/255, green: 156/255, blue: 46/255, alpha: 1)
            cell?.nameLbl.textColor = .white
            cell?.radioImg.tintColor = .white
            cell?.deleteImg.tintColor = .white
            
        } else {
            cell?.contentView.backgroundColor = .clear
            cell?.nameLbl.textColor = .black
            cell?.radioImg.tintColor = .black
            cell?.deleteImg.tintColor = .black
        }
        
        cell?.nameLbl.text = self.locaionsArray[indexPath.row].streetnum
        cell?.closeBtn.tag = indexPath.row
        cell?.closeBtn.addTarget(self, action: #selector(self.deleteAction(sender:)), for: .touchUpInside)
        
        return cell!
    }
    
    @objc func deleteAction(sender: UIButton) {
        self.removeLocation(index: sender.tag)
    }
    
    func getLocations() {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String
        
        let getLocationsUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.GETLOCATIONS_URL)
        let getLocationsParam: [String: String] = [
            "uid": id,
            "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
        ]
        
        AF.request(getLocationsUrl!, method: .post, parameters: getLocationsParam).response { (response) in
            if response.error == nil {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    
                    if jsonObj != nil {
                        if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let data = jsonObj!["data"] as? [[String: Any]] {
                                        for item in data {
                                            let model = LocationsModel(data: item)
                                            self.locaionsArray.append(model)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.noDataLbl.isHidden = true
                                            hud.dismiss()
                                            self.locationTable.reloadData()
                                            
                                            if self.locaionsArray.count == 0 {
                                                self.noDataLbl.isHidden = false
                                            }
                                        }
                                    }
                                    
                                } else {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.noDataLbl.isHidden = false
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
    
    func removeLocation(index: Int) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String
        
        let removeUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.REMOVELOCATIONS_URL)
        
        let removeParam: [String: String] = [
            "uid": id,
            "profile_id": self.locaionsArray[index].profile_id!,
            "flag": "1",
            "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
        ]
        
        AF.request(removeUrl!, method: .post, parameters: removeParam).response { (response) in
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
                                            
                                            self.locaionsArray.remove(at: index)
                                            let indexPath = IndexPath(row: index, section: 0)
                                            self.locationTable.deleteRows(at: [indexPath], with: .fade)
                                            self.locationTable.reloadData()
                                            self.clearAction()
                                            
                                            let count = self.locaionsArray.count
                                            self.noDataLbl.isHidden = (count == 0) ? false: true
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
    
    func saveProccess() {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String
        
        let addLocationsUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.ADDLOCATIONS_URL)
        let addLocationsParam: [String: String] = [
            "uid": id,
            "area": self.areaTxt.text!,
            "city": self.cityTxt.text!,
            "buildNum": self.buildingNoTxt.text!,
            "streetNum": self.streetTxt.text!,
            "depNum": self.aptNoTxt.text!,
            "lat": self.lat,
            "lang": self.long
        ]
        
        AF.request(addLocationsUrl!, method: .post, parameters: addLocationsParam).response { (response) in
            if response.error == nil {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    
                    if jsonObj != nil {
                        if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                                            hud.textLabel.text = message
                                            hud.dismiss(afterDelay: 1.5, animated: true, completion: {
                                                self.clearAction()
                                                self.locaionsArray.removeAll()
                                                self.getLocations()
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
    
    func updateProccess(index: Int) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String
        
        let updateLocationsUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.UPDATELOCATIONS_URL)
        let updateLocationsParam: [String: String] = [
            "uid": id,
            "profile_id": self.locaionsArray[index].profile_id!,
            "area": self.areaTxt.text!,
            "city": self.cityTxt.text!,
            "buildNum": self.buildingNoTxt.text!,
            "streetNum": self.streetTxt.text!,
            "depNum": self.aptNoTxt.text!,
            "lat": self.lat,
            "lang": self.long
        ]
        
        AF.request(updateLocationsUrl!, method: .post, parameters: updateLocationsParam).response { (response) in
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
    
    @IBAction func saveAction(sender: UIButton) {
        let title = self.saveBtn.title(for: .normal)
        
        if title == "Save".localized() {
            self.saveProccess()
            
        } else {
            self.updateProccess(index: sender.tag)
        }
    }
    
    @IBAction func getCurrentAction(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CurrentLocationVC") as! CurrentLocationVC
        vc.confirmDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func continueAction(sender: UIButton) {
        if self.locationSelected.area != nil {
            self.ContinueDelegate?.continueComplition(location: self.locationSelected)
            self.navigationController?.popViewController(animated: true)
            
        } else {
            let hud = JGProgressHUD(style: .light)
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.textLabel.text = "Please select location first".localized()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.5)
        }
    }
    
    func confirmComplition(placeMark: CLPlacemark, location: CLLocationCoordinate2D) {
        self.cityTxt.text = placeMark.locality
        self.areaTxt.text = placeMark.subLocality
        self.streetTxt.text = placeMark.thoroughfare
        self.lat = String(location.latitude)
        self.long = String(location.longitude)
    }

}
