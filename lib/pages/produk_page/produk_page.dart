import 'package:catering/pages/edit_produk_page/edit_produk_page.dart';
import 'package:catering_core/core.dart';
import 'package:catering_core/models/src/produk/produk_res.dart';
import 'package:flutter/material.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final getCubit = BaseLogic<List<ProdukRes>>();
  void getData() async {
    await getCubit.fetch(Repositories.getAllProduk, null);
  }

  void deleteData(String? kode) async {
    final isConfirm = await InfoCard(
      InfoType.verify,
      message: "Apakah anda yakin ingin melanjutkan",
    ).show(context);
    if (isConfirm != true) return;
    final res = await BaseLogic<ProdukRes>().fetch(Repositories.deleteProduk, ProdukRes(kode: kode));
    if (res is BaseLogicSuccess<BaseResponse<ProdukRes>>) {
      getData();
    }
    if (res is BaseLogicError) {
      // ignore: use_build_context_synchronously
      InfoCard(InfoType.error, message: res.failure.response.data.toString().replaceAll("\"", "")).show(context);
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () => context.push(const EditProdukPage()).then((value) => getData()), child: const Icon(Icons.add)),
        body: BaseBlocBuilder(
          cubit: getCubit,
          onLoading: (cubit) => const Center(
            child: CircularProgressIndicator(),
          ),
          onSuccess: (cubit, data) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    10.h,
                    MainText(
                      data.data?.length.toCurrency(),
                      style: TextStyle(fontSize: context.fontSize(20)),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: data.data?.length ?? 0,
                    itemBuilder: (context, index) => Container(
                          color: data.data?[index].isActive == false ? Colors.grey.withOpacity(.5) : null,
                          child: Slidable(
                            endActionPane: ActionPane(motion: const ScrollMotion(), children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  deleteData(data.data?[index].kode);
                                },
                                icon: Icons.delete_forever,
                                backgroundColor: Colors.red[400]!,
                                label: "Hapus",
                              )
                            ]),
                            child: ListTile(
                              onTap: () => context
                                  .push(EditProdukPage(
                                    kode: data.data?[index].kode,
                                  ))
                                  .then((value) => getData()),
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              leading: MainNetworkImage(
                                image: data.data?[index].foto,
                                fit: BoxFit.fill,
                              ),
                              title: MainText(
                                data.data?[index].nama,
                              ),
                              subtitle: MainText(
                                data.data?[index].deskripsi,
                              ),
                              trailing: MainText(
                                data.data?[index].harga.toCurrency(),
                              ),
                            ),
                          ),
                        )),
              ),
            ],
          ),
        ));
  }
}
