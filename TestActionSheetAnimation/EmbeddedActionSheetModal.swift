//
//  EmbeddedActionSheetModal.swift
//
//  Created by SonNH-HAV on 3/24/21.
//

import UIKit

private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

protocol SharedActionSheetPresenter : AnyObject {
    
    // set from outer
    func actionSheetWrapperSender(_ handler : EmbeddedActionSheetDelegate?)
    
    // call anywhere notify need close actionSheet
//    func actionSheetShouldDismiss(_ userInfo : Any?)
}



protocol EmbeddedActionSheetDelegate : AnyObject {
    func shouldDismissWith(_ userInfo : Any?)
}

class EmbeddedActionSheetModal: UIViewController, EmbeddedActionSheetDelegate {
    
    //MARK: - Constants
    private var popupOffset: CGFloat = 200
    private let topOffset: CGFloat = 60
    private let minTopOffset: CGFloat = 30
    private let durationAnimate : TimeInterval = 0.7
    private let shortDurationAnimate : TimeInterval = 0.3
    
    //MARK: - Fields
    private var currentState: State = .closed
    
    private var completionDismiss: ((Any?) -> Void)?
    private var userInfo : Any?
    private var headingTitle : String = ""
    
    convenience init(custom: UIViewController , preferHeight: CGFloat?, title: String = "") {
        self.init()
        self.headingTitle = title
        //
        if preferHeight != nil {
            self.popupOffset = preferHeight!
        }
        
        self.addChild(custom)
        contentView = custom.view
        custom.didMove(toParent: self)
        if let handler = custom as? (UIViewController & SharedActionSheetPresenter) {
            // assign handler = this wrapper
            handler.actionSheetWrapperSender(self)
        }
    }
    
    // MARK: - Views
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        return view
    }()
    
    private lazy var swipeImageView: UIImageView = {
        let imv = UIImageView(image: UIImage(named: "ic_menu_up"))
        imv.contentMode = .scaleAspectFit
        return imv
    }()
    
    private lazy var headingLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    // customView
    fileprivate var contentView: UIView!
    private lazy var defaultContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }()
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
//        view.isOpaque = false
        
        layout()
