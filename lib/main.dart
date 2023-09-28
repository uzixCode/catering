import 'package:catering/pages/splash/splash_page.dart';
import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'main_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupMainLocator();
  await locator.allReady();
  locator<Htreq>().setBaseUrl("http://139.180.185.229:8191");
  runApp(
      BlocProvider.value(value: locator<SettingCubit>(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CubitBuilder<SettingCubit>(
      cubit: context.read<SettingCubit>(),
      builder: (cubit) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => BaseLogic<List<KeranjangRes>>(),
          )
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        ),
      ),
    );
  }
}
