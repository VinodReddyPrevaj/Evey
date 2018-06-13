//
//  ResetLogInViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 10/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class ResetLogInViewController: UIViewController ,UITextFieldDelegate,CAAnimationDelegate{
    
    // for spinning animation on Button
    
    var isRotating = false
    var shouldStopRotating = false

    var upArrow = UIBarButtonItem()
    var downArrow = UIBarButtonItem()

    @IBOutlet weak var titleLabel: UIImageView!
    
    @IBOutlet weak var resetLoginButton: UIButton!
    @IBOutlet weak var userNameTF: UITextField!

    @IBOutlet weak var scrollView: UIScrollView!
    
    var userNameframe = CGRect()
    var resetLogInFrame = CGRect()
    
    var animationBackground = UIView()
    var animationView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
        doneButton.tintColor = #colorLiteral(red: 0.2941176471, green: 0.7568627451, blue: 0.9254901961, alpha: 1)
        
        
        animationBackground.frame = CGRect(x: 3, y: 3, width: resetLoginButton.frame.width-6, height: resetLoginButton.frame.height-6)
        animationBackground.backgroundColor = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 0.8862745098, alpha: 1)
        resetLoginButton.addSubview(animationBackground)
        animationBackground.isHidden = true
        
        animationView.image = UIImage(named: "spinner")
        animationView.frame = CGRect(x: 0, y: 0, width: resetLoginButton.frame.height/2, height: resetLoginButton.frame.height/2)
        animationView.center = animationBackground.center
        self.animationBackground.addSubview(animationView)


        
        upArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "UpArrow"), style: .plain, target: self, action: #selector(self.upArrowClicked))
        upArrow.tintColor=UIColor.gray
        
        downArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "DownArrow"), style: .plain, target: self, action: #selector(self.downArrowClicked))
        downArrow.tintColor=UIColor.gray
        
        let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.items = [upArrow, downArrow, flexibleSpaceWidth, doneButton]
        userNameTF.inputAccessoryView = keyboardDoneButtonView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        userNameTF.textContentType = UITextContentType("")


    }

    @IBAction func resetLoginAction(_ sender: Any) {
        dismissKeyboard()
        resetLoginButton.setTitleColor(UIColor.clear, for: .normal)
        animationBackground.isHidden = false
        
        if self.isRotating == false {
            self.animationView.rotate360Degrees(completionDelegate: self)
            self.isRotating = true
        }

        let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/reset/user/\((userNameTF.text)!)")!
        let session = URLSession.shared
        let request = NSMutableURLRequest (url: url as URL)
        request.httpMethod = "Get"
        //http://13.58.78.59:4200/orgID/api/reset/user/:username
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
            if let data = data {
                
                let response = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                DispatchQueue.main.async( execute: {
                    print(response)
                    if response.value(forKey: "success") as! Bool == true {
                        let msg = "Email Deliver a temporary password"
                        let attString = NSMutableAttributedString(string: msg)
                        self.animationBackground.isHidden = true
                        self.shouldStopRotating = true
                        self.resetLoginButton.setTitleColor(UIColor.white, for: .normal)

                        let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                        }
                        
                        // Create first button
                        let buttonOne = DefaultButton(title: "OK") {
                            let NPVC = self.storyboard?.instantiateViewController(withIdentifier :"NewPasswordViewController") as? NewPasswordViewController
                            
                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromRight
                            self.view.window!.layer.add(transition, forKey: kCATransition)

                            self.present(NPVC!, animated: false, completion:{

                            })
                            
                        }
                        popup.addButtons([buttonOne])
                        
                        self.present(popup, animated: true, completion: nil)

                    }else{
                        self.animationBackground.isHidden = true
                        self.shouldStopRotating = true
                        self.resetLoginButton.setTitleColor(UIColor.white, for: .normal)

                        let msg = "Your details does not match with our records"
                        let attString = NSMutableAttributedString(string: msg)
                        
                        
                        
                        
                        let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                        }
                        
                        // Create first button
                        let buttonOne = DefaultButton(title: "Try again") {
                        }
                        popup.addButtons([buttonOne])
                        
                        self.present(popup, animated: true, completion: {

                        })
  
                    }
                    
                    
                    
                    
                })
            }
        }
        task.resume()


    }
    func upArrowClicked(_ sender: Any) {
    }
    func downArrowClicked(_ sender: Any) {
    }

    func dismissKeyboard() {
        cancelAnimation()
        
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        animation()
       // titleLabel.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
          //  let scrollPoint = CGPoint(x: 0, y: self.view.frame.size.height/3.2)
           // self.scrollView.setContentOffset(scrollPoint, animated: true)
            
        })
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
       // titleLabel.isHidden = true
        
       // self.continueBtn.backgroundColor = UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cancelAnimation()
        resetLoginAction(self)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }


    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        self.titleLabel.frame = CGRect(x: screenWidth/2.757, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        self.scrollView.frame = CGRect(x: screenWidth/8.152, y: titleLabel.frame.origin.y+titleLabel.frame.size.height+screenHeight/5.442, width: screenWidth/1.329, height: screenHeight/1.472)
        self.scrollView.isHidden = true
        
        userNameTF.frame = CGRect(x: screenWidth/15, y:self.titleLabel.frame.origin.y+self.titleLabel.frame.height+screenHeight/1.638, width: screenWidth/1.150, height: screenHeight/11.910)

        resetLoginButton.frame = CGRect(x: screenWidth/15, y: userNameTF.frame.origin.y+userNameTF.frame.size.height+screenHeight/37.055, width: screenWidth/1.150, height: screenHeight/11.910)
        
        self.view.addSubview(userNameTF)
        self.view.addSubview(resetLoginButton)
        
        self.userNameframe = self.userNameTF.frame
        self.resetLogInFrame = self.resetLoginButton.frame
        
    }
    func animation(){
        UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
            
            UIView.animate(withDuration: 1, delay:0.0, options: [], animations: {
                
                self.userNameTF.frame = CGRect(x: self.userNameTF.frame.origin.x, y: (self.titleLabel.frame.origin.y+self.titleLabel.frame.height)+self.view.frame.height/4.042, width: self.userNameTF.frame.width, height: self.userNameTF.frame.height)
                
            }, completion: { (true) in
                
            })
            UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                self.resetLoginButton.frame = CGRect(x: self.resetLoginButton.frame.origin.x, y: self.userNameTF.frame.origin.y+self.userNameTF.frame.height+self.view.frame.height/37.055, width: self.resetLoginButton.frame.width, height: self.resetLoginButton.frame.height)
                
            }, completion: { (true) in

            })
            
            
            
        }, completion: { (true) in

        })
    }
    
    func cancelAnimation(){
        if userNameTF.isFirstResponder{
            UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
                UIView.animate(withDuration: 1, delay:0, options: [], animations: {
                    self.resetLoginButton.frame = self.resetLogInFrame

                    
                }, completion: { (true) in
                    
                })
                UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                    self.userNameTF.frame = self.userNameframe
                    self.userNameTF.resignFirstResponder()


                }, completion: { (true) in
                    
                })
                
                
                
            }, completion: { (true) in
                
            })
            
        }
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


}
