// ignore_for_file: use_build_context_synchronously

import 'package:catering_core/core.dart';
import 'package:catering_core/models/src/produk/produk_res.dart';
import 'package:catering_core/widgets/src/app_column.dart';
import 'package:catering_core/widgets/src/exandable_text_widget.dart';
import 'package:catering_core/widgets/src/icon_and_text_widget.dart';
import 'package:flutter/material.dart';

import '../keranjang/keranjang_page.dart';

class DetailProdukPage extends StatefulWidget {
  const DetailProdukPage({super.key, this.kode, this.kodeKeranjang});
  final String? kode;
  final String? kodeKeranjang;
  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  int total = 1;
  final getCubit = BaseLogic<ProdukRes>();
  final getKeranjangCubit = BaseLogic<KeranjangRes>();
  final addKeranjangCubit = BaseLogic<KeranjangRes>();
  final catatanCon = TextEditingController();
  void getData() async {
    await getCubit.fetch(
        Repositories.getSingleProduk, ProdukRes(kode: widget.kode));
  }

  void getKeranjangData() async {
    if (widget.kodeKeranjang == null) return;
    final res = await getKeranjangCubit.fetch(Repositories.getSingleKeranjang,
        KeranjangRes(kode: widget.kodeKeranjang));
    if (res is BaseLogicSuccess<BaseResponse<KeranjangRes>>) {
      catatanCon.text = res.data?.data?.catatan ?? "";
      total = res.data?.data?.total ?? 0;
      setState(() {});
    }
  }

  void updateKeranjangData() async {
    if (widget.kodeKeranjang == null) return;
    final res = await getKeranjangCubit.fetch(
        Repositories.updateKeranjang,
        KeranjangRes(
            kode: widget.kodeKeranjang,
            catatan: catatanCon.text,
            total: total));
    if (res is BaseLogicSuccess<BaseResponse<KeranjangRes>>) {
      context.pop();
    }
  }

  void addKeranjang() async {
    final res = await addKeranjangCubit.fetch(
      Repositories.addKeranjang,
      KeranjangRes(
        kodeProduk: widget.kode,
        kodeUser: locator<SettingCubit>().state.kd,
        total: total,
        catatan: catatanCon.text,
      ),
    );
    if (res is BaseLogicSuccess<BaseResponse<KeranjangRes>>) {
      context.read<BaseLogic<List<KeranjangRes>>>().fetch(
          Repositories.getAllKeranjangByUser,
          locator<SettingCubit>().state.kd!);
      InfoCard(
        InfoType.success,
        message: "Berhasil di masukan ke keranjang",
      ).show(context);
    }
    if (res is BaseLogicError) {
      InfoCard(InfoType.error,
              message:
                  res.failure.response.data.toString().replaceAll("\"", ""))
          .show(context);
    }
  }

  void decrease() {
    if (total <= 1) {
      setState(() {
        total = 1;
      });
      return;
    }
    setState(() {
      total -= 1;
    });
  }

  void increase() {
    setState(() {
      total += 1;
    });
  }

