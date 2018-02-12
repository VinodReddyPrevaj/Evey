//
//  NotesViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 02/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class NotesViewController: UIViewController,UITextViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var residentCareImage: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var residentNameDetails: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var textViewUpBorder: UILabel!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var buttonsViewBorder: UILabel!
    
    var careName = String()
    var residentNameDetailsStr =  String()
    //for beacon Detection
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        if UserDefaults.standard.value(forKey: "Came From") as! String == "DashBoardViewController" || UserDefaults.standard.value(forKey: "Came From") as! String == "RecentVisitsViewController" {
            residentNameDetails.text =  "\(UserDefaults.standard.value(forKey: "ResidentDetails")!)"
        }else{
            residentNameDetails.text =  "\(UserDefaults.standard.value(forKey: "nameRoom")!)"
        }

        residentCareImage.image = UIImage(named: "\(UserDefaults.standard.value(forKey: "CareImage")!)")
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
        
        let keyboardDoneButtonView = UIToolbar()
       keyboardDoneButtonView.frame = CGRect(x: 0, y: noteTextView.frame.origin.y+noteTextView.frame.height, width: self.view.frame.width, height: self.view.frame.height/12.584)
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneMethod))
        doneButton.tintColor = UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.back(_:)))
        cancelButton.tintColor = UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
  
        let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.items = [cancelButton, flexibleSpaceWidth, doneButton]
        buttonsView.isHidden = false
        self.noteTextView.inputAccessoryView = keyboardDoneButtonView
        
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

    override func viewDidAppear(_ animated: Bool) {
        //self.noteTextView.becomeFirstResponder()
    }
    
    @IBAction func back(_ sender: Any) {

//        if self.noteTextView.text.characters.count > 0{
//            let popup = PopupDialog(title: "", message: "I have marked your visit with \((self.residentNameDetails.text)!) has been Completed",  buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
//                
//            })
//            let okButton = DefaultButton(title:"OK"){
//                
//            }
//            let cancelButton = CancelButton(title:"Cancel"){
//                if self.noteTextView.text.characters.count > 0{
//                }
//            }
//            popup.addButtons([cancelButton,okButton])
//            self.present(popup, animated: true, completion: nil)

           let oues = self.storyboard?.instantiateViewController(withIdentifier: "OutcomeEntryViewController") as! OutcomeEntryViewController

        

            oues.care = careName
            oues.imageAndText.setValue(careName, forKey: "CareImage")
            oues.imageAndText.setValue(residentNameDetailsStr, forKey: "residentDetails")
            oues.noteStr = self.noteTextView.text
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)

            self.present(oues, animated: false, completion: nil)
       // }
        
    }
    func keyboardDidShow(_ note: Notification) {
        let keyboardFrameValue = note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let keyboardFrame: CGRect? = keyboardFrameValue?.cgRectValue
        var r: CGRect = self.noteTextView.frame
        r.size.height -= (keyboardFrame?.height)!
        self.noteTextView.frame = r
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.layoutIfNeeded()
        var caretRect: CGRect = self.noteTextView.caretRect(for: textView.selectedTextRange?.end ?? UITextPosition())
        caretRect.size.height += self.noteTextView.textContainerInset.bottom
        textView.scrollRectToVisible(caretRect, animated: false)
    }
    func dismissKeyboard() {
        
        
        self.noteTextView.resignFirstResponder()
        noteTextView.frame = CGRect(x: self.view.frame.width/31.25, y: textViewUpBorder.frame.origin.y+textViewUpBorder.frame.height, width: self.view.frame.width/1.068, height: self.view.frame.height/1.336)
    }
    func doneMethod () {
        dismissKeyboard()

    }

    @IBAction func menuAction(_ sender: Any) {
        let MenuVC = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("NotesViewController", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(MenuVC, animated: false, completion: nil)

    }
    
    func layOuts(){
        
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        backBtn.frame = CGRect(x: screenWidth/23.437, y: screenHeight/23, width: screenWidth/18.75, height: screenHeight/33.35)
        
        eveyTitle.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.size.width+screenWidth/3.712, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.213, y: screenHeight/23.437, width: screenWidth/11.363, height: screenHeight/31.761)
        
        residentCareImage.frame = CGRect(x: screenWidth/31.25, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/35.105, width: screenWidth/10.416, height: screenHeight/18.527)
        
        residentNameDetails.frame = CGRect(x: residentCareImage.frame.origin.x+residentCareImage.frame.width, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/35.105, width: screenWidth/1.518, height: screenHeight/18.527)
        
        textViewUpBorder.frame =  CGRect(x: 0, y: residentNameDetails.frame.origin.y+residentNameDetails.frame.size.height+screenHeight/95.28, width: screenWidth, height: screenHeight/screenHeight)
        
        noteTextView.frame = CGRect(x: screenWidth/31.25, y: textViewUpBorder.frame.origin.y+textViewUpBorder.frame.height, width: screenWidth/1.068, height: screenHeight/1.336)
        
        
        buttonsView.frame = CGRect(x: 0, y: noteTextView.frame.origin.y+noteTextView.frame.size.height, width: screenWidth, height: screenHeight/12.584)
        
        cancelBtn.frame = CGRect(x: screenWidth/15, y: buttonsView.frame.size.height/4.818, width: screenWidth/5.281, height: buttonsView.frame.size.height/1.766)
        
        doneBtn.frame = CGRect(x: cancelBtn.frame.origin.x+cancelBtn.frame.size.width+screenWidth/1.963, y: buttonsView.frame.size.height/4.818, width: screenWidth/5.281, height: buttonsView.frame.size.height/1.766)
        
        buttonsViewBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        
    }
    @IBAction func doneBtnAction(_ sender: Any) {
        let oues = self.storyboard?.instantiateViewController(withIdentifier: "OutcomeEntryViewController") as! OutcomeEntryViewController
        oues.care = careName
        if noteTextView.text.characters.count > 0 {
            oues.notesHint = true
        }
        oues.imageAndText.setValue(careName, forKey: "CareImage")
        oues.imageAndText.setValue(residentNameDetailsStr, forKey: "residentDetails")
        oues.noteStr = self.noteTextView.text
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        self.present(oues, animated: false, completion: nil)

    }

    @IBAction func cancelBtnAction(_ sender: Any) {
        let oues = self.storyboard?.instantiateViewController(withIdentifier: "OutcomeEntryViewController") as! OutcomeEntryViewController
        oues.care = careName
        if noteTextView.text.characters.count > 0 {
            oues.notesHint = true
        }
        oues.imageAndText.setValue(careName, forKey: "CareImage")
        oues.imageAndText.setValue(residentNameDetailsStr, forKey: "residentDetails")
        oues.noteStr = self.noteTextView.text
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)

        self.present(oues, animated: false, completion: nil)

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
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(RSVC, animated: false, completion: {
                                            UserDefaults.standard.set([], forKey: "NamesArray")
                                            UserDefaults.standard.set([], forKey: "SelectedArray")
                                            UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                            UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                            
                                    })
                                        
                                }else{
                                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "nameRoom"), forKey: "ResidentDetails")

                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForPause = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(nvc, animated: false, completion: {
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
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(RSVC, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }else{
                                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "nameRoom"), forKey: "ResidentDetails")

                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForContinue = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromRight
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(nvc, animated: false, completion: {
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
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromRight
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(RSVC, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }else{
                                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "nameRoom"), forKey: "ResidentDetails")

                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForComplete = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(nvc, animated: false, completion: {
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
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(DVC, animated: false, completion: nil)
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
