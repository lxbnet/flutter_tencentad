import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tencentad/flutter_tencentad.dart';

///
/// Description: 描述
/// Author: Gstory
/// Email: gstory0404@gmail.com
/// CreateDate: 2021/8/7 17:33
///
class SplashAdView extends StatefulWidget {
  final String codeId;
  final int fetchDelay;
  final SplashAdCallBack? callBack;

  const SplashAdView(
      {Key? key, required this.codeId, required this.fetchDelay, this.callBack})
      : super(key: key);

  @override
  _SplashAdViewState createState() => _SplashAdViewState();
}

class _SplashAdViewState extends State<SplashAdView> {
  String _viewType = "com.gstory.flutter_tencentad/SplashAdView";

  MethodChannel? _channel;

  //广告是否显示
  bool _isShowAd = true;

  @override
  void initState() {
    super.initState();
    _isShowAd = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isShowAd) {
      return Container();
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AndroidView(
          viewType: _viewType,
          creationParams: {
            "codeId": widget.codeId,
            "fetchDelay": widget.fetchDelay,
          },
          onPlatformViewCreated: _registerChannel,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: UiKitView(
          viewType: _viewType,
          creationParams: {
            "codeId": widget.codeId,
            "fetchDelay": widget.fetchDelay,
          },
          onPlatformViewCreated: _registerChannel,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else {
      return Container();
    }
  }

  //注册cannel
  void _registerChannel(int id) {
    _channel = MethodChannel("${_viewType}_$id");
    _channel?.setMethodCallHandler(_platformCallHandler);
  }

  //监听原生view传值
  Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      //显示广告
      case OnAdMethod.onShow:
        widget.callBack?.onShow!();
        break;
      //关闭
      case OnAdMethod.onClose:
        widget.callBack?.onClose!();
        break;
      //广告加载失败
      case OnAdMethod.onFail:
        if (mounted) {
          setState(() {
            _isShowAd = false;
          });
        }
        Map map = call.arguments;
        widget.callBack?.onFail!(map["code"], map["message"]);
        break;
      //点击
      case OnAdMethod.onClick:
        widget.callBack?.onClick!();
        break;
      //曝光
      case OnAdMethod.onExpose:
        widget.callBack?.onExpose!();
        break;
      //倒计时
      case OnAdMethod.onADTick:
        widget.callBack?.onADTick!(call.arguments);
        break;
    }
  }
}