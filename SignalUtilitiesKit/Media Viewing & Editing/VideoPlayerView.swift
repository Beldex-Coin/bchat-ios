//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import BChatUIKit

@objc
public class VideoPlayerView: UIView {
    @objc
    public var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    // Override UIView property
    override public static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

@objc
public protocol PlayerProgressBarDelegate {
    func playerProgressBarDidStartScrubbing(_ playerProgressBar: PlayerProgressBar)
    func playerProgressBar(_ playerProgressBar: PlayerProgressBar, scrubbedToTime time: CMTime)
    func playerProgressBar(_ playerProgressBar: PlayerProgressBar, didFinishScrubbingAtTime time: CMTime, shouldResumePlayback: Bool)
    
    func playVideo()
    func pauseVideo()
}

// Allows the user to tap anywhere on the slider to set it's position,
// without first having to grab the thumb.
class TrackingSlider: UISlider {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }
}

@objc
public class PlayerProgressBar: UIView {

    @objc
    public weak var delegate: PlayerProgressBarDelegate?

    private lazy var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]

        return formatter
    }()

    // MARK: Subviews
    private let positionLabel = UILabel()
    private let remainingLabel = UILabel()
    private let playAndPause = UIButton()
    private let speakerOptionButton = UIButton()
    private let slider = TrackingSlider()
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    weak private var progressObserver: AnyObject?
    private let fullScreenButton = UIButton()

    private let kPreferredTimeScale: CMTimeScale = 100

    @objc
    public var player: AVPlayer? {
        didSet {
            guard let item = player?.currentItem else {
                owsFailDebug("No player item")
                return
            }

            slider.minimumValue = 0

            let duration: CMTime = item.asset.duration
            slider.maximumValue = Float(CMTimeGetSeconds(duration))

            updateState()
            
            // OPTIMIZE We need a high frequency observer for smooth slider updates while playing,
            // but could use a much less frequent observer for label updates
            progressObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: kPreferredTimeScale), queue: nil, using: { [weak self] _ in
                // If it is playing update the time
                if self?.player?.rate != 0 && self?.player?.error == nil {
                    self?.updateState()
                }
            }) as AnyObject
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        // Background
        backgroundColor = Colors.mainBackGroundColor3
        
        // Dont remove thos lines
        
        //UIColor.lightGray.withAlphaComponent(0.5)
