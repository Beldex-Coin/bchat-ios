// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit


class CallView : UIView {
    
    lazy var callView: UIView = {
        let result = UIView()
        result.backgroundColor = Colors.bothGreenColor
        result.set(.height, to: 32)
        return result
    }()
    
    lazy var callInfoLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothWhiteColor
        result.font = Fonts.semiOpenSans(ofSize: 10)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Tap to Return to the Call"
        return result
    }()
    
    lazy var callIconImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "Outgoing_Call_top_banner")//Outgoing_Call_top_banner_decline
        result.set(.width, to: 18)
        result.set(.height, to: 18)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    var duration: Int = 0
    
    init() {
        super.init(frame: CGRect.zero)
        setUpView()
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(message:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(coder:) instead.")
    }
    
    
    
    func setUpView() {
        addSubview(callView)
        callView.addSubViews(callInfoLabel, callIconImageView)
        callView.pin(.top, to: .top, of: self, withInset: 0)
        callView.pin(.left, to: .left, of: self, withInset: 0)
        callView.pin(.right, to: .right, of: self, withInset: 0)
        NSLayoutConstraint.activate([
            callInfoLabel.centerYAnchor.constraint(equalTo: callView.centerYAnchor),
            callInfoLabel.leadingAnchor.constraint(equalTo: callView.leadingAnchor, constant: 16),
            callIconImageView.centerYAnchor.constraint(equalTo: callView.centerYAnchor),
            callIconImageView.trailingAnchor.constraint(equalTo: callView.trailingAnchor, constant: -20),
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectingCallShowViewTapped), name: .connectingCallShowViewNotification, object: nil)
    }
    
    
    @objc func connectingCallShowViewTapped(notification: NSNotification) {
        duration += 1
        if !String(format: "%.2d:%.2d", duration/60, duration%60).isEmpty {
            callInfoLabel.text = "\(String(format: "%.2d:%.2d", duration/60, duration%60)) Person in call"
            callIconImageView.image = UIImage(named: "End_Call_new")
            callIconImageView.set(.width, to: 18)
            callIconImageView.set(.height, to: 18)
            callIconImageView.layer.masksToBounds = true
            callIconImageView.contentMode = .scaleAspectFit
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleCallDeclineTapped(_:)))
            tap.cancelsTouchesInView = false
            callIconImageView.addGestureRecognizer(tap)
        } else {
            if let recognizers = callIconImageView.gestureRecognizers {
              for recognizer in recognizers {
                  callIconImageView.removeGestureRecognizer(recognizer)
              }
            }
        }
    }
    
    
    @objc func handleCallDeclineTapped(_ sender: UITapGestureRecognizer? = nil) {
        if let call = AppEnvironment.shared.callManager.currentCall {
            AppEnvironment.shared.callManager.endCall(call) { error in
                if let _ = error {
                    call.endBChatCall()
                    AppEnvironment.shared.callManager.reportCurrentCallEnded(reason: nil)
                }
            }
        }
    }
    
    
}
