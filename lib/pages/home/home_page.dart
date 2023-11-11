import 'package:catering_core/core.dart';
import 'package:catering_core/models/src/produk/produk_res.dart';
import 'package:catering_core/widgets/src/app_column.dart';
import 'package:catering_core/widgets/src/icon_and_text_widget.dart';
import 'package:flutter/material.dart';

import '../detail_produk_page/detail_produk_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final getCubit = BaseLogic<List<ProdukRes>>();
  final getRecomendCubit = BaseLogic<List<ProdukRes>>();
  CrossFadeState state = CrossFadeState.showFirst;
  final searchCon = TextEditingController();
  Future getData([String? keyword]) async {
    await getCubit.fetch(Repositories.postSearchProduk, keyword ?? searchCon.text);
  }

  Future getDataRcomend() async {
    await getRecomendCubit.fetch(Repositories.getAllRecomendProduk, null);
  }

  @override
  void initState() {
    getData();
    getDataRcomend();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (state == CrossFadeState.showSecond) {
          setState(() {
            state = CrossFadeState.showFirst;
          });
          return false;
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await getDataRcomend();
          await getData();
        },
        child: Scaffold(
          backgroundColor: AppColors.buttonBackgroundCOlor,
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: Dimensions.height45(context), bottom: Dimensions.height15(context)),
                padding: EdgeInsets.only(left: Dimensions.width20(context), right: Dimensions.width20(context)),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 500),
                  crossFadeState: state,
                  secondChild: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Container(
                        height: Dimensions.height45(context),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.height45(context))),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: TextField(
                              controller: searchCon,
                              decoration: const InputDecoration.collapsed(hintText: "Cari Produk"),
                              onChanged: (value) => getData(),
                            ),
                          ),
                        ),
                      )),
                      20.h,
                      Center(
                        child: InkWell(
                          onTap: () => setState(() {
                            state = CrossFadeState.showFirst;
                          }),
                          child: Container(
                            width: Dimensions.width45(context),
                            height: Dimensions.height45(context),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radius15(context)),
                              color: AppColors.mainColor,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: Dimensions.iconSize24(context),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  firstChild: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                        child: InkWell(
                          onTap: () => setState(() {
                            state = CrossFadeState.showSecond;
                          }),
                          child: Container(
                            width: Dimensions.width45(context),
                            height: Dimensions.height45(context),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radius15(context)),
                              color: AppColors.mainColor,
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: Dimensions.iconSize24(context),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: ListView(
                children: [
                  if (state == CrossFadeState.showFirst)
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(Dimensions.width30(context), 0, 0, 20),
                          child: BigText(text: "Recomended", size: context.fontSize(18)),
                        )),
                  if (state == CrossFadeState.showFirst)
                    BaseBlocBuilder(
                        cubit: getRecomendCubit,
                        onLoading: (cubit) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        onSuccess: (cubit, data) => CarouselSlider.builder(
                              itemCount: data.data?.length ?? 0,
                              options: CarouselOptions(
                                  enlargeCenterPage: true,
                                  // enableInfiniteScroll: true,
                                  height: Dimensions.pageViewContainer(context) + Dimensions.height30(context)),
                              itemBuilder: (context, index, realIndex) => Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => context.push(DetailProdukPage(
                                      kode: data.data?[index].kode,
                                    )),
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      height: Dimensions.pageViewContainer(context),
                                      margin: EdgeInsets.only(left: Dimensions.width10(context), right: Dimensions.width10(context)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radius30(context)),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(color: index.isEven ? const Color(0xFF69c5df) : const Color(0xFF9294cc), image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(locator<Htreq>().base.baseUrl + (data.data?[index].foto ?? "")))),
                                          ),
                                          if (data.data?[index].isActive == false)
                                            Positioned.fill(
                                                child: Container(
                                              color: Colors.grey.withOpacity(.8),
                                            )),
                                          if (data.data?[index].isActive == false)
                                            const Align(
                                                alignment: Alignment.center,
                                                child: MainText(
                                                  "Tidak tersedia",
                                                  style: TextStyle(color: Colors.white),
                                                ))
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      // height: Dimensions.pageViewTextContainer(context),
                                      margin: EdgeInsets.only(
                                        left: Dimensions.width30(context),
                                        right: Dimensions.width30(context),
                                        // bottom: Dimensions.height30(context),
                                      ),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radius20(context)), color: Colors.white, boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xFFe8e8e8),
                                          blurRadius: 5.0,
                                          offset: Offset(0, 5),
                                        ),
                                        BoxShadow(
                                          color: Colors.white,
                                          offset: Offset(-5, 0),
                                        ),
                                        BoxShadow(
                                          color: Colors.white,
                                          offset: Offset(5, 0),
                                        )
                                      ]),
                                      child: Container(
                                        padding: EdgeInsets.only(top: Dimensions.height20(context), bottom: Dimensions.height20(context), left: Dimensions.height15(context), right: Dimensions.height15(context)),
                                        child: AppColumn(
                                          text: data.data?[index].nama ?? "-",
                                          est: data.data?[index].estimasi,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                  if (state == CrossFadeState.showFirst)
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(Dimensions.width30(context), 20, 0, 10),
                          child: BigText(text: "Kategori", size: context.fontSize(18)),
                        )),
                  if (state == CrossFadeState.showFirst)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                              child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: InkWell(
                                    onTap: () {
                                      getData("CATERING");
                                      setState(() {
                                        state = CrossFadeState.showSecond;
                                      });
                                    },
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(child: Image.asset("assets/image/catering.png")),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const MainText("Catering")
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))),
                          Expanded(
                              child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: InkWell(
                                    onTap: () {
                                      getData("KUE_KERING");
                                      setState(() {
                                        state = CrossFadeState.showSecond;
                                      });
                                    },
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(child: Image.asset("assets/image/kue_kering.png")),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const MainText("Kue Kering")
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))),
                          Expanded(
                              child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: InkWell(
                                    onTap: () {
                                      getData("KUE_BASAH");
                                      setState(() {
                                        state = CrossFadeState.showSecond;
                                      });
                                    },
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(child: Image.asset("assets/image/kue_basah.png")),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const MainText("Kue Basah")
                                          ],
                                        ),
                                      ),
                                    ),
                                  )))
                        ],
                      ),
                    ),
                  BaseBlocBuilder(
                      cubit: getCubit,
                      onLoading: (cubit) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                      onSuccess: (cubit, data) => Column(
                            children: List.generate(
                              data.data?.length ?? 0,
                              (index) => InkWell(
                                onTap: () => context.push(DetailProdukPage(
                                  kode: data.data?[index].kode,
                                )),
                                child: Container(
                                  margin: EdgeInsets.only(left: Dimensions.width20(context), right: Dimensions.width20(context), bottom: Dimensions.height10(context)),
                                  child: Row(
                                    children: [
                                      Container(
                                        clipBehavior: Clip.antiAlias,
                                        width: Dimensions.listViewImgSize(context),
                                        height: Dimensions.listViewTextConstSize(context),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Dimensions.radius20(context)),
                                          color: Colors.white38,
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: MainNetworkImage(
                                                image: data.data?[index].foto,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (data.data?[index].isActive == false)
                                              Positioned.fill(
                                                  child: Container(
                                                color: Colors.grey.withOpacity(.8),
                                              )),
                                            if (data.data?[index].isActive == false)
                                              const Align(
                                                  alignment: Alignment.center,
                                                  child: MainText(
                                                    "Tidak tersedia",
                                                    style: TextStyle(color: Colors.white),
                                                  ))
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: Dimensions.listViewTextConstSize(context),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(topRight: Radius.circular(Dimensions.radius20(context)), bottomRight: Radius.circular(Dimensions.radius20(context))),
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(left: Dimensions.width10(context), right: Dimensions.width10(context)),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                BigText(text: data.data?[index].nama ?? "-"),
                                                SizedBox(
                                                  height: Dimensions.height10(context),
                                                ),
                                                SmallText(
                                                  text: data.data?[index].deskripsi ?? "-",
                                                  maxLines: 1,
                                                ),
                                                SizedBox(
                                                  height: Dimensions.height10(context),
                                                ),
                                                IconAndTextWidget(icon: Icons.access_time_rounded, text: data.data?[index].estimasi.toCurrency() ?? "0", iconColor: AppColors.iconColor2),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
