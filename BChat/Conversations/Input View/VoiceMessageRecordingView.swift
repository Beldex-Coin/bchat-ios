import BChatUIKit
import SignalUtilitiesKit

final class VoiceMessageRecordingView : UIView {
    
    private let voiceMessageButtonFrame: CGRect
    private weak var delegate: VoiceMessageRecordingViewDelegate?
    private let onLocked: (() -> Void)?
    private var isLocked = false
    private lazy var heightConstraint = set(.height, to: VoiceMessageRecordingView.recordingHeight)
    private lazy var slideToCancelStackViewRightConstraint = slideToCancelStackView.pin(.right, to: .right, of: self)
    private lazy var slideToCancelLabelCenterHorizontalConstraint = slideToCancelLabel.centerWithInset(.horizontal, in: self, inset: 60)
    private lazy var pulseViewWidthConstraint = pulseView.set(.width, to: VoiceMessageRecordingView.circleSize)
    private lazy var pulseViewHeightConstraint = pulseView.set(.height, to: VoiceMessageRecordingView.circleSize)
    private lazy var lockViewBottomConstraint = lockView.pin(.bottom, to: .top, of: circleView, withInset: 0)
    private let recordingStartDate = Date()
    private var recordingTimer: Timer?
    private var iconLeftConstraint: NSLayoutConstraint?
    private var iconTopConstraint: NSLayoutConstraint?
    var timerSecond = 0
    
    var timerSecondForConstraintOfProgressView = 0

