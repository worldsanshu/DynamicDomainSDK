import 'dart:async';
import 'dart:io';
import 'dart:convert';

// import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:openim_common/openim_common.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';


/// Utility class for video transcoding operations
class VideoTranscoder {
  VideoTranscoder._();

  /// Transcode video to iOS-compatible format
  static Future<File?> transcodeForIOS(File sourceFile,
      {String? outputPath}) async {
    try {
      Logger.print(
          '[VideoTranscoder] Starting iOS transcode: ${sourceFile.path}');

      // Check source file
      if (!sourceFile.existsSync()) {
        Logger.print('[VideoTranscoder] Source file does not exist');
        return null;
      }

      final srcSize = await sourceFile.length();
      if (srcSize == 0) {
        Logger.print('[VideoTranscoder] Source file is empty');
        return null;
      }

      // Generate output path if not provided
      String outPath = outputPath ?? '';
      if (outPath.isEmpty) {
        final libDir = await getLibraryDirectory();
        final cachesBase = Directory('${libDir.path}/Caches/transcoded');
        if (!await cachesBase.exists()) {
          await cachesBase.create(recursive: true);
        }
        final fileName =
            'transcoded_${DateTime.now().millisecondsSinceEpoch}.mp4';
        outPath = '${cachesBase.path}/$fileName';
      }

      final outFile = File(outPath);

      // Use iOS-compatible ffmpeg settings
      final cmd = '-y -i "${sourceFile.path}" '
          '-c:v libx264 -preset ultrafast -profile:v baseline -level 3.0 '
          '-pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" '
          '-c:a aac -b:a 128k -ac 2 -ar 44100 '
          '-movflags +faststart -f mp4 '
          '"$outPath"';

      Logger.print('[VideoTranscoder] FFmpeg command: $cmd');

      final session = await FFmpegKit.execute(cmd);
      final returnCode = await session.getReturnCode();
      final logs = await session.getLogs();

      Logger.print('[VideoTranscoder] FFmpeg return code: $returnCode');
      for (final log in logs) {
        Logger.print('[VideoTranscoder] FFmpeg log: ${log.getMessage()}');
      }

      if (!ReturnCode.isSuccess(returnCode)) {
        Logger.print('[VideoTranscoder] FFmpeg transcode failed');
        return null;
      }

      // Verify output file
      if (!outFile.existsSync()) {
        Logger.print('[VideoTranscoder] Transcoded file was not created');
        return null;
      }

      final outSize = await outFile.length();
      if (outSize == 0) {
        Logger.print('[VideoTranscoder] Transcoded file is empty');
        return null;
      }

      Logger.print(
          '[VideoTranscoder] Transcode completed successfully: $outPath ($outSize bytes)');
      return outFile;
    } catch (e, s) {
      Logger.print('[VideoTranscoder] Transcode error: $e\n$s');
      return null;
    }
  }

