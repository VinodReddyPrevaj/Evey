//
//  NewPasswordViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 10/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class NewPasswordViewController: UIViewController,UITextFieldDelegate,CAAnimationDelegate{
    
    // for spinning animation on Button
    
    var isRotating = false
    var shouldStopRotating = false
    
    var upArrow = UIBarButtonItem()
    var downArrow = UIBarButtonItem()
    
    @IBOutlet weak var titleLabel: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var temporaryPasswordTF: UITextField!

    @IBOutlet weak var verifyNewPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    var temporaryTFFrame = CGRect()
    var newPasswordFrame = CGRect()
    var verifyPasswordFrame = CGRect()
    var continueFrame = CGRect()
    
    var animationView = UIImageView()
    var animationBackground = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        
        animationBackground.frame = CGRect(x: 3, y: 3, width: continueButton.frame.width-6, height: continueButton.frame.height-6)
        animationBackground.backgroundColor = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 0.8862745098, alpha: 1)
        continueButton.addSubview(animationBackground)
        animationBackground.isHidden = true
        
        
        
        animationView.image = UIImage(named: "spinner")
        animationView.frame = CGRect(x: 0, y: 0, width: continueButton.frame.height/2, height: continueButton.frame.height/2)
        animationView.center = animationBackground.center
        self.animationBackground.addSubview(animationView)

        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
        doneButton.tintColor = #colorLiteral(red: 0.2941176471, green: 0.7568627451, blue: 0.9254901961, alpha: 1)
            //UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
        
        upArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "UpArrow"), style: .plain, target: self, action: #selector(self.upArrowClicked))
        upArrow.tintColor=UIColor.gray
        downArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "DownArrow"), style: .plain, target: self, action: #selector(self.downArrowClicked))
        downArrow.tintColor=UIColor.gray
        
        let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.items = [upArrow, downArrow, flexibleSpaceWidth, doneButton]
        temporaryPasswordTF.inputAccessoryView = keyboardDoneButtonView
        newPasswordTF.inputAccessoryView = keyboardDoneButtonView
        verifyNewPasswordTF.inputAccessoryView = keyboardDoneButtonView
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        temporaryPasswordTF.textContentType = UITextContentType("")
        newPasswordTF.textContentType = UITextContentType("")
        verifyNewPasswordTF.textContentType = UITextContentType("")

    }

    @IBAction func continueAction(_ sender: Any) {
        dismissKeyboard()
        if (temporaryPasswordTF.text?.characters.count)! > 0 && (newPasswordTF.text?.characters.count)! > 0 && (verifyNewPasswordTF.text?.characters.count)! > 0 && isPasswordValid(newPasswordTF.text!) && newPasswordTF.text! == verifyNewPasswordTF.text!{
            
            continueButton.setTitleColor(UIColor.clear, for: .normal)
            animationBackground.isHidden = false
            
            if self.isRotating == false {
                self.animationView.rotate360Degrees(completionDelegate: self)
                self.isRotating = true
            }

        let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/reset/user")!
        let session = URLSession.shared
        let request = NSMutableURLRequest (url: url as URL)
        request.httpMethod = "POST"
        let paramString = "temppwd=\((temporaryPasswordTF.text)!)&password=\((newPasswordTF.text)!)"
        
        request.setValue("application/json", forHTTPHeaderField: "Content_Type")
        
        var dataToPassServer: Data? = paramString.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let postLength = "\(UInt((dataToPassServer?.count)!))"
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
            if let data = data {
                
                let response = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                DispatchQueue.main.async( execute: {
                    if response.value(forKey: "success") as! Bool == true {
                        let msg = response.value(forKey: "msg") as! String
                        let attString = NSMutableAttributedString(string: msg)
                        
                        // Create the dialog
                        let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                        }
                        
                        // Create first button
                        let buttonOne = DefaultButton(title: "Ok") {
                            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                            
                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromRight
                            self.view.window!.layer.add(transition, forKey: kCATransition)
                            self.animationBackground.isHidden = true
                            self.shouldStopRotating = true
                            self.continueButton.setTitleColor(UIColor.white, for: .normal)

                            self.present(loginVC, animated: false, completion: nil)
                        }
                        
                        
                        popup.addButtons([buttonOne])
                        // Present dialog
                        self.present(popup, animated: true, completion: nil)
 
                    }
                    else {
                        
                        self.animationBackground.isHidden = true
                        self.shouldStopRotating = true
                        self.continueButton.setTitleColor(UIColor.white, for: .normal)

                        let msg = response.value(forKey: "msg") as! String
                        let attString = NSMutableAttributedString(string: msg)
                        
                        // Create the dialog
                        let popup = PopupDialog(title: "Oops!", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                        }
                        
                        // Create first button
                        let buttonOne = DefaultButton(title: "Try Again") {

                        }
                        
                        
                        popup.addButtons([buttonOne])
                        // Present dialog
                        self.present(popup, animated: true, completion: {

                        })
                    }
                    
                })
            }
        }
        task.resume()

        }else{
            if isPasswordValid(newPasswordTF.text!) == false {
                let msg = "New password minimum of eight characters using a mix of letters, numbers, and symbols."
                let attString = NSMutableAttributedString(string: msg)
                
                // Create the dialog
                let popup = PopupDialog(title: "Oops!", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                }
                
                // Create first button
                let buttonOne = DefaultButton(title: "Try Again") {
                    
                }
                
                
                popup.addButtons([buttonOne])
                // Present dialog
                self.present(popup, animated: true, completion: nil)

            }else if newPasswordTF.text != verifyNewPasswordTF.text {
                let msg = "Password does not match."
                let attString = NSMutableAttributedString(string: msg)
                
                // Create the dialog
                let popup = PopupDialog(title: "Oops!", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                }
                
                // Create first button
                let buttonOne = DefaultButton(title: "Try Again") {

                }
                
                
                popup.addButtons([buttonOne])
                // Present dialog
                self.present(popup, animated: true, completion: nil)
            }
        }
        
    }
    func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@","^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$" )
        return passwordTest.evaluate(with: password)
    }
    func upArrowClicked(_ sender: Any) {
        if newPasswordTF.isFirstResponder {
            temporaryPasswordTF.becomeFirstResponder()
        }else if verifyNewPasswordTF.isFirstResponder {
            newPasswordTF.becomeFirstResponder()
        }
    }
    func downArrowClicked(_ sender: Any) {
        if temporaryPasswordTF.isFirstResponder {
            newPasswordTF.becomeFirstResponder()
        }else if newPasswordTF.isFirstResponder {
            verifyNewPasswordTF.becomeFirstResponder()
        }
    }
    
    func dismissKeyboard() {
        
        
        cancelAnimation()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animation()
        // titleLabel.isHidden = false
//        UIView.animate(withDuration: 0.3, animations: {
////            let scrollPoint = CGPoint(x: 0, y: self.temporaryPasswordTF.frame.origin.y)
////            self.scrollView.setContentOffset(scrollPoint, animated: true)
//            
//        })
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        // titleLabel.isHidden = true
        
        // self.continueBtn.backgroundColor = UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
       // scrollView.setContentOffset(CGPoint.zero, animated: true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        continueAction(self)
        return true
    }

    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        self.titleLabel.frame = CGRect(x: screenWidth/2.757, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        self.scrollView.frame = CGRect(x: screenWidth/8.152, y: titleLabel.frame.origin.y+titleLabel.frame.size.height+screenHeight/23, width: screenWidth/1.329, height: screenHeight/1.217)
        self.scrollView.isHidden = true
        
        

        temporaryPasswordTF.frame = CGRect(x: screenWidth/15, y:self.titleLabel.frame.origin.y+self.titleLabel.frame.height+self.view.frame.size.height/2.575, width: screenWidth/1.150, height: self.view.frame.size.height/11.910)

        newPasswordTF.frame = CGRect(x: screenWidth/15, y: temporaryPasswordTF.frame.origin.y+temporaryPasswordTF.frame.size.height+self.view.frame.size.height/35.055, width: screenWidth/1.150, height: self.view.frame.size.height/11.910)

        verifyNewPasswordTF.frame = CGRect(x: screenWidth/15, y: newPasswordTF.frame.origin.y+newPasswordTF.frame.size.height+self.view.frame.size.height/35.055, width: screenWidth/1.150, height: self.view.frame.size.height/11.910)

        continueButton.frame = CGRect(x: screenWidth/15, y: verifyNewPasswordTF.frame.origin.y+verifyNewPasswordTF.frame.size.height+self.view.frame.size.height/35.055, width: screenWidth/1.150, height: self.view.frame.size.height/11.910)
        
        self.view.addSubview(temporaryPasswordTF)
        self.view.addSubview(newPasswordTF)
        self.view.addSubview(verifyNewPasswordTF)
        self.view.addSubview(continueButton)
        
        self.temporaryTFFrame = self.temporaryPasswordTF.frame
        self.newPasswordFrame = self.newPasswordTF.frame
        self.verifyPasswordFrame = self.verifyNewPasswordTF.frame
        self.continueFrame = self.continueButton.frame
        
    }
    
    
    func animation(){
        UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
            
            
            UIView.animate(withDuration: 1, delay:0.0, options: [], animations: {
                
                self.temporaryPasswordTF.frame = CGRect(x: self.temporaryPasswordTF.frame.origin.x, y: (self.titleLabel.frame.origin.y+self.titleLabel.frame.height)+self.view.frame.height/13.34, width: self.temporaryPasswordTF.frame.width, height: self.temporaryPasswordTF.frame.height)
                
            }, completion: { (true) in
                
            })
            UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                self.newPasswordTF.frame = CGRect(x: self.newPasswordTF.frame.origin.x, y: self.temporaryPasswordTF.frame.origin.y+self.temporaryPasswordTF.frame.height+self.view.frame.height/37.055, width: self.newPasswordTF.frame.width, height: self.newPasswordTF.frame.height)
                
            }, completion: { (true) in
                
            })
            
            UIView.animate(withDuration: 1, delay:0.2, options: [], animations: {
                self.verifyNewPasswordTF.frame = CGRect(x: self.verifyNewPasswordTF.frame.origin.x, y: self.newPasswordTF.frame.origin.y+self.newPasswordTF.frame.height+self.view.frame.height/37.055, width: self.verifyNewPasswordTF.frame.width, height: self.verifyNewPasswordTF.frame.height)
                
            }, completion: { (true) in
                
            })
            UIView.animate(withDuration: 1, delay:0.3, options: [], animations: {
                self.continueButton.frame = CGRect(x: self.continueButton.frame.origin.x, y: self.verifyNewPasswordTF.frame.origin.y+self.verifyNewPasswordTF.frame.height+self.view.frame.height/37.055, width: self.continueButton.frame.width, height: self.continueButton.frame.height)
                
            }, completion: { (true) in
                
            })
            

            

            
        }, completion: { (true) in
        })
    }
    
    func cancelAnimation(){
        if temporaryPasswordTF.isFirstResponder || self.newPasswordTF.isFirstResponder || self.verifyNewPasswordTF.isFirstResponder {
            UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
                UIView.animate(withDuration: 1, delay:0, options: [], animations: {
                    self.continueButton.frame = self.continueFrame
                    
                    
                }, completion: { (true) in
                    
                })
                UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                    self.verifyNewPasswordTF.frame = self.verifyPasswordFrame
                    
                    
                }, completion: { (true) in
                    
                })
                UIView.animate(withDuration: 1, delay:0.2, options: [], animations: {
                    self.newPasswordTF.frame = self.newPasswordFrame
                    
                    
                }, completion: { (true) in
                    
                })
                UIView.animate(withDuration: 1, delay:0.3, options: [], animations: {
                    self.temporaryPasswordTF.resignFirstResponder()
                    self.newPasswordTF.resignFirstResponder()
                    self.verifyNewPasswordTF.resignFirstResponder()
                    self.temporaryPasswordTF.frame = self.temporaryTFFrame
                    
                    
                }, completion: { (true) in
                    
                })

                
                
            }, completion: { (true) in
                
            })
            
        }
    }



}
