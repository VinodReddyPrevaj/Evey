//
//  AdminstratorsViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 28/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class AdminstratorsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var searchTop: UILabel!

    
    
    
    
    @IBOutlet weak var administratorsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var administratorLbl: UILabel!
    
    @IBOutlet weak var searchBarBackgroundView: UIView!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var buttonsViewBorder: UILabel!
    
    
    @IBOutlet weak var searchBottom: UILabel!
    var isSearch = Bool()
    let cancelButton = UIButton()
    let noResults = UILabel()
    
    
    var administrators =  ["Michael Jackson","Edward Leven","Elliot Ness","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB","A CB"]
    var filtered = [String]()
    //for beacon Detection
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        self.administratorsTableView.tableFooterView = UIView()
        noResults.text = "No Results"
        noResults.textColor = UIColor.black
        noResults.textAlignment = .center
        noResults.font = UIFont.boldSystemFont(ofSize: 21)
        noResults.frame = CGRect(x: 0, y: self.view.frame.height/2.785, width: self.view.frame.width, height: self.view.frame.height/16.675)
        noResults.isHidden = true
        
        self.cancelButton.frame = CGRect(x: self.view.frame.width, y: searchBar.frame.origin.y, width: self.view.frame.width/5, height: searchBar.frame.height)
        self.searchBarBackgroundView.addSubview(self.cancelButton)
        searchBar.returnKeyType = UIReturnKeyType.search
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.scrollViewWillBeginDragging(_:)))
        administratorsTableView.addGestureRecognizer(tap)
        view.addGestureRecognizer(tap)

        // to detect beacons
        
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)
        acceptableDistance = 2.0
        rssiArray.removeAll()
        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true
        searchBar.frame = CGRect(x: searchBar.frame.origin.x, y: searchBar.frame.origin.y, width: self.view.frame.width/1.25, height: searchBar.frame.height)
        self.cancelButton.setTitle("Cancel", for: .normal)
        self.cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.cancelButton.backgroundColor = UIColor.init(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        self.cancelButton.setTitleColor(UIColor(red: 94/255, green: 185/255, blue: 255/255, alpha: 1.0), for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.frame = CGRect(x: self.view.frame.width/1.25, y: self.searchBar.frame.origin.y, width: self.view.frame.width/5, height: self.searchBar.frame.height)
        }
        self.cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.searchBarBackgroundView.addSubview(self.cancelButton)
        
        
    }
    func cancel(){
        noResults.isHidden = true
        administratorsTableView.isHidden = false
        isSearch = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchBar.frame = CGRect(x: 0, y: searchTop.frame.origin.y+searchTop.frame.height, width: self.view.frame.width, height: searchBarBackgroundView.frame.height/1.045)
        self.cancelButton.frame = CGRect(x: self.view.frame.width, y: searchBar.frame.origin.y, width: self.view.frame.width/5, height: searchBar.frame.height)
        administratorsTableView.reloadData()
    }
    
    func dismissKeyboard(){
        
        searchBar.resignFirstResponder()
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (searchBar.text?.characters.count)! > 0 {
            searchBar.resignFirstResponder()
        }else{
            searchBar.resignFirstResponder()
            searchBar.frame = CGRect(x: 0, y: searchTop.frame.origin.y+searchTop.frame.height, width: self.view.frame.width, height: searchBarBackgroundView.frame.height/1.045)
            self.cancelButton.frame = CGRect(x: self.view.frame.width, y: searchBar.frame.origin.y, width: self.view.frame.width/5, height: searchBar.frame.height)
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        administratorsTableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            administratorsTableView.isHidden = false
            noResults.isHidden = true
            administratorsTableView.reloadData()
        }else{
            isSearch = true
            filtered = administrators.filter({ (text) -> Bool in
                let tmp: NSString = text as NSString
                let range = tmp.range(of: searchText, options: .caseInsensitive)
                return range.location != NSNotFound
            })
            if filtered.count == 0 {
                administratorsTableView.isHidden = true
                
                noResults.isHidden = false
                self.view.addSubview(noResults)
            }else{
                administratorsTableView.isHidden = false
                administratorsTableView.reloadData()
            }
        }
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch == true && (searchBar.text?.characters.count)! > 0{
            
            return filtered.count
        }else{
            
           return administrators.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return administratorsTableView.frame.height/8.96
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if  isSearch == true && (searchBar.text?.characters.count)! > 0{
        let fullName    = filtered[indexPath.row]
        let fullNameArr = fullName.components(separatedBy: " ")
        let customString = NSMutableAttributedString(string: "\(filtered[indexPath.row])");
        customString.addAttribute(NSFontAttributeName, value:(UIFont.init(name: ".SFUIText-Bold", size: 17))!, range: NSRange(location: fullNameArr[0].characters.count+1,length: fullNameArr[1].characters.count))
        cell.textLabel?.attributedText = customString
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        }else{
                let fullName    = administrators[indexPath.row]
                let fullNameArr = fullName.components(separatedBy: " ")
                let customString = NSMutableAttributedString(string: "\(administrators[indexPath.row])");
                customString.addAttribute(NSFontAttributeName, value:(UIFont.init(name: ".SFUIText-Bold", size: 17))!, range: NSRange(location: fullNameArr[0].characters.count+1,length: fullNameArr[1].characters.count))
                cell.textLabel?.attributedText = customString
                cell.selectionStyle = UITableViewCellSelectionStyle.none
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fullName    = administrators[indexPath.row]
        let fullNameArr = fullName.components(separatedBy: " ")
        let AdministratorContact = self.storyboard?.instantiateViewController(withIdentifier: "AdministratorContactViewController") as! AdministratorContactViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        AdministratorContact.titleNameString = "\((fullNameArr[0].characters.first)!)\((fullNameArr[1].characters.first)!)"
        AdministratorContact.administratorName = administrators[indexPath.row]
        self.present(AdministratorContact, animated: false, completion: nil)
    }
    @IBAction func cancelBtnAction(_ sender: Any) {
        let contacts = self.storyboard?.instantiateViewController(withIdentifier: "ContactsDummyViewController") as! ContactsDummyViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)

        self.present(contacts, animated: false, completion: nil)

    }
    
    
    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        eveyTitle.frame = CGRect(x: screenWidth/2.757, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.166, y: screenHeight/23.821, width: screenWidth/11.363, height: screenHeight/31.761)
        
        administratorLbl.frame = CGRect(x: screenWidth/46.875, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/31.761, width: screenWidth/1.518, height: screenHeight/19.051)
        
        
        searchBarBackgroundView.frame = CGRect(x: 0, y: administratorLbl.frame.origin.y+administratorLbl.frame.height+screenHeight/83.375, width: screenWidth, height: screenHeight/14.5)
        
        searchTop.frame = CGRect(x: 0, y: 0, width:searchBarBackgroundView.frame.width, height: 1)

        searchBar.frame = CGRect(x: 0, y: searchTop.frame.origin.y+searchTop.frame.height, width: screenWidth, height: searchBarBackgroundView.frame.height/1.045454545454545)
        
        searchBarBackgroundView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        searchBottom.frame = CGRect(x: 0, y:searchBar.frame.origin.y+searchBar.frame.height, width:searchBarBackgroundView.frame.width, height: 1)
        
        administratorsTableView.frame =  CGRect(x: 0, y: searchBarBackgroundView.frame.origin.y+searchBarBackgroundView.frame.size.height+screenHeight/133.4, width: screenWidth, height: screenHeight/1.488)
        
        buttonsView.frame = CGRect(x: 0, y: administratorsTableView.frame.origin.y+administratorsTableView.frame.size.height, width: screenWidth, height: screenHeight/12.584)
        
        
        cancelBtn.frame = CGRect(x: screenWidth/1.315, y: buttonsView.frame.size.height/4.818, width: screenWidth/5.281, height: buttonsView.frame.size.height/1.766)
        
        buttonsViewBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: buttonsView.frame.height/buttonsView.frame.height)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
        if (knownBeacons.count>0) {
            let closeBeacon = knownBeacons[0] as CLBeacon
            var maj =  Int()
            maj =  8
            let previousBeaconArray : [Int] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [Int]
            if previousBeaconArray.count == 0 {
                if closeBeacon.major.intValue == maj {
                }else{
                    rssiArray.append(closeBeacon.rssi)
                    if rssiArray.count == 1 {
                        let sumedrssi = rssiArray.reduce(0, +)
                        let processedrssi = sumedrssi/1
                        let base = Double(10)
                        let power = Double(-57-(processedrssi))/Double(10*2)
                        let dis = pow(Double(base), power)
                        print("\(closeBeacon.major.intValue)")
                        print("\(closeBeacon.rssi)")
                        print("accuracy \(closeBeacon.accuracy)")
                        print(dis)
                        rssiArray.removeAll()
                        //if closeBeacon.accuracy <= 4.0 {
                        if dis <= 4.0{
                            UserDefaults.standard.set([closeBeacon.major.intValue], forKey: "PreviousBeaconArray")
                            
                            popup.dismiss(animated: true, completion: {
                                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                
                            })
                            locationManager.stopRangingBeacons(in: region)
                            locationManager.stopMonitoring(for: region)
                            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                            self .present(nvc, animated: true, completion: {
                                UserDefaults.standard.set([], forKey: "SelectedArray")
                                UserDefaults.standard.set("", forKey: "Came From")
                            })
                        }
                    }
                }
                
            }else{
                if closeBeacon.major.intValue == maj {
                    rssiArray.append(closeBeacon.rssi)
                    if rssiArray.count == 1 {
                        let sumedrssi = rssiArray.reduce(0, +)
                        let processedrssi = sumedrssi/1
                        let base = Double(10)
                        let power = Double(-59-(processedrssi))/Double(10*2)
                        let dis = pow(Double(base), power)
                        print("\(closeBeacon.major.intValue)")
                        print("\(closeBeacon.rssi)")
                        print("accuracy \(closeBeacon.accuracy)")
                        print(dis)
                        rssiArray.removeAll()
                        //if closeBeacon.accuracy <= 3.0 {
                        if dis <= 3{
                            print("After")
                            UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                            let msg = "Are you finished with your visit or are you continuing care?"
                            let attString = NSMutableAttributedString(string: msg)
                            
                            popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                                
                            })

                            let pauseButton = CancelButton(title: "Pause", action: {
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")


                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    
                                        let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                        self.locationManager.stopMonitoring(for: region)
                                        self.locationManager.stopRangingBeacons(in: region)
                                    
                                        RSVC.alertForPause = true
                                    
                                        self.present(RSVC, animated: true, completion: {
                                            UserDefaults.standard.set([], forKey: "NamesArray")
                                            UserDefaults.standard.set([], forKey: "SelectedArray")
                                            UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                            UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                            
                                        })

                                    }else{
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForPause = true
                                    self.present(nvc, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }
                                
                            })
                            
                            let continueButton = CancelButton(title: "Continue", action: {
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    
                                    RSVC.alertForContinue = true
                                    
                                    self.present(RSVC, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }else{
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForContinue = true
                                    self.present(nvc, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }

                            })
                            
                            let completeButton = CancelButton(title: "Complete", action: {
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    
                                    RSVC.alertForComplete = true
                                    
                                    self.present(RSVC, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }else{
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForComplete = true
                                    self.present(nvc, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }

                            })
                            
                            let deleteButton = DestructiveButton(title: "Delete", action: {
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")


                            })
                            popup.addButtons([pauseButton,continueButton,completeButton,deleteButton])

                            let hallwayBeaconArray : [Int] = UserDefaults.standard.value(forKey: "HallwayBeaconArray") as! [Int]
                            if hallwayBeaconArray.count == 0 {
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count >= 1 && selectedArray.count == 0{
                                    let DVC = storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                    UserDefaults.standard.set([], forKey: "NamesArray")
                                    UserDefaults.standard.set([], forKey: "SelectedArray")
                                    locationManager.stopRangingBeacons(in: region)
                                    locationManager.stopMonitoring(for: region)
                                    
                                    self.present(DVC, animated: true, completion: nil)
                                }else{
                                    

                                    self.present(popup, animated: true, completion: {
                                        UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                        UserDefaults.standard.set([closeBeacon.major.intValue], forKey: "HallwayBeaconArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}