    // MARK: UI Components
    private lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "icons8-microphone")!.withTint(.white)
        result.contentMode = .scaleAspectFit
        let size = VoiceMessageRecordingView.iconSize
        result.set(.width, to: size)
        result.set(.height, to: size)
        return result
    }()

    private lazy var circleView: UIView = {
        let result = UIView()
        result.backgroundColor = Colors.destructive
        let size = VoiceMessageRecordingView.circleSize
        result.set(.width, to: size)
        result.set(.height, to: size)
        result.layer.cornerRadius = size / 2
        result.layer.masksToBounds = true
        return result
    }()

    private lazy var pulseView: UIView = {
        let result = UIView()
        result.backgroundColor = Colors.destructive
        result.layer.cornerRadius = VoiceMessageRecordingView.circleSize / 2
        result.layer.masksToBounds = true
        result.alpha = 0.5
        return result
    }()
    
    private lazy var rightAccessoryBackgroundView: UIView = {
        let result = UIView()
        result.backgroundColor = Colors.homeScreenFloatingbackgroundColor
        result.layer.cornerRadius = VoiceMessageRecordingView.rightAccessoryBackgroundWidth / 2
        result.clipsToBounds = true
        return result
    }()

    private lazy var slideToCancelStackView: UIStackView = {
        let result = UIStackView()
        result.axis = .horizontal
        result.spacing = Values.smallSpacing
        result.alignment = .trailing
        return result
    }()

    private lazy var chevronImageView: UIImageView = {
        let chevronSize = VoiceMessageRecordingView.chevronSize
        let chevronColor = (isLightMode ? UIColor.black : UIColor.white).withAlphaComponent(Values.mediumOpacity)
        let result = UIImageView(image: UIImage(named: "small_chevron_left")!.withTint(chevronColor))
        result.contentMode = .scaleAspectFit
        result.set(.width, to: chevronSize)
        result.set(.height, to: chevronSize)
        return result
    }()

    private lazy var slideToCancelLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("vc_conversation_voice_message_cancel_message", comment: "")
        result.font = Fonts.regularOpenSans(ofSize: Values.smallFontSize)
        result.textColor = Colors.text.withAlphaComponent(Values.mediumOpacity)
        return result
    }()

    private lazy var cancelButton: UIButton = {
        let result = UIButton()
        result.setTitle("Cancel", for: .normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: Values.smallFontSize)
        result.setTitleColor(Colors.text, for: .normal)
        result.addTarget(self, action: #selector(handleCancelButtonTapped), for: .touchUpInside)
        result.alpha = 0
        return result
    }()
    
    private lazy var pauseButton: UIButton = {
        let result = UIButton()
        result.setTitle("Pause", for: .normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: Values.smallFontSize)
        result.setTitleColor(Colors.text, for: .normal)
        result.addTarget(self, action: #selector(handlePauseButtonTapped), for: .touchUpInside)
        result.alpha = 0
        return result
    }()
    
    private lazy var playPauseButton: UIButton = {
        let result = UIButton()
        result.addTarget(self, action: #selector(handlePlayButtonTapped), for: .touchUpInside)
        result.alpha = 0
        let image = UIImage(named: "ic_play")
        result.setImage(image, for: .normal)
        let imageSelected = UIImage(named: "ic_pause_record")
        result.setImage(imageSelected, for: .selected)
        result.clipsToBounds = true
        result.isSelected = true
        return result
    }()
    
    private lazy var deleteButton: UIButton = {
        let result = UIButton()
        result.addTarget(self, action: #selector(handleDeleteButtonTapped), for: .touchUpInside)
        result.alpha = 0
        let image = UIImage(named: "ic_delete_voice_message")
        result.setImage(image, for: .normal)
        result.clipsToBounds = true
        result.isSelected = true
        return result
    }()

    private lazy var sendButton: UIButton = {
        let result = UIButton()
        result.backgroundColor = Colors.bothGreenColor
        result.layer.cornerRadius = 22
        result.addTarget(self, action: #selector(handleSendButtonTapped), for: .touchUpInside)
        let image = UIImage(named: "ic_sendMessage_new")?.withTint(.white)
        result.setImage(image, for: .normal)
        result.set(.width, to: 44)
        result.set(.height, to: 44)
        result.alpha = 0
        return result
    }()
    
    private lazy var audioButton: UIButton = {
        let result = UIButton()
        result.addTarget(self, action: #selector(audioButtonTapped), for: .touchUpInside)
        result.alpha = 0
        let image = UIImage(named: "ic_record")
        result.setImage(image, for: .normal)
        result.clipsToBounds = true
        return result
    }()
    
    private lazy var audioDurationLabel: UILabel = {
        let result = UILabel()
        result.text = "0:00"
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textColor = Colors.noDataLabelColor
        result.alpha = 0
        result.sizeToFit()
        result.set(.width, to: 44)
        return result
    }()
    
    private lazy var totalDurationLabel: UILabel = {
        let result = UILabel()
        result.text = "0:00"
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textColor = Colors.noDataLabelColor
        result.alpha = 0
        result.textAlignment = .right
        result.set(.width, to: 44)
        return result
    }()
    
    private lazy var audioWavesImageView: UIImageView = {
        let tintColor = Colors.audioWaveColor
        var result = UIImageView(image: UIImage(named: "ic_audioWaves")?.withTint(tintColor))
        result.set(.height, to: 24)
        result.contentMode = .scaleToFill
        result.alpha = 0
        return result
    }()
    
    private lazy var waveformRow: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ audioDurationLabel, audioWavesImageView, totalDurationLabel ])
        result.axis = .horizontal
        result.spacing = Values.smallSpacing
        result.alignment = .bottom
        return result
    }()
    
    private lazy var controlsRow: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ deleteButton, playPauseButton, sendButton ])
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .equalCentering
        result.spacing = Values.largeSpacing
        return result
    }()
    
    private lazy var lockedContainer: UIView = {
        let result = UIView()
        result.backgroundColor = Colors.incomingMessageColor
        result.layer.cornerRadius = 18
        result.isHidden = true
        result.alpha = 0
        return result
    }()

    private lazy var durationStackView: UIStackView = {
        let result = UIStackView()
        result.axis = .horizontal
        result.spacing = Values.smallSpacing
        result.alignment = .center
        return result
    }()

    private lazy var dotView: UIImageView = {
        let tintColor = Colors.destructive
        var result = UIImageView(image: UIImage(named: "ic_reddot_voice_recording")?.withTint(tintColor))
        let dotSize = VoiceMessageRecordingView.dotSize
        result.set(.width, to: dotSize)
        result.set(.height, to: dotSize)
        result.contentMode = .scaleToFill
        return result
    }()

    private lazy var durationLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.regularOpenSans(ofSize: Values.smallFontSize)
        result.text = "0:00"
        return result
    }()
    
    private lazy var progressView: UIView = {
        let result = UIView()
        result.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        result.alpha = 0
        return result
    }()
    

    private lazy var lockView = LockView()
    var TimerForConstraintOfProgressView: Timer?
    var isAudioRecordingStop = false
    var countDownTimer: Timer?
    var countDownTimerSecond = 0

    // MARK: Settings
    private static let recordingHeight: CGFloat = 50
    private static let lockedHeight: CGFloat = 100
    private static let circleSize: CGFloat = 46
    private static let pulseSize: CGFloat = 24
    private static let iconSize: CGFloat = 20
    private static let chevronSize: CGFloat = 16
    private static let dotSize: CGFloat = 16
    private static let lockViewHitMargin: CGFloat = 40
    private static let rightAccessoryBackgroundWidth: CGFloat = 56
    
    private lazy var progressViewRightConstraint = progressView.pin(.right, to: .right, of: audioWavesImageView, withInset: -audioWavesImageView.width)

    // MARK: Lifecycle
    init(voiceMessageButtonFrame: CGRect, delegate: VoiceMessageRecordingViewDelegate?, onLocked: (() -> Void)? = nil) {
        self.voiceMessageButtonFrame = voiceMessageButtonFrame
        self.delegate = delegate
        self.onLocked = onLocked
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateDurationLabel()
        }
        RunLoop.main.add(recordingTimer!, forMode: .common)
    }

    override init(frame: CGRect) {
        preconditionFailure("Use init(voiceMessageButtonFrame:) instead.")
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(voiceMessageButtonFrame:) instead.")
    }

    deinit {
        recordingTimer?.invalidate()
    }

    private func setUpViewHierarchy() {
        self.translatesAutoresizingMaskIntoConstraints = false
        heightConstraint.isActive = true
        backgroundColor = Colors.incomingMessageColor
        layer.cornerRadius = 22
        // Icon
        addSubview(iconImageView)
        iconLeftConstraint = iconImageView.pin(.left, to: .left, of: self)
        iconTopConstraint = iconImageView.pin(.top, to: .top, of: self)
        updateVoiceMessageButtonFrame(voiceMessageButtonFrame)
        // Circle
        insertSubview(circleView, at: 0)
        circleView.center(in: iconImageView)
        // Pulse
        insertSubview(pulseView, at: 0)
        pulseView.center(in: circleView)
        // Background behind lock + mic
        insertSubview(rightAccessoryBackgroundView, belowSubview: pulseView)
        rightAccessoryBackgroundView.set(.width, to: VoiceMessageRecordingView.rightAccessoryBackgroundWidth)
        rightAccessoryBackgroundView.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor, constant: 2).isActive = true
        // Slide to cancel stack view
        slideToCancelStackView.addArrangedSubview(chevronImageView)
        slideToCancelStackView.addArrangedSubview(slideToCancelLabel)
        addSubview(slideToCancelStackView)
        slideToCancelStackViewRightConstraint.isActive = true
        slideToCancelStackView.center(.vertical, in: iconImageView)
        // Cancel button
        addSubview(cancelButton)
        cancelButton.center(.horizontal, in: self)
        cancelButton.center(.vertical, in: iconImageView)
        // Duration stack view
        durationStackView.addArrangedSubview(dotView)
        durationStackView.addArrangedSubview(durationLabel)
        addSubview(durationStackView)
        durationStackView.pin(.left, to: .left, of: self, withInset: Values.largeSpacing)
        durationStackView.center(.vertical, in: iconImageView)
        // Lock view
        addSubview(lockView)
        lockView.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor, constant: 2).isActive = true
        lockViewBottomConstraint.isActive = true
        rightAccessoryBackgroundView.pin(.top, to: .top, of: lockView, withInset: -Values.smallSpacing)
        rightAccessoryBackgroundView.pin(.bottom, to: .bottom, of: circleView, withInset: Values.smallSpacing)
        
        addSubview(pauseButton)
        pauseButton.pin(.left, to: .right, of: durationStackView, withInset: 8)
        pauseButton.center(.vertical, in: iconImageView)
        
        addSubview(lockedContainer)
        lockedContainer.pin(.top, to: .top, of: self, withInset: 4)
        lockedContainer.pin(.left, to: .left, of: self, withInset: 0)
        lockedContainer.pin(.right, to: .right, of: self, withInset: 0)
        lockedContainer.pin(.bottom, to: .bottom, of: self, withInset: 0)
        
        lockedContainer.addSubview(waveformRow)
        waveformRow.pin(.top, to: .top, of: lockedContainer, withInset: 2)
        waveformRow.pin(.left, to: .left, of: lockedContainer, withInset: 12)
        waveformRow.pin(.right, to: .right, of: lockedContainer, withInset: -8)
        
        lockedContainer.addSubview(controlsRow)
        controlsRow.pin(.top, to: .bottom, of: waveformRow, withInset: 2)
        controlsRow.pin(.left, to: .left, of: lockedContainer, withInset: 12)
        controlsRow.pin(.right, to: .right, of: lockedContainer, withInset: -12)
        controlsRow.pin(.bottom, to: .bottom, of: lockedContainer, withInset: -12)
        
        NSLayoutConstraint.activate([
            deleteButton.heightAnchor.constraint(equalToConstant: 40),
            deleteButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        lockedContainer.addSubview(progressView)
        progressView.pin(.left, to: .left, of: audioWavesImageView)
        progressView.pin(.top, to: .top, of: audioWavesImageView)
        progressViewRightConstraint.isActive = true
        progressView.pin(.bottom, to: .bottom, of: audioWavesImageView)
        
    }

    // MARK: Updating
    @objc private func updateDurationLabel() {
        DispatchQueue.main.async {
            self.timerSecond += 1
            let interval = Date().timeIntervalSince(self.recordingStartDate)
            let formattedDuration = OWSFormat.formatDurationSeconds(Int(interval))
            self.durationLabel.text = formattedDuration
            self.audioDurationLabel.text = formattedDuration
            self.totalDurationLabel.text = formattedDuration
        }
        
        // For Resume Audio Don't Delete
//        getSecondsIntoMinutesAndSecondFormate(seconds: self.timerSecond) { minutes, seconds in
//            let minutes = self.getStringFrom(seconds: minutes)
//            let seconds = self.getStringFrom(seconds: seconds)
//            self.audioDurationLabel.text = "\(minutes):\(seconds)"
//        }
    }

    func updateVoiceMessageButtonFrame(_ frame: CGRect) {
        let iconSize = VoiceMessageRecordingView.iconSize
        let center = frame.center
        iconLeftConstraint?.constant = center.x - iconSize / 2
        iconTopConstraint?.constant = center.y - iconSize / 2
        layoutIfNeeded()
    }

    // MARK: Animation
    func animate() {
        layoutIfNeeded()
        slideToCancelStackViewRightConstraint.isActive = false
        slideToCancelLabelCenterHorizontalConstraint.isActive = true
        lockViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let self = self else { return }
            self.alpha = 1
            self.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.fadeOutDotView()
            self.pulse()
        })
    }

    private func fadeOutDotView() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.dotView.alpha = 0
        }, completion: { [weak self] _ in
            self?.fadeInDotView()
        })
    }

    private func fadeInDotView() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.dotView.alpha = 1
        }, completion: { [weak self] _ in
            self?.fadeOutDotView()
        })
    }

    private func pulse() {
        let collapsedSize = VoiceMessageRecordingView.circleSize
        let collapsedFrame = CGRect(center: pulseView.center, size: CGSize(width: collapsedSize, height: collapsedSize))
        let expandedSize = VoiceMessageRecordingView.circleSize + VoiceMessageRecordingView.pulseSize
        let expandedFrame = CGRect(center: pulseView.center, size: CGSize(width: expandedSize, height: expandedSize))
        pulseViewWidthConstraint.constant = expandedSize
        pulseViewHeightConstraint.constant = expandedSize
        UIView.animate(withDuration: 1, animations: { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
            self.pulseView.frame = expandedFrame
            self.pulseView.layer.cornerRadius = expandedSize / 2
            self.pulseView.alpha = 0
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.pulseViewWidthConstraint.constant = collapsedSize
            self.pulseViewHeightConstraint.constant = collapsedSize
            self.pulseView.frame = collapsedFrame
            self.pulseView.layer.cornerRadius = collapsedSize / 2
            self.pulseView.alpha = 0.5
            self.pulse()
        })
    }

    // MARK: Interaction
    func handleLongPressMoved(to location: CGPoint) {
        if location.x < bounds.center.x {
            let translationX = location.x - bounds.center.x
            let sign: CGFloat = -1
            let chevronDamping: CGFloat = 4
            let labelDamping: CGFloat = 3
            let chevronX = (chevronDamping * (sqrt(abs(translationX)) / sqrt(chevronDamping))) * sign
            let labelX = (labelDamping * (sqrt(abs(translationX)) / sqrt(labelDamping))) * sign
            chevronImageView.transform = CGAffineTransform(translationX: chevronX, y: 0)
            slideToCancelLabel.transform = CGAffineTransform(translationX: labelX, y: 0)
        } else {
            chevronImageView.transform = .identity
            slideToCancelLabel.transform = .identity
        }
        if isValidLockViewLocation(location) {
            if !lockView.isExpanded {
                UIView.animate(withDuration: 0.25) {
                    self.lockViewBottomConstraint.constant = 0
                }
            }
            lockView.expandIfNeeded()
        } else {
            if lockView.isExpanded {
                UIView.animate(withDuration: 0.25) {
                    self.lockViewBottomConstraint.constant = 0
                }
            }
            lockView.collapseIfNeeded()
        }
    }

    func handleLongPressEnded(at location: CGPoint) {
        if pulseView.frame.contains(location) {
            delegate?.endVoiceMessageRecording()
        } else if isValidLockViewLocation(location) {
            transitionToLockedUI()
        } else {
            delegate?.cancelVoiceMessageRecording()
        }
    }

    @objc private func handleCircleViewTap() {
        delegate?.endVoiceMessageRecording()
    }

    @objc private func handleCancelButtonTapped() {
        delegate?.cancelVoiceMessageRecording()
    }

    @objc private func handleCloseButtonTapped() {
        delegate?.cancelVoiceMessageRecording()
    }
    
    // For pause button
    @objc private func handlePauseButtonTapped() {

    }
    
    @objc private func handlePlayButtonTapped(_ sender: UIButton) {
        self.totalDurationLabel.alpha = 1
        if sender.isSelected {
            if TimerForConstraintOfProgressView != nil {
                TimerForConstraintOfProgressView?.invalidate()
                TimerForConstraintOfProgressView = nil
            }
            if countDownTimer != nil {
                countDownTimer?.invalidate()
                countDownTimer = nil
            }
            if !isAudioRecordingStop {
                if recordingTimer != nil {
                    recordingTimer?.invalidate()
                    recordingTimer = nil
                }
                countDownTimerSecond = 0
                audioDurationLabel.text = OWSFormat.formatDurationSeconds(countDownTimerSecond)
                delegate?.pauseRecording()
                isAudioRecordingStop = true
            } else {
                delegate?.playRecording()
            }
        } else {
            TimerForConstraintOfProgressView = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.handleProgressChanged()
            }
            countDownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.handleCountDownTimer()
            }
            delegate?.playRecording()
        }
        sender.isSelected = !sender.isSelected
    }
    
    // For Resume Audio Don't Delete
    @objc private func audioButtonTapped(_ sender: UIButton) {
        // For Resume Audio Don't Delete
//        if !isAudioRecordingStop {
//            delegate?.showAlertForAudioRecordingIsOn()
//            return
//        }
//        self.playPauseauseButton.isSelected = true
//        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//            self?.updateDurationLabel()
//        }
//        isAudioRecordingStop = false
//        delegate?.resumeAudioRecording()
    }
    
    // Convert seconds into minutes and seconds formate
    func getSecondsIntoMinutesAndSecondFormate(seconds: Int, completion: @escaping (_ minutes: Int, _ seconds: Int)->()) {
        completion((seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    // Convert seconds into double digits
    func getStringFrom(seconds: Int) -> String {
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }

    // MARK: Convenience
    private func isValidLockViewLocation(_ location: CGPoint) -> Bool {
        let lockViewHitMargin = VoiceMessageRecordingView.lockViewHitMargin
        return location.y < 0 && location.x > (lockView.frame.minX - lockViewHitMargin) && location.x < (lockView.frame.maxX + lockViewHitMargin)
    }
    
    
    private func handleProgressChanged() {
        timerSecondForConstraintOfProgressView += 1
        if timerSecondForConstraintOfProgressView > timerSecond {
            timerSecondForConstraintOfProgressView = 0
            // For stop loop
            if TimerForConstraintOfProgressView != nil {
                TimerForConstraintOfProgressView?.invalidate()
                TimerForConstraintOfProgressView = nil
                playPauseButton.isSelected = false
                audioDurationLabel.text = "0:00"
                isAudioPlaying = false
            }
        }
        
        if timerSecond > 0 {
            let percentageFinished = ((timerSecondForConstraintOfProgressView * Int(audioWavesImageView.width())) / timerSecond)
            let finalConstraintOfProgressView = Int(audioWavesImageView.width()) - percentageFinished
            progressViewRightConstraint.constant = CGFloat(-finalConstraintOfProgressView)
        }
    }
    
    private func handleCountDownTimer() {
        countDownTimerSecond += 1
        if countDownTimerSecond > timerSecond {
            countDownTimerSecond = 0
            // For stop count down timer
            if countDownTimer != nil {
                countDownTimer?.invalidate()
                countDownTimer = nil
                countDownTimerSecond = 0
            }
        }
        audioDurationLabel.text = OWSFormat.formatDurationSeconds(countDownTimerSecond)
    }
    
    @objc private func handleDeleteButtonTapped(_ sender: UIButton) {
        delegate?.deleteRecording()
    }
    
    @objc private func handleSendButtonTapped() {
        delegate?.endVoiceMessageRecording()
    }

    private func transitionToLockedUI() {
        isLocked = true
        heightConstraint.constant = VoiceMessageRecordingView.lockedHeight
        onLocked?()
        
        let recordingViews: [UIView] = [
            rightAccessoryBackgroundView,
            lockView,
            slideToCancelStackView,
            circleView,
            pulseView,
            iconImageView,
            durationStackView,
            cancelButton,
            pauseButton
        ]
        
        lockedContainer.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            recordingViews.forEach { $0.alpha = 0 }
            self.lockedContainer.alpha = 1
            self.deleteButton.alpha = 1
            self.playPauseButton.alpha = 1
            self.sendButton.alpha = 1
            self.audioDurationLabel.alpha = 1
            self.audioWavesImageView.alpha = 1
            self.progressView.alpha = 1
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
            self.progressViewRightConstraint.constant = -(self.audioWavesImageView.width())
        }, completion: { _ in
            recordingViews.forEach { $0.isHidden = true }
        })
    }
    
    
    
}

