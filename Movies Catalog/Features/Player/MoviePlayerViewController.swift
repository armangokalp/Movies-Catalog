//
//  MoviePlayerViewController.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

import UIKit
import AVKit
import AVFoundation
import Combine

/**
 * MoviePlayerViewController
 * 
 * Video player screen with custom controls for movie playback.
 * Features play/pause, seeking, progress tracking, and auto-hiding controls.
 * Uses MVVM architecture with MoviePlayerViewModel for business logic.
 */
class MoviePlayerViewController: UIViewController {

    private let viewModel = MoviePlayerViewModel()
    private var playerLayer: AVPlayerLayer?
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var playerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Colors.overlay
        view.alpha = 0
        return view
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
     
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backTrackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(backwardsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(forwardsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = Constants.Colors.controlsBackground
        button.layer.cornerRadius = Constants.CornerRadius.large
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = Constants.Colors.primary
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.3)
        slider.thumbTintColor = Constants.Colors.primary
        slider.addTarget(self, action: #selector(progressSliderChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        return slider
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlayerLayer()
        setupGestures()
        configureBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let windowScene = view.window?.windowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .allButUpsideDown))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(playerContainerView)
        view.addSubview(controlsContainerView)
        view.addSubview(closeButton)
        
        controlsContainerView.addSubview(playPauseButton)
        controlsContainerView.addSubview(backTrackButton)
        controlsContainerView.addSubview(forwardButton)
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
        backTrackButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
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
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.large),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Spacing.large),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.closeButtonSize),
            
            // Play/Pause
            playPauseButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor, constant: -Constants.Spacing.small),
            playPauseButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.playButtonSize),
            playPauseButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.playButtonSize),
            
            // Backward
            backTrackButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor,
                                                      constant: -Constants.Spacing.small),
            backTrackButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),

            // Forward
            forwardButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor,
                                                   constant: Constants.Spacing.small),
            forwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),

            
            // Current Time Label
            currentTimeLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: Constants.Spacing.large),
            currentTimeLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -Constants.Spacing.large),
            
            // Duration Label
            durationLabel.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -Constants.Spacing.large),
            durationLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -Constants.Spacing.large),
            
            // Progress Slider
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: Constants.Spacing.medium),
            progressSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -Constants.Spacing.medium),
            progressSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor)
        ])
    }
    
    private func setupPlayerLayer() {
        guard let player = viewModel.player else { return }
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        
        if let playerLayer = playerLayer {
            playerContainerView.layer.addSublayer(playerLayer)
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped))
        playerContainerView.addGestureRecognizer(tapGesture)
    }
    

    @objc private func playPauseButtonTapped() {
        viewModel.togglePlayPause()
    }
    @objc private func backwardsButtonTapped() {
        viewModel.backward()
    }
    @objc private func forwardsButtonTapped() {
        viewModel.forward()
    }
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    @objc private func playerViewTapped() {
        viewModel.toggleControlsVisibility()
    }
    @objc private func progressSliderChanged(_ slider: UISlider) {
        viewModel.seek(to: slider.value)
    }
    @objc private func progressSliderTouchEnded(_ slider: UISlider) {
        viewModel.seek(to: slider.value)
    }
    
    
    // data binding
    private func configureBindings() {
        viewModel.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                let imageName = isPlaying ? "pause.fill" : "play.fill"
                self?.playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
            }
            .store(in: &cancellables)
        
        viewModel.$playbackProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progressSlider.value = progress
            }
            .store(in: &cancellables)
        
        viewModel.$currentTimeText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeText in
                self?.currentTimeLabel.text = timeText
            }
            .store(in: &cancellables)
        
        viewModel.$durationText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] durationText in
                self?.durationLabel.text = durationText
            }
            .store(in: &cancellables)
        
        viewModel.$controlsVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                self?.animateControlsVisibility(isVisible: isVisible)
            }
            .store(in: &cancellables)
        
        viewModel.onPlayerReady = { [weak self] in
            self?.viewModel.play()
        }
    }
    
    private func animateControlsVisibility(isVisible: Bool) {
        UIView.animate(withDuration: Constants.Animation.defaultDuration) {
            self.controlsContainerView.alpha = isVisible ? 1 : 0
            self.closeButton.alpha = isVisible ? 1 : 0
        }
    }
}
