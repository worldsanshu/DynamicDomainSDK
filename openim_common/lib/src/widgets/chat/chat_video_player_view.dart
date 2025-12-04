// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../custom_cupertino_controls.dart';
import '../../utils/video_transcoder.dart';

abstract class VideoControllerService {
  Future<VideoPlayerController> getVideo(String videoUrl);

  Future<File?> getCacheFile(String videoUrl);
}

class CachedVideoControllerService extends VideoControllerService {
  final BaseCacheManager _cacheManager;

  CachedVideoControllerService(this._cacheManager);

  @override
  Future<VideoPlayerController> getVideo(String videoUrl) async {
    final file = await getCacheFile(videoUrl);

    if (file == null) {
      Logger.print('[VideoControllerService]: No video in cache');

      Logger.print('[VideoControllerService]: Saving video to cache');
      unawaited(_cacheManager.downloadFile(videoUrl));

      return VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    } else {
      Logger.print('[VideoControllerService]: Loading video from cache');
      return VideoPlayerController.file(
        file,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    }
  }

  @override
  Future<File?> getCacheFile(String videoUrl) async {
    final fileInfo = await _cacheManager.getFileFromCache(videoUrl);

    return fileInfo?.file;
  }

  Future<File> ensureLocalFile(String videoUrl) async {
    final cached = await getCacheFile(videoUrl);
    if (cached != null) return cached;
    // Download to cache and return file
    final downloaded = await _cacheManager.getSingleFile(videoUrl);
    return downloaded;
  }
}

class ChatVideoPlayerView extends StatefulWidget {
  const ChatVideoPlayerView({
    super.key,
    this.path,
    this.url,
    this.coverUrl,
    this.file,
    this.heroTag,
    this.onDownload,
    this.autoPlay = true,
    this.muted = false,
  });

  final String? path;
  final String? url;
  final File? file;
  final String? coverUrl;
  final String? heroTag;
  final bool autoPlay;
  final bool muted;
  final Function(String? url, File? file)? onDownload;

  @override
  State<ChatVideoPlayerView> createState() => _ChatVideoPlayerViewState();
}

class _ChatVideoPlayerViewState extends State<ChatVideoPlayerView>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  String? _initError;
  bool _isTranscoding = false;
  bool _isOpeningExternally = false;

  final _cachedVideoControllerService =
      CachedVideoControllerService(DefaultCacheManager());

  @override
  void initState() {
    initializePlayer();
    super.initState();
  }

