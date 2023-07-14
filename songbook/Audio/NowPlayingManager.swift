import AVFoundation
import BookModel
import MediaPlayer

enum NowPlayingManager {
    private static let albumArt = MPMediaItemArtwork(boundsSize: CGSize(width: 10, height: 10)) { size -> UIImage in
        UIGraphicsBeginImageContextWithOptions(size, true, 0)

        let colorSpace = CGColorSpace(name: CGColorSpace.displayP3) ?? CGColorSpaceCreateDeviceRGB()
        let startColorComp = Theme.coverColorOne.cgColor.components ?? []
        let endColorComp = Theme.coverColorTwo.cgColor.components ?? []
        let colorComps =  startColorComp + endColorComp
        let locations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colorComps, locations: locations, count: 2)!

        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: 0, y: size.height)
        UIGraphicsGetCurrentContext()?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    static func updateNowPlaying(
        for item: PlayableItem?,
        with player: AVAudioPlayer?
    ) {
        let center = MPNowPlayingInfoCenter.default()
        guard let item, let player else {
#if os(macOS)
            center.playbackState = .stopped
#endif
            center.nowPlayingInfo = nil
            return
        }
#if os(macOS)
        center.playbackState = .playing
#endif
        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = item.albumTitle
        nowPlayingInfo[MPMediaItemPropertyAlbumTrackCount] = NSNumber(value: UInt(item.albumTrackCount))
        nowPlayingInfo[MPMediaItemPropertyAlbumTrackNumber] = NSNumber(value: UInt(item.albumTrackNumber))
        nowPlayingInfo[MPMediaItemPropertyArtist] = item.author
        nowPlayingInfo[MPMediaItemPropertyArtwork] = albumArt
        nowPlayingInfo[MPMediaItemPropertyMediaType] = NSNumber(value: MPMediaType.music.rawValue)
        // Setting this causes the now playing UI to remember the progress each item. We don't want
        // that behavior. Each song should start at the beginning when it starts playing.
        //        nowPlayingInfo[MPMediaItemPropertyPersistentID] = NSNumber(value: UInt64(item.persistentId) as MPMediaEntityPersistentID)
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: player.duration)
        nowPlayingInfo[MPMediaItemPropertyTitle] = item.title
        nowPlayingInfo[MPNowPlayingInfoCollectionIdentifier] = item.albumTitle
        nowPlayingInfo[MPNowPlayingInfoPropertyAssetURL] = item.audioFileURL
        //        nowPlayingInfo[MPNowPlayingInfoPropertyChapterCount] = NSNumber(value: 2 as UInt)
        //        nowPlayingInfo[MPNowPlayingInfoPropertyChapterNumber] = NSNumber(value: 1 as UInt)
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = NSNumber(value: 1.0 as Double)
        //        nowPlayingInfo[MPNowPlayingInfoPropertyExternalContentIdentifier] = "\(item.persistentId)"
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = NSNumber(value: false)
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = NSNumber(value: MPNowPlayingInfoMediaType.audio.rawValue)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueCount] = NSNumber(value: UInt(item.albumTrackCount))
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueIndex] = NSNumber(value: UInt(item.albumTrackNumber - 1))
        //        nowPlayingInfo[MPNowPlayingInfoPropertyServiceIdentifier] = "Service"

        let currentTime = player.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: (player.isPlaying ? 1.0 : 0.0) as Double)
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: currentTime as Double)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = NSNumber(value: Float(currentTime / player.duration))

        center.nowPlayingInfo = nowPlayingInfo
    }
}
