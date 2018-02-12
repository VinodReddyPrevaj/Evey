//
//  SplashViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 15/12/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animation()
    }
    
    func animation(){
        UIView.animate(withDuration: 0.5, delay: 0.02, options: [], animations: {
            self.imageView.alpha = 0.3
        }) { (true) in
            UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                self.imageView.alpha = 1.0
            }, completion: { (true) in
                UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                    self.imageView.alpha = 0.3
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                        self.imageView.alpha = 1.0
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                            self.imageView.alpha = 0.3
                        }, completion: { (true) in
                            UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                                self.imageView.alpha = 1.0
                            }, completion: { (true) in
                                UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                                    self.imageView.alpha = 0.3
                                }, completion: { (true) in
                                    UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                                        self.imageView.alpha = 1.0
                                    }, completion: { (true) in
                                        UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                                            self.imageView.alpha = 0.3
                                        }, completion: { (true) in
                                            UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                                                self.imageView.alpha = 1.0
                                            }, completion: { (true) in
                                                UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                                                    self.imageView.alpha = 0.3
                                                }, completion: { (true) in
                                                    UIView.animate(withDuration: 0.5, delay:0, options: .curveEaseIn, animations: {
                                                        self.imageView.alpha = 1.0
                                                    }, completion: { (true) in
                                                    })
                                                    
                                                })

                                            })
                                            
                                        })

                                    })
                                    
                                })

                            })
                            
                        })
 
                    })
                    
                })
            })
        }

    }

}
