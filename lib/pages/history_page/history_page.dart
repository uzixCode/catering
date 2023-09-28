import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

import '../detail_orderan_page/detail_orderan_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final getCubit = BaseLogic<List<OrderanRes>>();
  Future getData() async {
    await getCubit.fetch(
        Repositories.getAllOrderanByUser, locator<SettingCubit>().state.kd!);
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
    return RefreshIndicator(
      onRefresh: () async => await getData(),
      child: Scaffold(
        backgroundColor: AppColors.buttonBackgroundCOlor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BaseBlocBuilder(
            cubit: getCubit,
            onLoading: (cubit) => const Center(
              child: CircularProgressIndicator(),
            ),
            onSuccess: (cubit, data) => ListView.builder(
                itemCount: data.data?.length ?? 0,
                itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.white,
                      child: ListTile(
                        onTap: () => context.push(DetailOrderan(
                          kode: data.data?[index].kode,
                        )),
                        title: MainText(data.data?[index].nama),
                        subtitle: MainText(data.data?[index].createdAt
                            .getDateMonthNameShortYearBulletHourMinute()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MainText(data.data?[index].total.toCurrency()),
                            10.h,
                            if (data.data?[index].status == 6)
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green[400],
                              ),
                            if (data.data?[index].status == 0)
                              Icon(
                                Icons.cancel_outlined,
                                color: Colors.red[400],
                              )
                          ],
                        ),
                      ),
                    )),
          ),
        ),
      ),
    );
  }
}
