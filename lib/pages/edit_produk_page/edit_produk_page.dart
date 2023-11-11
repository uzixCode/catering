import 'package:catering/pages/files_page/files_page.dart';
import 'package:catering_core/core.dart';
import 'package:catering_core/models/src/produk/produk_res.dart';
import 'package:flutter/material.dart';

class EditProdukPage extends StatefulWidget {
  const EditProdukPage({super.key, this.kode});
  final String? kode;
  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  final getCubit = BaseLogic<ProdukRes>();
  final addCubit = BaseLogic<ProdukRes>();
  String? image;
  bool? isRecomend;
  bool? isTersedia;
  final namaCon = TextEditingController();
  final deskripsiCon = TextEditingController();
  final kategoriCon = TextEditingController();
  final hargaCon = TextEditingController(text: "0");
  final estimasiCon = TextEditingController(text: "0");
  void getData() async {
    final res = await getCubit.fetch(Repositories.getSingleProduk, ProdukRes(kode: widget.kode));
    if (res is BaseLogicSuccess<BaseResponse<ProdukRes>>) {
      namaCon.text = res.data?.data?.nama ?? "-";
      deskripsiCon.text = res.data?.data?.deskripsi ?? "-";
      hargaCon.text = res.data?.data?.harga.toCurrency() ?? "0";
      estimasiCon.text = res.data?.data?.estimasi.toCurrency() ?? "0";
      kategoriCon.text = res.data?.data?.kategori ?? "-";
      image = res.data?.data?.foto;
      isRecomend = res.data?.data?.recomend;
      isTersedia = res.data?.data?.isActive ?? true;
      setState(() {});
    }
    if (res is BaseLogicError) {
      // ignore: use_build_context_synchronously
      InfoCard(InfoType.error, message: res.failure.response.data.toString().replaceAll("\"", "")).show(context);
    }
  }

  void addData() async {
    final res = await addCubit.fetch(Repositories.addProduk, ProdukRes(nama: namaCon.text, deskripsi: deskripsiCon.text, harga: int.tryParse(hargaCon.text.numericOnly()) ?? 0, foto: image));
    if (res is BaseLogicSuccess<BaseResponse<ProdukRes>>) {
      // ignore: use_build_context_synchronously
      context.pop();
    }
    if (res is BaseLogicError) {
      // ignore: use_build_context_synchronously
      InfoCard(InfoType.error, message: res.failure.response.data.toString().replaceAll("\"", "")).show(context);
    }
  }

  void updateData() async {
    final res = await addCubit.fetch(Repositories.updateProduk, ProdukRes(kode: widget.kode, nama: namaCon.text, deskripsi: deskripsiCon.text, kategori: kategoriCon.text, recomend: isRecomend, estimasi: int.tryParse(estimasiCon.text.numericOnly()) ?? 0, harga: int.tryParse(hargaCon.text.numericOnly()) ?? 0, foto: image, isActive: isTersedia));
    if (res is BaseLogicSuccess<BaseResponse<ProdukRes>>) {
      // ignore: use_build_context_synchronously
      getData();
    }
    if (res is BaseLogicError) {
      // ignore: use_build_context_synchronously
      InfoCard(InfoType.error, message: res.failure.response.data.toString().replaceAll("\"", "")).show(context);
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
            controller: deskripsiCon,
            label: "Deskripsi",
            maxLines: null,
          ),
          20.v,
          MainTextField(
            controller: hargaCon,
            label: "Harga",
            keyboardType: TextInputType.number,
            prefix: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MainText("Rp")
              ],
            ),
          ),
          20.v,
          MainTextField(
            controller: estimasiCon,
            label: "Estimasi",
            keyboardType: TextInputType.number,
            suffix: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MainText("Menit")
              ],
            ),
          ),
          20.v,
          MainTextField(
            controller: kategoriCon,
            label: "Kategori",
          ),
          20.v,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MainText(
                "Tersedia",
                style: TextStyle(fontSize: context.fontSize(20)),
              ),
              Switch(
                value: isTersedia == true,
                onChanged: (value) => setState(() {
                  isTersedia = value;
                }),
              )
            ],
          ),
          20.v,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MainText(
                "Recomend",
                style: TextStyle(fontSize: context.fontSize(20)),
              ),
              Switch(
                value: isRecomend == true,
                onChanged: (value) => setState(() {
                  isRecomend = value;
                }),
              )
            ],
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
