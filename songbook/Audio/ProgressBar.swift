import SwiftUI

/// An interactive media playback progress bar.
struct ProgressBar: View {
    /// The manual progress percentage while dragging.
    @State private var adjustedProgress: Double = 0 {
        didSet {
            /// Generate impact feedback when the progress hits one of the edges of the bar while
            /// dragging.
            if adjustedProgress >= 1 && oldValue < 1 ||
               adjustedProgress <= 0 && oldValue > 0 {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    /// The shared audio player.
    @EnvironmentObject private var audioPlayer: AudioPlayer

    /// The shared audio player progress.
    @EnvironmentObject private var audioPlayerProgress: AudioPlayerProgress

    /// The visual height of the progress bar.
    @State private var barHeight: CGFloat = 5

    /// `true` iff the user is dragging the progress bar to a new location.
    @State private var dragging = false

    /// The current progress percentage to display in the progress bar.
    private var progress: Double {
        dragging ? adjustedProgress : audioPlayerProgress.progress
    }

    /// The actual progress percentage when a drag interaction started.
    @State private var progressAtDragStart: Double = 0

    /// The height of the touchable area in the progress bar. The touchable area is taller than the
    /// visual height of the progress bar.
    private let touchHeight: CGFloat = 40

    var body: some View {
        GeometryReader { proxy in
            Group {
                ZStack(alignment: .leading) {
                    Color.accentColor.opacity(audioPlayer.isPlaying ? 0.2 : 0)
                    Color.accentColor.frame(width: progress * proxy.size.width)
                }
                .background(.background.secondary)
                .frame(height: audioPlayer.isPlaying ? barHeight : 0)
            }
            .clipped()
            .frame(height: touchHeight, alignment: .bottom)
            .contentShape(Rectangle())
            .allowsHitTesting(audioPlayer.isPlaying)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !dragging {
                            dragging = true
                            progressAtDragStart = audioPlayerProgress.progress
                            withAnimation {
                                barHeight = 15
                            }
                        }
                        adjustedProgress = (progressAtDragStart +
                            (value.translation.width / proxy.size.width)).limited(0...1)
                    }
                    .onEnded { value in
                        withAnimation {
                            barHeight = 5
                        }
                        dragging = false
                        adjustedProgress = (progressAtDragStart +
                            (value.translation.width / proxy.size.width)).limited(0...1)
                        audioPlayerProgress.seek(to: adjustedProgress)
                    }
            )
        }
        .frame(height: touchHeight)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar().frame(height: 10)
    }
}
