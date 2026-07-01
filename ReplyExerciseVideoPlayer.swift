import SwiftUI
import AVKit

struct ReplyExerciseVideoPlayer: View {
    var exercise: Exercise
    var height: CGFloat = 310

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var body: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
                    .disabled(true)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .onAppear { player.play() }
                    .onDisappear { player.pause() }
            } else {
                ReplyMissingVideoPlaceholder(exercise: exercise)
            }
        }
        .frame(height: height)
        .onAppear {
            setupPlayerIfPossible()
        }
    }

    private func setupPlayerIfPossible() {
        guard player == nil else { return }

        let extensions = ["mp4", "mov", "m4v"]
        let folders = [nil, "ExerciseVideos", "StarterVideos", "Videos"]

        for folder in folders {
            for ext in extensions {
                if let url = Bundle.main.url(
                    forResource: exercise.videoName,
                    withExtension: ext,
                    subdirectory: folder
                ) {
                    startPlayer(url: url)
                    return
                }
            }
        }

        if let remote = exercise.remoteVideoURL,
           let remoteURL = URL(string: remote),
           remoteURL.scheme?.hasPrefix("http") == true {
            startPlayer(url: remoteURL)
        }
    }

    private func startPlayer(url: URL) {
        let item = AVPlayerItem(url: url)
        let queue = AVQueuePlayer(playerItem: item)
        let playerLooper = AVPlayerLooper(player: queue, templateItem: item)
        queue.isMuted = true
        queue.actionAtItemEnd = .none
        self.player = queue
        self.looper = playerLooper
        queue.play()
    }
}

struct ReplyMissingVideoPlaceholder: View {
    var exercise: Exercise

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.black.gradient)

            VStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.white)

                Text("Video needed")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))

                Text("\(exercise.videoName).mp4")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))

                Text("Put it in the ExerciseVideos folder and tick the app target.")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}
