import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/account_service.dart';

class AccountNotifier extends Notifier<AccountUser?> {
  @override
  AccountUser? build() => AccountService().currentUser;

  Future<void> register({
    required String email,
    required String name,
    required String password,
  }) async {
    final user = await AccountService().register(
        email: email, name: name, password: password);
    state = user;
  }

  Future<void> login({required String email, required String password}) async {
    final user = await AccountService().login(email: email, password: password);
    state = user;
  }

  Future<void> logout() async {
    await AccountService().logout();
    state = null;
  }
}

final accountProvider = NotifierProvider<AccountNotifier, AccountUser?>(
  AccountNotifier.new,
);
