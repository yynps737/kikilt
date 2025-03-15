import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kikilt/app/providers/app_providers.dart';
import 'package:kikilt/app/routes.dart';
import 'package:kikilt/constants/theme.dart';
import 'package:kikilt/services/security_service.dart';
import 'package:refena_flutter/refena_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Hive本地存储
  await Hive.initFlutter();

  // 初始化安全服务（证书和密钥）
  await SecurityService.initialize();

  // 设置首选方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    RefenaScope(
      observers: [
        if (true) // TODO: 根据调试模式调整
          RefenaDebugObserver(),
      ],
      child: const KikiLtApp(),
    ),
  );
}

class KikiLtApp extends StatelessWidget {
  const KikiLtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RefenaProviderScope(
      child: RefenaConsumer<ThemeNotifier, ThemeMode>(
        listenableSelector: (notifier) => notifier,
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'KikiLt',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: appRouter,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],
          );
        },
      ),
    );
  }
}