// MARK: Lock Vie
extension VoiceMessageRecordingView {

    fileprivate final class LockView : UIView {
        private lazy var widthConstraint = set(.width, to: LockView.width)
        private(set) var isExpanded = false

        private lazy var stackView: UIStackView = {
            let result = UIStackView()
            result.axis = .vertical
            result.spacing = Values.smallSpacing
            result.alignment = .center
            result.isLayoutMarginsRelativeArrangement = true
            result.layoutMargins = UIEdgeInsets(top: 12, leading: 0, bottom: 8, trailing: 0)
            return result
        }()

        private static let width: CGFloat = 48
        static let expansionMargin: CGFloat = 3
        private static let lockIconSize: CGFloat = 20
        private static let chevronIconSize: CGFloat = 20

        override init(frame: CGRect) {
            super.init(frame: frame)
            setUpViewHierarchy()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setUpViewHierarchy()
        }

        private func setUpViewHierarchy() {
            let iconTint: UIColor = isLightMode ? .black : .white
            // Size & shape
            widthConstraint.isActive = true
            layer.cornerRadius = LockView.width / 2
            layer.masksToBounds = true
            // Lock icon
            let lockIconImageView = UIImageView(image: UIImage(named: "ic_lock_voice_recording")!.withTint(iconTint))
            let lockIconSize = LockView.lockIconSize
            lockIconImageView.set(.width, to: lockIconSize)
            lockIconImageView.set(.height, to: lockIconSize)
            stackView.addArrangedSubview(lockIconImageView)
            // Chevron icon
            let chevronIconImageView = UIImageView(image: UIImage(named: "ic_uparrow_voice_recording")!.withTint(iconTint))
            let chevronIconSize = LockView.chevronIconSize
            chevronIconImageView.set(.width, to: chevronIconSize)
            chevronIconImageView.set(.height, to: chevronIconSize)
            stackView.addArrangedSubview(chevronIconImageView)
            // Stack view
            addSubview(stackView)
            stackView.pin(to: self)
        }

        func expandIfNeeded() {
            guard !isExpanded else { return }
            isExpanded = true
            let expansionMargin = LockView.expansionMargin
            let newWidth = LockView.width + 2 * expansionMargin
            widthConstraint.constant = newWidth
            UIView.animate(withDuration: 0.25) {
                self.layer.cornerRadius = newWidth / 2
                self.stackView.layoutMargins = UIEdgeInsets(top: 12 + expansionMargin, leading: 0, bottom: 8 + expansionMargin, trailing: 0)
                self.layoutIfNeeded()
            }
        }

        func collapseIfNeeded() {
            guard isExpanded else { return }
            isExpanded = false
            let newWidth = LockView.width
            widthConstraint.constant = newWidth
            UIView.animate(withDuration: 0.25) {
                self.layer.cornerRadius = newWidth / 2
                self.stackView.layoutMargins = UIEdgeInsets(top: 12, leading: 0, bottom: 8, trailing: 0)
                self.layoutIfNeeded()
            }
        }
    }
}

// MARK: Delegate
protocol VoiceMessageRecordingViewDelegate : class {

    func startVoiceMessageRecording()
    func endVoiceMessageRecording()
    func cancelVoiceMessageRecording()
    func pauseRecording()
    func playRecording()
    func resumeAudioRecording()
    func showAlertForAudioRecordingIsOn()
    func deleteRecording()
    
}
