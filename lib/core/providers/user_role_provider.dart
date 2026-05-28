import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';

final userRoleProvider =
    StateNotifierProvider<UserRoleNotifier, UserRole>((ref) => UserRoleNotifier(ref));

class UserRoleNotifier extends StateNotifier<UserRole> {
  UserRoleNotifier(this._ref) : super(UserRole.buyer) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final role = await _ref.read(secureStorageProvider).getUserRole();
    state = role;
  }

  void setRole(UserRole role) {
    if (state == role) return;
    state = role;
    _ref.read(secureStorageProvider).setUserRole(role.storageValue);
  }
}
