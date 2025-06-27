import UIKit
import WebRTC

final class MiniCallView: UIView, RTCVideoViewDelegate {
    var callVC: CallVC
    
    // MARK: UI
    private static let defaultSize: CGFloat = 100
    private let topMargin = (UIWindow.keyWindow?.safeAreaInsets.top ?? 0) + Values.veryLargeSpacing
    private let bottomMargin = UIWindow.keyWindow?.safeAreaInsets.bottom ?? 0
    
    private var widthW: NSLayoutConstraint?
    private var heightH: NSLayoutConstraint?
    private var leftL: NSLayoutConstraint?
    private var rightR: NSLayoutConstraint?
    private var topT: NSLayoutConstraint?
    private var bottomB: NSLayoutConstraint?
    
//#if targetEnvironment(simulator)
//    // Note: 'RTCMTLVideoView' doesn't seem to work on the simulator so use 'RTCEAGLVideoView' instead
//    private lazy var remoteVideoView: RTCEAGLVideoView = {
//        let result = RTCEAGLVideoView()
//        result.delegate = self
//        result.alpha = self.callVC.call.isRemoteVideoEnabled ? 1 : 0
//        result.backgroundColor = .black
//        return result
//    }()
//#else
    private lazy var remoteVideoView: RTCMTLVideoView = {
        let result = RTCMTLVideoView()
        result.delegate = self
        result.alpha = self.callVC.bChatCall.isRemoteVideoEnabled ? 1 : 0
        result.videoContentMode = .scaleAspectFit
        result.backgroundColor = .black
        return result
    }()
//#endif
   
    // MARK: Initialization
    public static var current: MiniCallView?
    
    init(from callVC: CallVC) {
        self.callVC = callVC
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        setUpViewHierarchy()
        setUpGestureRecognizers()
        MiniCallView.current = self
        self.callVC.bChatCall.remoteVideoStateDidChange = { isEnabled in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    self.remoteVideoView.alpha = isEnabled ? 1 : 0
                    if !isEnabled {
                        self.widthW?.constant = MiniCallView.defaultSize
                        self.heightH?.constant = MiniCallView.defaultSize
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(message:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(coder:) instead.")
    }
    
    private func setUpViewHierarchy() {
        self.widthW = self.set(.width, to: MiniCallView.defaultSize)
        self.heightH = self.set(.height, to: MiniCallView.defaultSize)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        // Background
        let background = getBackgroudView()
        self.addSubview(background)
        background.pin(to: self)
        // Remote video view
        callVC.bChatCall.attachRemoteVideoRenderer(remoteVideoView)
        self.addSubview(remoteVideoView)
        remoteVideoView.translatesAutoresizingMaskIntoConstraints = false
        remoteVideoView.pin(to: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideMiniView(_:)), name: .dismissMiniView, object: nil)
    }
    
    private func getBackgroudView() -> UIView {
        let background = UIView()
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 32
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = callVC.bChatCall.profilePicture
        background.addSubview(imageView)
        imageView.set(.width, to: 64)
        imageView.set(.height, to: 64)
        imageView.center(in: background)
        return background
    }
    
    private func setUpGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
        makeViewDraggable()
    }
    
    // MARK: Interaction
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        dismiss()
        guard let presentingVC = CurrentAppContext().frontmostViewController() else { preconditionFailure() } // FIXME: Handle more gracefully
        presentingVC.present(callVC, animated: true, completion: nil)
    }
    
    public func show() {
        self.alpha = 0.0
        let window = CurrentAppContext().mainWindow!
        window.addSubview(self)
        leftL = self.autoPinEdge(toSuperviewEdge: .left)
        leftL?.isActive = false
        rightR = self.autoPinEdge(toSuperviewEdge: .right)
        topT = self.autoPinEdge(toSuperviewEdge: .top, withInset: topMargin)
        bottomB = self.autoPinEdge(toSuperviewEdge: .bottom, withInset: bottomMargin)
        bottomB?.isActive = false
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.alpha = 1.0
        }, completion: nil)
    }
    
    @objc
    public func hideMiniView(_ notification: Notification) {
        dismiss()
    }
    
    public func dismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.callVC.bChatCall.removeRemoteVideoRenderer(self.remoteVideoView)
            self.callVC.setupStateChangeCallbacks()
            MiniCallView.current = nil
            self.removeFromSuperview()
        })
    }
    
    // MARK: RTCVideoViewDelegate
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        let newSize = CGSize(width: min(160.0, 160.0 * size.width / size.height), height: min(160.0, 160.0 * size.height / size.width))
        persistCurrentPosition(newSize: newSize)
        self.widthW?.constant = newSize.width
        self.heightH?.constant = newSize.height
    }
    
    func persistCurrentPosition(newSize: CGSize) {
        let currentCenter = self.center
        
        if currentCenter.x < self.superview!.width() / 2 {
            leftL?.isActive = true
            rightR?.isActive = false
        } else {
            leftL?.isActive = false
            rightR?.isActive = true
        }
        
        let willTouchTop = currentCenter.y < newSize.height / 2 + topMargin
        let willTouchBottom = currentCenter.y + newSize.height / 2 >= self.superview!.height()
        if willTouchBottom {
            topT?.isActive = false
            bottomB?.isActive = true
        } else {
            let constant = willTouchTop ? topMargin : currentCenter.y - newSize.height / 2
            topT?.constant = constant
            topT?.isActive = true
            bottomB?.isActive = false
        }
    }

}
