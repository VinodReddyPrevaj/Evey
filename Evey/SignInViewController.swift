//
//  SignInViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 26/09/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController,UITextFieldDelegate,CAAnimationDelegate {
    
    // for spinning animation on Button
    
    var isRotating = false
    var shouldStopRotating = false

    
    var upArrow = UIBarButtonItem()
    var downArrow = UIBarButtonItem()
    let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    @IBOutlet weak var eveyImage: UIImageView!
    @IBOutlet weak var resetLogIn: UIButton!
    @IBOutlet weak var titleLabel: UIImageView!
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var userNameTF: UITextField!
    var eveyfloat = CGRect()
    var userfloat = CGRect()
    var passwordfloat = CGRect()
    var continiuefloat = CGRect()
    let  UserName = "prevaj@gmail.com"
    let  Password = "PREVAJ123!@#!"
    var animationView = UIImageView()
    var animationBackground = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layOuts()
        animationBackground.frame = CGRect(x: 3, y: 3, width: continueBtn.frame.width-6, height: continueBtn.frame.height-6)
        animationBackground.backgroundColor = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 0.8862745098, alpha: 1)
        continueBtn.addSubview(animationBackground)
        animationBackground.isHidden = true
        
        animationView.image = UIImage(named: "spinner")
        animationView.frame = CGRect(x: 0, y: 0, width: continueBtn.frame.height/2, height: continueBtn.frame.height/2)
        animationView.center = animationBackground.center
        self.animationBackground.addSubview(animationView)
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
        doneButton.tintColor = #colorLiteral(red: 0.2941176471, green: 0.7568627451, blue: 0.9254901961, alpha: 1)
        //UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
        
        upArrow = UIBarButtonItem(image:#imageLiteral(resourceName: "UpArrow") , style: .plain, target: self, action: #selector(self.upArrowClicked))
        upArrow.tintColor=UIColor.gray
        downArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "DownArrow"), style: .plain, target: self, action: #selector(self.downArrowClicked))
        downArrow.tintColor=UIColor.gray
        
        let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.items = [upArrow, downArrow, flexibleSpaceWidth, doneButton]
        userNameTF.inputAccessoryView = keyboardDoneButtonView
        passwordTF.inputAccessoryView = keyboardDoneButtonView
        userNameTF.textContentType = UITextContentType("")
        passwordTF.textContentType = UITextContentType("")
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
        }

    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == passwordTF {
            
            if (userNameTF.text?.characters.count)! >= 6 {
                return true
            }else{
                return false
            }
        }
        return true
    }
    
    
    func upArrowClicked(_ sender: Any) {
        if passwordTF.isFirstResponder {
            userNameTF.becomeFirstResponder()
        }
    }
    func downArrowClicked(_ sender: Any) {
        if userNameTF.isFirstResponder {
            passwordTF.becomeFirstResponder()
            
        }
    }
    
    func dismissKeyboard() {
        
        
        cancelAnimation()
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if (textField == userNameTF) {
            animation()
            self.continueBtn.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.8235294118, blue: 0.9294117647, alpha: 1)
            if (passwordTF.text?.characters.count)! >= 8 {
                self.continueBtn.backgroundColor = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 0.8862745098, alpha: 1)
            }else{
                self.continueBtn.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.8235294118, blue: 0.9294117647, alpha: 1)
                
            }

            
        }
        if (textField == passwordTF) {
            animation()
            if (passwordTF.text?.characters.count)! >= 8 {
                self.continueBtn.backgroundColor = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 0.8862745098, alpha: 1)
            }else{
                self.continueBtn.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.8235294118, blue: 0.9294117647, alpha: 1)
 
            }
        }
        //titleLabel.isHidden = false
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.continueBtn.backgroundColor = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 0.8862745098, alpha: 1)
        cancelAnimation()
        //scrollView.setContentOffset(CGPoint.zero, animated: true)
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == passwordTF {
            
            if  ((passwordTF.text!.characters.count)>=7) {
                    //self.continueBtn.isUserInteractionEnabled = true

                self.continueBtn.backgroundColor = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 0.8862745098, alpha: 1)
                return true
            }
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cancelAnimation()
        continueButtonTapOn(self)
        return true
    }
    func animation(){
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.titleLabel.alpha = 1.0
            
            
        }) { (true) in
            self.titleLabel.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
            self.eveyImage.alpha = 1.0
            UIView.animate(withDuration: 0.8, delay: 0, options: [], animations: {() -> Void in
                self.eveyImage.frame = CGRect(x: self.eveyImage.frame.origin.x, y: self.view.frame.height/11.910, width: self.eveyImage.frame.width, height: self.eveyImage.frame.height)
                
                self.eveyImage.alpha = 0.0
            }, completion: {(_ finished: Bool) -> Void in
                self.eveyImage.isHidden = true
                
            })
            
            UIView.animate(withDuration: 1, delay:0.0, options: [], animations: {
                
                self.userNameTF.frame = CGRect(x: self.userNameTF.frame.origin.x, y: (self.eveyImage.frame.origin.y+self.eveyImage.frame.height)-self.eveyImage.frame.height/4.175, width: self.userNameTF.frame.width, height: self.userNameTF.frame.height)
                
            }, completion: { (true) in
                
            })
            UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                self.passwordTF.frame = CGRect(x: self.passwordTF.frame.origin.x, y: self.userNameTF.frame.origin.y+self.userNameTF.frame.height+self.view.frame.height/37.055, width: self.passwordTF.frame.width, height: self.passwordTF.frame.height)
                
            }, completion: { (true) in
                
            })
            
            
            UIView.animate(withDuration: 1, delay:0.2, options: [], animations: {
                self.continueBtn.frame = CGRect(x: self.continueBtn.frame.origin.x, y: self.passwordTF.frame.origin.y+self.passwordTF.frame.height+self.view.frame.height/37.055, width: self.continueBtn.frame.width, height: self.continueBtn.frame.height)
            }, completion: { (true) in

            })
            
        }, completion: { (true) in
            
        })
    }
    
    func cancelAnimation(){
    
        
        if userNameTF.isFirstResponder||passwordTF.isFirstResponder{
            self.titleLabel.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                self.titleLabel.alpha = 0.0
            }) { (true) in
                self.titleLabel.isHidden = true
            }
            
            self.eveyImage.alpha = 1.0
            UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
                UIView.animate(withDuration: 1, delay:0, options: [], animations: {
                    self.continueBtn.frame = self.continiuefloat
                    UIView.animate(withDuration: 1, delay:0.3, options: [], animations: {
                        
                        self.eveyImage.frame = self.eveyfloat
                        
                        self.eveyImage.alpha = 1.0
                        self.eveyImage.isHidden = false
                    }, completion: { (true) in
                    })
                    
                }, completion: { (true) in
                    
                })
                UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                    self.userNameTF.resignFirstResponder()
                    self.passwordTF.resignFirstResponder()
                    self.passwordTF.frame = self.passwordfloat
                    
                }, completion: { (true) in
                    
                })
                UIView.animate(withDuration: 1, delay:0.2, options: [], animations: {
                    self.userNameTF.frame = self.userfloat
                    
                }, completion: { (true) in
                    
                })
                self.eveyImage.alpha = 0.0
                UIView.animate(withDuration: 1, delay:0.3, options: [], animations: {
                    self.eveyImage.frame = self.eveyfloat
                    
                    self.eveyImage.alpha = 1.0
                    
                }, completion: { (true) in
                    self.eveyImage.isHidden = false
                })
                
                
                
            }, completion: { (true) in
                
            })
            
        }
        
    }
    
    
    @IBAction func continueButtonTapOn(_ sender: Any) {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        }else{
            print("worked")
        }
        if (userNameTF.text?.characters.count)! > 0 && (passwordTF.text?.characters.count)! > 0 {
            self.continueBtn.isUserInteractionEnabled = false
            dismissKeyboard()
            
            //continueBtn.isUserInteractionEnabled = false
            continueBtn.setTitleColor(UIColor.clear, for: .normal)
            animationBackground.isHidden = false
            
            if self.isRotating == false {
                self.animationView.rotate360Degrees(completionDelegate: self)
                self.isRotating = true
            }

            let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/signin")!
            let session = URLSession.shared
            let request = NSMutableURLRequest (url: url as URL)
            request.httpMethod = "POST"
            let paramString = "username=\((self.userNameTF.text)!)&password=\((self.passwordTF.text)!)&device_token=devicetoken"
            
            request.setValue("application/json", forHTTPHeaderField: "Content_Type")
            
            var dataToPassServer: Data? = paramString.data(using: String.Encoding.ascii, allowLossyConversion: true)
            
                    let postLength = "\(UInt((dataToPassServer?.count)!))"
            request.setValue(postLength, forHTTPHeaderField: "Content-Length")
            
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
            if let data = data {
                var re = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
                DispatchQueue.main.async( execute: {
                let successString =  "\(re["success"]!)"
                if (successString == "1") {
                    let user1 = re["user"]
                    UserDefaults.standard.set(user1?["_id"] as! String, forKey: "user_Id")
                    
                    UserDefaults.standard.set(user1?["token"] as! String, forKey: "authorization_Token")
                    
                    let loggedInUserName: UserDefaults? = UserDefaults.standard
                    loggedInUserName?.set(self.userNameTF.text, forKey: "loggedInUserName")
                    
                    UserDefaults.standard.setValue(user1?["first_name"]!, forKey: "user_First_Name")
                    
                    loggedInUserName?.synchronize()
                    
                    let credentials: UserDefaults? = UserDefaults.standard
                    credentials?.set(true, forKey: "checking")
                    credentials?.synchronize()
                    
                     self.announcementSerevrData()
                    
                    let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/announce")!
                    let session = URLSession.shared
                    let request = NSMutableURLRequest (url: url as URL)
                    request.httpMethod = "Get"
                    
                    request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                    
                    let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                        if let data = data {
                            
                            let response = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                            
                            DispatchQueue.main.async( execute: {
                                
                                self.careDetailsFromServer()
                                let DBVC = self.storyboard?.instantiateViewController(withIdentifier :"DashBoardViewController") as? DashBoardViewController
                                if response.value(forKey: "isactive") as! Bool == true {
                                    DBVC?.announcementString = response.value(forKey: "message") as! String
                                }
                                let transition = CATransition()
                                transition.duration = 0
                                transition.type = kCATransitionPush
                                transition.subtype = kCATransitionFromRight
                                self.view.window!.layer.add(transition, forKey: kCATransition)
                                Constants.dashBoard = false
                                self.continueBtn.isUserInteractionEnabled = true
                                //DBVC?.nameLabel.text=UserDefaults.standard.value(forKey: "user_First_Name") as? String

                                self.present(DBVC!, animated: false, completion: {
                                    self.animationBackground.isHidden = true
                                    self.shouldStopRotating = true
                                    self.continueBtn.setTitleColor(UIColor.white, for: .normal)
                                })
                            })
                        }
                    }
                    task.resume()

                }else {
                    //self.continueBtn.isUserInteractionEnabled = true
                    
                    self.animationBackground.isHidden = true
                    self.shouldStopRotating = true
                    self.continueBtn.setTitleColor(UIColor.white, for: .normal)

                    let msg = "Your login does not match our records"
                                let attString = NSMutableAttributedString(string: msg)
                                
                    // Create the dialog
                    let popup = PopupDialog(title: "Oops!", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                    }
                                
                    // Create first button
                    let buttonOne = DefaultButton(title: "Try Again") {
                        self.resetLogIn.isHidden = false
                        self.continueBtn.isUserInteractionEnabled = true
                        
                    }
                    
                    popup.addButtons([buttonOne])
                    // Present dialog
                    self.present(popup, animated: true, completion: {
                    })
                        self.userNameTF.text = nil
                        self.passwordTF.text = nil
                }

                })
                }
            }
             task.resume()
        }
    }
    func announcementSerevrData(){
        let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/setting/beacon")!
        let session = URLSession.shared
        let request = NSMutableURLRequest (url: url as URL)
        request.httpMethod = "Get"
        //http://13.58.78.59:4200/orgID/api/reset/user/:username
        
        request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
        
        let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
            if let data = data {
                
                let response = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary

                Constants.hallwayRange = Double(response.value(forKey: "hrange") as! String)!
                Constants.roomRange = Double(response.value(forKey: "rrange") as! String)!
                let rtxDic = response.value(forKey: "rtx") as! NSDictionary
                let htxDic = response.value(forKey: "htx") as! NSDictionary

                Constants.hallwayRSSI = Double(htxDic.value(forKey: "permeter") as! String)!
                Constants.roomRSSI = Double(rtxDic.value(forKey: "permeter") as! String)!
                
                print(Constants.roomRSSI)
                print(Constants.roomRange)
                print(Constants.hallwayRSSI)
                print(Constants.hallwayRange)

            }
        }
        task.resume()
    }
    
    @IBAction func resetLoginAction(_ sender: Any) {
        
        let RLVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetLogInViewController")as! ResetLogInViewController
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(RLVC, animated: false, completion: {
            
        })
        
    }
    // for Spinning Animation on Button
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.animationView.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    // for Spinning Animation on Button
    func reset() {
        self.isRotating = false
        self.shouldStopRotating = false
    }

    
    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        self.titleLabel.frame = CGRect(x: screenWidth/2.757, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        eveyImage.frame = CGRect(x: self.view.frame.size.width/10.714, y: (self.titleLabel.frame.origin.y+titleLabel.frame.height+screenHeight/5.015), width: screenWidth/1.225, height: (screenHeight/3.994))
        self.eveyfloat = self.eveyImage.frame
        
        userNameTF.frame = CGRect(x: screenWidth/15, y: eveyImage.frame.origin.y+eveyImage.frame.size.height+screenHeight/19.617, width: screenWidth/1.150, height: screenHeight/11.910)
        self.userfloat = self.userNameTF.frame
        
        passwordTF.frame = CGRect(x: screenWidth/15, y: userNameTF.frame.origin.y+userNameTF.frame.size.height+screenHeight/37.055, width: screenWidth/1.150, height: screenHeight/11.910)
        self.passwordfloat = self.passwordTF.frame
        
        continueBtn.frame = CGRect(x: screenWidth/15, y: passwordTF.frame.origin.y+passwordTF.frame.size.height+screenHeight/37.055, width: screenWidth/1.150, height: screenHeight/11.910)
        self.continiuefloat = self.continueBtn.frame
        
        self.view.addSubview(eveyImage)
        self.view.addSubview(userNameTF)
        self.view.addSubview(passwordTF)
        self.view.addSubview(continueBtn)
        
        resetLogIn.frame = CGRect(x: screenWidth/2.613, y: continueBtn.frame.origin.y+continueBtn.frame.size.height+screenHeight/16.675, width: screenWidth/4.310, height: screenHeight/39.235)
        
    }
    func careDetailsFromServer() {
        
        let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/list/care")!
        let session = URLSession.shared
        let request = NSMutableURLRequest (url: url as URL)
        request.httpMethod = "Get"
        
        request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
        
        let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
            if let data = data {
                
                let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                print(re)
                let careWithIDs = NSMutableDictionary()
                
                for i in 0..<re.count {
                    
                    let care = re[i] as! NSDictionary
                        let Name = care.value(forKey: "name")
                        let _id = care.value(forKey: "_id")
                        careWithIDs.setValue(_id, forKey: Name as! String)
                    Constants.careIDs.add(["name":Name as! String,"id":_id as! String])
                }

                let careIDS = NSKeyedArchiver.archivedData(withRootObject: careWithIDs)
                UserDefaults.standard.set(careIDS, forKey: "Care_Ids")

            }
        }
        task.resume()
        
    }

    
}
