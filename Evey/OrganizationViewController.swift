//
//  OrganizationViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 01/12/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class OrganizationViewController: UIViewController,UITextFieldDelegate,CAAnimationDelegate {
    @IBOutlet weak var eveyImage: UIImageView!
    @IBOutlet weak var titleLabel: UIImageView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var organizationIDTF: UITextField!
    var upArrow = UIBarButtonItem()
    var downArrow = UIBarButtonItem()
    
    var eveyImageFrame = CGRect()
    var organizationIDFrame = CGRect()
    var continueFrame = CGRect()
    let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    var animationView = UIImageView()
    var animationBackground = UIView()
    var isRotating = false
    var shouldStopRotating = false

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
        
        upArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "UpArrow"), style: .plain, target: self, action: #selector(self.upArrowClicked))
        upArrow.tintColor=UIColor.gray
        downArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "DownArrow"), style: .plain, target: self, action: #selector(self.downArrowClicked))
        downArrow.tintColor=UIColor.gray
        
        let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.items = [upArrow, downArrow, flexibleSpaceWidth, doneButton]
        organizationIDTF.inputAccessoryView = keyboardDoneButtonView
        organizationIDTF.textContentType = UITextContentType("")
        
    }
    
    
    func upArrowClicked(_ sender: Any) {
//        if passwordTF.isFirstResponder {
//            userNameTF.becomeFirstResponder()
//        }
    }
    func downArrowClicked(_ sender: Any) {
//        if userNameTF.isFirstResponder {
//            passwordTF.becomeFirstResponder()
//            
//        }
    }
    
    func dismissKeyboard() {
        
        cancelAnimation()
        
    }
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        
        return (string == filtered)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        animation()
