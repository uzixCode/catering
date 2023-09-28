import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

import '../edit_metode_pembayaran_page/edit_metode_pembayaran_page.dart';

class MetodePembayaranPage extends StatefulWidget {
  const MetodePembayaranPage({super.key, this.isPicking});
  final bool? isPicking;
  @override
  State<MetodePembayaranPage> createState() => _MetodePembayaranPageState();
}

class _MetodePembayaranPageState extends State<MetodePembayaranPage> {
  final getCubit = BaseLogic<List<MetodePembayaranRes>>();
  void getData() async {
    await getCubit.fetch(Repositories.getAllMetodePembayaran, "null");
  }

  void deleteData(String? kode) async {
    final isConfirm = await InfoCard(
      InfoType.verify,
      message: "Apakah anda yakin ingin melanjutkan",
    ).show(context);
    if (isConfirm != true) return;
    final res = await BaseLogic<MetodePembayaranRes>().fetch(
        Repositories.deleteMetodePembayaran, MetodePembayaranRes(kode: kode));
    if (res is BaseLogicSuccess<BaseResponse<MetodePembayaranRes>>) {
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
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: widget.isPicking == true
            ? null
            : FloatingActionButton(
                onPressed: () => context
                    .push(const EditMetodePembayaranPage())
                    .then((value) => getData()),
                child: const Icon(Icons.add)),
        body: BaseBlocBuilder(
          cubit: getCubit,
          onLoading: (cubit) => const Center(
            child: CircularProgressIndicator(),
          ),
          onSuccess: (cubit, data) => ListView.builder(
              itemCount: data.data?.length ?? 0,
              itemBuilder: (context, index) => Slidable(
                    endActionPane:
                        ActionPane(motion: const ScrollMotion(), children: [
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
                      onTap: () {
                        if (widget.isPicking == true) {
                          context.pop(data.data?[index]);
                          return;
                        }
                        context
                            .push(EditMetodePembayaranPage(
                              kode: data.data?[index].kode,
                            ))
                            .then((value) => getData());
                      },
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      leading: MainNetworkImage(
                        image: data.data?[index].image,
                        fit: BoxFit.fill,
                      ),
                      title: MainText(
                        data.data?[index].nama,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MainText(
                            data.data?[index].atasNama,
                          ),
                          MainText(
                            data.data?[index].noRek,
                          ),
                        ],
                      ),
                    ),
                  )),
        ));
  }
}
