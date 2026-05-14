import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/common_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

class SwitchManager {
  static final SwitchManager instance = SwitchManager._internal();

  factory SwitchManager() => instance;

  SwitchManager._internal();

  // 是否可以跳转B页面
  var canToB = false.obs;

  /// 执行页面跳转相关的前置逻辑。
  /// 此方法主要用于触发 Firebase Remote Config 的拉取和解析过程。
  Future<void> excutePage() async {
    await Future.wait([
      _getCloak(),
      _getFirebaseRemoteConfig(),
    ]).then((List<bool> result) {
      // 共同判断 canToB 的值，只有黑名单允许且 RemoteConfig 允许，才可跳转B页面
      canToB.value = result[0] && result[1];
      commonDebugPrint("SwitchManager final canToB: $canToB (cloakAllow: ${result[0]}, remoteAllow: ${result[1]})");
    });
  }

  Future<bool> _getCloak({int retryCount = 0}) async {
    if (retryCount > 3) {
      return false;
    }
    final result = await CommonApi.cloak();
    if (result.isSuccess) {
      final data = result.responseData?.data;
      commonDebugPrint('SwitchManager: cloak data: $data');
      // 命中黑名单：addison 正常模式：tahoe
      return data == 'tahoe';
    } else {
      // 重试
      commonDebugPrint("SwitchManager: _getCloak Server API error: ${result.error?.message ?? ApiResponse.unknownErrorMsg}");
      return await _getCloak(retryCount: retryCount + 1);
    }
  }

  /// 异步获取并解析 Firebase Remote Config 的各项开关配置。
  /// 
  /// 主要包含以下几个维度的判断：
  /// 1. `movix_reffer_clo`：全局黑名单控制。为 'close' 时直接拦截。
  /// 2. `movix_cloak_add`：模拟器和 VPN 屏蔽控制。为 'open' 且当前环境触发命中时进行拦截。
  /// 3. `movix_country_cloak`：区域屏蔽控制。当下发配置包含当前设备的国家或省市时进行拦截。
  ///
  /// 所有条件均通过后，将 [remoteAllow] 置为 true。
  Future<bool> _getFirebaseRemoteConfig() async {
    await RemoteConfigManager().fetchAndActivateConfig();
    
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    String movixRefferClo = remoteConfig.getString('movix_reffer_clo').isEmptyString() ? 'all' : remoteConfig.getString('movix_reffer_clo');
    String movixCloakAdd = remoteConfig.getString('movix_cloak_add').isEmptyString() ? 'open' : remoteConfig.getString('movix_cloak_add');
    String movixCountryCloak = remoteConfig.getString('movix_country_cloak').isEmptyString() ? 'Minnesota' : remoteConfig.getString('movix_country_cloak');

    bool allowToB = false; // 默认为false

    // 1. 判断 movix_reffer_clo
    if (movixRefferClo == 'all') { // 默认值是 all
      allowToB = true;
    } else { // 'close'
      allowToB = false;
    }

    // 2. 判断 movix_cloak_add
    if (allowToB && movixCloakAdd == 'open') { // 默认值是 open
      bool isSim = await _isSimulator();
      bool isVpn = await _isVpnActive();
      commonDebugPrint('SwitchManager: 是否是虚拟机：$isSim----是否使用了Vpn: $isVpn');
      if (isSim || isVpn) {
        allowToB = false;
      }
    }

    // 3. 判断 movix_country_cloak
    if (allowToB) {
      bool isLocationBlocked = await _checkLocationBlockWithRetry(movixCountryCloak);
      if (isLocationBlocked) {
        allowToB = false;
      }
    }

    commonDebugPrint("SwitchManager remoteAllow: $allowToB (reffer_clo: $movixRefferClo, cloak_add: $movixCloakAdd, country_cloak: $movixCountryCloak)");
    return allowToB;
  }

  /// 带有容错和重试机制的完整地理位置检测
  Future<bool> _checkLocationBlockWithRetry(String blockedConfig) async {
    // 1. 优先调用 _getLocationBlockFromServer
    bool? serverResult = await _getLocationBlockFromServer(blockedConfig);
    if (serverResult != null) {
      return serverResult;
    }

    // 2. 退而求其次调用 _isLocationBlocked
    bool? fallbackResult = await _isLocationBlocked(blockedConfig);
    if (fallbackResult != null) {
      return fallbackResult;
    }

    // 3. 均失败
    commonDebugPrint("SwitchManager: Location check failed, retrying... ");
    bool? retryResult = await _getLocationBlockFromServer(blockedConfig, needRetry: true, retryCount: 0);
    if (retryResult != null) {
      return retryResult;
    }

    // 4. 连续2次重试后仍失败，判定为阻断
    commonDebugPrint("SwitchManager: Location check failed after 2 retries, blocking by default.");
    return true; // true 代表阻断，禁止进入B页面
  }

