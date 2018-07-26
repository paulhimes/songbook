//
//  AudioPlayer.swift
//  songbook
//
//  Created by Paul Himes on 1/17/18.
//  Copyright © 2018 Paul Himes. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayer: NSObject, AVAudioPlayerDelegate {

    @objc var delegate: AudioPlayerDelegate?
    @objc var hasSongFiles: Bool {
        get {
            return audioFileURLs.count > 0
        }
    }
    @objc var playbackProgress: Double {
        get {
            guard let audioPlayer = audioPlayer, audioPlayer.duration > 0 else { return 0 }
            return min(1, max(0, audioPlayer.currentTime / audioPlayer.duration))
        }
    }
    @objc var duration: Double {
        get {
            guard let audioPlayer = audioPlayer else { return 0 }
            return audioPlayer.duration
        }
    }
    @objc var isPlaying: Bool {
        get {
            guard let audioPlayer = audioPlayer else { return false }
            return audioPlayer.isPlaying
        }
    }
    
    private let audioFileDirectory: URL
    private var audioPlayer: AVAudioPlayer?
    @objc private(set) var currentSong: Song?
    private var currentTuneIndex = 0
    
    private lazy var audioFileURLs: [URL] = {
        let fileManager = FileManager.default
        guard let directoryEnumerator = fileManager.enumerator(at: self.audioFileDirectory, includingPropertiesForKeys: [], options: [], errorHandler: { (url, error) -> Bool in
            NSLog("Error enumerating url: \(url)")
            return true
        }) else { return [] }
        
        var audioFileURLs: [URL] = []
        
        for case let fileURL as URL in directoryEnumerator {
            let fileExtension = fileURL.pathExtension
            if fileExtension.localizedCaseInsensitiveCompare("m4a") == .orderedSame ||
               fileExtension.localizedCaseInsensitiveCompare("mp3") == .orderedSame ||
               fileExtension.localizedCaseInsensitiveCompare("wav") == .orderedSame {
                audioFileURLs.append(fileURL)
            }
        }
        
        return audioFileURLs
    }()
    
    private static let playbackModeKey = "PlaybackMode"
    private static let defaultPlaybackMode: PlaybackMode = .continuous
    @objc static var playbackMode: PlaybackMode {
        get {
            guard UserDefaults.standard.value(forKey: playbackModeKey) != nil else { return defaultPlaybackMode }
            return PlaybackMode(rawValue: UserDefaults.standard.integer(forKey: playbackModeKey)) ?? defaultPlaybackMode
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: playbackModeKey)
            UserDefaults.standard.synchronize()
        }
    }

    @objc init(directory: URL) {
        audioFileDirectory = directory
        super.init()
        
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget() { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.playNext()
            return .success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget() { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.playPrevious()
            return .success
        }
        MPRemoteCommandCenter.shared().playCommand.addTarget() { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if self?.audioPlayer == nil {
                if let song = self?.delegate?.currentSong() {
                    self?.startPlayingAtSong(song, tuneIndex: 0)
                    return .success
                } else {
                    return .commandFailed
                }
            } else if !(self?.audioPlayer?.isPlaying ?? false) {
                self?.updateNowPlayingInfoCenterProgress()
                self?.audioPlayer?.play()
                self?.updateNowPlayingInfoCenterProgress()
                if let song = self?.currentSong, let tuneIndex = self?.currentTuneIndex {
                    self?.delegate?.audioPlayerStartedPlayingSong(song, tuneIndex: tuneIndex)
                }
                return .success
            } else {
                return .commandFailed
            }
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget() { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if (self?.audioPlayer?.isPlaying ?? false) {
                self?.pausePlayback()
                return .success
            } else {
                return .commandFailed
            }
        }
        MPRemoteCommandCenter.shared().stopCommand.addTarget() { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.stopPlayback()
            return .success
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteChanged), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterrupted(notification:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)

    }

    @objc private func audioSessionRouteChanged(notification: Notification) {
        guard let audioSessionRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as? UInt else {
            if audioPlayer?.isPlaying ?? false {
                pausePlayback()
            }
            return
        }
        
        switch audioSessionRouteChangeReason {
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            if audioPlayer?.isPlaying ?? false {
                pausePlayback()
            }
        default:
            break
        }
    }

    @objc func audioSessionInterrupted(notification: Notification) {
        guard let userInfo = notification.userInfo, let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSessionInterruptionType(rawValue: typeInt) else { return }

        switch interruptionType {
        case .began:
            pausePlayback()
        case .ended:
            // We don't want to resume automatically after an interruption.
            break
        }
    }

    @objc func startPlayingAtSong(_ song: Song, tuneIndex: Int) {
        currentSong = song
        currentTuneIndex = tuneIndex
        
        let songAudioFiles = audioFileURLsForSong(song)
        guard tuneIndex >= 0 && tuneIndex < songAudioFiles.count else {
            if AudioPlayer.playbackMode == .continuous {
                playNext()
            }
            return
        }
        
        let audioFile = songAudioFiles[tuneIndex]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

            audioPlayer?.stop()

            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
            guard let audioPlayer = audioPlayer else { return }

            audioPlayer.delegate = self
            audioPlayer.play()
            
            var titleString = ""
            if let number = song.number {
                titleString.append("\(number.stringValue): ")
            }
            if let title = song.title {
                titleString.append(title)
            }
            if songAudioFiles.count > 1 {
                titleString.append(" (Tune \(currentTuneIndex + 1))")
            }

            let albumString = [song.section.title ?? "", song.section.book.title ?? ""].filter { $0.count > 0 }.joined(separator: " - ")

            let artworkSize = CGSize(width: 10, height: 10)
            let albumArt = MPMediaItemArtwork(boundsSize: artworkSize) { (size) -> UIImage in
                UIGraphicsBeginImageContextWithOptions(artworkSize, true, 0)
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let startColorComp = Theme.coverColorOne.cgColor.components ?? []
                let endColorComp = Theme.coverColorTwo.cgColor.components ?? []
                let colorComps =  startColorComp + endColorComp
                let locations:[CGFloat] = [0.0, 1.0]
                let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colorComps, locations: locations, count: 2)!
                
                let startPoint = CGPoint(x: 0, y: 0)
                let endPoint = CGPoint(x: 0, y: artworkSize.height)
                UIGraphicsGetCurrentContext()?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
                
                let image = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                return image
            }
            
            var nowPlayingInfo: [String: Any] = [MPMediaItemPropertyTitle: titleString,
                                                 MPMediaItemPropertyAlbumTitle: albumString,
                                                 MPMediaItemPropertyArtwork: albumArt,
                                                 MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue]


            if let author = song.author {
                nowPlayingInfo[MPMediaItemPropertyArtist] = author
            }

            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

            updateNowPlayingInfoCenterProgress()

            delegate?.audioPlayerStartedPlayingSong(song, tuneIndex: tuneIndex)
            
        } catch {
            NSLog("Failed to start playing audio file: \(error)")
        }
        
    }
    
    private func pausePlayback() {
        updateNowPlayingInfoCenterProgress()
        audioPlayer?.pause()
        updateNowPlayingInfoCenterProgress()
        delegate?.audioPlayerStopped()
    }

    @objc func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil

        currentSong = nil
        currentTuneIndex = 0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        
        delegate?.audioPlayerStopped()
    }
    
    private func playNext() {
        guard let currentSong = currentSong else {
            stopPlayback()
            return
        }
        
        // Check if the current song has more tunes.
        let audioFilesForCurrentSong = audioFileURLsForSong(currentSong)
        if currentTuneIndex < audioFilesForCurrentSong.count - 1 {
            // Play the next tune for the current song.
            startPlayingAtSong(currentSong, tuneIndex: currentTuneIndex + 1)
            return
        }
        
        // Find the next song with a tune
        var model: SongbookModel? = currentSong
        while let nextModel = model?.nextObject() {
            if let nextSong = nextModel as? Song {
                let audioFilesForNextSong = audioFileURLsForSong(nextSong)
                if audioFilesForNextSong.count > 0 {
                    startPlayingAtSong(nextSong, tuneIndex: 0)
                    return
                }
            }
            model = nextModel
        }
        
        // Start over from the beginning.
        if (hasSongFiles) {
            startPlayingAtSong(currentSong.section.book.closestSong(), tuneIndex: 0)
        } else {
            stopPlayback()
        }
    }
    
    private func playPrevious() {
        guard let currentSong = currentSong else {
            stopPlayback()
            return
        }
        
        // Check if the current song has more tunes.
        if currentTuneIndex > 0 {
            // Play the previous tune for the current song.
            startPlayingAtSong(currentSong, tuneIndex: currentTuneIndex - 1)
            return
        }
        
        // Find the previous song with a tune
        var model: SongbookModel? = currentSong
        while let previousModel = model?.previousObject() {
            if let previousSong = previousModel as? Song {
                let audioFilesForPreviousSong = audioFileURLsForSong(previousSong)
                if audioFilesForPreviousSong.count > 0 {
                    startPlayingAtSong(previousSong, tuneIndex: audioFilesForPreviousSong.count - 1)
                    return
                }
            }
            model = previousModel
        }
        
        stopPlayback()
    }
    
    @objc func audioFileURLsForSong(_ song: Song) -> [URL] {
        let songIndex = song.section.songs.index(of: song)
        let sectionIndex = song.section.book.sections.index(of: song.section)
        let filePrefixA = "\(sectionIndex)-\(songIndex)."
        let filePrefixB = "\(sectionIndex)-\(songIndex)-"

        var matchingAudioFileURLs = audioFileURLs.filter {
            $0.lastPathComponent.hasPrefix(filePrefixA) ||
            $0.lastPathComponent.hasPrefix(filePrefixB)
        }
        
        matchingAudioFileURLs.sort { (fileURL1, fileURL2) -> Bool in
            return fileURL1.lastPathComponent.localizedCaseInsensitiveCompare(fileURL2.lastPathComponent) == .orderedAscending
        }
        
        return matchingAudioFileURLs
    }
    
    private func updateNowPlayingInfoCenterProgress() {
        guard let audioPlayer = audioPlayer else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()

        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.isPlaying ? 1 : 0
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = audioPlayer.isPlaying ? 1 : 0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch AudioPlayer.playbackMode {
        case .single:
            stopPlayback()
        case .continuous:
            playNext()
        case .repeatOne:
            if let currentSong = currentSong {
                startPlayingAtSong(currentSong, tuneIndex: currentTuneIndex)
            } else {
                stopPlayback()
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopPlayback()
    }
}

@objc protocol AudioPlayerDelegate {
    func audioPlayerStopped()
    func audioPlayerStartedPlayingSong(_ song: Song, tuneIndex: Int)
    func currentSong() -> Song?
}

@objc enum PlaybackMode: Int {
    case single = 0
    case continuous = 1
    case repeatOne = 2
}
