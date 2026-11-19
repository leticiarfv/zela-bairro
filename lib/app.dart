import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

class ZelaBairroApp extends StatelessWidget {
  const ZelaBairroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZelaBairro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
