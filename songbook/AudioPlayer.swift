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
    
    private let audioFileDirectory: URL
    private var audioPlayer: AVAudioPlayer?
    private var currentSong: Song?
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
            self?.audioPlayer?.play()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget() { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.audioPlayer?.pause()
            return .success
        }
        MPRemoteCommandCenter.shared().stopCommand.addTarget() { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.stopPlayback()
            return .success
        }
    }
    
    @objc func startPlayingAtSong(_ song: Song, tuneIndex: Int) {
        currentSong = song
        currentTuneIndex = tuneIndex
        
        let songAudioFiles = audioFileURLsForSong(song)
        guard tuneIndex >= 0 && tuneIndex < songAudioFiles.count else {
            playNext()
            return
        }
        
        let audioFile = songAudioFiles[tuneIndex]
        
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
            audioPlayer?.delegate = self
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            audioPlayer?.play()
            
            var titleString = ""
            if let number = song.number {
                titleString.append("\(number.stringValue): ")
            }
            if let title = song.title {
                titleString.append(title)
            }
            if songAudioFiles.count > 1 {
                titleString.append(" (Tune \(tuneIndex + 1))")
            }
            
            let albumString = [song.section.title ?? "", song.section.book.title ?? ""].filter { $0.count > 0 }.joined(separator: " - ")
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: titleString,
                                                               MPMediaItemPropertyAlbumTitle: albumString,
                                                               MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue]
            
            delegate?.audioPlayerStarted()
            
        } catch {
            NSLog("Failed to start playing audio file: \(error)")
        }
        
    }

    @objc func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        
        currentSong = nil
        currentTuneIndex = 0
        
        UIApplication.shared.endReceivingRemoteControlEvents()
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
        while let nextModel = model?.nextObject() as? SongbookModel {
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
        while let previousModel = model?.previousObject() as? SongbookModel {
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
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNext()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopPlayback()
    }
}

@objc protocol AudioPlayerDelegate {
    func audioPlayerStopped()
    func audioPlayerStarted()
}
