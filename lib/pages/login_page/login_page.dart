// ignore: file_names

import 'package:catering/pages/daftar_user_page/daftar_user_page.dart';
import 'package:catering/pages/main_page/main_page.dart';
import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

import '../main_admin_page/main_admin_page.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final email = TextEditingController();
  final password = TextEditingController();
  bool isObscure = true;
  void login(BaseLogic<UserRes> cubit, BuildContext context) async {
    final res = await cubit.fetch(Repositories.login,
        UserRes(email: email.text, password: password.text));
    if (res is BaseLogicSuccess<BaseResponse<UserRes>>) {
      if (res.data?.data == null) return;

      // ignore: use_build_context_synchronously
      InfoCard(
        InfoType.success,
        message: "Sukses",
      ).show(context).then(
        (value) async {
          locator<SettingCubit>().emiting(
            SettingState(
              status: res.data?.data?.status,
              kd: res.data?.data?.kode,
            ),
          );
          if (res.data?.data?.status == 1) {
            // ignore: use_build_context_synchronously
            context.pushReplacement(const MainAdminPage());
          }
          if (res.data?.data?.status == 2) {
            // ignore: use_build_context_synchronously
            context.pushReplacement(const MainPage());
          }
        },
      );
    }
    if (res is BaseLogicError) {
      // ignore: use_build_context_synchronously
      InfoCard(InfoType.error,
              message:
                  res.failure.response.data.toString().replaceAll("\"", ""))
          .show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: context.rsize(0.50, max: 250),
                        height: context.rsize(0.50, max: 250),
                        child: Image.asset("assets/image/logo part 1.png")),
                    MainText(
                      "Login",
                      style: TextStyle(
                          color: BaseColor.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: context.fontSize(15, max: 45)),
                    ),
                    20.v,
                    MainTextField(
                      controller: email,
                      label: "Email",
                      hintText: "Masukan email",
                    ),
                    20.v,
                    StatefulBuilder(
                      builder: (_, state) => MainTextField(
                        controller: password,
                        label: "Password",
                        hintText: "Password",
                        isObscure: isObscure,
                        suffix: AnimatedCrossFade(
                            firstChild: IconButton(
                                onPressed: () => state.call(() {
                                      isObscure = !isObscure;
                                    }),
                                icon: const Icon(Icons.visibility)),
                            secondChild: IconButton(
                                onPressed: () => state.call(() {
                                      isObscure = !isObscure;
                                    }),
                                icon: const Icon(Icons.visibility_off)),
                            crossFadeState: isObscure
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300)),
                      ),
                    ),
                    20.v,
                    BaseBlocBuilder<UserRes>(
                      cubit: BaseLogic<UserRes>(),
                      defaultChild: (cubit) => SizedBox(
                        width: double.maxFinite,
                        child: MainButton(
                          onPressed: () => login(cubit, context),
                          isLoading: cubit.state is BaseLogicLoading,
                          child: const Left("Masuk"),
                        ),
                      ),
                    ),
                    // TextButton(
                    //     onPressed: () => context.push(const LupaPasswordPage()),
                    //     child: const MainText("Lupa password ?")),
                    20.v,
                    BaseBlocBuilder<UserRes>(
                      cubit: BaseLogic<UserRes>(),
                      defaultChild: (cubit) => SizedBox(
                          width: double.maxFinite,
                          child: TextButton(
                              onPressed: () {
                                context.push(const DaftarUserPage());
                              },
                              child: MainText(
                                "Daftar",
                                style: TextStyle(
                                    fontSize: context.fontSize(25, max: 25)),
                              ))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 700)),
      ],
    ));
  }
}
