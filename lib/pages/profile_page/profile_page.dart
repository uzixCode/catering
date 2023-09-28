import 'package:catering/pages/splash/splash_page.dart';
import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final getCubit = BaseLogic<UserRes>();
  final updateCubit = BaseLogic<UserRes>();
  final namaCon = TextEditingController();
  final emailCon = TextEditingController();
  final notelpCon = TextEditingController();

  void getData() async {
    final res = await getCubit.fetch(Repositories.getSingleUser,
        UserRes(kode: locator<SettingCubit>().state.kd));
    if (res is BaseLogicSuccess<BaseResponse<UserRes>>) {
      namaCon.text = res.data?.data?.nama ?? "-";
      emailCon.text = res.data?.data?.email ?? "-";
      notelpCon.text = res.data?.data?.notelp ?? "-";
    }
    if (res is BaseLogicError) {
      if (mounted) {
        InfoCard(InfoType.error,
                message:
                    res.failure.response.data.toString().replaceAll("\"", ""))
            .show(context);
      }
    }
  }

  void updateData() async {
    final isConfirm = await InfoCard(
      InfoType.verify,
      message: "Apakah anda yakin ingin melanjutkan",
    ).show(context);
    if (isConfirm != true) return;
    final res = await updateCubit.fetch(
        Repositories.updateUser,
        UserRes(
            kode: locator<SettingCubit>().state.kd,
            nama: namaCon.text,
            email: emailCon.text,
            notelp: notelpCon.text));
    if (res is BaseLogicSuccess<BaseResponse<UserRes>>) {
      // ignore: use_build_context_synchronously
      getData();
      setState(() {
        isEdit = false;
      });
    }
    if (res is BaseLogicError) {
      // ignore: use_build_context_synchronously
      InfoCard(InfoType.error,
              message:
                  res.failure.response.data.toString().replaceAll("\"", ""))
          .show(context);
    }
  }

  bool isEdit = false;
  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseBlocBuilder(
        cubit: getCubit,
        onLoading: (cubit) => const Center(
          child: CircularProgressIndicator(),
        ),
        onSuccess: (cubit, data) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: ListView(
            children: [
              Align(
                  alignment: Alignment.topRight,
                  child: TextButton.icon(
                      onPressed: () async {
                        final isConfirm = await InfoCard(
                          InfoType.verify,
                          message: "Apakah anda yakin ingin melanjutkan",
                        ).show(context);
                        if (isConfirm != true) return;
                        // ignore: use_build_context_synchronously
                        context.read<SettingCubit>().reset();
                        // ignore: use_build_context_synchronously
                        context.pushReplacement(const SplashScreen());
                      },
                      icon: const Icon(Icons.logout),
                      label: const MainText("Logout"))),
              20.v,
              MainTextField(
                label: "Nama",
                readOnly: !isEdit,
                controller: namaCon,
              ),
              20.v,
              MainTextField(
                label: "Email",
                readOnly: !isEdit,
                controller: emailCon,
              ),
              20.v,
              MainTextField(
                label: "Notelp",
                readOnly: !isEdit,
                controller: notelpCon,
              ),
              20.v,
              if (!isEdit)
                SizedBox(
                  width: double.infinity,
                  child: MainButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.grey[400])),
                    child: const Left("Edit"),
                    onPressed: () async {
                      setState(() {
                        isEdit = true;
                      });
                    },
                  ),
                ),
              if (isEdit)
                SizedBox(
                  width: double.infinity,
                  child: MainButton(
                    child: const Left("Simpan"),
                    onPressed: () => updateData(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
