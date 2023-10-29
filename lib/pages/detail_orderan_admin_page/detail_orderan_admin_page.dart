import 'package:catering_core/core.dart';
import 'package:catering_core/models/src/orderanItem/orederan_item.dart';
import 'package:flutter/material.dart';

class DetailOrderanAdmin extends StatefulWidget {
  const DetailOrderanAdmin({super.key, this.kode});
  final String? kode;

  @override
  State<DetailOrderanAdmin> createState() => _DetailOrderanAdminState();
}

class _DetailOrderanAdminState extends State<DetailOrderanAdmin> {
  final getCubit = BaseLogic<OrderanRes>();
  final updateCubit = BaseLogic<OrderanRes>();
  bool isEdit = false;
  Future getData() async {
    final res = await getCubit.fetch(
        Repositories.getSingleOrderan, OrderanRes(kode: widget.kode));
    if (res is BaseLogicSuccess<BaseResponse<OrderanRes>>) {}
    if (res is BaseLogicError) {
      // ignore: use_build_context_synchronously
      InfoCard(InfoType.error,
              message:
                  res.failure.response.data.toString().replaceAll("\"", ""))
          .show(context);
    }
  }

  void updateData(OrderanRes data) async {
    final res = await updateCubit.fetch(
        Repositories.updateOrderan, data.copyWith(kode: widget.kode));
    if (res is BaseLogicSuccess<BaseResponse<OrderanRes>>) {
      setState(() {
        isEdit = false;
      });
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

  String status(int status) => dataBuilder(() {
        switch (status) {
          case 0:
            return "Pesanan Ditolak";
          case 1:
            return "Menunggu Konfirmasi";
          case 2:
            return "Menunggu di Proses";
          case 3:
            return "Sedang di Proses";
          case 4:
            return "Selesai di Proses";
          case 5:
            return "Menunggu Pengantaran/Penjemputan";
          case 6:
            return "Pesanan Selesai";
          default:
            return "Unkown";
        }
      })!;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await getData(),
      child: Scaffold(
        backgroundColor: AppColors.buttonBackgroundCOlor,
        body: BaseBlocBuilder(
          cubit: getCubit,
          onLoading: (cubit) => const Center(
            child: CircularProgressIndicator(),
          ),
          onSuccess: (cubit, data) => ListView(
            children: [
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MainText(
                              status(data.data?.status ?? 1000),
                              style: TextStyle(fontSize: context.fontSize(25)),
                            ),
                          ),
                        ),
                      ),
                      20.v,
                      LRText(
                        left: const Left("Order"),
                        right: Left(dataBuilder(() {
                          if (data.data?.tipe == 2) {
                            return "Ambil di tempat";
                          }
                          return "COD";
                        })!),
                      ),
                      10.v,
                      if (data.data?.tipe == 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: LRText(
                            left: const Left("Ongkir"),
                            right: Right(Builder(
                              builder: (context) {
                                if (isEdit) {
                                  return Row(
                                    children: [
                                      Expanded(
                                          child: MainTextField(
                                        controller: TextEditingController(
                                          text: (data.data?.ongkir ?? 0)
                                              .toCurrency(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onSubmitted: (text) => updateData(
                                            OrderanRes(
                                                ongkir: int.tryParse(
                                                    text.numericOnly()))),
                                      )),
                                      10.h,
                                      InkWell(
                                          onTap: () {
                                            setState(() {
                                              isEdit = false;
                                            });
                                          },
                                          child: Icon(
                                            Icons.cancel,
                                            color: Colors.red[400],
                                          ))
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(
                                      child: MainText(data.data?.ongkir
                                              .toCurrency()
                                              .toString() ??
                                          ""),
                                    ),
                                    10.h,
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            isEdit = true;
                                          });
                                        },
                                        child: const Icon(Icons.edit))
                                  ],
                                );
                              },
                            )),
                          ),
                        ),
                      LRText(
                        left: const Left("Alamat"),
                        right: Left(data.data?.alamat ?? ""),
                      ),
                      10.v,
                      LRText(
                        left: const Left("Penerima"),
                        right: Left(data.data?.nama ?? ""),
                      ),
                      10.v,
                      LRText(
                        left: const Left("No telp"),
                        right: Left(data.data?.notelp ?? ""),
                      ),
                      10.v,
                      LRText(
                        isUseDivider: false,
                        left: const Left("Catatan"),
                        right: Left(data.data?.catatan ?? ""),
                      ),
                    ],
                  ),
                ),
              ),
              20.v,
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BaseBlocBuilder(
                      cubit: BaseLogic<List<OrderanItemRes>>(),
                      initState: (cubit) => cubit.fetch(
                          Repositories.getAllOrderanItemByOrder,
                          data.data?.kode ?? ""),
                      onSuccess: (cubit, dataItem) => ExpansionTile(
                          onExpansionChanged: (value) {
                            if (cubit.state is BaseLogicInit) {
                              cubit.fetch(Repositories.getAllOrderanItemByOrder,
                                  data.data?.kode ?? "");
                            }
                          },
                          tilePadding: const EdgeInsets.all(0),
                          title: MainText(
                            "Item",
                            style: TextStyle(fontSize: context.fontSize(20)),
                          ),
                          children: dataItem.data
                                  ?.map<Widget>((e) => ListTile(
                                        title: MainText(e.produk?.nama),
                                        subtitle: MainText(
                                            e.produk?.harga.toCurrency()),
                                        trailing: MainText(
                                            "X ${e.total.toCurrency()}"),
                                      ))
                                  .toList() ??
                              [])),
                ),
              ),
              Container(
                color: Colors.white,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: LRText(
                    isUseDivider: false,
                    left: Right(MainText(
                      "Total",
                      style: TextStyle(fontSize: context.fontSize(20)),
                    )),
                    right: Right(MainText(
                      "Rp ${((data.data?.total ?? 0) + (data.data?.ongkir ?? 0)).toCurrency()}",
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: context.fontSize(20)),
                    )),
                  ),
                ),
              ),
              20.v,
              Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Builder(builder: (context) {
                      if (data.data?.isPaid == true) {
                        return Row(
                          children: [
                            Expanded(
                              child: MainText(
                                "Sudah Terbayar",
                                style:
                                    TextStyle(fontSize: context.fontSize(16)),
                              ),
                            ),
                            Expanded(
                                child: Center(
                              child: Icon(
                                Icons.monetization_on,
                                color: Colors.green[400],
                              ),
                            ))
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: MainText(
                              "Belum Terbayar",
                              style: TextStyle(fontSize: context.fontSize(16)),
                            ),
                          ),
                          Expanded(
                              child: MainButton(
                                  onPressed: () async {
                                    final isConfirm =
                                        await InfoCard(InfoType.verify)
                                            .show(context);
                                    if (isConfirm != true) return;
                                    updateData(OrderanRes(isPaid: true));
                                  },
                                  child: const Left("Konfirmasi")))
                        ],
                      );
                    }),
                  )),
              if (data.data?.buktiPembayaran != null)
                Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ExpansionTile(
                        title: MainText(
                          "Bukti Pembayaran",
                          style: TextStyle(fontSize: context.fontSize(20)),
                        ),
                        children: [
                          InkWell(
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => Center(
                                child: InteractiveViewer(
                                  child: MainNetworkImage(
                                      image: data.data?.buktiPembayaran),
                                ),
                              ),
                            ),
                            child: SizedBox(
                              height: context.height(.3),
                              child: MainNetworkImage(
                                image: data.data?.buktiPembayaran,
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
              24.v,
              if ((data.data?.status ?? 0) < 6 && (data.data?.status ?? 0) != 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (data.data?.status == 1)
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: MainButton(
                            onPressed: () async {
                              final isConfirm =
                                  await InfoCard(InfoType.verify).show(context);
                              if (isConfirm != true) return;
                              updateData(OrderanRes(status: 0));
                            },
                            child: const Left("Tolak"),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.red[400])),
                          ),
                        )),
                      Expanded(
                        child: MainButton(
                            onPressed: () async {
                              final isConfirm =
                                  await InfoCard(InfoType.verify).show(context);
                              if (isConfirm != true) return;
                              updateData(OrderanRes(
                                  status: (data.data?.status ?? 1000) + 1));
                            },
                            child:
                                Left(status((data.data?.status ?? 1000) + 1))),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