//        popupView.addGestureRecognizer(tapRecognizer)
       // popupView.addGestureRecognizer(panRecognizer)
        
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hide)))
        
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        popupView.addGestureRecognizer(pan)
    }
    
    /*
    // for add view by demand (AddChildController outer)
    func setCustomView(_ custom: UIView, preferHeight: CGFloat) {
        contentView = custom
        self.popupOffset = preferHeight
    }
    
    func setCustomViewController(_ custom: UIViewController, preferHeight: CGFloat?) {
        self.addChild(custom)
        custom.didMove(toParent: self)
        contentView = custom.view
        if preferHeight != nil {
            self.popupOffset = preferHeight!
        }
    }
    */
    
    private var bottomConstraint = NSLayoutConstraint()
    
    fileprivate func getHeaderOffset() -> CGFloat {
        return headingTitle.isEmpty ? minTopOffset : topOffset
    }
    
    private func layout() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        // init with hide 100% height
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset + getHeaderOffset())
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: popupOffset + getHeaderOffset()).isActive = true
        
        let topHeaderView = UIView()
        popupView.addSubview(topHeaderView)
        topHeaderView.translatesAutoresizingMaskIntoConstraints = false
        topHeaderView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 10).isActive = true
        topHeaderView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -10).isActive = true
        topHeaderView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 0).isActive = true
        topHeaderView.heightAnchor.constraint(equalToConstant: getHeaderOffset()).isActive = true
        topHeaderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hide)))
        
        topHeaderView.addSubview(swipeImageView)
        swipeImageView.translatesAutoresizingMaskIntoConstraints = false
        swipeImageView.centerXAnchor.constraint(equalTo: topHeaderView.centerXAnchor).isActive = true
        swipeImageView.topAnchor.constraint(equalTo: topHeaderView.topAnchor, constant: 0).isActive = true
        swipeImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        swipeImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        if !headingTitle.isEmpty {
            headingLabel.text = headingTitle
            topHeaderView.addSubview(headingLabel)
            headingLabel.translatesAutoresizingMaskIntoConstraints = false
            headingLabel.leadingAnchor.constraint(equalTo: topHeaderView.leadingAnchor, constant: 8).isActive = true
            headingLabel.trailingAnchor.constraint(equalTo: topHeaderView.trailingAnchor, constant: -8).isActive = true
            headingLabel.centerXAnchor.constraint(equalTo: topHeaderView.centerXAnchor).isActive = true
            headingLabel.topAnchor.constraint(equalTo: swipeImageView.bottomAnchor, constant: 0).isActive = true
        }
        
     
        popupView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 8).isActive = true
        contentView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -8).isActive = true
        contentView.topAnchor.constraint(equalTo: topHeaderView.bottomAnchor, constant: 0).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: popupOffset).isActive = true
        contentView.layoutIfNeeded()
    }
    
    @objc func show(_ completion: ((Any?) -> Void)? = nil){
        self.completionDismiss = completion
        showInCurrent()
        
        // dismiss xong moi tra ve userInfo
    }
    
    @objc func hide(){
        currentState = .closed
        self.animateTransitionIfNeeded(to: currentState, duration: shortDurationAnimate)
    }
    
    fileprivate func showInCurrent(){
        self.modalPresentationStyle = .overFullScreen
        topViewController()?.present(self, animated: true, completion: nil)
        currentState = .open
        self.animateTransitionIfNeeded(to: currentState, duration: durationAnimate)
    }
    
    fileprivate func topViewController () -> UIViewController? {
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            if let presented = topController.presentedViewController {
                return presented
            } else {
                return topController
            }
        }
        return nil
    }

    //MARK: ActionSheetDelegate
    func shouldDismissWith(_ userInfo: Any?) {
        if let message = userInfo as? String {
            print(message)
        }
        self.userInfo = userInfo
        
        self.hide()
    }
    
    /*
    //MARK: - Tap Gesture
   
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewTapped(recognizer:)))
        return recognizer
    }()
    
    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    @objc private func popupViewTapped(recognizer: UITapGestureRecognizer) {
        let state = currentState.opposite
        let transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = 440
            }
            self.view.layoutIfNeeded()
        })
        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            }
            
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = 440
            }
        }
        transitionAnimator.startAnimation()
    }
 */
    
    //MARK: - Pan Gesture
    
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
   
    /// All of the currently running animators.
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress: CGFloat = 0
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
    
        switch recognizer.state {
        case .began:
            
            // start the animations
            animateTransitionIfNeeded(to: currentState.opposite, duration: durationAnimate)
            
            // pause all animations, since the next event may be a pan changed
            runningAnimators.forEach{$0.pauseAnimation()}
            
            animationProgress = runningAnimators.first?.fractionComplete ?? 0
            //print("animationProgress = \(animationProgress)")
        case .changed:
            
            // variable setup
            let translation = recognizer.translation(in: popupView)
            var fraction = -translation.y / (popupOffset + getHeaderOffset())
            
            // adjust the fraction for the current state and reversed state
            if currentState == .open { fraction *= -1 }
            if runningAnimators[0].isReversed { fraction *= -1 }
            
            // apply the new fraction
            let newComplete =  fraction + animationProgress
            //print("newComplete = \(newComplete)")
            runningAnimators.forEach{$0.fractionComplete = newComplete }
            
        case .ended:
            
            // variable setup
            let yVelocity = recognizer.velocity(in: popupView).y
            let shouldClose = yVelocity > 0
            
            // if there is no motion, continue all animations and exit early
            if yVelocity == 0 {
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
            }
            
            // reverse the animations based on their current state and pan motion
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            }
            
            // continue all animations
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
            
        default:
            ()
        }
    }
    
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
      
        // ensure that the animators array is empty (which implies new animations need to be created)
        guard runningAnimators.isEmpty else { return }
        
        // an animator for the transition
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = 20
            case .closed:
                self.popupView.layer.cornerRadius = 0
                self.bottomConstraint.constant = self.popupOffset + self.getHeaderOffset() // hide all
            }
            //
            self.view.layoutIfNeeded()
        })
        
        // the transition completion block
        transitionAnimator.addCompletion { position in
            // update the state
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            }
            
            // manually reset the constraint positions
            var needDissmiss = false
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.popupOffset + self.getHeaderOffset() // hide all
                needDissmiss = true
            }
            
            // remove all running animators
            self.runningAnimators.removeAll()
            
            if needDissmiss {
                // ActionSheet dismiss xong moi tra ve completion
                self.dismiss(animated: false, completion: {
                    self.completionDismiss?(self.userInfo)
                })
            }
        }
        
        // start all animators
        transitionAnimator.startAnimation()
        
        // keep track of all running animators
        runningAnimators.append(transitionAnimator)
    }
}

// MARK: - InstantPanGestureRecognizer
/// A pan gesture that enters into the `began` state on touch down instead of waiting for a touches moved event.
class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizer.State.began
    }
}


