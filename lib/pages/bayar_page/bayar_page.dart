// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:catering/pages/files_page/files_page.dart';
import 'package:catering_core/core.dart';

class BayarPage extends StatefulWidget {
  const BayarPage({
    Key? key,
    this.kode,
    this.kodeOrderan,
  }) : super(key: key);
  final String? kode;
  final String? kodeOrderan;
  @override
  State<BayarPage> createState() => _EditMetodePembayaranPageState();
}

class _EditMetodePembayaranPageState extends State<BayarPage> {
  final getCubit = BaseLogic<MetodePembayaranRes>();
  final updateCubit = BaseLogic<OrderanRes>();
  void getData() async {
    final res = await getCubit.fetch(Repositories.getSingleMetodePembayaran,
        MetodePembayaranRes(kode: widget.kode));
    if (res is BaseLogicSuccess<BaseResponse<MetodePembayaranRes>>) {}
    if (res is BaseLogicError) {
      InfoCard(InfoType.error,
              message:
                  res.failure.response.data.toString().replaceAll("\"", ""))
          .show(context);
    }
  }

  void updateData(OrderanRes data) async {
    final res = await updateCubit.fetch(
        Repositories.updateOrderan, data.copyWith(kode: widget.kodeOrderan));
    if (res is BaseLogicSuccess<BaseResponse<OrderanRes>>) {
      InfoCard(InfoType.success, message: "Sukses")
          .show(context)
          .then((value) => context.pop());
    }
    if (res is BaseLogicError) {
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
        backgroundColor: Colors.grey[100],
        body: BaseBlocBuilder(
          cubit: getCubit,
          onLoading: (cubit) => const Center(
            child: CircularProgressIndicator(),
          ),
          onSuccess: (cubit, data) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Center(
                          child: MainText(
                            "Bayar",
                            style: TextStyle(fontSize: context.fontSize(15)),
                          ),
                        ),
                        24.v,
                        LRText(
                          left: const Left("Metode"),
                          right: Left(data.data?.nama ?? ""),
                        ),
                        10.v,
                        LRText(
                          left: const Left("Atas Nama"),
                          right: Left(data.data?.atasNama ?? ""),
                        ),
                        10.v,
                        LRText(
                          left: const Left("No Bank/E-Wallet"),
                          right: Left(data.data?.noRek ?? ""),
                        ),
                        if (data.data?.image != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: MainNetworkImage(image: data.data?.image),
                          ),
                        20.v,
                        BaseBlocBuilder(
                          cubit: updateCubit,
                          defaultChild: (cubit) => MainButton(
                            child: const Left("Konfirmasi"),
                            isLoading: cubit.state is BaseLogicLoading,
                            onPressed: () async {
                              final picked =
                                  await context.push<String?>(FilesPage(
                                isPicking: true,
                                owner: locator<SettingCubit>().state.kd,
                              ));
                              if (picked == null) return;
                              // print(picked);
                              updateData(OrderanRes(buktiPembayaran: picked));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
