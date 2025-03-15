import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikilt/features/about/about_screen.dart';
import 'package:kikilt/features/device_discovery/device_discovery_screen.dart';
import 'package:kikilt/features/file_transfer/file_selection_screen.dart';
import 'package:kikilt/features/file_transfer/file_transfer_screen.dart';
import 'package:kikilt/features/file_transfer/transfer_history_screen.dart';
import 'package:kikilt/features/home/home_screen.dart';
import 'package:kikilt/features/settings/settings_screen.dart';
import 'package:kikilt/features/splash/splash_screen.dart';

/// 应用路由配置
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/device-discovery',
      builder: (context, state) => const DeviceDiscoveryScreen(),
    ),
    GoRoute(
      path: '/file-selection',
      builder: (context, state) {
        final deviceId = state.queryParameters['deviceId'];
        if (deviceId == null) {
          return const HomeScreen();
        }
        return FileSelectionScreen(deviceId: deviceId);
      },
    ),
    GoRoute(
      path: '/file-transfer',
      builder: (context, state) {
        final deviceId = state.queryParameters['deviceId'];
        final sessionId = state.queryParameters['sessionId'];
        if (deviceId == null || sessionId == null) {
          return const HomeScreen();
        }
        return FileTransferScreen(
          deviceId: deviceId,
          sessionId: sessionId,
        );
      },
    ),
    GoRoute(
      path: '/transfer-history',
      builder: (context, state) => const TransferHistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        '404 - 页面未找到',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    ),
  ),
);