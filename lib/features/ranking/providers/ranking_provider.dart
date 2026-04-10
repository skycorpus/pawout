import 'package:flutter/foundation.dart';

import '../models/ranking_model.dart';

class RankingProvider extends ChangeNotifier {
  final List<RankingModel> _rankings = const [];

  List<RankingModel> get rankings => List.unmodifiable(_rankings);
}
