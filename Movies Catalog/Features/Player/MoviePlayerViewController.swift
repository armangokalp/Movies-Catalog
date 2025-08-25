//
//  MoviePlayerViewController.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

import UIKit
import AVKit
import AVFoundation

class MoviePlayerViewController: UIViewController {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isPlaying = false
    private var timeObserver: Any?
    
    private let videoURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
    
    
    private lazy var playerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .systemRed
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.3)
        slider.thumbTintColor = .systemRed
        slider.addTarget(self, action: #selector(progressSliderChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        return slider
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private var controlsTimer: Timer?
    private var isSeeking = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlayer()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Support both orientations
        if let windowScene = view.window?.windowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .allButUpsideDown))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanupPlayer()
    }
    
    
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(playerContainerView)
        view.addSubview(controlsContainerView)
        view.addSubview(closeButton)
        
        controlsContainerView.addSubview(playPauseButton)
        controlsContainerView.addSubview(progressSlider)
        controlsContainerView.addSubview(currentTimeLabel)
        controlsContainerView.addSubview(durationLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        playerContainerView.translatesAutoresizingMaskIntoConstraints = false
        controlsContainerView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Player Container
            playerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Controls Container
            controlsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            controlsContainerView.heightAnchor.constraint(equalToConstant: 100),
            
            // Close Button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Play/Pause
            playPauseButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor, constant: -10),
            playPauseButton.widthAnchor.constraint(equalToConstant: 50),
            playPauseButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Current Time Label
            currentTimeLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 16),
            currentTimeLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -16),
            
            // Duration Label
            durationLabel.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -16),
            durationLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -16),
            
            // Progress Slider
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 12),
            progressSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -12),
            progressSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor)
        ])
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        
        if let playerLayer = playerLayer {
            playerContainerView.layer.addSublayer(playerLayer)
        }
        
        // Add time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateProgress()
        }
        
        // Observe player status
        player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player?.addObserver(self, forKeyPath: "currentItem.duration", options: .new, context: nil)
        
        // Autoplay
        player?.play()
        isPlaying = true
        updatePlayPauseButton()
        showControlsTemporarily()
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped))
        playerContainerView.addGestureRecognizer(tapGesture)
    }
    

    @objc private func playPauseButtonTapped() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
        updatePlayPauseButton()
        showControlsTemporarily()
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func playerViewTapped() {
        toggleControlsVisibility()
    }
    
    @objc private func progressSliderChanged(_ slider: UISlider) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(slider.value) * totalSeconds
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        currentTimeLabel.text = formatTime(seekTime)
    }
    
    @objc private func progressSliderTouchBegan(_ slider: UISlider) {
        isSeeking = true
    }
    
    @objc private func progressSliderTouchEnded(_ slider: UISlider) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(slider.value) * totalSeconds
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        
        player?.seek(to: seekTime) { [weak self] _ in
            self?.isSeeking = false
        }
        showControlsTemporarily()
    }
    
    // Helpers
    private func updatePlayPauseButton() {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func updateProgress() {
        guard !isSeeking,
              let currentTime = player?.currentTime(),
              let duration = player?.currentItem?.duration,
              CMTimeGetSeconds(duration) > 0 else { return }
        
        let currentSeconds = CMTimeGetSeconds(currentTime)
        let totalSeconds = CMTimeGetSeconds(duration)
        
        progressSlider.value = Float(currentSeconds / totalSeconds)
        currentTimeLabel.text = formatTime(currentTime)
        durationLabel.text = formatTime(duration)
    }
    
    private func formatTime(_ time: CMTime) -> String {
        let seconds = CMTimeGetSeconds(time)
        let mins = Int(seconds / 60)
        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func toggleControlsVisibility() {
        let isVisible = controlsContainerView.alpha > 0
        
        UIView.animate(withDuration: 0.3) {
            self.controlsContainerView.alpha = isVisible ? 0 : 1
            self.closeButton.alpha = isVisible ? 0 : 1
        }
        
        if !isVisible {
            showControlsTemporarily()
        }
    }
    
    private func showControlsTemporarily() {
        controlsTimer?.invalidate()
        
        UIView.animate(withDuration: 0.3) {
            self.controlsContainerView.alpha = 1
            self.closeButton.alpha = 1
        }
        
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.controlsContainerView.alpha = 0
                self?.closeButton.alpha = 0
            }
        }
    }
    
    private func cleanupPlayer() {
        controlsTimer?.invalidate()
        
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        
        player?.removeObserver(self, forKeyPath: "status")
        player?.removeObserver(self, forKeyPath: "currentItem.duration")
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player?.status == .readyToPlay {
                updateProgress()
            }
        } else if keyPath == "currentItem.duration" {
            updateProgress()
        }
    }
}
