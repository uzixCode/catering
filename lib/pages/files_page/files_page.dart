import 'dart:developer';

import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

import 'logic.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key, this.isPicking, this.owner});
  final bool? isPicking;
  final String? owner;
  @override
  State<FilesPage> createState() => _FilesPageState();
}

class Notifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

class _FilesPageState extends State<FilesPage> {
  final userCubit = BaseLogic<List<FileRes>>();
  final uploadCubit = BaseLogic<FileRes>();
  final searchCon = TextEditingController();
  final deleteNotifierCubit = DeleteButtonNotifier();
  List<String> selectedFile = [];
  int? isSuspend;
  String sort = "desc";
  void getData() async {
    await userCubit.fetch(Repositories.getFiles, FileRes(owner: widget.owner));
    selectedFile.clear();
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  void uploadFile() async {
    FilePickerResult? pickdFile = await FilePicker.platform.pickFiles();
    if (pickdFile == null) return;
    final res = await uploadCubit.fetch(Repositories.uploadFiles,
        FileRes(data: pickdFile, owner: widget.owner));
    if (res is BaseLogicSuccess<BaseResponse<FileRes>>) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isPicking != true
          ? null
          : AppBar(
              title: const MainText("Pilih File"),
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CubitBuilder(
            isWithProvider: true,
            cubit: deleteNotifierCubit,
            builder: (cubit) => selectedFile.isEmpty
                ? const SizedBox()
                : BaseBlocBuilder(
                    cubit: BaseLogic<dynamic>(),
                    defaultChild: (cubit) => FloatingActionButton(
                        onPressed: () async {
                          final res = await cubit.fetch(
                              Repositories.deleteFiles,
                              DeleteFileReq(files: selectedFile));
                          if (res is BaseLogicSuccess<BaseResponse<dynamic>>) {
                            getData();
                          } else {
                            // ignore: use_build_context_synchronously
                            InfoCard(InfoType.error).show(context);
                          }
                        },
                        child: cubit.state is BaseLogicLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Icon(
                                Icons.delete_forever,
                                color: Colors.red[400],
                              )),
                  ),
          ),
          16.v,
          BaseBlocBuilder(
            cubit: uploadCubit,
            defaultChild: (cubit) => FloatingActionButton(
                onPressed: () => uploadFile(),
                child: cubit.state is BaseLogicLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(Icons.upload_file_outlined)),
          ),
        ],
      ),
      body: BaseBlocBuilder(
        cubit: userCubit,
        onLoading: (cubit) => const Center(
          child: CircularProgressIndicator(),
        ),
        onSuccess: (cubit, data) => GridView.builder(
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          itemCount: data.data?.length ?? 0,
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.width(1) < 600 ? 4 : 10),
          itemBuilder: (context, index) {
            return StatefulBuilder(
              builder: (context, state) => Tooltip(
                message: data.data?[index].nama,
                waitDuration: const Duration(seconds: 1),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        if (widget.isPicking == true) {
                          context.pop(data.data![index].path);
                          return;
                        }
                        state.call(() {
                          if (selectedFile.contains(data.data![index].kode!)) {
                            selectedFile.remove(data.data![index].kode!);
                          } else {
                            selectedFile.add(data.data![index].kode!);
                          }
                        });
                        deleteNotifierCubit.notify();
                      },
                      onDoubleTap: () {
                        try {
                          launchUrl(Uri.parse(locator<Htreq>().base.baseUrl +
                              (data.data?[index].path ?? "")));
                        } catch (e) {
                          log(e.toString());
                        }
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                            color:
                                selectedFile.contains(data.data![index].kode!)
                                    ? Colors.green[400]
                                    : null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                locator<Htreq>().base.baseUrl +
                                    (data.data?[index].path ?? ""),
                                // loadingBuilder: (context, child, loadingProgress) =>
                                //     const Center(
                                //   child: CircularProgressIndicator(),
                                // ),
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.description),
                              ),
                            )),
                      ),
                    )),
                    MainText(
                      data.data?[index].nama,
                      maxLines: 1,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
