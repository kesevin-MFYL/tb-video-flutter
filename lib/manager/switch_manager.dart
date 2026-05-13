
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/common_api.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class SwitchManager {
  static final SwitchManager instance = SwitchManager._internal();

  factory SwitchManager() => instance;

  SwitchManager._internal();

  // 是否可以跳转B页面
  bool canToB = false;

  /// 执行页面跳转相关的前置逻辑。
  /// 此方法主要用于触发 Firebase Remote Config 的拉取和解析过程。
  void excutePage() {
    _getFirebaseRemoteConfig();
  }

  /// 异步获取并解析 Firebase Remote Config 的各项开关配置。
  /// 
  /// 主要包含以下几个维度的判断：
  /// 1. `movix_reffer_clo`：全局黑名单控制。为 'close' 时直接拦截。
  /// 2. `movix_cloak_add`：模拟器和 VPN 屏蔽控制。为 'open' 且当前环境触发命中时进行拦截。
  /// 3. `movix_country_cloak`：区域屏蔽控制。当下发配置包含当前设备的国家或省市时进行拦截。
  ///
  /// 所有条件均通过后，将 [canToB] 置为 true。
  void _getFirebaseRemoteConfig() async {
    await RemoteConfigManager().fetchAndActivateConfig();
    
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    String movixRefferClo = remoteConfig.getString('movix_reffer_clo').isEmptyString() ? 'all' : remoteConfig.getString('movix_reffer_clo');
    String movixCloakAdd = remoteConfig.getString('movix_cloak_add').isEmptyString() ? 'open' : remoteConfig.getString('movix_cloak_add');
    String movixCountryCloak = remoteConfig.getString('movix_country_cloak').isEmptyString() ? 'Minnesota' : remoteConfig.getString('movix_country_cloak');

    bool allowToB = false; // 默认canToB为false

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
      bool isLocationBlocked = await _isLocationBlocked(movixCountryCloak);
      if (isLocationBlocked) {
        allowToB = false;
      }
    }

    canToB = allowToB;
    commonDebugPrint("SwitchManager canToB: $canToB (reffer_clo: $movixRefferClo, cloak_add: $movixCloakAdd, country_cloak: $movixCountryCloak)");
  }

  Future<bool?> _getLocationBlockFromServer({int retryCount = 0}) async {
    if (retryCount > 2) {
      return null;
    }
    final result = await CommonApi.getIpAddress();
    if (result.isSuccess) {
      final data = result.responseData?.data;
    } else {
      return await _getLocationBlockFromServer(retryCount: retryCount + 1);
    }
    return false;
  }

  /// 检查当前设备的网络位置是否被屏蔽。
  ///
  /// [blockedConfig] 传入的是由分号分隔的区域字符串（如 "Minnesota; London"）。
  /// 内部通过调用外部 IP 解析接口 (freeipapi.com) 获取当前的真实国家、省份和城市。
  /// 如果配置项中的任一名称匹配当前的位置，则返回 true。
  Future<bool> _isLocationBlocked(String blockedConfig) async {
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
        commonDebugPrint('SwitchManager: $country--$region--$city');

        // 解析下发的配置，格式如 "Minnesota; London"
        List<String> blockedList = blockedConfig
            .split(';')
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList();
        
        for (String blockedItem in blockedList) {
          if (country == blockedItem || region == blockedItem || city == blockedItem) {
            commonDebugPrint("SwitchManager: Location blocked matched: $blockedItem");
            return true;
          }
        }
      }
    } catch (e) {
      commonDebugPrint("SwitchManager: Error checking location: $e");
    }
    return false;
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