  @override
  void dispose() {
    Logger.print('[ChatVideoPlayerView]: dispose');

    () async {
      await _chewieController?.pause();
      await _videoPlayerController.pause();
      await _videoPlayerController.dispose();
      _chewieController?.dispose();
    }();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _initError = null;
    var file = widget.file;

    // Try to resolve local file first
    if (file == null) {
      String? candidatePath = _path;
      if (IMUtils.isNotNullEmptyStr(candidatePath)) {
        // Normalize iOS cache path if needed
        if (Platform.isIOS && candidatePath!.contains('/Library/Caches/')) {
          final libDir = await getLibraryDirectory();
          final cachesBase = '${libDir.path}/Caches';
          final suffix = candidatePath.split('/Library/Caches').last;
          candidatePath = cachesBase + suffix;
        }

        // On Android, ensure storage permission when accessing external storage
        bool canAccess = true;
        if (Platform.isAndroid) {
          canAccess = await Permissions.checkStorage();
        }

        if (canAccess && IMUtils.isNotNullEmptyStr(candidatePath)) {
          final f = File(candidatePath!);
          final existFile = await f.exists();
          if (existFile) {
            file = f;
          }
        }
      }
    }

    // Build controller
    try {
      if (file != null && file.existsSync()) {
        Logger.print('[ChatVideoPlayerView] Using local file: ${file.path}');
        _videoPlayerController = VideoPlayerController.file(
          file,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        // Validate url before network fallback
        if (!IMUtils.isValidUrl(_url)) {
          Logger.print(
              '[ChatVideoPlayerView] Invalid or empty video url: $_url');
          setState(() {
            _initError = StrRes.videoUnavailable;
          });
          return;
        }
        Logger.print('[ChatVideoPlayerView] Loading from network/cache: $_url');
        _videoPlayerController =
            await _cachedVideoControllerService.getVideo(_url!);
      }

      await _videoPlayerController.initialize();
      if (widget.muted) {
        _videoPlayerController.setVolume(0);
      }
      _createChewieController();
      if (mounted) setState(() {});
    } catch (e, s) {
      Logger.print('[ChatVideoPlayerView] initialize error: $e\n$s');

      // iOS: try auto-transcode fallback to MP4 (H.264 + AAC)
      if (Platform.isIOS) {
        final recovered = await _attemptTranscodeAndReinit(originalFile: file);
        if (recovered) return;
      } else if (Platform.isAndroid) {
        // Android: try auto-transcode fallback for MediaCodec compatibility
        final recovered =
            await _attemptAndroidTranscodeAndReinit(originalFile: file);
        if (recovered) return;
      }

      if (mounted) {
        setState(() {
          _initError = StrRes.fileOpenErrorMessage;
        });
      }
    }
  }

  /// Android-specific transcode fallback for MediaCodec compatibility issues
  Future<bool> _attemptAndroidTranscodeAndReinit({File? originalFile}) async {
    try {
      Logger.print(
          '[ChatVideoPlayerView] Starting Android transcode fallback...');

      // Resolve a source file to transcode
      File? src = originalFile;
      if (src == null || !src.existsSync()) {
        if (IMUtils.isValidUrl(_url)) {
          try {
            src = await _cachedVideoControllerService.ensureLocalFile(_url!);
            Logger.print(
                '[ChatVideoPlayerView] Downloaded source file for Android transcode: ${src.path}');
          } catch (e) {
            Logger.print(
                '[ChatVideoPlayerView] Download for Android transcode failed: $e');
          }
        }
      }

      if (src == null || !src.existsSync()) {
        Logger.print(
            '[ChatVideoPlayerView] No source file for Android transcode');
        return false;
      }

      // Check source file size
      final srcSize = await src.length();
      if (srcSize == 0) {
        Logger.print('[ChatVideoPlayerView] Source file is empty');
        return false;
      }
      Logger.print('[ChatVideoPlayerView] Source file size: $srcSize bytes');

      // Prepare output path in Caches/android_transcoded/<hash>.mp4
      final out =
          await _buildAndroidTranscodedPath(src.path, key: _url ?? src.path);
      final outFile = File(out);

      // Check if transcoded file already exists and is valid
      if (outFile.existsSync()) {
        final outSize = await outFile.length();
        if (outSize > 0) {
          Logger.print(
              '[ChatVideoPlayerView] Using existing Android transcoded file: ${outFile.path}');
          final isValid = await VideoTranscoder.isAndroidCompatible(outFile);
          if (isValid) {
            Logger.print(
                '[ChatVideoPlayerView] Existing Android transcoded file is valid');
          } else {
            Logger.print(
                '[ChatVideoPlayerView] Existing Android transcoded file is invalid, will re-transcode');
            // Delete invalid file and re-transcode
            await outFile.delete();
          }
        }
      }

      // Run transcode if needed
      if (!outFile.existsSync()) {
        if (mounted) {
          setState(() {
            _isTranscoding = true;
          });
        }

        // Use VideoTranscoder utility for Android
        final transcodedFile =
            await VideoTranscoder.transcodeForAndroidWithFallback(src,
                outputPath: out);
        if (transcodedFile == null) {
          Logger.print('[ChatVideoPlayerView] Android transcode failed');
          if (mounted) {
            setState(() {
              _isTranscoding = false;
              _initError = StrRes.videoFormatNotSupported;
            });
          }
          return false;
        }
      }

      // Initialize controller with transcoded file
      Logger.print(
          '[ChatVideoPlayerView] Initializing controller with Android transcoded file: ${outFile.path}');
      _videoPlayerController = VideoPlayerController.file(
        outFile,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _videoPlayerController.initialize();
      Logger.print(
          '[ChatVideoPlayerView] Android transcode controller initialized successfully');

      if (widget.muted) {
        _videoPlayerController.setVolume(0);
      }
      _createChewieController();

      if (mounted) {
        setState(() {
          _isTranscoding = false;
          _initError = null;
        });
      }

      Logger.print(
          '[ChatVideoPlayerView] Android transcode fallback completed successfully');
      return true;
    } catch (e, s) {
      Logger.print(
          '[ChatVideoPlayerView] Android transcode fallback failed: $e\n$s');
      if (mounted) {
        setState(() {
          _isTranscoding = false;
          _initError = StrRes.fileOpenErrorMessage;
        });
      }
      return false;
    }
  }

  /// Build path for Android transcoded video
  Future<String> _buildAndroidTranscodedPath(String sourcePath,
      {required String key}) async {
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
    final digest = md5.convert(utf8.encode('android_$key'));
    return '${cachesBase.path}/${digest.toString()}.mp4';
  }

  Future<bool> _attemptTranscodeAndReinit({File? originalFile}) async {
    try {
      Logger.print('[ChatVideoPlayerView] Starting transcode fallback...');

      // Resolve a source file to transcode
      File? src = originalFile;
      if (src == null || !src.existsSync()) {
        if (IMUtils.isValidUrl(_url)) {
          try {
            src = await _cachedVideoControllerService.ensureLocalFile(_url!);
            Logger.print(
                '[ChatVideoPlayerView] Downloaded source file: ${src.path}');
          } catch (e) {
            Logger.print(
                '[ChatVideoPlayerView] download for transcode failed: $e');
          }
        }
      }

      if (src == null || !src.existsSync()) {
        Logger.print('[ChatVideoPlayerView] No source file for transcode');
        return false;
      }

      // Check source file size
      final srcSize = await src.length();
      if (srcSize == 0) {
        Logger.print('[ChatVideoPlayerView] Source file is empty');
        return false;
      }
      Logger.print('[ChatVideoPlayerView] Source file size: $srcSize bytes');

      // Prepare output path in Caches/transcoded/<hash>.mp4
      final out = await _buildTranscodedPath(src.path, key: _url ?? src.path);
      final outFile = File(out);

      // Check if transcoded file already exists and is valid
      if (outFile.existsSync()) {
        final outSize = await outFile.length();
        if (outSize > 0) {
          Logger.print(
              '[ChatVideoPlayerView] Using existing transcoded file: ${outFile.path}');
          final isValid = await VideoTranscoder.isIOSCompatible(outFile);
          if (isValid) {
            Logger.print(
                '[ChatVideoPlayerView] Existing transcoded file is valid');
          } else {
            Logger.print(
                '[ChatVideoPlayerView] Existing transcoded file is invalid, will re-transcode');
            // Delete invalid file and re-transcode
            await outFile.delete();
          }
        }
      }

      // Run transcode if needed
      if (!outFile.existsSync()) {
        if (mounted) {
          setState(() {
            _isTranscoding = true;
          });
        }

        // Use VideoTranscoder utility
        final transcodedFile =
            await VideoTranscoder.transcodeForIOS(src, outputPath: out);
        if (transcodedFile == null) {
          Logger.print('[ChatVideoPlayerView] Transcode failed');
          if (mounted) {
            setState(() {
              _isTranscoding = false;
              _initError = StrRes.videoFormatNotSupported;
            });
          }
          return false;
        }
      }

      // Initialize controller with transcoded file
      Logger.print(
          '[ChatVideoPlayerView] Initializing controller with transcoded file: ${outFile.path}');
      _videoPlayerController = VideoPlayerController.file(
        outFile,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _videoPlayerController.initialize();
      Logger.print('[ChatVideoPlayerView] Controller initialized successfully');

      if (widget.muted) {
        _videoPlayerController.setVolume(0);
      }
      _createChewieController();

      if (mounted) {
        setState(() {
          _isTranscoding = false;
          _initError = null;
        });
      }

      Logger.print(
          '[ChatVideoPlayerView] Transcode fallback completed successfully');
      return true;
    } catch (e, s) {
      Logger.print('[ChatVideoPlayerView] transcode fallback failed: $e\n$s');
      if (mounted) {
        setState(() {
          _isTranscoding = false;
          _initError = StrRes.fileOpenErrorMessage;
        });
      }
      return false;
    }
  }

  Future<String> _buildTranscodedPath(String sourcePath,
      {required String key}) async {
    final libDir = await getLibraryDirectory();
    final cachesBase = Directory('${libDir.path}/Caches/transcoded');
    if (!await cachesBase.exists()) {
      await cachesBase.create(recursive: true);
    }
    final digest = md5.convert(utf8.encode(key));
    return '${cachesBase.path}/${digest.toString()}.mp4';
  }

  // ignore: unused_element
  String _ffArg(String p) => '"$p"';

  void _createChewieController() {
    final hasValidUrl = IMUtils.isValidUrl(widget.url);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: widget.autoPlay,
      looping: false,
      allowFullScreen: false,
      allowPlaybackSpeedChanging: false,
      showControlsOnInitialize: true,
      customControls: CustomCupertinoControls(
          backgroundColor: Colors.black.withOpacity(0.7),
          iconColor: Colors.white),
      // hideControlsTimer: const Duration(seconds: 1),
      optionsTranslation: OptionsTranslation(
        playbackSpeedButtonText: StrRes.playSpeed,
        cancelButtonText: StrRes.cancel,
      ),
      additionalOptions: (context) => hasValidUrl
          ? [
              OptionItem(
                onTap: () async {
                  final u = widget.url!;
                  final file =
                      await _cachedVideoControllerService.getCacheFile(u);
                  widget.onDownload?.call(u, file);
                  Get.back();
                },
                iconData: Icons.download_outlined,
                title: StrRes.download,
              ),
            ]
          : [],
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(
              fontFamily: 'FilsonPro',
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Future<void> toggleVideo() async {
    await _videoPlayerController.pause();
    await initializePlayer();
  }

  Future<void> _openInOtherApp() async {
    if (_isOpeningExternally) return;
    if (mounted) setState(() => _isOpeningExternally = true);
    try {
      File? f = widget.file;
      if (f == null || !f.existsSync()) {
        // Try path
        final p0 = _path;
        if (IMUtils.isNotNullEmptyStr(p0)) {
          var p = p0!;
          if (Platform.isIOS && p.contains('/Library/Caches/')) {
            final libDir = await getLibraryDirectory();
            final cachesBase = '${libDir.path}/Caches';
            final suffix = p.split('/Library/Caches').last;
            p = cachesBase + suffix;
          }
          final cand = File(p);
          if (await cand.exists()) {
            f = cand;
          }
        }
      }
      if ((f == null || !f.existsSync()) && IMUtils.isValidUrl(_url)) {
        try {
          f = await _cachedVideoControllerService.ensureLocalFile(_url!);
        } catch (e) {
          Logger.print('[ChatVideoPlayerView] ensureLocalFile failed: $e');
        }
      }
      if (f != null && await f.exists()) {
        await IMUtils.openFileByOtherApp(f.path);
      } else {
        IMViews.showToast(StrRes.fileNotFound);
      }
    } finally {
      if (mounted) setState(() => _isOpeningExternally = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          if (_chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized)
            Chewie(controller: _chewieController!)
          else ...[
            _buildCoverView(context),
            if (_initError != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _initError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'FilsonPro',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: _openInOtherApp,
                            child: Text(StrRes.openInOtherApp),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => Get.back(),
                            child: Text(StrRes.cancel),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (_isTranscoding)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoActivityIndicator(color: Colors.white, radius: 14),
                  ],
                ),
              ),
            ),
          if (_isOpeningExternally)
            Container(
              color: Colors.black38,
              child: const Center(
                child:
                    CupertinoActivityIndicator(color: Colors.white, radius: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoverView(BuildContext context) => null != widget.coverUrl
      ? Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: ImageUtil.networkImage(
                  url: widget.coverUrl!,
                  loadProgress: false,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth),
            ),
            const Center(
              child: CupertinoActivityIndicator(
                color: Colors.white,
                radius: 15,
              ),
            ),
          ],
        )
      : Container();

  String? get _path => widget.path;

  String? get _url => widget.url;
}
