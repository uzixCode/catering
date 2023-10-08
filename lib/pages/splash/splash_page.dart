// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';

import 'package:catering/base/no_data_page.dart';
import 'package:catering/pages/main_page/main_page.dart';
import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

import '../login_page/login_page.dart';
import '../main_admin_page/main_admin_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 3), () async {
      try {
        await locator<SettingCubit>().load();
        if (locator<SettingCubit>().state.status != null) {
          if (locator<SettingCubit>().state.status == 1) {
            context.pushReplacement(const MainAdminPage());
          }
          if (locator<SettingCubit>().state.status == 2) {
            context.pushReplacement(const MainPage());
          }
          return;
        }
        context.pushReplacement(LoginPage());
      } catch (e) {
        context.pushReplacement(NoDataPage(
          text: e.toString(),
        ));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/image/logo part 1.png",
              width: Dimensions.splashImg(context),
            ),
          ).animate().scale(
              duration: const Duration(seconds: 1),
              begin: const Offset(0, 0),
              end: const Offset(1, 1)),
          Center(
            child: Image.asset(
              "assets/image/logo part 2.png",
              width: Dimensions.splashImg(context),
            ),
          )
              .animate(
                onComplete: (controller) => controller.repeat(),
              )
              .shimmer(duration: const Duration(seconds: 1)),
        ],
      ),
    );
  }
}
