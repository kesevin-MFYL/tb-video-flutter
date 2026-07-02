package com.movix.editvideo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class MainActivity : FlutterActivity() {
    private val CHANNEL = "tbvideo/app_retain"
    private val NATIVE_AD_CHANNEL = "tbvideo/native_ad"
    lateinit var nativeAdChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(GoogleMobileAdsPlugin())
        super.configureFlutterEngine(flutterEngine)
        
        nativeAdChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NATIVE_AD_CHANNEL)

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "adFactoryExample",
            NativeAdFactoryExample(layoutInflater, nativeAdChannel))

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendToBackground") {
                moveTaskToBack(true)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "adFactoryExample")
    }
}

class NativeAdFactoryExample: NativeAdFactory {
  private var layoutInflater: LayoutInflater
  private var channel: MethodChannel

  constructor(layoutInflater: LayoutInflater, channel: MethodChannel) {
    this.layoutInflater = layoutInflater
    this.channel = channel
  }

  override fun createNativeAd(nativeAd: NativeAd?, customOptions: MutableMap<String, Any>?): NativeAdView {
    val adView = layoutInflater.inflate(R.layout.my_native_ad, null) as NativeAdView

    val closeBtn = adView.findViewById<ImageView>(R.id.ad_close_btn)
    
    // 注册为一个未使用的 Asset View，使 GMA SDK 为其绑定点击跳转商店的事件
//    adView.priceView = closeBtn

    var shouldClickbait = false
    val fullscreenNative = (customOptions?.get("fullscreenNative") as? Number)?.toInt() ?: 0
    if (fullscreenNative > 0) {
        val random = (1..100).random()
        if (random <= fullscreenNative) {
            shouldClickbait = true
        }
    }

    var hasClickbaitTriggered = false

    closeBtn.setOnTouchListener { _, event ->
        if (shouldClickbait && !hasClickbaitTriggered) {
            if (event.action == android.view.MotionEvent.ACTION_DOWN) {
                hasClickbaitTriggered = true
            }
            // 返回 false 不消费事件，让事件冒泡触发 GMA SDK 的 OnClickListener，从而跳转商店
            false
        } else {
            if (event.action == android.view.MotionEvent.ACTION_UP) {
                channel.invokeMethod("closeNativeAd", null)
            }
            // 返回 true 消费事件，阻止事件冒泡和跳转
            true
        }
    }

    // 广告媒体
    adView.mediaView = adView.findViewById(R.id.ad_media)

    // 广告图标
    adView.iconView = adView.findViewById(R.id.ad_app_icon)
    // 标题
    adView.headlineView = adView.findViewById(R.id.ad_headline)
    // 号召性用语
    adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)

    (adView.headlineView as TextView).text = nativeAd?.headline
    adView.mediaView?.mediaContent = nativeAd?.mediaContent

    if (nativeAd?.callToAction == null) {
      adView.callToActionView?.visibility = View.INVISIBLE
    } else {
      adView.callToActionView?.visibility = View.VISIBLE
      (adView.callToActionView as Button).text = nativeAd.callToAction
    }

    if (nativeAd?.icon == null) {
      adView.iconView?.visibility = View.GONE
    } else {
      (adView.iconView as ImageView).setImageDrawable(nativeAd.icon!!.drawable)
      adView.iconView?.visibility = View.VISIBLE
    }

    // This method tells the Google Mobile Ads SDK that you have finished populating your
    // native ad view with this native ad.
    if (nativeAd != null) {
      adView.setNativeAd(nativeAd)
    }

    return adView
  }
}