  @override
  void initState() {
    getData();
    getKeranjangData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
      child: BaseBlocBuilder(
        cubit: getCubit,
        onLoading: (cubit) => const Center(
          child: CircularProgressIndicator(),
        ),
        onSuccess: (cubit, data) => Scaffold(
            body: Stack(
              children: [
                //background image
                Positioned(
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.maxFinite,
                      height: Dimensions.popularFoodImgSize(context),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  locator<Htreq>().base.baseUrl +
                                      (data.data?.foto ?? "")))),
                    )),
                //icon widget
                Positioned(
                    top: Dimensions.height45(context),
                    left: Dimensions.width20(context),
                    right: Dimensions.width20(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () => context.pop(),
                            child: const AppIcon(icon: Icons.arrow_back_ios)),
                        if (widget.kodeKeranjang == null)
                          InkWell(
                            onTap: () => context.push(const KeranjangPage()),
                            child: Stack(
                              children: [
                                const AppIcon(
                                    icon: Icons.shopping_cart_outlined),
                                const Positioned(
                                  right: 0,
                                  top: 0,
                                  child: AppIcon(
                                    icon: Icons.circle,
                                    size: 20,
                                    iconColor: Colors.transparent,
                                    backgroundcolor: AppColors.mainColor,
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  top: 5,
                                  child: BaseBlocBuilder(
                                    cubit: context
                                        .read<BaseLogic<List<KeranjangRes>>>(),
                                    onLoading: (cubit) => const SizedBox(
                                      height: 12,
                                      width: 12,
                                      child: CircularProgressIndicator(),
                                    ),
                                    onSuccess: (cubit, data) => BigText(
                                      text:
                                          data.data?.length.toCurrency() ?? "0",
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ],
                    )),
                //introduction of food
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: (Dimensions.popularFoodImgSize(context) - 20) -
                        MediaQuery.of(context).viewInsets.bottom,
                    child: Container(
                      padding: EdgeInsets.only(
                          left: Dimensions.width20(context),
                          right: Dimensions.width20(context),
                          top: Dimensions.height20(context)),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight:
                                  Radius.circular(Dimensions.radius20(context)),
                              topLeft: Radius.circular(
                                  Dimensions.radius20(context))),
                          color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppColumn(
                              text: data.data?.nama ?? "-",
                              est: data.data?.estimasi ?? 0),
                          SizedBox(
                            height: Dimensions.height10(context),
                          ),
                          MainText(
                            "Rp ${data.data?.harga.toCurrency()}",
                            style: TextStyle(
                                color: AppColors.iconColor2,
                                fontSize: context.fontSize(25)),
                          ),
                          const Divider(
                            thickness: 5,
                          ),
                          SizedBox(
                            height: Dimensions.height10(context),
                          ),
                          Row(
                            children: [
                              BigText(text: "Deskripsi"),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: IconAndTextWidget(
                                      icon: Icons.access_time_rounded,
                                      text:
                                          "${data.data?.estimasi.toCurrency()} min",
                                      iconColor: AppColors.iconColor2),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: Dimensions.height20(context),
                          ),
                          Expanded(
                              child: SingleChildScrollView(
                                  child: ExpandableTextWidget(
                                      text: data.data?.deskripsi ?? "-"))),
                          MainTextField(
                            label: "Catatan",
                            controller: catatanCon,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    )),
                //expandable text widget
              ],
            ),
            bottomNavigationBar: Container(
              height: Dimensions.bottomHeightBar(context),
              padding: EdgeInsets.only(
                  top: Dimensions.height30(context),
                  bottom: Dimensions.height30(context),
                  left: Dimensions.width20(context),
                  right: Dimensions.width20(context)),
              decoration: BoxDecoration(
                  color: AppColors.buttonBackgroundCOlor,
                  borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(Dimensions.radius20(context) * 2),
                      topRight:
                          Radius.circular(Dimensions.radius20(context) * 2))),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        right: Dimensions.width20(context),
                      ),
                      padding: EdgeInsets.only(
                        top: Dimensions.height20(context),
                        bottom: Dimensions.height20(context),
                        left: Dimensions.width20(context),
                        right: Dimensions.width20(context),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              Dimensions.radius20(context)),
                          color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                              onTap: () => decrease(),
                              child: const Icon(Icons.remove,
                                  color: AppColors.signColor)),
                          SizedBox(
                            width: Dimensions.width10(context) / 2,
                          ),
                          BigText(text: total.toCurrency()),
                          SizedBox(
                            width: Dimensions.width10(context) / 2,
                          ),
                          InkWell(
                              onTap: () => increase(),
                              child: const Icon(Icons.add,
                                  color: AppColors.signColor))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (widget.kodeKeranjang != null) {
                          updateKeranjangData();
                          return;
                        }
                        addKeranjang();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            top: Dimensions.height20(context),
                            bottom: Dimensions.height20(context),
                            left: Dimensions.width15(context),
                            right: Dimensions.width15(context)),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                Dimensions.radius20(context)),
                            color: AppColors.mainColor),
                        child: BigText(
                          text: dataBuilder(() {
                            if (widget.kodeKeranjang != null) {
                              return "Update Keranjang";
                            }
                            return "Tambah Keranjang";
                          })!,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