  /// 优先调用自己的服务器接口获取 IP 和地理位置
  /// 如果成功，返回是否被阻断 (true/false)；如果失败/异常，返回 null
  Future<bool?> _getLocationBlockFromServer(String blockedConfig, {bool needRetry = false, int retryCount = 0}) async {
    if (retryCount > 2) {
      return null;
    }
    final result = await CommonApi.getIpAddress();
    if (result.isSuccess) {
      final data = result.responseData?.data;
      String country = data?.country?.toLowerCase() ?? '';
      String subdivision = data?.subdivision?.toLowerCase() ?? '';
      commonDebugPrint('SwitchManager: Server API location: $country--$subdivision');

      List<String> blockedList = blockedConfig
          .split(';')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();

      for (String blockedItem in blockedList) {
        if (country == blockedItem || subdivision == blockedItem) {
          commonDebugPrint("SwitchManager: Server location blocked matched: $blockedItem");
          return true;
        }
      }
      return false;
    } else {
      commonDebugPrint("SwitchManager: getIpAddress Server API error: ${result.error?.message ?? ApiResponse.unknownErrorMsg}");
      if (needRetry) {
        return await _getLocationBlockFromServer(blockedConfig, needRetry: true, retryCount: retryCount + 1);
      }
      return null;// 表示获取失败
    }
  }

  /// 检查当前设备的网络位置是否被屏蔽 (退而求其次的第三方 API)。
  ///
  /// [blockedConfig] 传入的是由分号分隔的区域字符串（如 "Minnesota; London"）。
  /// 内部通过调用外部 IP 解析接口 (freeipapi.com) 获取当前的真实国家、省份和城市。
  /// 如果配置项中的任一名称匹配当前的位置，则返回 true。成功返回 bool，失败/异常返回 null。
  Future<bool?> _isLocationBlocked(String blockedConfig) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      // 使用 freeipapi 获取当前设备的国家和省份信息
      final response = await dio.get('https://freeipapi.com/api/json');
      if (response.statusCode == 200) {
        final data = response.data;
        String country = data['countryName']?.toString().toLowerCase() ?? '';
        String region = data['regionName']?.toString().toLowerCase() ?? '';
        String city = data['cityName']?.toString().toLowerCase() ?? '';
        commonDebugPrint('SwitchManager: Fallback API location: $country--$region--$city');

        // 解析下发的配置，格式如 "Minnesota; London"
        List<String> blockedList = blockedConfig
            .split(';')
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList();

        for (String blockedItem in blockedList) {
          if (country == blockedItem || region == blockedItem || city == blockedItem) {
            commonDebugPrint("SwitchManager: Fallback location blocked matched: $blockedItem");
            return true;
          }
        }
        return false;
      }
    } catch (e) {
      commonDebugPrint("SwitchManager: Error checking fallback location: $e");
    }
    return null; // 表示获取失败
  }

  /// 检测当前运行环境是否为模拟器。
  ///
  /// 区分 Android 和 iOS，借助 `device_info_plus` 插件的 `isPhysicalDevice` 属性来判断。
  /// 返回 true 表示当前环境是模拟器。
  Future<bool> _isSimulator() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return !androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return !iosInfo.isPhysicalDevice;
      }
    } catch (e) {
      commonDebugPrint("SwitchManager: Error checking simulator: $e");
    }
    return false;
  }

  /// 检测设备当前是否开启了 VPN 代理连接。
  ///
  /// 通过遍历系统底层提供的 `NetworkInterface.list()` 检查当前所有的网络接口。
  /// 如果网卡名称包含 `tun`、`ppp`、`pptp`、`ipsec` 或 `tap`，则判定为使用了 VPN。
  /// 返回 true 表示检测到 VPN 环境。
  Future<bool> _isVpnActive() async {
    try {
      List<NetworkInterface> interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      for (var interface in interfaces) {
        final name = interface.name.toLowerCase();
        if (name.contains('tun') ||
            name.contains('ppp') ||
            name.contains('pptp') ||
            name.contains('ipsec') ||
            name.contains('tap')) {
          return true;
        }
      }
    } catch (e) {
      commonDebugPrint("SwitchManager: Error checking VPN: $e");
    }
    return false;
  }
}
