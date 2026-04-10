import 'package:flutter/foundation.dart';

import '../models/walk_model.dart';

class WalkProvider extends ChangeNotifier {
  final List<WalkModel> _walks = [];

  List<WalkModel> get walks => List.unmodifiable(_walks);

  void addWalk(WalkModel walk) {
    _walks.add(walk);
    notifyListeners();
  }
}
