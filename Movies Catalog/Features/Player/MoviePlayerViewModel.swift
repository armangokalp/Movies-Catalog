//
//  MoviePlayerViewModel.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 26.08.2025.
//

import Foundation
import AVFoundation
import Combine

// Handle AVPlayer logic and state management
class MoviePlayerViewModel: NSObject, ObservableObject {
    private(set) var player: AVPlayer?
    private let videoURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
    private var timeObserver: Any?
    private var controlsTimer: Timer?
    
    @Published var isPlaying: Bool = false
    @Published var playbackProgress: Float = 0.0
    @Published var currentTimeText: String = "00:00"
    @Published var durationText: String = "00:00"
    @Published var isSeeking: Bool = false
    @Published var controlsVisible: Bool = false
    @Published var isPlayerReady: Bool = false
    
    var onPlayerReady: (() -> Void)?
    var onPlaybackStateChanged: ((Bool) -> Void)?
    var onProgressUpdated: ((Float, String, String) -> Void)?
    
    override init() {
        super.init()
        setupPlayer()
    }
    
    deinit {
        cleanupPlayer()
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        
        // Add time observer for progress updates
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            self?.updateProgress()
        }
        
        // Observe player status
        player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player?.addObserver(self, forKeyPath: "currentItem.duration", options: .new, context: nil)
    }
    
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
        onPlaybackStateChanged?(true)
        showControlsTemporarily()
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        onPlaybackStateChanged?(false)
        showControlsTemporarily()
    }
    
    func forward() {
        seek(to: playbackProgress + 0.025)
    }
    
    func backward() {
        seek(to: playbackProgress - 0.025)
    }
    
    func seek(to progress: Float) {
        guard let duration = player?.currentItem?.duration,
              CMTimeGetSeconds(duration) > 0 else { return }
        
        isSeeking = true
        let totalSeconds = CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(Double(progress) * totalSeconds), timescale: 1)
        
        player?.seek(to: seekTime) { [weak self] _ in
            self?.isSeeking = false
        }
        
        showControlsTemporarily()
    }
    
    func showControlsTemporarily() {
        controlsVisible = true
        controlsTimer?.invalidate()
        
        controlsTimer = Timer.scheduledTimer(withTimeInterval: Constants.Animation.controlsHideDelay, repeats: false) { [weak self] _ in
            self?.hideControls()
        }
    }
    
    func toggleControlsVisibility() {
        if controlsVisible {
            hideControls()
        } else {
            showControlsTemporarily()
        }
    }
    
    
    private func hideControls() {
        controlsVisible = false
        controlsTimer?.invalidate()
    }
    
    private func updateProgress() {
        guard !isSeeking,
              let currentTime = player?.currentTime(),
              let duration = player?.currentItem?.duration,
              CMTimeGetSeconds(duration) > 0 else { return }
        
        let currentSeconds = CMTimeGetSeconds(currentTime)
        let totalSeconds = CMTimeGetSeconds(duration)
        
        let progress = Float(currentSeconds / totalSeconds)
        let currentTimeString = formatTime(currentTime)
        let durationString = formatTime(duration)
        
        playbackProgress = progress
        currentTimeText = currentTimeString
        durationText = durationString
        
        onProgressUpdated?(progress, currentTimeString, durationString)
    }
    

    private func formatTime(_ time: CMTime) -> String {
        let seconds = CMTimeGetSeconds(time)
        guard !seconds.isNaN && !seconds.isInfinite else { return "00:00" }
        
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    
    var playPauseButtonImageName: String {
        return isPlaying ? "pause.fill" : "play.fill"
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
    }
}

extension MoviePlayerViewModel {  // KVO Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if keyPath == "status" {
                if self.player?.status == .readyToPlay {
                    self.isPlayerReady = true
                    self.onPlayerReady?()
                    self.updateProgress()
                }
            } else if keyPath == "currentItem.duration" {
                self.updateProgress()
            }
        }
    }
}
