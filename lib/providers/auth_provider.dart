import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_kit/models/auth_mode.dart';
import 'package:flutter_kit/models/state/auth_state.dart';
import 'package:flutter_kit/providers/network_provider.dart';
import 'package:flutter_kit/src/utils/consts.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/toast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

const _initialState = FkAuthState();
const _secureStorage = FlutterSecureStorage();

@riverpod
class Auth extends _$Auth {
  @override
  FkAuthState build() => _initialState;

  /// Comprueba si existe una sesión guardada. Si la hay, la carga en el estado
  /// de la aplicación y lo inicializa. Si no la hay, solo lo inicializa.
  Future<void> initialize() async {
    if (state.isInitialized) {
      return;
    }

    final secureValues = await _secureStorage.readAll();

    if (secureValues[accessTokenKey] != null &&
        secureValues[refreshTokenKey] != null) {
      state = state.copyWith(
        isInitialized: true,
        accessToken: secureValues[accessTokenKey],
        refreshToken: secureValues[refreshTokenKey],
      );
    } else {
      state = state.copyWith(isInitialized: true);
    }
  }

  /// Inicia sesión con las credenciales introducidas. Si se ha iniciado sesión
  /// correctamente, guarda los tokens en el almacenamiento seguro y los carga
  /// en el estado de la aplicación.
  Future<bool> login<T>({
    required T endpoint,
    bool useRefreshToken = false,
    FkAuthMode? authMode,
    user = '',
    pass = '',
  }) async {
    EasyLoading.show();

    final Map<String, dynamic> params = {};

    if (useRefreshToken) {
      params['payload'] = {
        'grantType': 'REFRESH_TOKEN',
        'refreshToken': state.refreshToken,
      };
    } else if (authMode != null) {
      switch (authMode) {
        case FkManualAuthMode():
          params['payload'] = {
            'grantType': 'PASSWORD',
            'username': user,
            'password': pass,
          };
          break;
        case FkAutoAuthMode():
          params['payload'] = {
            'grantType': 'CLIENT_CREDENTIALS',
            'email': authMode.user,
            'clientSecret': authMode.pass,
          };
      }
    }

    try {
      final res = await ref.read(networkProvider.notifier).mutate(
            endpoint: endpoint,
            useBasicAuth: true,
            params: params,
          );

      if (res.exception != null) {
        for (var err in res.exception!.graphqlErrors) {
          Debugger.log('Login error (try)', err);
        }

        if (useRefreshToken) return false;

        Toast.show(
          'Las credenciales introducidas no son correctas',
          mode: ToastMode.error,
        );
      } else {
        Map<String, dynamic>? oAuthData = res.data?['oAuthCreateCredentials'];

        if (oAuthData != null) {
          Debugger.log('Login OAuth data', oAuthData);

          await _secureStorage.write(
            key: accessTokenKey,
            value: oAuthData['accessToken'],
          );
          await _secureStorage.write(
            key: refreshTokenKey,
            value: oAuthData['refreshToken'],
          );

          state = state.copyWith(
            accessToken: oAuthData['accessToken'],
            refreshToken: oAuthData['refreshToken'],
          );

          return true;
        } else {
          Debugger.log('Login OAuth data is null', res);

          Toast.show(
            'Ha habido un error desconocido',
            mode: ToastMode.error,
          );
        }
      }

      return false;
    } catch (e) {
      Debugger.log('Login error (catch)', e);

      logout();

      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Simula un login para depuración.
  Future<bool> debugLogin<T>({
    String accessToken = 'accessToken',
    String refreshToken = 'refreshToken',
    Duration delay = const Duration(seconds: 1),
  }) async {
    EasyLoading.show();

    await _secureStorage.write(
      key: accessTokenKey,
      value: accessToken,
    );
    await _secureStorage.write(
      key: refreshTokenKey,
      value: refreshToken,
    );

    state = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    await Future.delayed(delay);

    EasyLoading.dismiss();

    return true;
  }

  /// Cierra la sesión actual y borra los tokens del almacenamiento seguro.
  Future<void> logout() async {
    Debugger.log('Logout');

    await _secureStorage.delete(key: accessTokenKey);
    await _secureStorage.delete(key: refreshTokenKey);

    state = state.copyWith(accessToken: '', refreshToken: '');
  }
}
