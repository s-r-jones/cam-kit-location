//  Copyright Snap Inc. All rights reserved.

import AVFoundation
import SCSDKCameraKit
import UIKit

/// Sample video recorder implementation.
public class Recorder {
    /// The URL to write the video to.
    private let outputURL: URL

    /// The AVWriterOutput for CameraKt.
    public let output: AVWriterOutput

    private let writer: AVAssetWriter
    private let videoInput: AVAssetWriterInput
    private let pixelBufferInput: AVAssetWriterInputPixelBufferAdaptor

    private let audioInput: AVAssetWriterInput = {
        let compressionAudioSettings: [String: Any] =
            [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVEncoderBitRateKey: 128_000,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
            ]

        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: compressionAudioSettings)
        audioInput.expectsMediaDataInRealTime = true
        return audioInput
    }()

    /// Designated init to pass in required deps
    /// - Parameters:
    ///   - url: output URL of video file
    ///   - orientation: current orientation of device
    ///   - size: height of video output
    /// - Throws: Throws error if cannot create asset writer with output file URL and file type
    public init(url: URL, orientation: AVCaptureVideoOrientation, size: CGSize) throws {
        self.outputURL = url
        self.writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
        self.videoInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoHeightKey: size.height,
                AVVideoWidthKey: size.width,
                AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
            ]
        )
        videoInput.expectsMediaDataInRealTime = true
        videoInput.transform = Recorder.affineTransform(orientation: orientation, mirrored: false)

        self.pixelBufferInput = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            ]
        )

        writer.add(videoInput)
        writer.add(audioInput)

        self.output = AVWriterOutput(avAssetWriter: writer, pixelBufferInput: pixelBufferInput, audioInput: audioInput)
    }

    public func startRecording() {
        writer.startWriting()
        output.startRecording()
    }

    public func finishRecording(completion: ((URL?, Error?) -> Void)?) {
        output.stopRecording()
        videoInput.markAsFinished()
        audioInput.markAsFinished()
        writer.finishWriting { [weak self] in
            completion?(self?.outputURL, nil)
        }
    }

    private static func affineTransform(orientation: AVCaptureVideoOrientation, mirrored: Bool)
        -> CGAffineTransform
    {
        var transform: CGAffineTransform = .identity
        switch orientation {
        case .portraitUpsideDown:
            transform = transform.rotated(by: .pi)
        case .landscapeRight:
            transform = transform.rotated(by: .pi / 2)
        case .landscapeLeft:
            transform = transform.rotated(by: -.pi / 2)
        default:
            break
        }

        if mirrored {
            transform = transform.scaledBy(x: -1, y: 1)
        }

        return transform
    }
}

private extension AVCaptureVideoOrientation {
    var isPortrait: Bool {
        self == .portrait || self == .portraitUpsideDown
    }
}
