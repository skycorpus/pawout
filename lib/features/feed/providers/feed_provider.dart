import 'package:flutter/foundation.dart';

import '../models/feed_item_model.dart';
import '../repositories/feed_repository.dart';

class FeedProvider extends ChangeNotifier {
  FeedProvider({FeedRepository? repository})
      : _repository = repository ?? FeedRepository();

  final FeedRepository _repository;
  List<FeedItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FeedItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFeed({required String myUserId}) async {
    if (myUserId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.fetchFeed(myUserId: myUserId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