  /// Transcode video to Android-compatible format for MediaCodec compatibility
  static Future<File?> transcodeForAndroid(File sourceFile,
      {String? outputPath}) async {
    try {
      Logger.print(
          '[VideoTranscoder] Starting Android transcode: ${sourceFile.path}');

      // Check source file
      if (!sourceFile.existsSync()) {
        Logger.print('[VideoTranscoder] Source file does not exist');
        return null;
      }

      final srcSize = await sourceFile.length();
      if (srcSize == 0) {
        Logger.print('[VideoTranscoder] Source file is empty');
        return null;
      }

      // Generate output path if not provided
      String outPath = outputPath ?? '';
      if (outPath.isEmpty) {
        // Use different directory for Android vs iOS
        Directory cachesBase;
        if (Platform.isAndroid) {
          final appDocDir = await getApplicationDocumentsDirectory();
          cachesBase = Directory('${appDocDir.path}/android_transcoded');
        } else {
          final libDir = await getLibraryDirectory();
          cachesBase = Directory('${libDir.path}/Caches/android_transcoded');
        }

        if (!await cachesBase.exists()) {
          await cachesBase.create(recursive: true);
        }
        final fileName =
            'android_transcoded_${DateTime.now().millisecondsSinceEpoch}.mp4';
        outPath = '${cachesBase.path}/$fileName';
      }

      final outFile = File(outPath);

      // Use Android-compatible ffmpeg settings with FORCED resolution scaling
      // Force scale down to 1080p or lower for maximum MediaCodec compatibility
      final cmd = '-y -i "${sourceFile.path}" '
          '-c:v libx264 -preset fast -profile:v baseline -level 3.0 '
          '-pix_fmt yuv420p '
          '-vf "scale=1920:1080:force_original_aspect_ratio=decrease" '
          '-c:a aac -b:a 128k -ac 2 -ar 44100 '
          '-movflags +faststart -f mp4 '
          '"$outPath"';

      Logger.print('[VideoTranscoder] Android FFmpeg command: $cmd');

      final session = await FFmpegKit.execute(cmd);
      final returnCode = await session.getReturnCode();
      final logs = await session.getLogs();

      Logger.print('[VideoTranscoder] Android FFmpeg return code: $returnCode');
      for (final log in logs) {
        Logger.print(
            '[VideoTranscoder] Android FFmpeg log: ${log.getMessage()}');
      }

      if (!ReturnCode.isSuccess(returnCode)) {
        Logger.print('[VideoTranscoder] Android FFmpeg transcode failed');
        return null;
      }

      // Verify output file
      if (!outFile.existsSync()) {
        Logger.print(
            '[VideoTranscoder] Android transcoded file was not created');
        return null;
      }

      final outSize = await outFile.length();
      if (outSize == 0) {
        Logger.print('[VideoTranscoder] Android transcoded file is empty');
        return null;
      }

      Logger.print(
          '[VideoTranscoder] Android transcode completed successfully: $outPath ($outSize bytes)');
      return outFile;
    } catch (e, s) {
      Logger.print('[VideoTranscoder] Android transcode error: $e\n$s');
      return null;
    }
  }

  /// Transcode video to Android-compatible format with multiple fallback resolutions
  static Future<File?> transcodeForAndroidWithFallback(File sourceFile,
      {String? outputPath}) async {
    try {
      Logger.print(
          '[VideoTranscoder] Starting Android transcode with fallback: ${sourceFile.path}');

      // Check source file
      if (!sourceFile.existsSync()) {
        Logger.print('[VideoTranscoder] Source file does not exist');
        return null;
      }

      final srcSize = await sourceFile.length();
      if (srcSize == 0) {
        Logger.print('[VideoTranscoder] Source file is empty');
        return null;
      }

      // Generate output path if not provided
      String outPath = outputPath ?? '';
      if (outPath.isEmpty) {
        // Use different directory for Android vs iOS
        Directory cachesBase;
        if (Platform.isAndroid) {
          final appDocDir = await getApplicationDocumentsDirectory();
          cachesBase = Directory('${appDocDir.path}/android_transcoded');
        } else {
          final libDir = await getLibraryDirectory();
          cachesBase = Directory('${libDir.path}/Caches/android_transcoded');
        }

        if (!await cachesBase.exists()) {
          await cachesBase.create(recursive: true);
        }
        final fileName =
            'android_transcoded_${DateTime.now().millisecondsSinceEpoch}.mp4';
        outPath = '${cachesBase.path}/$fileName';
      }

      // Try multiple resolutions for maximum compatibility
      final resolutions = [
        {'width': 1920, 'height': 1080, 'name': '1080p'},
        {'width': 1280, 'height': 720, 'name': '720p'},
        {'width': 854, 'height': 480, 'name': '480p'},
        {'width': 640, 'height': 360, 'name': '360p'},
      ];

      for (final resolution in resolutions) {
        try {
          Logger.print(
              '[VideoTranscoder] Trying ${resolution['name']} resolution...');

          final outFile = File(outPath);

          // Use Android-compatible ffmpeg settings with specific resolution
          final cmd = '-y -i "${sourceFile.path}" '
              '-c:v libx264 -preset ultrafast -profile:v baseline -level 3.0 '
              '-pix_fmt yuv420p '
              '-vf "scale=${resolution['width']}:${resolution['height']}:force_original_aspect_ratio=decrease" '
              '-c:a aac -b:a 96k -ac 2 -ar 44100 '
              '-movflags +faststart -f mp4 '
              '"$outPath"';

          Logger.print(
              '[VideoTranscoder] Android FFmpeg command for ${resolution['name']}: $cmd');

          final session = await FFmpegKit.execute(cmd);
          final returnCode = await session.getReturnCode();

          if (ReturnCode.isSuccess(returnCode)) {
            // Verify output file
            if (await outFile.exists() && await outFile.length() > 0) {
              Logger.print(
                  '[VideoTranscoder] Android transcode completed successfully with ${resolution['name']}: $outPath');
              return outFile;
            }
          } else {
            Logger.print(
                '[VideoTranscoder] ${resolution['name']} transcode failed');
          }
        } catch (e) {
          Logger.print(
              '[VideoTranscoder] ${resolution['name']} transcode error: $e');
          continue; // Try next resolution
        }
      }

      Logger.print('[VideoTranscoder] All Android transcode attempts failed');
      return null;
    } catch (e, s) {
      Logger.print(
          '[VideoTranscoder] Android transcode with fallback error: $e\n$s');
      return null;
    }
  }

