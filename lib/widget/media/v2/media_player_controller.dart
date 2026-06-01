import 'dart:math';

import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/widget/media/utils/fullscreen.dart';
import 'package:editvideo/widget/media/v2/model/media_data_source.dart';
import 'package:editvideo/widget/media/v2/model/media_data_status.dart';
import 'package:editvideo/widget/media/v2/model/media_player_status.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:ns_danmaku/ns_danmaku.dart';
import 'package:status_bar_control_plus/status_bar_control_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MediaPlayerController {
  /// 播放器
  Player? mediaPlayer;

  /// 视频控制器
  VideoController? videoController;

  var playerCount = 0.obs;

  /// 数据加载状态
  final MediaDataStatus mediaDataStatus = MediaDataStatus();

  /// 播放状态
  final MediaPlayerStatus mediaPlayerStatus = MediaPlayerStatus();

  /// 是否自动播放 默认开启
  var autoPlay = true;

  /// 默认播放速度
  var defaultSpeed = 1.0;

  /// 快进秒数
  var fastSeconds = 15;

  /// 播放模式 默认不循环
  var looping = PlaylistMode.none;

  /// 是否自动熄屏
  var autoWakelock = true;

  /// 记录开关 默认开启
  var openRecord = true;

  /// 控制面板相关
  /// 显示控制面板 默认关闭
  final showControls = false.obs;

  /// 锁定控制面板
  final controlsLock = false.obs;

  /// 总时长
  final totalDuration = Rx<Duration>(Duration.zero);

  /// 当前进度
  final currentPosition = Rx<Duration>(Duration.zero);

  /// 是否正在缓冲
  final isBuffering = false.obs;

  /// 缓存进度
  final bufferedDuration = Rx<Duration>(Duration.zero);

  /// 是否长按中
  final longPressStatus = false.obs;

  /// 快退
  final fastRewindStatus = false.obs;

  /// 快进
  final fastForwardStatus = false.obs;

  var fastAssets = '';
  var fastTips = '';

  /// 是否正在滑动进度条
  final isSliderMoving = false.obs;

  final sliderPosition = Rx<Duration>(Duration.zero);

  /// 当前亮度 恢复时使用
  var currentBrightness = 0.0;

  /// 是否全屏
  final isFullScreen = false.obs;

  /// 隐藏操作栏计时器
  Timer? _hideTimer;

  /// 快退计时器
  Timer? _rewindTimer;
  /// 快进计时器
  Timer? _forwardTimer;

  /// 上一次的播放时间
  int _lastPositionSeconds = 0;

  ///todo 字幕开关 默认关闭
  var openSubTitles = false.obs;

  ///todo 字幕
  var subTitles = [].obs;
  var subTitleContent = ''.obs;

  ///todo 弹幕开关
  final isOpenDanmu = false.obs;

  ///todo 关联弹幕控制器
  DanmakuController? danmakuController;

  ///todo 弹幕相关配置
  late List blockTypes;
  late double showArea;
  late double opacityVal;
  late double fontSizeVal;
  late double strokeWidth;
  late double danmakuDurationVal;
  late List<double> speedsList;

  /// 事件流
  var subscriptions = <StreamSubscription>[];

  /// 数据加载状态监听
  Stream<MediaDataStatusType> get onDataStatusChanged => mediaDataStatus.status.stream;

  /// 播放状态监听
  Stream<MediaPlayerStatusType> get onPlayerStatusChanged => mediaPlayerStatus.status.stream;

  /// 播放进度监听
  Stream<Duration> get onPositionChanged => currentPosition.stream;

  /// 播放状态监听集合
  final List<Function(MediaPlayerStatusType status)> _statusChangedListeners = [];

  /// 播放进度监听集合
  final List<Function()> _positionListeners = [];

  // 获取实例 传参
  MediaPlayerController({String videoType = 'archive'}) {
    if (videoType != 'none') {
      playerCount.value += 1;
      //todo _videoType.value = videoType;
    }
  }

  // 初始化资源
  Future<bool> setDataSource(
    MediaDataSource dataSource, {
    // 默认自动播放
    bool autoPlay = true,
    // 默认自动播放
    double defaultSpeed = 1.0,
    // 默认不循环
    PlaylistMode looping = PlaylistMode.none,
    // 记录开关
    bool openRecord = true,
    // 是否开启字幕
    bool openSubTitles = false,
    // 初始进度
    Duration initVideoPosition = Duration.zero,
    // 硬件加速
    bool hardware = false,
    double? width,
    double? height,
  }) async {
    try {
      // 初始化数据加载状态
      mediaDataStatus.status.value = MediaDataStatusType.loading;

      this.autoPlay = autoPlay;
      this.defaultSpeed = defaultSpeed;
      this.looping = looping;
      this.openRecord = openRecord;
      this.openSubTitles.value = openSubTitles;

      subTitles = [].obs;
      subTitleContent.value = '';

      if (mediaPlayer != null && mediaPlayer!.state.playing) {
        await pause();
      }

      if (playerCount.value == 0) {
        return false;
      }

      // 每次配置时先移除监听
      removeListeners();

      // 配置Player 音轨、字幕等等
      mediaPlayer = await _createVideoController(dataSource, looping, hardware, width, height, initVideoPosition);

      // 添加监听
      addListeners();

      // 获取视频时长
      totalDuration.value = mediaPlayer!.state.duration;

      // 数据加载完成
      mediaDataStatus.status.value = MediaDataStatusType.completed;

      await _initializePlayer();

      return true;
    } catch (err) {
      mediaDataStatus.status.value = MediaDataStatusType.error;
      print('plPlayer err:  $err');
    }
    return false;
  }

  // 配置播放器
  Future<Player> _createVideoController(
    MediaDataSource dataSource,
    PlaylistMode looping,
    bool hardware,
    double? width,
    double? height,
    Duration initVideoPosition,
  ) async {
    // 缓存状态
    isBuffering.value = false;
    // 缓存进度
    bufferedDuration.value = Duration.zero;
    // 当前进度
    currentPosition.value = Duration.zero;
    // 上一次的播放时间
    _lastPositionSeconds = 0;

    // 初始化时清空弹幕，防止上次重叠
    if (danmakuController != null) {
      danmakuController!.clear();
    }

    // 创建播放器
    Player player =
        mediaPlayer ??
        Player(
          configuration: PlayerConfiguration(
            // 默认缓存 50M 大小
            bufferSize: 50 * 1024 * 1024,
          ),
        );

    var pp = player.platform as NativePlayer;
    // 解除倍速限制
    await pp.setProperty("af", "scaletempo2=max-speed=8");
    // todo// 音量不一致
    // if (Platform.isAndroid) {
    //   await pp.setProperty("volume-max", "100");
    //   String defaultAoOutput = setting.get(SettingBoxKey.defaultAoOutput, defaultValue: '0');
    //   await pp.setProperty("ao", aoOutputList.where((e) => e['value'] == defaultAoOutput).first['title']);
    // }

    await player.setAudioTrack(AudioTrack.auto());

    // 音轨
    if (dataSource.audioSource != '' && dataSource.audioSource != null) {
      // await pp.setProperty(
      //   'audio-files',
      //   UniversalPlatform.isWindows
      //       ? dataSource.audioSource!.replaceAll(';', '\\;')
      //       : dataSource.audioSource!.replaceAll(':', '\\:'),
      // );
    } else {
      await pp.setProperty('audio-files', '');
    }

    // 创建视频控制器
    videoController =
        videoController ??
        VideoController(
          player,
          configuration: VideoControllerConfiguration(
            enableHardwareAcceleration: hardware,
            androidAttachSurfaceAfterVideoParameters: false,
          ),
        );

    // 播放模式
    player.setPlaylistMode(looping);

    if (dataSource.type == MediaDataSourceType.asset) {
      final assetUrl = dataSource.videoSource!.startsWith("asset://")
          ? dataSource.videoSource!
          : "asset://${dataSource.videoSource!}";
      await player.open(Media(assetUrl, httpHeaders: dataSource.httpHeaders), play: false);
    } else {
      await player.open(
        Media(dataSource.videoSource!, httpHeaders: dataSource.httpHeaders, start: initVideoPosition),
        play: false,
      );
    }
    return player;
  }

  //
  Future _initializePlayer() async {
    /// 自动播放
    if (autoPlay) {
      await play();
    }

    /// 设置倍速
    await setPlaybackSpeed(defaultSpeed);
  }

  /// 切换操作栏状态
  void toggleControls() {
    showControls.value = !showControls.value;
    if (showControls.value && mediaPlayerStatus.playing) {
      _startHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  /// 切换播放状态
  void togglePlay() async {
    if (mediaPlayerStatus.playing) {
      pause();
      showControls.value = true;
      _cancelHideTimer();
    } else {
      play(repeat: mediaPlayerStatus.completed ? true : false);
    }
  }

  /// 播放视频
  Future<void> play({bool repeat = false}) async {
    // repeat为true，将从头播放
    if (repeat) {
      await seekTo(Duration.zero);
    }
    await mediaPlayer?.play();
    // 播放时延迟3s隐藏控制栏
    _startHideTimer();
  }

  /// 暂停播放
  Future<void> pause({bool isInterrupt = false}) async {
    await mediaPlayer?.pause();
  }

  /// 跳转至指定位置
  Future<void> seekTo(Duration position, {bool isHorizontalMove = false}) async {
    try {
      if (position < Duration.zero) {
        position = Duration.zero;
      }
      currentPosition.value = position;
      _lastPositionSeconds = position.inSeconds;
      if (totalDuration.value.inSeconds != 0) {
        if (!isHorizontalMove) {
          await mediaPlayer?.stream.buffer.first;
        }
        await mediaPlayer?.seek(position);

        _startHideTimer();
      }
    } catch (err) {
      print('Error while seeking: $err');
    }
  }

  /// 设置倍速
  Future<void> setPlaybackSpeed(double speed) async {
    await mediaPlayer?.setRate(speed);
    // try {
    // DanmakuOption currentOption = danmakuController!.option;
    // defaultDuration ??= currentOption.duration;
    // DanmakuOption updatedOption = currentOption.copyWith(
    //     duration: (defaultDuration! / speed) * playbackSpeed);
    // danmakuController!.updateOption(updatedOption);
    // } catch (_) {}
    // // fix 长按倍速后放开不恢复
    // if (!doubleSpeedStatus.value) {
    //   _playbackSpeed.value = speed;
    // }
  }

  /// 快退
  Future<void> fastRewind() async {
    fastTips = 'Rewind';
    fastAssets = Assets.commonIconRewindTips;
    fastRewindStatus.value = true;

    _rewindTimer = Timer(const Duration(milliseconds: 200), () {
      Duration result = mediaPlayer!.state.position - Duration(seconds: fastSeconds);
      result = result.clamp(
        Duration.zero,
        mediaPlayer!.state.duration,
      );
      mediaPlayer!.seek(result);
      mediaPlayer!.play();

      fastRewindStatus.value = false;

      _rewindTimer?.cancel();
      _rewindTimer = null;
    });
  }

  /// 快进
  Future<void> fastForward() async {
    fastTips = 'Forward';
    fastAssets = Assets.commonIconForwardTips;
    fastForwardStatus.value = true;

    _forwardTimer = Timer(const Duration(milliseconds: 200), () {
      Duration result = mediaPlayer!.state.position + Duration(seconds: fastSeconds);
      result = result.clamp(
        Duration.zero,
        mediaPlayer!.state.duration,
      );
      mediaPlayer!.seek(result);
      mediaPlayer!.play();

      fastForwardStatus.value = false;

      _forwardTimer?.cancel();
      _forwardTimer = null;
    });
  }

  // 全屏
  Future<void> triggerFullScreen({bool status = true}) async {
    await StatusBarControlPlus.setHidden(true, animation: StatusBarAnimation.FADE);
    if (!isFullScreen.value && status) {
      isFullScreen.value = true;

      /// 进入全屏
      await enterFullScreen();
      await landScape();
    } else if (isFullScreen.value && !status) {
      StatusBarControlPlus.setHidden(false, animation: StatusBarAnimation.FADE);
      exitFullScreen();
      await verticalScreen();

      isFullScreen.value = false;
    }
  }

  /// 开始隐藏控制栏计时
  void _startHideTimer() {
    _cancelHideTimer();

    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mediaPlayerStatus.playing && !isSliderMoving.value) {
        showControls.value = false;
      }
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  // 记录播放信息
  Future recordPlayerInfo({int progress = 0, bool playStatusChanged = false}) async {
    if (!openRecord) {
      return false;
    }
    // 播放状态变化时，更新
    if (playStatusChanged) {
      //todo
    } else
    // 正常播放时，间隔5秒更新一次
    if (progress - _lastPositionSeconds >= 5) {
      _lastPositionSeconds = progress;
    }
  }

  /// 播放器事件监听
  void addListeners() {
    subscriptions.addAll([
      /// 进度监听
      mediaPlayer!.stream.position.listen((event) {
        currentPosition.value = event >= Duration.zero ? event : Duration.zero;
        // 拖动进度条时，不更新进度
        if (!isSliderMoving.value) {
          sliderPosition.value = event;
        }
        //todo
        // querySubtitleContent(videoPlayerController!.state.position.inSeconds.toDouble());

        // 触发进度回调事件
        for (var element in _positionListeners) {
          element();
        }

        // 播放进度变化时记录播放信息
        recordPlayerInfo(progress: currentPosition.value.inSeconds);
      }),

      /// 播放/暂停监听
      mediaPlayer!.stream.playing.listen((event) {
        commonDebugPrint('MediaPlayer playStatus: $event');
        mediaPlayerStatus.status.value = event ? MediaPlayerStatusType.playing : MediaPlayerStatusType.paused;

        // 触发回调事件
        _callStateChangeListeners(playerStatus: mediaPlayerStatus.status.value);

        if (mediaPlayer!.state.position.inSeconds != 0) {
          // 播放状态变化时记录播放信息
          recordPlayerInfo(progress: currentPosition.value.inSeconds, playStatusChanged: true);
        }
      }),

      /// 播放完成监听
      mediaPlayer!.stream.completed.listen((event) {
        commonDebugPrint('MediaPlayer playStatus: $event');
        if (event) {
          mediaPlayerStatus.status.value = MediaPlayerStatusType.completed;

          /// 播放完成显示控制栏
          showControls.value = true;

          // 触发回调事件
          _callStateChangeListeners(playerStatus: mediaPlayerStatus.status.value);
          // 播放状态变化时记录播放信息
          recordPlayerInfo(progress: currentPosition.value.inSeconds, playStatusChanged: true);
        }
      }),

      /// 总时长监听
      mediaPlayer!.stream.duration.listen((event) => totalDuration.value = event),

      /// 缓冲进度监听
      mediaPlayer!.stream.buffer.listen((event) {
        bufferedDuration.value = event;
      }),

      /// 缓冲状态
      mediaPlayer!.stream.buffering.listen((event) {
        isBuffering.value = event;
      }),
    ]);
  }

  /// 移除播放器事件监听
  void removeListeners() {
    for (final s in subscriptions) {
      s.cancel();
    }
    subscriptions.clear();
  }

  /// 触发播放状态回调事件
  void _callStateChangeListeners({required MediaPlayerStatusType playerStatus}) {
    for (var element in _statusChangedListeners) {
      element(playerStatus);
    }
    _autoWakelockCallback(playerStatus);
  }

  /// 自动锁屏
  void _autoWakelockCallback(MediaPlayerStatusType playerStatus) {
    if (Platform.isLinux) {
      return;
    }
    if (autoWakelock) {
      if (playerStatus == MediaPlayerStatusType.playing) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    } else {
      WakelockPlus.disable();
    }
  }

  /// 添加进度监听
  void addPositionListener(Function() listener) {
    _positionListeners.add(listener);
  }

  /// 移除进度监听
  void removePositionListener(Function(Duration position) listener) {
    _positionListeners.remove(listener);
  }

  /// 添加状态监听
  void addStatusLister(Function(MediaPlayerStatusType status) listener) {
    _statusChangedListeners.add(listener);
  }

  /// 移除状态监听
  void removeStatusLister(Function(MediaPlayerStatusType status) listener) {
    _statusChangedListeners.remove(listener);
  }
}
