import 'package:catering_core/core.dart';

class DeleteButtonNotifier extends Cubit<int> {
  DeleteButtonNotifier() : super(0);
  void notify() => emit(state + 1);
}
