import 'package:catering_core/core.dart';

void setupMainLocator() {
  setupLocatorCore();
  locator.registerSingleton<SettingCubit>(SettingCubit());
  locator.registerSingleton<BaseLogic<int>>(BaseLogic<int>());
}
