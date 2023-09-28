import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

import '../map_page/map_page.dart';

class EditAlamatPage extends StatefulWidget {
  const EditAlamatPage({super.key, this.kode});
  final String? kode;
  @override
  State<EditAlamatPage> createState() => _EditAlamatPageState();
}

class _EditAlamatPageState extends State<EditAlamatPage> {
  final getCubit = BaseLogic<AlamatRes>();
  final addCubit = BaseLogic<AlamatRes>();

  final namaCon = TextEditingController();
  final detailCon = TextEditingController();
  final kategoriCon = TextEditingController();
  final hargaCon = TextEditingController(text: "0");
  final estimasiCon = TextEditingController(text: "0");
  List<Marker> markers = [];
  final mapController = MapController();
  void getData() async {
    final res = await getCubit.fetch(
        Repositories.getSingleAlamat, AlamatRes(kode: widget.kode));
    if (res is BaseLogicSuccess<BaseResponse<AlamatRes>>) {
      namaCon.text = res.data?.data?.nama ?? "-";
      detailCon.text = res.data?.data?.detail ?? "-";
      setLocation(LatLng(double.tryParse(res.data?.data?.lat ?? "0") ?? 0,
          double.tryParse(res.data?.data?.lng ?? "0") ?? 0));
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
        Repositories.addAlamat,
        AlamatRes(
          kodeUser: locator<SettingCubit>().state.kd,
          nama: namaCon.text,
          detail: detailCon.text,
          lat: markers.first.point.latitude.toString(),
          lng: markers.first.point.longitude.toString(),
        ));
    if (res is BaseLogicSuccess<BaseResponse<AlamatRes>>) {
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
      Repositories.updateAlamat,
      AlamatRes(
        kode: widget.kode,
        nama: namaCon.text,
        detail: detailCon.text,
        lat: markers.first.point.latitude.toString(),
        lng: markers.first.point.longitude.toString(),
      ),
    );
    if (res is BaseLogicSuccess<BaseResponse<AlamatRes>>) {
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
              final loc = await context.push<LatLng?>(const MapPage());
              if (loc == null) return;
              setLocation(loc);
            },
            child: SizedBox(
              width: double.infinity,
              height: context.rsize(.5),
              child: IgnorePointer(
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                      maxZoom: 18,
                      center:
                          const LatLng(-6.175109367260184, 106.82724425556285)),
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
            controller: namaCon,
            label: "Nama",
          ),
          20.v,
          MainTextField(
            controller: detailCon,
            label: "Detail Alamat",
            maxLines: null,
          ),
          20.v,
          BaseBlocBuilder(
            cubit: addCubit,
            defaultChild: (cubit) => MainButton(
              isLoading: cubit.state is BaseLogicLoading,
              onPressed: () async {
                if (markers.isEmpty) {
                  InfoCard(
                    InfoType.warning,
                    message: "Silahkan pilih map terlebih dahulu",
                  ).show(context);
                  return;
                }
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
