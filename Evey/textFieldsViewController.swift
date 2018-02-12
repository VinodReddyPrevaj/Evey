//
//  textFieldsViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 12/12/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class textFieldsViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var evey: UIImageView!
    
    @IBOutlet weak var userNameTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    var userfloat =  CGRect()
    var passfloat =  CGRect()
    var continuefloat =  CGRect()
    var eveyfloat =  CGRect()
    var frameView  = UIView()
    var upArrow = UIBarButtonItem()
    var downArrow = UIBarButtonItem()
    let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        userfloat = userNameTF.frame
        passfloat = passwordTF.frame
        continuefloat = continueBtn.frame
        eveyfloat = evey.frame
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyBoard))
        doneButton.tintColor = UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
        
        upArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "UpArrow"), style: .plain, target: self, action: #selector(self.upArrowClicked))
        upArrow.tintColor=UIColor.gray
        downArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "DownArrow"), style: .plain, target: self, action: #selector(self.downArrowClicked))
        downArrow.tintColor=UIColor.gray
        
        let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.items = [upArrow, downArrow, flexibleSpaceWidth, doneButton]
        userNameTF.inputAccessoryView = keyboardDoneButtonView
        passwordTF.inputAccessoryView = keyboardDoneButtonView

        
//        self.frameView = UIView(frame: CGRect(x:0, y:0, width:self.view.bounds.width, height:self.view.bounds.height))
//        
//        
//        // Keyboard stuff.
//        let center: NotificationCenter = NotificationCenter.default
//        center.addObserver(self, selector: #selector(textFieldsViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        center.addObserver(self, selector: #selector(textFieldsViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

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

//    override func viewWillDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
//
//    
//    
//    func keyboardWillShow(notification: NSNotification) {
//        UIView.animate(withDuration: 30, delay: 0, options: [], animations: {
//        
//        let info = notification.userInfo! as NSDictionary
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//        
//        let keyboardHeight: CGFloat = keyboardSize.height
//        
//        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat
//        
//        
//        UIView.animate(withDuration: 3, delay: 0, options: [], animations: {
//            UIView.animate(withDuration: 3, delay: 0, options: [], animations: { 
//                self.userNameTF.frame = CGRect(x:self.userNameTF.frame.origin.x, y:175, width:self.userNameTF.frame.width, height:56)
//
//            }, completion: { (true) in
//                
//            })
//            UIView.animate(withDuration: 3, delay: 0.2, options: [], animations: {
//                self.passwordTF.frame = CGRect(x:self.userNameTF.frame.origin.x, y:249, width:self.userNameTF.frame.width, height:56)
//
//            }, completion: { (true) in
//                
//            })
//            UIView.animate(withDuration: 3, delay: 0.4, options: [], animations: {
//                self.continueBtn.frame = CGRect(x:self.userNameTF.frame.origin.x, y:322, width:self.userNameTF.frame.width, height:56)
//                
//            }, completion: { (true) in
//                
//            })
//
//        }, completion: nil)
//            
//        }) { (true) in
//            
//        }
//        
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        let info = notification.userInfo! as NSDictionary
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//        
//        let keyboardHeight: CGFloat = keyboardSize.height
//        
//        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat
//        
//        UIView.animate(withDuration: 3, delay: 0.25, options: UIViewAnimationOptions.curveEaseInOut, animations: {
//            self.frameView.frame = CGRect(x:0, y:(self.frameView.frame.origin.y + keyboardHeight), width:self.view.bounds.width, height:self.view.bounds.height)
//        }, completion: nil)
//        
//    }

    override func viewDidAppear(_ animated: Bool) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyBoard))
        view.addGestureRecognizer(tap)

    }

    func dismissKeyBoard(){
        if userNameTF.isFirstResponder||passwordTF.isFirstResponder{
        self.evey.alpha = 1.0
        UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
            UIView.animate(withDuration: 1, delay:0, options: [], animations: {
                self.continueBtn.frame = self.continuefloat
                UIView.animate(withDuration: 1, delay:0.3, options: [], animations: {
                    self.evey.frame = self.eveyfloat
                    
                    self.evey.alpha = 1.0
                    self.evey.isHidden = false
                }, completion: { (true) in
                })

            }, completion: { (true) in
                
            })
            UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                self.userNameTF.resignFirstResponder()
                self.passwordTF.resignFirstResponder()
                self.passwordTF.frame = self.passfloat
                
            }, completion: { (true) in
                
            })
            UIView.animate(withDuration: 1, delay:0.2, options: [], animations: {
                self.userNameTF.frame = self.userfloat
                
            }, completion: { (true) in
                
            })
            self.evey.alpha = 0.0
            UIView.animate(withDuration: 1, delay:0.3, options: [], animations: {
                self.evey.frame = self.eveyfloat
                
                self.evey.alpha = 1.0
                
            }, completion: { (true) in
                self.evey.isHidden = false
            })



        }, completion: { (true) in
            
        })

        }
    }

    
    @IBAction func continueAction(_ sender: Any) {
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
     //   if userNameTF.isFirstResponder || passwordTF.isFirstResponder{

            UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {

                self.evey.alpha = 1.0
                UIView.animate(withDuration: 0.8, delay: 0, options: [], animations: {() -> Void in
                    self.evey.frame = CGRect(x: self.eveyfloat.origin.x, y: 175-119, width: self.evey.frame.width, height: self.evey.frame.height)

                    self.evey.alpha = 0.0
                }, completion: {(_ finished: Bool) -> Void in
                    self.evey.isHidden = true
        
                })

                UIView.animate(withDuration: 1, delay:0.0, options: [], animations: {

                    self.userNameTF.frame = CGRect(x: self.userNameTF.frame.origin.x, y: 175, width: self.userNameTF.frame.width, height: self.userNameTF.frame.height)
        
                }, completion: { (true) in
        
                })
                UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                    self.passwordTF.frame = CGRect(x: self.passwordTF.frame.origin.x, y: 249, width: self.passwordTF.frame.width, height: self.passwordTF.frame.height)
        
                }, completion: { (true) in

                })


                UIView.animate(withDuration: 1, delay:0.2, options: [], animations: {
                    self.continueBtn.frame = CGRect(x: self.continueBtn.frame.origin.x, y: 322, width: self.continueBtn.frame.width, height: self.continueBtn.frame.height)
                }, completion: { (true) in
                })

            }, completion: { (true) in
            })
      //  }
    }
   
    
    
    