//        UIView.animate(withDuration: 0.3, animations: {
//            let scrollPoint = CGPoint(x: 0, y: self.eveyImage.frame.origin.y+self.eveyImage.bounds.size.height)
//            self.scrollView.setContentOffset(scrollPoint, animated: true)
//            
//        })
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.continueBtn.backgroundColor = #colorLiteral(red: 0.2941176471, green: 0.7568627451, blue: 0.9254901961, alpha: 1)
            //UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
       // scrollView.setContentOffset(CGPoint.zero, animated: true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cancelAnimation()
        continueBtnAction(self)
        return true
    }
    


    @IBAction func continueBtnAction(_ sender: Any) {
        if (organizationIDTF.text?.characters.count)! > 0{
            cancelAnimation()
            
            continueBtn.setTitleColor(UIColor.clear, for: .normal)
            animationBackground.isHidden = false
            
            if self.isRotating == false {
                self.animationView.rotate360Degrees(completionDelegate: self)
                self.isRotating = true
            }

            let organizationID  = organizationIDTF.text?.replacingOccurrences(of: " ", with: "")
            let url:NSURL = NSURL(string: "\(serviceConstants.url)evey/api/client/\((organizationID)!)")!
            let sessionConfig = URLSessionConfiguration.default
            //sessionConfig.timeoutIntervalForRequest = 3.0
           // sessionConfig.timeoutIntervalForResource = 60.0
            let session = URLSession(configuration: sessionConfig)

            //let session = URLSession.shared
            let request = NSMutableURLRequest (url: url as URL)
            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
            if let data = data {
                
                let response = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                print(response)
                DispatchQueue.main.async( execute: {

                let keys = response.allKeys as! [String]
                if keys.contains("client_key"){
                    UserDefaults.standard.set("\(response["client_key"]!)", forKey: "OrganizationID")
                    
                        let logInVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController

                        let transition = CATransition()
                        transition.duration = 0.3
                        transition.type = kCATransitionPush
                        transition.subtype = kCATransitionFromRight
                        self.view.window!.layer.add(transition, forKey: kCATransition)
                        
                        self.present(logInVC, animated: false, completion: { 
                            self.animationBackground.isHidden = true
                            self.shouldStopRotating = true
                            self.continueBtn.setTitleColor(UIColor.white, for: .normal)
                        })
  
                }else{
                    
                    self.animationBackground.isHidden = true
                    self.shouldStopRotating = true
                    self.continueBtn.setTitleColor(UIColor.white, for: .normal)

                    let msg = "Your login does not match our records"
                    let attString = NSMutableAttributedString(string: msg)
                    
                    let popup = PopupDialog(title: "Oops!", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                    }
                    
                    // Create first button
                    let buttonOne = DefaultButton(title: "Try Again") {
                        self.organizationIDTF.text = nil
                        self.animationBackground.isHidden = true
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

        }
        
    }
    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
       
        self.titleLabel.frame = CGRect(x: screenWidth/2.757, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
       
        eveyImage.frame = CGRect(x: screenWidth/10.714, y: titleLabel.frame.origin.y+titleLabel.frame.size.height+screenHeight/5.015, width: screenWidth/1.225, height: screenHeight/3.994)
        
        organizationIDTF.frame = CGRect(x: screenWidth/15, y: eveyImage.frame.origin.y+eveyImage.frame.size.height+screenHeight/6.175, width: screenWidth/1.150, height: screenHeight/11.910)

        continueBtn.frame = CGRect(x: screenWidth/15, y: organizationIDTF.frame.origin.y+organizationIDTF.frame.size.height+screenHeight/37.055, width: screenWidth/1.150, height: screenHeight/11.910)
        
        self.view.addSubview(eveyImage)
        self.view.addSubview(organizationIDTF)
        self.view.addSubview(continueBtn)
        
        self.eveyImageFrame = self.eveyImage.frame
        self.organizationIDFrame = self.organizationIDTF.frame
        self.continueFrame = self.continueBtn.frame
    }
    
    
    func animation(){
        self.titleLabel.alpha = 0.0
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.titleLabel.alpha = 1.0
            
        }) { (true) in
            self.titleLabel.isHidden = false
        }

        UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
            
            self.eveyImage.alpha = 1.0
            UIView.animate(withDuration: 3, delay: 0.01, options: [], animations: {() -> Void in
                self.eveyImage.frame = CGRect(x: self.eveyImage.frame.origin.x, y: (self.titleLabel.frame.origin.y+self.titleLabel.frame.height)+self.view.frame.height/10.106, width: self.eveyImage.frame.width, height: self.eveyImage.frame.height)
                
                self.eveyImage.alpha = 0.0
            }, completion: {(_ finished: Bool) -> Void in
                self.eveyImage.isHidden = true
                
            })
            
            UIView.animate(withDuration: 1, delay:0.0, options: [], animations: {
                
                self.organizationIDTF.frame = CGRect(x: self.organizationIDTF.frame.origin.x, y: (self.titleLabel.frame.origin.y+self.titleLabel.frame.height)+self.view.frame.height/3.605, width: self.organizationIDTF.frame.width, height: self.organizationIDTF.frame.height)
                
            }, completion: { (true) in
                
            })
            UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                self.continueBtn.frame = CGRect(x: self.continueBtn.frame.origin.x, y: self.organizationIDTF.frame.origin.y+self.organizationIDTF.frame.height+self.view.frame.height/37.055, width: self.continueBtn.frame.width, height: self.continueBtn.frame.height)
                
            }, completion: { (true) in
                
            })
            
            
        },completion: { (true) in
            
        })
    }
    
    func cancelAnimation(){
        if organizationIDTF.isFirstResponder{
            self.titleLabel.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                self.titleLabel.alpha = 0.0
            }) { (true) in
                self.titleLabel.isHidden = true
            }
            
            self.eveyImage.alpha = 1.0
            UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
                UIView.animate(withDuration: 1, delay:0, options: [], animations: {
                    self.continueBtn.frame = self.continueFrame
                    UIView.animate(withDuration: 1, delay:0.2, options: [], animations: {
                        
                        self.eveyImage.frame = self.eveyImageFrame
                        
                        self.eveyImage.alpha = 1.0
                        self.eveyImage.isHidden = false
                    }, completion: { (true) in
                    })
                    
                }, completion: { (true) in
                    
                })
                UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                    self.organizationIDTF.frame = self.organizationIDFrame
                    
                }, completion: { (true) in
                    
                })

                self.eveyImage.alpha = 0.0
                UIView.animate(withDuration: 1, delay:0.3, options: [], animations: {
                    self.eveyImage.frame = self.eveyImageFrame
                    self.organizationIDTF.resignFirstResponder()
                    self.eveyImage.alpha = 1.0
                    
                }, completion: { (true) in
                    self.eveyImage.isHidden = false
                })
                
                
                
            }, completion: { (true) in
                
            })
            
        }
    }


}
