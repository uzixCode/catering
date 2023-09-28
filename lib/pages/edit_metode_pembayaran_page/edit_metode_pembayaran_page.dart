import 'package:catering/pages/files_page/files_page.dart';
import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

class EditMetodePembayaranPage extends StatefulWidget {
  const EditMetodePembayaranPage({super.key, this.kode});
  final String? kode;
  @override
  State<EditMetodePembayaranPage> createState() =>
      _EditMetodePembayaranPageState();
}

class _EditMetodePembayaranPageState extends State<EditMetodePembayaranPage> {
  final getCubit = BaseLogic<MetodePembayaranRes>();
  final addCubit = BaseLogic<MetodePembayaranRes>();
  String? image;
  bool? isRecomend;
  final namaCon = TextEditingController();
  final atasNamaCon = TextEditingController();
  final noRekCon = TextEditingController();
  final hargaCon = TextEditingController(text: "0");
  final estimasiCon = TextEditingController(text: "0");
  void getData() async {
    final res = await getCubit.fetch(Repositories.getSingleMetodePembayaran,
        MetodePembayaranRes(kode: widget.kode));
    if (res is BaseLogicSuccess<BaseResponse<MetodePembayaranRes>>) {
      namaCon.text = res.data?.data?.nama ?? "-";
      atasNamaCon.text = res.data?.data?.atasNama ?? "-";
      noRekCon.text = res.data?.data?.noRek ?? "-";
      image = res.data?.data?.image;
      setState(() {});
    }
    if (res is BaseLogicError) {
      // ignore: use_build_context_synchronously
      InfoCard(InfoType.error,
              message:
                  res.failure.response.data.toString().replaceAll("\"", ""))
          .show(context);
    }
  }

  void addData() async {
    final res = await addCubit.fetch(
      Repositories.addMetodePembayaran,
      MetodePembayaranRes(
        nama: namaCon.text,
        atasNama: atasNamaCon.text,
        noRek: noRekCon.text,
        image: image,
      ),
    );
    if (res is BaseLogicSuccess<BaseResponse<MetodePembayaranRes>>) {
      // ignore: use_build_context_synchronously
      context.pop();
    }
    if (res is BaseLogicError) {
      // ignore: use_build_context_synchronously
      InfoCard(InfoType.error,
              message:
                  res.failure.response.data.toString().replaceAll("\"", ""))
          .show(context);
    }
  }

  void updateData() async {
    final res = await addCubit.fetch(
      Repositories.updateMetodePembayaran,
      MetodePembayaranRes(
        kode: widget.kode,
        nama: namaCon.text,
        atasNama: atasNamaCon.text,
        noRek: noRekCon.text,
        image: image,
      ),
    );
    if (res is BaseLogicSuccess<BaseResponse<MetodePembayaranRes>>) {
      // ignore: use_build_context_synchronously
      getData();
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
  void initState() {
    if (widget.kode != null) getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          InkWell(
            onTap: () async {
              final img = await context.push<String?>(const FilesPage(
                isPicking: true,
              ));
              if (img == null) return;
              setState(() {
                image = img;
              });
            },
            child: SizedBox(
              width: double.infinity,
              height: context.rsize(.5),
              child: BaseCard(
                  child: MainNetworkImage(
                image: image,
                fit: BoxFit.contain,
              )),
            ),
          ),
          20.v,
          MainTextField(
            controller: namaCon,
            label: "Nama",
          ),
          20.v,
          MainTextField(
            controller: atasNamaCon,
            label: "Atas Nama",
            maxLines: null,
          ),
          20.v,
          MainTextField(
            controller: noRekCon,
            label: "Nomer Rekening / Nomer E-Wallet",
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
                if (widget.kode == null) {
                  addData();
                } else {
                  updateData();
                }
              },
              child: const Left("Simpan"),
            ),
          )
        ],
      ),
    ));
  }
}