//        if !UIAccessibility.isReduceTransparencyEnabled {
//            addSubview(blurEffectView)
//            blurEffectView.ows_autoPinToSuperviewEdges()
//        }

        // Configure controls

        let kLabelFont = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: UIFont.Weight.regular)
        positionLabel.font = kLabelFont
        remainingLabel.font = kLabelFont

        // Configure passAndpaly button
        playAndPause.setImage(UIImage(named: "ic_play_image"), for: .normal)
        playAndPause.addTarget(self, action: #selector(playAndPauseButtonTapped), for: .touchUpInside)
        
        // Configure speakerOptionButton
        speakerOptionButton.setImage(UIImage(named: "ic_speaker_image"), for: .normal)
        speakerOptionButton.addTarget(self, action: #selector(speakerButtonTapped), for: .touchUpInside)

        // We use a smaller thumb for the progress slider.
        slider.setThumbImage(#imageLiteral(resourceName: "sliderProgressThumb"), for: .normal)
        slider.maximumTrackTintColor = UIColor(hex: 0xFFFFFF).withAlphaComponent(0.5)
        slider.minimumTrackTintColor = UIColor(hex: 0xFFFFFF).withAlphaComponent(0.5)
        
        slider.addTarget(self, action: #selector(handleSliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(handleSliderTouchUp), for: .touchUpInside)
        slider.addTarget(self, action: #selector(handleSliderTouchUp), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(handleSliderValueChanged), for: .valueChanged)

        // Panning is a no-op. We just absorb pan gesture's originating in the video controls
        // from propogating so we don't inadvertently change pages while trying to scrub in
        // the MediaPageView.
        let panAbsorber = UIPanGestureRecognizer(target: self, action: nil)
        self.addGestureRecognizer(panAbsorber)
        
        // Configure fullScreen button
        fullScreenButton.setImage(UIImage(named: "ic_fullScreen"), for: .normal)
        fullScreenButton.addTarget(self, action: #selector(fullScreenButtonTapped), for: .touchUpInside)
        

        // Layout Subviews

        addSubview(playAndPause)
        addSubview(positionLabel)
        addSubview(remainingLabel)
        addSubview(speakerOptionButton)
        addSubview(slider)
        
        // Don't Delete
        // For FullScreen uncomment this
//        addSubview(fullScreenButton)
        
        let buttonWidth: CGFloat = 24
        let buttonHeight: CGFloat = 24
        
        playAndPause.autoSetDimensions(to: CGSize(width: buttonWidth, height: buttonHeight))
        playAndPause.autoPinEdge(toSuperviewMargin: .leading)
        playAndPause.autoVCenterInSuperview()

        positionLabel.autoPinEdge(.leading, to: .trailing, of: playAndPause, withOffset: 8)
        positionLabel.autoVCenterInSuperview()

        let kSliderMargin: CGFloat = 8

        slider.autoPinEdge(.leading, to: .trailing, of: positionLabel, withOffset: kSliderMargin)
        slider.autoVCenterInSuperview()

        remainingLabel.autoPinEdge(.leading, to: .trailing, of: slider, withOffset: kSliderMargin)
        remainingLabel.autoVCenterInSuperview()
        
        speakerOptionButton.autoSetDimensions(to: CGSize(width: buttonWidth, height: buttonHeight))
        speakerOptionButton.autoPinEdge(.leading, to: .trailing, of: remainingLabel, withOffset: kSliderMargin)
        speakerOptionButton.autoPinEdge(toSuperviewMargin: .trailing)
        speakerOptionButton.autoVCenterInSuperview()
        
        // Don't Delete
        // For FullScreen uncomment this
//        fullScreenButton.autoPinEdge(.leading, to: .trailing, of: speakerOptionButton, withOffset: kSliderMargin)
//        fullScreenButton.autoPinEdge(toSuperviewMargin: .trailing)
//        fullScreenButton.autoVCenterInSuperview()
        
        
//        // Notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(isFromPassActionTapped), name: Notification.Name("isFromPassAction"), object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            player?.volume = 1.0
        } catch {
            print("Failed to play audio: \(error)")
        }
        
        notificationCenter.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player)
        
        notificationCenter.addObserver(self, selector: #selector(playAction), name: Notification.Name("playAction"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(pauseAction), name: Notification.Name("pauseAction"), object: nil)
    }
    
    @objc func playerDidFinishPlaying() {
        playAndPause.isSelected = false
        playAndPause.setImage(UIImage(named: "ic_play_image"), for: .normal)
    }

    // MARK: Gesture handling

    var wasPlayingWhenScrubbingStarted: Bool = false
    
    @objc func isFromPassActionTapped(notification: NSNotification) {
        playAndPause.setImage(UIImage(named: "ic_pause_image"), for: .normal)
    }
    
    @objc func playAction(notification: NSNotification) {
        playAndPause.isSelected = true
        playAndPause.setImage(UIImage(named: "ic_pause_image"), for: .normal)
    }
    
    @objc func pauseAction(notification: NSNotification) {
        playAndPause.isSelected = false
        playAndPause.setImage(UIImage(named: "ic_play_image"), for: .normal)
    }
    
    ///Small Buton Pass and Paly Button
    @objc private func playAndPauseButtonTapped() {
        playAndPause.isSelected.toggle()
        if playAndPause.isSelected {
            playAndPause.setImage(UIImage(named: "ic_pause_image"), for: .normal)
            delegate?.playVideo()
        } else {
            playAndPause.setImage(UIImage(named: "ic_play_image"), for: .normal)
            delegate?.pauseVideo()
        }
    }
    
    ///speaker
    @objc private func speakerButtonTapped() {
        speakerOptionButton.isSelected.toggle()
        if speakerOptionButton.isSelected {
            speakerOptionButton.setImage(UIImage(named: "ic_speaker_mute"), for: .normal)
            player?.volume = 0.0
        } else {
            speakerOptionButton.setImage(UIImage(named: "ic_speaker_image"), for: .normal)
            player?.volume = 1.0
        }
    }
    
    // fullScreen button action
    @objc func fullScreenButtonTapped(notification: NSNotification) {
         NotificationCenter.default.post(name: Notification.Name(rawValue: "fullScreenButtonTapped"), object: nil)
    }

    @objc
    private func handleSliderTouchDown(_ slider: UISlider) {
        guard let player = self.player else {
            owsFailDebug("player was nil")
            return
        }

        self.wasPlayingWhenScrubbingStarted = (player.rate != 0) && (player.error == nil)

        self.delegate?.playerProgressBarDidStartScrubbing(self)
    }

    @objc
    private func handleSliderTouchUp(_ slider: UISlider) {
        let sliderTime = time(slider: slider)
        self.delegate?.playerProgressBar(self, didFinishScrubbingAtTime: sliderTime, shouldResumePlayback: wasPlayingWhenScrubbingStarted)
    }

    @objc
    private func handleSliderValueChanged(_ slider: UISlider) {
        let sliderTime = time(slider: slider)
        self.delegate?.playerProgressBar(self, scrubbedToTime: sliderTime)
    }

    // MARK: Render cycle

    public func updateState() {
        guard let player = player else {
            owsFailDebug("player isn't set.")
            return
        }

        guard let item = player.currentItem else {
            owsFailDebug("player has no item.")
            return
        }

        let position = player.currentTime()
        let positionSeconds: Float64 = CMTimeGetSeconds(position)
        positionLabel.text = formatter.string(from: positionSeconds)

        let duration: CMTime = item.asset.duration
        let remainingTime = duration - position
        let remainingSeconds = CMTimeGetSeconds(remainingTime)

        guard let remainingString = formatter.string(from: remainingSeconds) else {
            owsFailDebug("unable to format time remaining")
            remainingLabel.text = "0:00"
            return
        }

        // show remaining time as negative
        remainingLabel.text = "-\(remainingString)"

        slider.setValue(Float(positionSeconds), animated: false)
    }

    // MARK: Util

    private func time(slider: UISlider) -> CMTime {
        let seconds: Double = Double(slider.value)
        return CMTime(seconds: seconds, preferredTimescale: kPreferredTimeScale)
    }
    
    // MARK: - Functions
    
    public func manuallySetValue(_ positionSeconds: CGFloat, durationSeconds: CGFloat) {
        let remainingSeconds = (durationSeconds - positionSeconds)
        
        slider.minimumValue = 0
        slider.maximumValue = Float(durationSeconds)
        
        positionLabel.text = formatter.string(from: positionSeconds)
        
        guard let remainingString = formatter.string(from: remainingSeconds) else {
            owsFailDebug("unable to format time remaining")
            remainingLabel.text = "0:00"
            return
        }
        
        // show remaining time as negative
        remainingLabel.text = "-\(remainingString)"
        
        slider.setValue(Float(positionSeconds), animated: false)
    }
}
