import NVActivityIndicatorView

@objc(SNVoiceMessageView)
public final class VoiceMessageView : UIView {
    private let viewItem: ConversationViewItem
    private var isShowingSpeedUpLabel = false
    @objc var progress: Int = 0 { didSet { handleProgressChanged() } }
    @objc var isPlaying = false { didSet { handleIsPlayingChanged() } }

    private lazy var progressViewRightConstraint = progressView.pin(.right, to: .right, of: audioWavesImageView, withInset: -52)

    private var attachment: TSAttachment? { viewItem.attachmentStream ?? viewItem.attachmentPointer }
    private var duration: Int { Int(viewItem.audioDurationSeconds) }

    // MARK: UI Components
    private lazy var progressView: UIView = {
        let result = UIView()
        result.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        result.layer.cornerRadius = 22
        return result
    }()

    private lazy var toggleImageView: UIImageView = {
        var result = UIImageView(image: UIImage(named: "ic_playNew"))
        if viewItem.interaction is TSIncomingMessage {
            let tint = Colors.titleColor
            result = UIImageView(image: UIImage(named: "ic_playNew")?.withTint(tint))
        }
        result.set(.width, to: 14)
        result.set(.height, to: 14)
        result.contentMode = .scaleAspectFit
        return result
    }()

    private lazy var loader: NVActivityIndicatorView = {
        let result = NVActivityIndicatorView(frame: CGRect.zero, type: .circleStrokeSpin, color: Colors.text, padding: nil)
        result.set(.width, to: VoiceMessageView.toggleContainerSize + 2)
        result.set(.height, to: VoiceMessageView.toggleContainerSize + 2)
        return result
    }()

    private lazy var countdownLabelContainer: UIView = {
        let result = UIView()
        result.backgroundColor = .clear
        result.layer.masksToBounds = true
        result.set(.height, to: VoiceMessageView.toggleContainerSize)
        result.set(.width, to: 44)
        return result
    }()

    private lazy var countdownLabel: UILabel = {
        let result = UILabel()
        result.textColor = .white
        if viewItem.interaction is TSIncomingMessage {
            let tint = Colors.titleColor
            result.textColor = tint
        }
        result.font = Fonts.OpenSans(ofSize: 11)
        result.text = "0:00"
        return result
    }()

    private lazy var speedUpLabel: UILabel = {
        let result = UILabel()
        result.textColor = .black
        result.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        result.alpha = 0
        result.text = "1.5x"
        result.textAlignment = .center
        return result
    }()
    