//    func textFieldDidBeginEditing(_ textField: UITextField) { // became first responder
//        
//        //move textfields up
//        let myScreenRect: CGRect = self.view.frame
//        
//        let keyboardHeight : CGFloat = 216
//        
//        UIView.beginAnimations( "animateView", context: nil)
//        var movementDuration:TimeInterval = 0.35
//        var needToMove: CGFloat = 0
//        
//        var frame : CGRect = self.view.frame
//        if (self.passwordTF.frame.origin.y + self.passwordTF.frame.size.height + /*self.navigationController.navigationBar.frame.size.height + */UIApplication.shared.statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight)) {
//            needToMove = (continueBtn.frame.origin.y + continueBtn.frame.size.height + /*self.navigationController.navigationBar.frame.size.height +*/ UIApplication.shared.statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight);
//        }
//        
//        //frame.origin.y = -needToMove
//            if userNameTF.isFirstResponder{
//                self.passwordTF.resignFirstResponder()
//            }else{
//                self.userNameTF.resignFirstResponder()
//            }
//        
//        UIView.setAnimationDuration(0.3)
//        UIView.animate(withDuration: 1.0, delay: 0, options: [], animations: {
//                            self.evey.alpha = 1.0
//                            UIView.animate(withDuration: 0.8, delay: 0, options: [], animations: {() -> Void in
//                                self.evey.frame = CGRect(x: self.eveyfloat.origin.x, y: 56, width: self.evey.frame.width, height: self.evey.frame.height)
//            
//                                self.evey.alpha = 0.0
//                            }, completion: {(_ finished: Bool) -> Void in
//                                self.evey.isHidden = true
//                    
//                            })
//   
//        UIView.animate(withDuration: 1, delay: 0.1, options: [], animations: {
//            self.userNameTF.frame = CGRect(x: self.userNameTF.frame.origin.x, y: 175, width: self.userNameTF.frame.width, height: self.userNameTF.frame.height)
//        }) { (true) in
//            
//        }
//            UIView.animate(withDuration: 1, delay: 0.2, options: [], animations: {
//                self.passwordTF.frame = CGRect(x: self.userNameTF.frame.origin.x, y: 249, width: self.userNameTF.frame.width, height: self.userNameTF.frame.height)
//            }) { (true) in
//            }
//
//            UIView.animate(withDuration: 1, delay: 0.3, options: [], animations: {
//                self.continueBtn.frame = CGRect(x: self.userNameTF.frame.origin.x, y: 322, width: self.userNameTF.frame.width, height: self.userNameTF.frame.height)
//            }) { (true) in
//                UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
//                   // self.view.frame = frame
//                    UIView.commitAnimations()
//
//                }, completion: { (true) in
//                    
//                })
//            }
//
//        }) { (true) in
//        }
//
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        //move textfields back down
//        UIView.beginAnimations( "animateView", context: nil)
//        var movementDuration:TimeInterval = 0.35
//        var frame : CGRect = self.view.frame
//        frame.origin.y = 0
//        self.view.frame = frame
//        UIView.commitAnimations()
//    }
//   
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        
//        passwordTF.resignFirstResponder()
//        //continueButtonTapOn(self)
//        return true
//    }
    
    
    
    
    

   

}
