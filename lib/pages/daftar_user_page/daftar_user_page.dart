import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

class DaftarUserPage extends StatefulWidget {
  const DaftarUserPage({super.key, this.kode});
  final String? kode;
  @override
  State<DaftarUserPage> createState() => _DaftarUserPageState();
}

class _DaftarUserPageState extends State<DaftarUserPage> {
  final addCubit = BaseLogic<UserRes>();
  String? image;
  bool? isRecomend;
  final emailCon = TextEditingController();
  final namaCon = TextEditingController();
  final passwordCon = TextEditingController();
  final ulangiPasswordCon = TextEditingController();
  final notelpCon = TextEditingController();

  void addData() async {
    if (!verify()) return;
    final res = await addCubit.fetch(
        Repositories.addUser,
        UserRes(
          email: emailCon.text,
          nama: namaCon.text,
          password: passwordCon.text,
          notelp: notelpCon.text,
          status: 2,
        ));
    if (res is BaseLogicSuccess<BaseResponse<UserRes>>) {
      // ignore: use_build_context_synchronously
      InfoCard(
        InfoType.success,
        message: "Sukses",
      ).show(context).then((value) => context.pop());
    }
    if (res is BaseLogicError) {
      // ignore: use_build_context_synchronously
      InfoCard(InfoType.error,
              message:
                  res.failure.response.data.toString().replaceAll("\"", ""))
          .show(context);
    }
  }

  bool verify() {
    if (emailCon.text.isEmpty) {
      InfoCard(
        InfoType.warning,
        message: "Email tidak boleh kosong",
      ).show(context);
      return false;
    }
    if (namaCon.text.isEmpty) {
      InfoCard(
        InfoType.warning,
        message: "Nama tidak boleh kosong",
      ).show(context);
      return false;
    }
    if (notelpCon.text.isEmpty) {
      InfoCard(
        InfoType.warning,
        message: "No. Telp tidak boleh kosong",
      ).show(context);
      return false;
    }
    if (passwordCon.text.isEmpty) {
      InfoCard(
        InfoType.warning,
        message: "Password tidak boleh kosong",
      ).show(context);
      return false;
    }
    if (ulangiPasswordCon.text != passwordCon.text) {
      InfoCard(
        InfoType.warning,
        message: "Ulangi password tidak match",
      ).show(context);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const MainText("Daftar"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              MainTextField(
                controller: emailCon,
                label: "Email",
                maxLines: null,
              ),
              20.v,
              MainTextField(
                controller: namaCon,
                label: "Nama",
              ),
              20.v,
              MainTextField(
                controller: notelpCon,
                label: "No. Telp",
                maxLines: null,
              ),
              20.v,
              MainTextField(
                controller: passwordCon,
                label: "Password",
              ),
              20.v,
              MainTextField(
                controller: ulangiPasswordCon,
                label: "Ulangi Password",
                maxLines: null,
              ),
              20.v,
              BaseBlocBuilder(
                cubit: addCubit,
                defaultChild: (cubit) => MainButton(
                  isLoading: cubit.state is BaseLogicLoading,
                  onPressed: () async {
                    final isConfirm = await InfoCard(
                      InfoType.verify,
                      message: "Apakah anda yakin ingin melanjutkan",
                    ).show(context);
                    if (isConfirm != true) return;
                    addData();
                  },
                  child: const Left("Simpan"),
                ),
              )
            ],
          ),
        ));
  }
}
