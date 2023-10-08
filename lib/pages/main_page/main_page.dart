import 'dart:developer';

import 'package:catering/base/no_data_page.dart';
import 'package:catering/pages/history_page/history_page.dart';
import 'package:catering/pages/home/home_page.dart';
import 'package:catering/pages/keranjang/keranjang_page.dart';
import 'package:catering/pages/profile_page/profile_page.dart';
import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void onTapNav(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateFCMToken() async {
    FirebaseMessaging.instance
        .getToken()
        .then((value) => log("FCM TOKEN : $value"));
  }

  @override
  void initState() {
    updateFCMToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
            Expanded(
              child: dataBuilder(() {
                switch (_selectedIndex) {
                  case 0:
                    return const HomePage();
                  case 1:
                    return const KeranjangPage(
                      isUseAppbar: null,
                    );
                  case 2:
                    return const HistoryPage();
                  case 3:
                    return const ProfilePage();
                  default:
                    return const NoDataPage(text: "Halaman Tidak Ditemukan");
                }
              })!,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: AppColors.mainColor,
          unselectedItemColor: Colors.amberAccent,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 0.0,
          unselectedFontSize: 0.0,
          currentIndex: _selectedIndex,
          onTap: onTapNav,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: ("Main")),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: ("cart")),
            BottomNavigationBarItem(
                icon: Icon(Icons.archive), label: ("history")),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ("me"))
          ],
        ));
  }
}