    private lazy var audioWavesImageView: UIImageView = {
        var result = UIImageView(image: UIImage(named: "ic_audioWaves"))
        if viewItem.interaction is TSIncomingMessage {
            let tint = Colors.titleColor
            result = UIImageView(image: UIImage(named: "ic_audioWaves")?.withTint(tint))
        }
        result.set(.height, to: 24)
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    

    // MARK: Settings
    private static let width: CGFloat = 200
    private static let toggleContainerSize: CGFloat = 20
    private static let inset = Values.smallSpacing

    // MARK: Lifecycle
    init(viewItem: ConversationViewItem) {
        self.viewItem = viewItem
        self.progress = Int(viewItem.audioProgressSeconds)
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
        handleProgressChanged()
    }

    override init(frame: CGRect) {
        preconditionFailure("Use init(viewItem:) instead.")
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(viewItem:) instead.")
    }

    private func setUpViewHierarchy() {
        let toggleContainerSize = VoiceMessageView.toggleContainerSize
        let inset = VoiceMessageView.inset
        // Width & height
        set(.width, to: VoiceMessageView.width)
        set(.height, to: 44)
        // Toggle
        let toggleContainer = UIView()
        toggleContainer.backgroundColor = .clear
        toggleContainer.set(.width, to: toggleContainerSize)
        toggleContainer.set(.height, to: toggleContainerSize)
        toggleContainer.addSubview(toggleImageView)
        toggleImageView.center(in: toggleContainer)
        toggleContainer.layer.cornerRadius = toggleContainerSize / 2
        toggleContainer.layer.masksToBounds = true
        
        addSubview(audioWavesImageView)
        audioWavesImageView.pin(.left, to: .left, of: self, withInset: 28)
        audioWavesImageView.pin(.right, to: .right, of: self, withInset: -52)
        audioWavesImageView.center(.vertical, in: self)
        // Line
        let lineView = UIView()
        lineView.backgroundColor = .clear
        lineView.set(.height, to: 1)
        // Countdown label
        countdownLabelContainer.addSubview(countdownLabel)
        countdownLabel.center(in: countdownLabelContainer)
        // Speed up label
        countdownLabelContainer.addSubview(speedUpLabel)
        speedUpLabel.center(in: countdownLabelContainer)
        // Constraints
        addSubview(progressView)
        progressView.pin(.left, to: .left, of: self, withInset: 28)
        progressView.pin(.top, to: .top, of: self)
        progressView.pin(.bottom, to: .bottom, of: self)
        addSubview(toggleContainer)
        toggleContainer.pin(.left, to: .left, of: self, withInset: inset)
        toggleContainer.pin(.top, to: .top, of: self, withInset: inset)
        toggleContainer.pin(.bottom, to: .bottom, of: self, withInset: -inset)
        addSubview(lineView)
        lineView.pin(.left, to: .right, of: toggleContainer)
        lineView.center(.vertical, in: self)
        addSubview(countdownLabelContainer)
        countdownLabelContainer.pin(.left, to: .right, of: lineView)
        countdownLabelContainer.pin(.right, to: .right, of: self, withInset: -inset)
        countdownLabelContainer.center(.vertical, in: self)
        addSubview(loader)
        loader.center(in: toggleContainer)
        progressViewRightConstraint.isActive = true
    }

    // MARK: Updating
    public override func layoutSubviews() {
        super.layoutSubviews()
        countdownLabelContainer.layer.cornerRadius = countdownLabelContainer.bounds.height / 2
    }

    private func handleIsPlayingChanged() {
        toggleImageView.image = isPlaying ? UIImage(named: "ic_pauseNew") : UIImage(named: "ic_playNew")
        if viewItem.interaction is TSIncomingMessage {
            if isLightMode {
                let tint = UIColor(hex: 0x333333)
                toggleImageView.image = isPlaying ? UIImage(named: "ic_pauseNew")?.withTint(tint) : UIImage(named: "ic_playNew")?.withTint(tint)
            }
        }
        if !isPlaying { progress = 0 }
    }

    private func handleProgressChanged() {
        let isDownloaded = (attachment?.isDownloaded == true)
        loader.isHidden = isDownloaded
        if isDownloaded { loader.stopAnimating() } else if !loader.isAnimating { loader.startAnimating() }
        guard isDownloaded else { return }
        countdownLabel.text = OWSFormat.formatDurationSeconds(duration - progress)
        guard viewItem.audioProgressSeconds > 0 && viewItem.audioDurationSeconds > 0 else {
            toggleImageView.image = isPlaying ? UIImage(named: "ic_pauseNew") : UIImage(named: "ic_playNew")
            if viewItem.interaction is TSIncomingMessage {
                if isLightMode {
                    let tint = UIColor(hex: 0x333333)
                    toggleImageView.image = isPlaying ? UIImage(named: "ic_pauseNew")?.withTint(tint) : UIImage(named: "ic_playNew")?.withTint(tint)
                }
            }
            return progressViewRightConstraint.constant = -120
        }
        let fraction = viewItem.audioProgressSeconds / viewItem.audioDurationSeconds
        progressViewRightConstraint.constant = -(120 * (1 - fraction))
        toggleImageView.image = isPlaying ? UIImage(named: "ic_pauseNew") : UIImage(named: "ic_playNew")
        if viewItem.interaction is TSIncomingMessage {
            if isLightMode {
                let tint = UIColor(hex: 0x333333)
                toggleImageView.image = isPlaying ? UIImage(named: "ic_pauseNew")?.withTint(tint) : UIImage(named: "ic_playNew")?.withTint(tint)
            }
        }
    }

    func showSpeedUpLabel() {
        guard !isShowingSpeedUpLabel else { return }
        isShowingSpeedUpLabel = true
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.countdownLabel.alpha = 0
            self.speedUpLabel.alpha = 1
        }
        Timer.scheduledTimer(withTimeInterval: 1.25, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.25, animations: {
                guard let self = self else { return }
                self.countdownLabel.alpha = 1
                self.speedUpLabel.alpha = 0
            }, completion: { _ in
                self?.isShowingSpeedUpLabel = false
            })
        }
    }
}
