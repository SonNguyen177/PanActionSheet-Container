//
//  CustomViewController.swift
//  TestActionSheetAnimation
//
//  Created by SonNH-HAV on 3/29/21.
//

import UIKit

class CustomViewController: UIViewController, SharedActionSheetPresenter {
    
    
    var wrapper : SharedActionSheetDelegate?
    func actionSheetWrapperSender(_ handler: SharedActionSheetDelegate?) {
        wrapper = handler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .red
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
        let label = UILabel(frame: CGRect(x: 0, y: 80, width: self.view.bounds.size.width, height: 40))
        label.text = "Hi, Action sheet wrapper!"
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(label)
    }
    
    @objc func tapped() {
        print(#function)
        if let actionSheetMode = wrapper {
            wrapper?.shouldDismissWith("We don't talk any more!")
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
