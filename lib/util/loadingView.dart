import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

// ref https://www.jianshu.com/p/ac31efdd73a6

typedef OnTapCallback = Function(OnloadingView widget);

enum LoadStatus {
  idle,
  loading,
  load_sucs,
  error,
}

class OnloadingView extends StatefulWidget {
  OnloadingView(
      {Key? key,
      this.nowStatus = LoadStatus.idle,
      required this.child,
      required this.onError})
      : super(key: key);

  final Widget child;
  final OnTapCallback onError;
  LoadStatus nowStatus;
  late _OnloadingViewState _state;

  @override
  State<OnloadingView> createState() {
    _state = _OnloadingViewState();
    return _state;
  }

  /// 更新LoadingStatus
  void updateStatus(LoadStatus status) {
    // 避免widget在build时setState()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("updateStatus:$status");
      _state?.updateStatus(status);
    });
  }
}

class _OnloadingViewState extends State<OnloadingView> {
  Widget _buildLoadingBox() {
    return const SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBox() {
    return const SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (widget.nowStatus) {
      case LoadStatus.idle:
        return widget.child;
      case LoadStatus.loading:
        return _buildLoadingBox();
      case LoadStatus.load_sucs:
        return widget.child;
      case LoadStatus.error:
        return _buildErrorBox();
    }
  }

  void updateStatus(LoadStatus status) {
    setState(() {
      widget.nowStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }
}
