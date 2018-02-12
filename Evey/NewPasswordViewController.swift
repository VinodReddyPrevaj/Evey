//
//  NewPasswordViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 10/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class NewPasswordViewController: UIViewController,UITextFieldDelegate{
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
    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
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
        let svc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController")as! SignInViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(svc, animated: false, completion: {
            
        })

        
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
        
        

        temporaryPasswordTF.frame = CGRect(x: screenWidth/8.152, y:self.titleLabel.frame.origin.y+self.titleLabel.frame.height+self.view.frame.size.height/2.575, width: scrollView.frame.size.width, height: self.view.frame.size.height/11.910)

        newPasswordTF.frame = CGRect(x: screenWidth/8.152, y: temporaryPasswordTF.frame.origin.y+temporaryPasswordTF.frame.size.height+self.view.frame.size.height/35.055, width: scrollView.frame.size.width, height: self.view.frame.size.height/11.910)

        verifyNewPasswordTF.frame = CGRect(x: screenWidth/8.152, y: newPasswordTF.frame.origin.y+newPasswordTF.frame.size.height+self.view.frame.size.height/35.055, width: scrollView.frame.size.width, height: self.view.frame.size.height/11.910)

        continueButton.frame = CGRect(x: screenWidth/8.152, y: verifyNewPasswordTF.frame.origin.y+verifyNewPasswordTF.frame.size.height+self.view.frame.size.height/35.055, width: scrollView.frame.size.width, height: self.view.frame.size.height/11.910)
        
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
