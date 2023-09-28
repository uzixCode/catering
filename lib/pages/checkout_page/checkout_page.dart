// ignore_for_file: use_build_context_synchronously

import 'package:catering/pages/detail_orderan_page/detail_orderan_page.dart';
import 'package:catering/pages/main_page/main_page.dart';
import 'package:catering/pages/metode_pembayaran_page/metode_pembayaran_page.dart';
import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

import '../alamat/alamat_page.dart';
import '../map_page/map_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, this.kode});
  final String? kode;
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? image;
  int tipe = 1;
  final namaCon = TextEditingController();
  final notelp = TextEditingController();
  final alamatCon = TextEditingController();
  final mapController = MapController();
  List<Marker> markers = [];
  DateTime? date;
  MetodePembayaranRes? metodePembayaranRes;
  final getProfileCubit = BaseLogic<UserRes>();

  void getDataProfile() async {
    final res = await getProfileCubit.fetch(Repositories.getSingleUser,
        UserRes(kode: locator<SettingCubit>().state.kd));
    if (res is BaseLogicSuccess<BaseResponse<UserRes>>) {
      namaCon.text = res.data?.data?.nama ?? "-";
      notelp.text = res.data?.data?.notelp ?? "-";
    }
    if (res is BaseLogicError) {
      if (mounted) {
        InfoCard(InfoType.error,
                message:
                    res.failure.response.data.toString().replaceAll("\"", ""))
            .show(context);
      }
    }
  }

  void setLocation(LatLng point) => setState(() {
        markers = [
          Marker(
            point: point,
            builder: (context) => Icon(
              Icons.location_on,
              color: Colors.red[400],
              size: context.rsize(.1),
            ),
          )
        ];
        mapController.move(point, 14);
      });
  void addData(int total, BaseLogic<OrderanRes> cubit) async {
    if (verify() == false) return;
    final isConfirm = await InfoCard(
      InfoType.verify,
      message: "Anda yakin ingin melanjutkan",
    ).show(context);
    if (isConfirm != true) return;
    final res = await cubit.fetch(
        Repositories.addOrderan,
        OrderanRes(
          kodeUser: locator<SettingCubit>().state.kd,
          nama: namaCon.text,
          alamat: alamatCon.text,
          notelp: notelp.text,
          pengambilan: date.toString(),
          tipe: tipe,
          lat: markers.first.point.latitude.toString(),
          lng: markers.first.point.longitude.toString(),
          metodePembayaran: metodePembayaranRes?.kode,
          total: total,
        ));
    if (res is BaseLogicSuccess<BaseResponse<OrderanRes>>) {
      InfoCard(
        InfoType.success,
        message: "Berhasil melakukan checkout",
      ).show(context).then((value) async {
        context
            .push(DetailOrderan(
              kode: res.data?.data?.kode,
            ))
            .then((value) => context.pushReplacement(const MainPage()));
      });
    }
    if (res is BaseLogicError) {
      InfoCard(InfoType.error,
              message:
                  res.failure.response.data.toString().replaceAll("\"", ""))
          .show(context);
    }
  }

  bool verify() {
    if (markers.isEmpty) {
      InfoCard(
        InfoType.warning,
        message: "Silahkan pilih lokasi map terlebih dahulu",
      ).show(context);
      return false;
    }
    if (namaCon.text.isEmpty) {
      InfoCard(
        InfoType.warning,
        message: "Silahkan nama penerima terlebih dahulu",
      ).show(context);
      return false;
    }
    if (alamatCon.text.isEmpty) {
      InfoCard(
        InfoType.warning,
        message: "Silahkan isi alamat terlebih dahulu",
      ).show(context);
      return false;
    }
    if (notelp.text.isEmpty) {
      InfoCard(
        InfoType.warning,
        message: "Silahkan isi notelp terlebih dahulu",
      ).show(context);
      return false;
    }
    if (date == null) {
      InfoCard(
        InfoType.warning,
        message: "Silahkan pilih tanggal terlebih dahulu",
      ).show(context);
      return false;
    }
    if (tipe == 2 && metodePembayaranRes == null) {
      InfoCard(
        InfoType.warning,
        message: "Silahkan pilih metode pembayaran terlebih dahulu",
      ).show(context);
      return false;
    }
    return true;
  }

  @override
  void initState() {
    getDataProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const MainText("Checkout"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextButton.icon(
                  onPressed: () async {
                    final alamat =
                        await context.push<AlamatRes>(const AlamatPage());
                    if (alamat == null) return;
                    setLocation(LatLng(double.tryParse(alamat.lat ?? "0") ?? 0,
                        double.tryParse(alamat.lng ?? "0") ?? 0));
                    alamatCon.text = alamat.detail ?? "";
                  },
                  icon: const Icon(Icons.map),
                  label: const MainText("Pilih Alamat")),
              10.v,
              InkWell(
                onTap: () async {
                  final loc = await context.push<LatLng?>(const MapPage());
                  if (loc == null) return;
                  setLocation(loc);
                },
                child: SizedBox(
                  height: context.rsize(.3),
                  width: context.rsize(.8),
                  child: IgnorePointer(
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                          maxZoom: 18,
                          onTap: (tapPosition, point) => setState(() {
                                markers = [
                                  Marker(
                                    point: point,
                                    builder: (context) => Icon(
                                      Icons.location_on,
                                      color: Colors.red[400],
                                      size: context.rsize(.1),
                                    ),
                                  )
                                ];
                                mapController.move(point, 14);
                              }),
                          center: const LatLng(
                              -8.660055582969436, 116.52222799437303)),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        ),
                        MarkerLayer(
                          markers: markers,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              20.v,
              MainTextField(
                controller: alamatCon,
                label: "Alamat",
                maxLines: null,
              ),
              20.v,
              MainTextField(
                controller: namaCon,
                label: "Nama Penerima",
              ),
              20.v,
              MainTextField(
                controller: notelp,
                label: "Notelp Penerima",
              ),
              20.v,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MainText(
                    "Pengambilan",
                    style: TextStyle(fontSize: context.fontSize(20)),
                  ),
                  Row(
                    children: [
                      const MainText("Cod"),
                      Switch(
                        value: tipe == 2,
                        onChanged: (value) => setState(() {
                          tipe = value ? 2 : 1;
                        }),
                      ),
                      const MainText("Ambil di tempat"),
                    ],
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MainText(
                      "Tanggal ${dataBuilder<String>(() {
                        if (tipe == 1) return "Pengantaran";
                        return "Pengambilan";
                      })!}",
                      style: TextStyle(fontSize: context.fontSize(20)),
                    ),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100));
                        if (pickedDate == null) return;
                        final pickedHour = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (pickedHour == null) return;
                        date = DateTime(pickedDate.year, pickedDate.month,
                            pickedDate.day, pickedHour.hour, pickedHour.minute);
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          MainText(date == null
                              ? ""
                              : date
                                  .toString()
                                  .getDateMonthNameShortYearBulletHourMinute()),
                          10.h,
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MainText(
                      "Metode Pembayaran",
                      style: TextStyle(fontSize: context.fontSize(20)),
                    ),
                    InkWell(
                      onTap: () async {
                        final metode = await context.push<MetodePembayaranRes?>(
                            const MetodePembayaranPage(
                          isPicking: true,
                        ));
                        if (metode == null) return;
                        metodePembayaranRes = metode;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          MainText(metodePembayaranRes?.nama),
                          10.h,
                          const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              10.v,
              BaseBlocBuilder(
                  cubit: context.read<BaseLogic<List<KeranjangRes>>>(),
                  onSuccess: (cubit, data) => ExpansionTile(
                      tilePadding: const EdgeInsets.all(0),
                      title: MainText(
                        "Item",
                        style: TextStyle(fontSize: context.fontSize(20)),
                      ),
                      children: data.data
                              ?.map<Widget>((e) => ListTile(
                                    title: MainText(e.produk?.nama),
                                    subtitle:
                                        MainText(e.produk?.harga.toCurrency()),
                                    trailing:
                                        MainText("X ${e.total.toCurrency()}"),
                                  ))
                              .toList() ??
                          [])),
              BaseBlocBuilder(
                cubit: context.read<BaseLogic<List<KeranjangRes>>>(),
                onSuccess: (cubit, data) => Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MainText(
                        "Total",
                        style: TextStyle(fontSize: context.fontSize(20)),
                      ),
                      MainText(
                        dataBuilder(() {
                          int t = 0;
                          for (KeranjangRes element in data.data ?? []) {
                            t += ((element.total ?? 0) *
                                (element.produk?.harga ?? 0));
                          }
                          return "Rp ${t.toCurrency()}";
                        }),
                        style: TextStyle(fontSize: context.fontSize(20)),
                      ),
                    ],
                  ),
                ),
              ),
              BaseBlocBuilder(
                cubit: context.read<BaseLogic<List<KeranjangRes>>>(),
                onSuccess: (cubit, data) => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: BaseBlocBuilder(
                    cubit: BaseLogic<OrderanRes>(),
                    defaultChild: (cubit) => MainButton(
                        isLoading: cubit.state is BaseLogicLoading,
                        onPressed: () async {
                          addData(
                              dataBuilder<int>(() {
                                int t = 0;
                                for (KeranjangRes element in data.data ?? []) {
                                  t += ((element.total ?? 0) *
                                      (element.produk?.harga ?? 0));
                                }
                                return t;
                              })!,
                              cubit);
                        },
                        child: const Left("Checkout")),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
