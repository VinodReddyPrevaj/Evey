//
//  SignInViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 26/09/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController,UITextFieldDelegate {
    
    var upArrow = UIBarButtonItem()
    var downArrow = UIBarButtonItem()
    let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    @IBOutlet weak var eveyImage: UIImageView!
    @IBOutlet weak var resetLogIn: UIButton!
    @IBOutlet weak var titleLabel: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var userNameTF: UITextField!
    var eveyfloat = CGRect()
    var userfloat = CGRect()
    var passwordfloat = CGRect()
    var continiuefloat = CGRect()
    let  UserName = "prevaj@gmail.com"
    let  Password = "PREVAJ123!@#!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layOuts()
        
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
            if (userNameTF.text?.isEmpty)! {
                return false
            }else{
                return true
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
            // For Arrow Color
            //upArrow.tintColor=UIColor.gray
            //downArrow.tintColor=UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
            animation()
            self.continueBtn.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.8235294118, blue: 0.9294117647, alpha: 1)
            //UIColor(red: 132.0 / 255.0, green: 210.0 / 255.0, blue: 237.0 / 255.0, alpha: 1)
            
        }
        if (textField == passwordTF) {
            // For Arrow Color
            //downArrow.tintColor=UIColor.gray
            //upArrow.tintColor=UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
            
            // addColorToUIKeyboardButton()
            animation()
            if (passwordTF.text?.isEmpty)! {
                self.continueBtn.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.8235294118, blue: 0.9294117647, alpha: 1)
                
                //UIColor(red: 132.0 / 255.0, green: 210.0 / 255.0, blue: 237.0 / 255.0, alpha: 1)
                
            }
        }
        //titleLabel.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            let scrollPoint = CGPoint(x: 0, y: self.userNameTF.frame.origin.y)
            self.scrollView.setContentOffset(scrollPoint, animated: true)
            
        })
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.continueBtn.backgroundColor = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 0.8862745098, alpha: 1)
        //UIColor(red: 94.0 / 255.0, green: 185.0 / 255.0, blue: 226 / 255.0, alpha: 1)
        cancelAnimation()
        //scrollView.setContentOffset(CGPoint.zero, animated: true)
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == passwordTF {
            
            if  ((passwordTF.text!.characters.count)>=0) {
                
                self.continueBtn.backgroundColor = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 0.8862745098, alpha: 1)
                //UIColor(red: 94 / 255.0, green: 185 / 255.0, blue: 226 / 255.0, alpha: 1)
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
                
                self.userNameTF.frame = CGRect(x: self.userNameTF.frame.origin.x, y: (self.eveyImage.frame.origin.y+self.eveyImage.frame.height)-self.eveyImage.frame.height/19.833, width: self.userNameTF.frame.width, height: self.userNameTF.frame.height)
                
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
            //dismissKeyboard()
            
            //            UserDefaults.standard.set("HWBYJAcz", forKey: "OrganizationID")
            //        let url:NSURL = NSURL(string: "http://13.58.78.59:6060/\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/signin")!
            //        let session = URLSession.shared
            //        let request = NSMutableURLRequest (url: url as URL)
            //        request.httpMethod = "POST"
            //        let paramString = "username=\((userNameTF.text)!)&password=\((passwordTF.text)!)"
            //        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content_Type")
            //
            //        request.setValue("vinodreddysure", forHTTPHeaderField: "device_token")
            //
            //        var dataToPassServer: Data? = paramString.data(using: String.Encoding.ascii, allowLossyConversion: true)
            //        let postLength = "\(UInt((dataToPassServer?.count)!))"
            //        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
            //
            //        request.httpBody = paramString.data(using: String.Encoding.utf8)
            //
            //        let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
            //        if let data = data {
            //
            //            var re = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
            //            print(re)
            //            print(re["success"]!)
            //            DispatchQueue.main.async( execute: {
            //            let successString =  "\(re["success"]!)"
            if (userNameTF.text == "john_joseph") && passwordTF.text == "evey@!&?" {
                
                let loggedInUserName: UserDefaults? = UserDefaults.standard
                loggedInUserName?.set(self.userNameTF.text, forKey: "loggedInUserName")
                loggedInUserName?.synchronize()
                let credentials: UserDefaults? = UserDefaults.standard
                credentials?.set(true, forKey: "checking")
                credentials?.synchronize()
                
                let DBVC = self.storyboard?.instantiateViewController(withIdentifier :"DashBoardViewController") as? DashBoardViewController
                
                let transition = CATransition()
                transition.duration = 0
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.present(DBVC!, animated: false, completion: nil)
                DBVC?.nameLabel.text="john"
                UserDefaults.standard.set("john", forKey: "name")
                
            }
            else {
                
                dismissKeyboard()
                let msg = "Your login does not match our records"
                let attString = NSMutableAttributedString(string: msg)
                
                // Create the dialog
                let popup = PopupDialog(title: "Oops!", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                    print("Completed")
                }
                
                // Create first button
                let buttonOne = DefaultButton(title: "Try Again") {
                    self.resetLogIn.isHidden = false
                }
                
                popup.addButtons([buttonOne])
                // Present dialog
                self.present(popup, animated: true, completion: nil)
                self.userNameTF.text = nil
                self.passwordTF.text = nil
            }
            //})
            //}
            //}
            // task.resume()
        }
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
    
    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        self.titleLabel.frame = CGRect(x: screenWidth/2.757, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        
        
        self.scrollView.frame = CGRect(x: screenWidth/8.152, y: titleLabel.frame.origin.y+titleLabel.frame.size.height+screenHeight/5.442, width: screenWidth/1.329, height: screenHeight/1.472)
        self.scrollView.isHidden = true
        
        
        eveyImage.frame = CGRect(x: self.view.frame.size.width/7.075, y: (self.titleLabel.frame.origin.y+titleLabel.frame.height+screenHeight/3.705), width: screenWidth/1.415, height: (screenHeight/5.605))
        self.eveyfloat = self.eveyImage.frame
        
        userNameTF.frame = CGRect(x: screenWidth/8.152, y: eveyImage.frame.origin.y+eveyImage.frame.size.height+screenHeight/19.617, width: screenWidth/1.329, height: screenHeight/11.910)
        self.userfloat = self.userNameTF.frame
        
        passwordTF.frame = CGRect(x: screenWidth/8.152, y: userNameTF.frame.origin.y+userNameTF.frame.size.height+screenHeight/37.055, width: screenWidth/1.329, height: screenHeight/11.910)
        self.passwordfloat = self.passwordTF.frame
        
        continueBtn.frame = CGRect(x: screenWidth/8.152, y: passwordTF.frame.origin.y+passwordTF.frame.size.height+screenHeight/37.055, width: screenWidth/1.329, height: screenHeight/11.910)
        self.continiuefloat = self.continueBtn.frame
        
        self.view.addSubview(eveyImage)
        self.view.addSubview(userNameTF)
        self.view.addSubview(passwordTF)
        self.view.addSubview(continueBtn)
        
        resetLogIn.frame = CGRect(x: screenWidth/2.613, y: scrollView.frame.origin.y+scrollView.frame.size.height+screenHeight/333.5, width: screenWidth/4.310, height: screenHeight/39.235)
        
        
    }
}
