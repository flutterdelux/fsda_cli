import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import 'dashboard/dashboard_route.dart';

class Startup extends StatefulWidget {
  static const _logoSize = 150.0;
  static const _logoGap = 8.0;

  const Startup({super.key});

  @override
  State<Startup> createState() => _StartupState();
}

class _StartupState extends State<Startup> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) DashboardRoute.toHome(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: Startup._logoSize,
          height: Startup._logoSize,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(Startup._logoGap),
                child: ClipOval(
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    AppAssets.logo,
                    width: Startup._logoSize,
                    height: Startup._logoSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const CircularProgressIndicator(strokeWidth: 4.0),
            ],
          ),
        ),
      ),
    );
  }
}
