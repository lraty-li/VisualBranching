// import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';

class ShowDesktopIntent extends Intent {
  const ShowDesktopIntent();
}

class HideAction extends Action<ShowDesktopIntent> {
  HideAction();
  @override
  Object? invoke(covariant ShowDesktopIntent intent) {
    // appWindow.minimize();
    return null;
  }
}

/// An ActionDispatcher that logs all the actions that it invokes.
class LoggingActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    print('Action invoked: $action($intent) from $context');
    super.invokeAction(action, intent, context);

    return null;
  }
}
