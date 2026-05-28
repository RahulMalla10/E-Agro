import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifies [GoRouter] to re-run redirects without recreating the router instance.
final routerRefreshProvider = Provider<RouterRefresh>((ref) {
  final refresh = RouterRefresh();
  ref.onDispose(refresh.dispose);
  return refresh;
});

class RouterRefresh extends ChangeNotifier {
  void notifyRouter() => notifyListeners();
}
