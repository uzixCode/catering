import 'package:catering/pages/edit_alamat_page/edit_alamat_page.dart';
import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

class AlamatPage extends StatefulWidget {
  const AlamatPage({super.key});

  @override
  State<AlamatPage> createState() => _AlamatPageState();
}

class _AlamatPageState extends State<AlamatPage> {
  final getCubit = BaseLogic<List<AlamatRes>>();
  void getData() async {
    await getCubit.fetch(
        Repositories.getAllAlamatByUser, locator<SettingCubit>().state.kd!);
  }

  void deleteData(String? kode) async {
    final res = await BaseLogic<AlamatRes>()
        .fetch(Repositories.deleteAlamat, AlamatRes(kode: kode));
    if (res is BaseLogicSuccess<BaseResponse<AlamatRes>>) {
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
        floatingActionButton: FloatingActionButton(
            onPressed: () =>
                context.push(const EditAlamatPage()).then((value) => getData()),
            child: const Icon(Icons.add)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: BaseBlocBuilder(
                  cubit: getCubit,
                  onLoading: (cubit) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  onSuccess: (cubit, data) => ListView.builder(
                      itemCount: data.data?.length ?? 0,
                      itemBuilder: (context, index) => ListTile(
                            onTap: () {
                              context.pop(data.data?[index]);
                            },
                            title: MainText(data.data?[index].nama),
                            subtitle: MainText(data.data?[index].detail),
                            trailing: IconButton(
                                onPressed: () =>
                                    deleteData(data.data?[index].kode),
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red[400],
                                )),
                          )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
