// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:openim_common/openim_common.dart';
import 'video_transcoder.dart';

/// Example usage of VideoTranscoder utility
class VideoTranscoderExample {
  /// Example: Transcode video before sending
  static Future<File?> prepareVideoForSending(File originalVideo) async {
    try {
      // Check if video is already iOS compatible
      final isCompatible = await VideoTranscoder.isIOSCompatible(originalVideo);
      if (isCompatible) {
        Logger.print('[Example] Video is already iOS compatible');
        return originalVideo;
      }

      // Get video info
      final videoInfo = await VideoTranscoder.getVideoInfo(originalVideo);
      if (videoInfo != null) {
        Logger.print('[Example] Original video info: $videoInfo');
      }

      // Transcode to iOS compatible format
      Logger.print('[Example] Transcoding video for iOS compatibility...');
      final transcodedFile =
          await VideoTranscoder.transcodeForIOS(originalVideo);

      if (transcodedFile != null) {
        Logger.print(
            '[Example] Video transcoded successfully: ${transcodedFile.path}');

        // Get transcoded video info
        final transcodedInfo =
            await VideoTranscoder.getVideoInfo(transcodedFile);
        if (transcodedInfo != null) {
          Logger.print('[Example] Transcoded video info: $transcodedInfo');
        }

        return transcodedFile;
      } else {
        Logger.print('[Example] Video transcode failed');
        return null;
      }
    } catch (e) {
      Logger.print('[Example] Error preparing video: $e');
      return null;
    }
  }

  /// Example: Check video compatibility before playing
  static Future<bool> checkVideoCompatibility(File videoFile) async {
    try {
      // Get video info
      final videoInfo = await VideoTranscoder.getVideoInfo(videoFile);
      if (videoInfo == null) {
        Logger.print('[Example] Could not get video info');
        return false;
      }

      // Check video streams
      final streams = videoInfo['streams'] as List?;
      if (streams == null || streams.isEmpty) {
        Logger.print('[Example] No video streams found');
        return false;
      }

      bool hasVideo = false;
      bool hasAudio = false;

      for (final stream in streams) {
        final codecType = stream['codec_type'];
        final codecName = stream['codec_name'];

        if (codecType == 'video') {
          hasVideo = true;
          Logger.print('[Example] Video codec: $codecName');
        } else if (codecType == 'audio') {
          hasAudio = true;
          Logger.print('[Example] Audio codec: $codecName');
        }
      }

      if (!hasVideo) {
        Logger.print('[Example] No video stream found');
        return false;
      }

      // Check iOS compatibility
      final isCompatible = await VideoTranscoder.isIOSCompatible(videoFile);
      Logger.print('[Example] iOS compatible: $isCompatible');

      return isCompatible;
    } catch (e) {
      Logger.print('[Example] Error checking video compatibility: $e');
      return false;
    }
  }

  /// Example: Get video metadata
  static Future<Map<String, dynamic>?> getVideoMetadata(File videoFile) async {
    try {
      final videoInfo = await VideoTranscoder.getVideoInfo(videoFile);
      if (videoInfo == null) {
        return null;
      }

      final format = videoInfo['format'];
      final streams = videoInfo['streams'] as List?;

      if (format == null || streams == null) {
        return null;
      }

      // Extract video stream info
      Map<String, dynamic>? videoStream;
      Map<String, dynamic>? audioStream;

      for (final stream in streams) {
        final codecType = stream['codec_type'];
        if (codecType == 'video' && videoStream == null) {
          videoStream = stream;
        } else if (codecType == 'audio' && audioStream == null) {
          audioStream = stream;
        }
      }

      // Build metadata
      final metadata = <String, dynamic>{
        'duration': format['duration'] != null
            ? (double.parse(format['duration'].toString()) * 1000).round()
            : null,
        'size': format['size'] != null
            ? int.parse(format['size'].toString())
            : null,
        'bitrate': format['bit_rate'] != null
            ? int.parse(format['bit_rate'].toString())
            : null,
        'video': videoStream != null
            ? {
                'codec': videoStream['codec_name'],
                'width': videoStream['width'],
                'height': videoStream['height'],
                'fps': videoStream['r_frame_rate'],
              }
            : null,
        'audio': audioStream != null
            ? {
                'codec': audioStream['codec_name'],
                'channels': audioStream['channels'],
                'sampleRate': audioStream['sample_rate'],
              }
            : null,
      };

      return metadata;
    } catch (e) {
      Logger.print('[Example] Error getting video metadata: $e');
      return null;
    }
  }

  /// Example: Clean up old transcoded files
  static Future<void> cleanupExample() async {
    try {
      Logger.print('[Example] Cleaning up old transcoded files...');
      await VideoTranscoder.cleanupOldTranscodedFiles(days: 7);
      Logger.print('[Example] Cleanup completed');
    } catch (e) {
      Logger.print('[Example] Cleanup error: $e');
    }
  }
}