  /// Check if video is iOS compatible
  static Future<bool> isIOSCompatible(File videoFile) async {
    try {
      final controller = VideoPlayerController.file(
        videoFile,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await controller.initialize();
      await controller.dispose();
      return true;
    } catch (e) {
      Logger.print('[VideoTranscoder] Video not iOS compatible: $e');
      return false;
    }
  }

  /// Check if video is Android compatible (MediaCodec compatible)
  static Future<bool> isAndroidCompatible(File videoFile) async {
    try {
      final controller = VideoPlayerController.file(
        videoFile,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await controller.initialize();
      await controller.dispose();
      return true;
    } catch (e) {
      Logger.print('[VideoTranscoder] Video not Android compatible: $e');
      return false;
    }
  }

  /// Get video information using FFprobe
  static Future<Map<String, dynamic>?> getVideoInfo(File videoFile) async {
    try {
      final cmd =
          '-v quiet -print_format json -show_format -show_streams "${videoFile.path}"';
      final session = await FFmpegKit.execute(cmd);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final output = await session.getOutput();
        if (output != null && output.isNotEmpty) {
          return jsonDecode(output);
        }
      }
      return null;
    } catch (e) {
      Logger.print('[VideoTranscoder] Failed to get video info: $e');
      return null;
    }
  }

  /// Get video duration in milliseconds
  static Future<int?> getVideoDuration(File videoFile) async {
    try {
      final info = await getVideoInfo(videoFile);
      if (info != null && info['format'] != null) {
        final duration = info['format']['duration'];
        if (duration != null) {
          return (double.parse(duration.toString()) * 1000).round();
        }
      }
      return null;
    } catch (e) {
      Logger.print('[VideoTranscoder] Failed to get video duration: $e');
      return null;
    }
  }

  /// Get video resolution
  static Future<Map<String, int>?> getVideoResolution(File videoFile) async {
    try {
      final info = await getVideoInfo(videoFile);
      if (info != null && info['streams'] != null) {
        final streams = info['streams'] as List;
        for (final stream in streams) {
          if (stream['codec_type'] == 'video') {
            final width = stream['width'];
            final height = stream['height'];
            if (width != null && height != null) {
              return {
                'width': width,
                'height': height,
              };
            }
          }
        }
      }
      return null;
    } catch (e) {
      Logger.print('[VideoTranscoder] Failed to get video resolution: $e');
      return null;
    }
  }

  /// Clean up transcoded files older than specified days
  static Future<void> cleanupOldTranscodedFiles({int days = 7}) async {
    try {
      final libDir = await getLibraryDirectory();
      final cachesBase = Directory('${libDir.path}/Caches/transcoded');

      if (!await cachesBase.exists()) {
        return;
      }

      final files = await cachesBase.list().toList();
      final cutoffTime = DateTime.now().subtract(Duration(days: days));

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await file.delete();
            Logger.print(
                '[VideoTranscoder] Deleted old transcoded file: ${file.path}');
          }
        }
      }
    } catch (e) {
      Logger.print('[VideoTranscoder] Cleanup error: $e');
    }
  }

  /// Get transcoded file path for a given source file
  static Future<String> getTranscodedPath(String sourcePath) async {
    final libDir = await getLibraryDirectory();
    final cachesBase = Directory('${libDir.path}/Caches/transcoded');
    if (!await cachesBase.exists()) {
      await cachesBase.create(recursive: true);
    }

    final fileName = 'transcoded_${DateTime.now().millisecondsSinceEpoch}.mp4';
    return '${cachesBase.path}/$fileName';
  }
}
