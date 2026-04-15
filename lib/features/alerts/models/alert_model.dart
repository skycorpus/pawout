enum AlertType { like, follow }

class AlertModel {
  const AlertModel({
    required this.type,
    required this.actorName,
    required this.createdAt,
    this.dogName,
  });

  final AlertType type;
  final String actorName;   // 좋아요/팔로우 한 사람
  final DateTime createdAt;
  final String? dogName;    // 좋아요인 경우 강아지 이름

  String get message {
    switch (type) {
      case AlertType.like:
        return dogName != null
            ? '$actorName님이 $dogName를 좋아합니다'
            : '$actorName님이 좋아요를 눌렀습니다';
      case AlertType.follow:
        return '$actorName님이 팔로우하기 시작했습니다';
    }
  }
}
