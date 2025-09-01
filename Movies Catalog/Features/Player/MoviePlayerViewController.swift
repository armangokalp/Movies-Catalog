//
//  MoviePlayerViewController.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

// Screen: in-app movie player (custom AVPlayer + orientation-based layout)

import UIKit
import AVKit
import AVFoundation
import Combine

class MoviePlayerViewController: UIViewController {
    private let playerViewModel: MoviePlayerViewModel
    private var detailViewModel: MovieDetailViewModel?
    private var playerLayer: AVPlayerLayer?
    private var cancellables = Set<AnyCancellable>()
    weak var parentDetailViewController: MovieDetailViewController?
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var fullscreenConstraints: [NSLayoutConstraint] = []
    private var controlsConstraints: [NSLayoutConstraint] = []
    
    // MARK: UI Components
    
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
        label.font = Constants.Typography.caption1
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = Constants.Typography.caption1
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var fullscreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(fullscreenButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var pipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pip.enter"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = Constants.Colors.controlsBackground
        button.layer.cornerRadius = Constants.CornerRadius.medium
        button.addTarget(self, action: #selector(pipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleInPlayer: UILabel = {
        let label = UILabel()
        label.text = detailViewModel?.title ?? ""
        label.font = Constants.Typography.title3
        label.textColor = .white
        label.numberOfLines = 0
        label.alpha = 0
        return label
    }()
    
    private lazy var movieDetailsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private lazy var movieDetailsContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var movieTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.title1
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var movieDateLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.body
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    private lazy var movieVoteCountLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.caption1
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var moviePopularityLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.caption1
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var movieRevenueLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.caption1
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var movieOverviewLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.body
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    
    init(detailViewModel: MovieDetailViewModel,
         playerViewModel: MoviePlayerViewModel = MoviePlayerViewModel()) {
        self.detailViewModel = detailViewModel
        self.playerViewModel = playerViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlayerLayer()
        setupGestures()
        configureBindings()
        setupMovieDetails()
        updateLayoutForOrientation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let windowScene = view.window?.windowScene { /// Enable all orientation just for this view
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .allButUpsideDown))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateLayoutForOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.updateLayoutForOrientation()
        }, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }
    
    
    //MARK: Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(playerContainerView)
        view.addSubview(controlsContainerView)
        view.addSubview(closeButton)
        view.addSubview(titleInPlayer)
        view.addSubview(pipButton)
        view.addSubview(movieDetailsScrollView)
        
        movieDetailsScrollView.addSubview(movieDetailsContentView)
        movieDetailsContentView.addSubview(movieTitleLabel)
        movieDetailsContentView.addSubview(movieDateLabel)
        movieDetailsContentView.addSubview(movieVoteCountLabel)
        movieDetailsContentView.addSubview(moviePopularityLabel)
        movieDetailsContentView.addSubview(movieRevenueLabel)
        movieDetailsContentView.addSubview(movieOverviewLabel)
        
        controlsContainerView.addSubview(playPauseButton)
        controlsContainerView.addSubview(backTrackButton)
        controlsContainerView.addSubview(forwardButton)
        controlsContainerView.addSubview(progressSlider)
        controlsContainerView.addSubview(currentTimeLabel)
        controlsContainerView.addSubview(durationLabel)
        controlsContainerView.addSubview(fullscreenButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        [playerContainerView, controlsContainerView, closeButton, titleInPlayer, playPauseButton,
         backTrackButton, forwardButton, progressSlider, currentTimeLabel,
         durationLabel, fullscreenButton, pipButton, movieDetailsScrollView, movieDetailsContentView,
         movieTitleLabel, movieDateLabel, movieVoteCountLabel, moviePopularityLabel, 
         movieRevenueLabel, movieOverviewLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupMovieDetailsConstraints()
        
        setupLayoutConstraints()
    }
    
    private func setupLayoutConstraints() {
        // Portrait mode
        portraitConstraints = [
            playerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            movieDetailsScrollView.topAnchor.constraint(equalTo: playerContainerView.bottomAnchor),
            
            controlsContainerView.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
            controlsContainerView.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
            controlsContainerView.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor),
            controlsContainerView.heightAnchor.constraint(equalToConstant: 100),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.large),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Spacing.large),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.closeButtonSize),
            
            titleInPlayer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.large),
            titleInPlayer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            pipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.large),
            pipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Spacing.large),
            pipButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.closeButtonSize),
            pipButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.closeButtonSize)
        ]
        
        // Fullscreen
        fullscreenConstraints = [
            playerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            controlsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            controlsContainerView.heightAnchor.constraint(equalToConstant: 100),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.large),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Spacing.large),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.closeButtonSize),
            
            titleInPlayer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.large),
            titleInPlayer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            pipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.large),
            pipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Spacing.large),
            pipButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.closeButtonSize),
            pipButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.closeButtonSize)
        ]
        
        
        controlsConstraints = [
            // Play/Pause
            playPauseButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor, constant: -Constants.Spacing.small),
            playPauseButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.playButtonSize),
            playPauseButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.playButtonSize),
            
            // Backward
            backTrackButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -Constants.Spacing.small),
            backTrackButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            // Forward
            forwardButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: Constants.Spacing.small),
            forwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            // CurrentTime Label
            currentTimeLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: Constants.Spacing.large),
            currentTimeLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -Constants.Spacing.large),
            
            // Fullscreen Button
            fullscreenButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -Constants.Spacing.large),
            fullscreenButton.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -Constants.Spacing.large),
            
            // Duration Label
            durationLabel.trailingAnchor.constraint(equalTo: fullscreenButton.leadingAnchor, constant: -Constants.Spacing.medium),
            durationLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -Constants.Spacing.large),
            
            // Slider
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: Constants.Spacing.medium),
            progressSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -Constants.Spacing.medium),
            progressSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor)
        ]
    }
    
    private func setupMovieDetailsConstraints() {
        NSLayoutConstraint.activate([
            movieDetailsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            movieDetailsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            movieDetailsScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            movieDetailsContentView.topAnchor.constraint(equalTo: movieDetailsScrollView.topAnchor),
            movieDetailsContentView.leadingAnchor.constraint(equalTo: movieDetailsScrollView.leadingAnchor),
            movieDetailsContentView.trailingAnchor.constraint(equalTo: movieDetailsScrollView.trailingAnchor),
            movieDetailsContentView.bottomAnchor.constraint(equalTo: movieDetailsScrollView.bottomAnchor),
            movieDetailsContentView.widthAnchor.constraint(equalTo: movieDetailsScrollView.widthAnchor),
            
            movieTitleLabel.topAnchor.constraint(equalTo: movieDetailsContentView.topAnchor, constant: Constants.Spacing.large),
            movieTitleLabel.leadingAnchor.constraint(equalTo: movieDetailsContentView.leadingAnchor, constant: Constants.Spacing.large),
            movieTitleLabel.widthAnchor.constraint(lessThanOrEqualTo: movieDetailsContentView.widthAnchor, multiplier: detailViewModel?.date == "" ? 1 : 0.65, constant: -Constants.Spacing.large),
            
            movieDateLabel.topAnchor.constraint(equalTo: movieTitleLabel.topAnchor),
            movieDateLabel.trailingAnchor.constraint(equalTo: movieDetailsContentView.trailingAnchor, constant: -Constants.Spacing.large),
            movieDateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: movieTitleLabel.trailingAnchor, constant: Constants.Spacing.medium),
            
            movieVoteCountLabel.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: Constants.Spacing.medium),
            movieVoteCountLabel.leadingAnchor.constraint(equalTo: movieDetailsContentView.leadingAnchor, constant: Constants.Spacing.large),
            
            moviePopularityLabel.centerYAnchor.constraint(equalTo: movieVoteCountLabel.centerYAnchor),
            moviePopularityLabel.leadingAnchor.constraint(equalTo: movieVoteCountLabel.trailingAnchor, constant: Constants.Spacing.large),
            
            movieRevenueLabel.topAnchor.constraint(equalTo: movieVoteCountLabel.bottomAnchor, constant: Constants.Spacing.small),
            movieRevenueLabel.leadingAnchor.constraint(equalTo: movieDetailsContentView.leadingAnchor, constant: Constants.Spacing.large),
            
            movieOverviewLabel.topAnchor.constraint(equalTo: movieRevenueLabel.bottomAnchor, constant: Constants.Spacing.large),
            movieOverviewLabel.leadingAnchor.constraint(equalTo: movieDetailsContentView.leadingAnchor, constant: Constants.Spacing.large),
            movieOverviewLabel.trailingAnchor.constraint(equalTo: movieDetailsContentView.trailingAnchor, constant: -Constants.Spacing.large),
            movieOverviewLabel.bottomAnchor.constraint(equalTo: movieDetailsContentView.bottomAnchor, constant: -Constants.Spacing.large)
        ])
    }
    
    private func setupPlayerLayer() {
        guard let player = playerViewModel.player else { return }
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        
        if let playerLayer = playerLayer {
            playerContainerView.layer.addSublayer(playerLayer)
        }
    }
    
    private func setupPictureInPicture() {
        guard let playerLayer = playerLayer else { 
            print("PlayerLayer is nil in setupPictureInPicture")
            return 
        }
        print("Setting up PiP with playerLayer")
        playerViewModel.setupPictureInPicture(with: playerLayer)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped))
        playerContainerView.addGestureRecognizer(tapGesture)
    }
    
    private func setupMovieDetails() {
        guard let viewModel = detailViewModel else { return }
        
        movieTitleLabel.text = viewModel.title
        movieDateLabel.text = viewModel.date
        movieVoteCountLabel.text = viewModel.voteCount
        moviePopularityLabel.text = viewModel.popularity
        movieOverviewLabel.text = viewModel.overview
        
        if let revenue = viewModel.revenue {
            movieRevenueLabel.text = revenue
            movieRevenueLabel.isHidden = false
        } else {
            movieRevenueLabel.isHidden = true
        }
    }
    
    
    //MARK: Action
    
    @objc private func playPauseButtonTapped() {
        playerViewModel.togglePlayPause()
    }
    @objc private func backwardsButtonTapped() {
        playerViewModel.backward()
    }
    @objc private func forwardsButtonTapped() {
        playerViewModel.forward()
    }
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    @objc private func fullscreenButtonTapped() {
        let isLandscape = view.bounds.width > view.bounds.height
        if isLandscape {
            forceOrientation(.portrait)
        } else {
            forceOrientation(.landscapeRight)
        }
    }
    @objc private func playerViewTapped() {
        playerViewModel.toggleControlsVisibility()
    }
    @objc private func progressSliderChanged(_ slider: UISlider) {
        playerViewModel.seek(to: slider.value)
    }
    @objc private func progressSliderTouchEnded(_ slider: UISlider) {
        playerViewModel.seek(to: slider.value)
    }
    @objc private func pipButtonTapped() {
        print("PiP button tapped!")
        print("PiP supported: \(playerViewModel.isPictureInPictureSupported)")
        print("Player ready: \(playerViewModel.isPlayerReady)")
        playerViewModel.startPictureInPicture()
    }
    
    
    
    
    
    private func updateLayoutForOrientation() { /// for device orientation
        let isLandscape = view.bounds.width > view.bounds.height
        
        NSLayoutConstraint.deactivate(portraitConstraints + fullscreenConstraints + controlsConstraints)
        
        if isLandscape {
            NSLayoutConstraint.activate(fullscreenConstraints + controlsConstraints)
            movieDetailsScrollView.isHidden = true
            view.backgroundColor = .black
            fullscreenButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
        } else {
            NSLayoutConstraint.activate(portraitConstraints + controlsConstraints)
            movieDetailsScrollView.isHidden = false
            view.backgroundColor = .systemBackground
            fullscreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
            titleInPlayer.alpha = 0
        }
    }
    
    private func forceOrientation(_ orientation: UIInterfaceOrientationMask) { /// for fullscreen button
        guard let windowScene = view.window?.windowScene else { return }
        
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
    }
    
    
    private func configureBindings() { /// Data Binding
        playerViewModel.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                let imageName = isPlaying ? "pause.fill" : "play.fill"
                self?.playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
            }
            .store(in: &cancellables)
        
        playerViewModel.$playbackProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progressSlider.value = progress
            }
            .store(in: &cancellables)
        
        playerViewModel.$currentTimeText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeText in
                self?.currentTimeLabel.text = timeText
            }
            .store(in: &cancellables)
        
        playerViewModel.$durationText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] durationText in
                self?.durationLabel.text = durationText
            }
            .store(in: &cancellables)
        
        playerViewModel.$controlsVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                self?.animateControlsVisibility(isVisible: isVisible)
            }
            .store(in: &cancellables)
        
        playerViewModel.onPlayerReady = { [weak self] in
            self?.playerViewModel.play()
            self?.setupPictureInPicture()
        }
        
        playerViewModel.$isPictureInPictureSupported
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSupported in
                self?.pipButton.isHidden = !isSupported
            }
            .store(in: &cancellables)
        
        playerViewModel.$isPictureInPictureActive
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isActive in
                let imageName = isActive ? "pip.exit" : "pip.enter"
                self?.pipButton.setImage(UIImage(systemName: imageName), for: .normal)
            }
            .store(in: &cancellables)
    }
    
    private func animateControlsVisibility(isVisible: Bool) {
        let isLandscape = view.bounds.width > view.bounds.height
        
        UIView.animate(withDuration: Constants.Animation.defaultDuration) {
            self.controlsContainerView.alpha = isVisible ? 1 : 0
            self.closeButton.alpha = isVisible ? 1 : 0
            self.pipButton.alpha = isVisible ? 1 : 0
            self.titleInPlayer.alpha = (isVisible && isLandscape) ? 1 : 0
        }
    }
}
