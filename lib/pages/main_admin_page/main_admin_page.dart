import 'dart:developer';

import 'package:catering/base/no_data_page.dart';
import 'package:catering/pages/files_page/files_page.dart';
import 'package:catering/pages/orderan_page/orderan_page.dart';
import 'package:catering/pages/profile_page/profile_page.dart';
import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

import '../metode_pembayaran_page/metode_pembayaran_page.dart';
import '../produk_page/produk_page.dart';

class MainAdminPage extends StatefulWidget {
  const MainAdminPage({super.key});

  @override
  State<MainAdminPage> createState() => _MainAdminPageState();
}

class _MainAdminPageState extends State<MainAdminPage> {
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
                    return const OrderanPage();
                  case 1:
                    return const ProdukPage();
                  case 2:
                    return const FilesPage();
                  case 3:
                    return const MetodePembayaranPage();
                  case 4:
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
            BottomNavigationBarItem(icon: Icon(Icons.archive), label: ("home")),
            BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2), label: ("produk")),
            BottomNavigationBarItem(
                icon: Icon(Icons.folder_open), label: ("files")),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: ("metode pembayaran")),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ("me"))
          ],
        ));
  }
}
