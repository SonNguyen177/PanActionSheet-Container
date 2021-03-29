//
//  ViewController.swift
//  TestActionSheetAnimation
//
//  Created by SonNH-HAV on 3/16/21.
//

//https://www.swiftkickmobile.com/building-better-app-animations-swift-uiviewpropertyanimator/
//https://github.com/nathangitter/interactive-animations/blob/master/InteractiveAnimations/InteractiveAnimations/ViewController.swift

import UIKit

class ViewController: UIViewController {
    
    let btnShowPopup = UIButton(type: .custom)
    let btnShowModal = UIButton(type: .custom)
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    private func layout() {
       
        view.addSubview(btnShowPopup)
        btnShowPopup.setTitle("Show ActionSheet", for: .normal)
        btnShowPopup.layer.cornerRadius = 8
        btnShowPopup.titleLabel?.textColor = UIColor.white
        btnShowPopup.backgroundColor = .blue
        btnShowPopup.addTarget(self, action: #selector(pressButton), for: .touchUpInside)

        btnShowPopup.translatesAutoresizingMaskIntoConstraints = false
        btnShowPopup.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        btnShowPopup.widthAnchor.constraint(equalToConstant: 180).isActive = true
        btnShowPopup.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btnShowPopup.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80).isActive = true
        
        view.addSubview(btnShowModal)
        btnShowModal.setTitle("Show Modal", for: .normal)
        btnShowModal.layer.cornerRadius = 8
        btnShowModal.titleLabel?.textColor = UIColor.white
        btnShowModal.backgroundColor = .red
        btnShowModal.addTarget(self, action: #selector(pressModal), for: .touchUpInside)

        btnShowModal.translatesAutoresizingMaskIntoConstraints = false
        btnShowModal.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        btnShowModal.widthAnchor.constraint(equalToConstant: 180).isActive = true
        btnShowModal.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btnShowModal.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 126).isActive = true
    }
    
    @objc func pressButton(){
        let vc = CustomViewController()
        SharedActionSheetViewController(custom: vc, preferHeight: 200).show()
    }
    
    @objc func pressModal(){
        let vc = CustomViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
