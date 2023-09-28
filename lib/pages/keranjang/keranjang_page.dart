import 'package:catering/pages/checkout_page/checkout_page.dart';
import 'package:catering/pages/detail_produk_page/detail_produk_page.dart';
import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  void getData() async {
    await context.read<BaseLogic<List<KeranjangRes>>>().fetch(
        Repositories.getAllKeranjangByUser, locator<SettingCubit>().state.kd!);
  }

  void deleteData(String? kode) async {
    final res = await BaseLogic<KeranjangRes>()
        .fetch(Repositories.deleteKeranjang, KeranjangRes(kode: kode));
    if (res is BaseLogicSuccess<BaseResponse<KeranjangRes>>) {
      getData();
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
      child: Scaffold(
        backgroundColor: AppColors.buttonBackgroundCOlor,
        bottomNavigationBar: BaseBlocBuilder(
          cubit: context.read<BaseLogic<List<KeranjangRes>>>(),
          onSuccess: (cubit, data) => (data.data?.length ?? 0) < 1
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MainButton(
                      onPressed: () => context.push(const CheckoutPage()),
                      child: const Left("Checkout")),
                ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: BaseBlocBuilder(
                  cubit: context.read<BaseLogic<List<KeranjangRes>>>(),
                  onLoading: (cubit) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  onSuccess: (cubit, data) => ListView.builder(
                    itemCount: data.data?.length ?? 0,
                    itemBuilder: (context, index) => Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              Dimensions.radius20(context))),
                      child: InkWell(
                        onTap: () => context
                            .push(DetailProdukPage(
                              kode: data.data?[index].kodeProduk,
                              kodeKeranjang: data.data?[index].kode,
                            ))
                            .then((value) => getData()),
                        child: SizedBox(
                          width: double.maxFinite,
                          height: Dimensions.height20(context) * 5,
                          child: Row(
                            children: [
                              Container(
                                width: Dimensions.height20(context) * 5,
                                height: Dimensions.height20(context) * 5,
                                // margin: EdgeInsets.only(
                                //     bottom: Dimensions.height10(context)),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(locator<Htreq>()
                                                .base
                                                .baseUrl +
                                            (data.data?[index].produk?.foto ??
                                                ""))),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radius20(context)),
                                    color: Colors.white),
                              ),
                              SizedBox(
                                width: Dimensions.width10(context),
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: Dimensions.height20(context) * 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    BigText(
                                      text:
                                          data.data?[index].produk?.nama ?? "-",
                                      color: Colors.black54,
                                    ),
                                    SmallText(
                                      text: data.data?[index].catatan ?? "-",
                                      maxLines: 1,
                                    ),
                                    BigText(
                                      text: data.data?[index].total
                                              .toCurrency() ??
                                          "0",
                                      color: Colors.redAccent,
                                    ),
                                  ],
                                ),
                              )),
                              IconButton(
                                  onPressed: () =>
                                      deleteData(data.data?[index].kode),
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red[400],
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
