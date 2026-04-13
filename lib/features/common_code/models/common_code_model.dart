class CommonCode {
  final String groupCode;
  final String code;
  final String codeName;
  final int sortOrder;

  CommonCode({
    required this.groupCode,
    required this.code,
    required this.codeName,
    required this.sortOrder,
  });

  factory CommonCode.fromJson(Map<String, dynamic> json) {
    return CommonCode(
      groupCode: json['group_code'] as String,
      code: json['code'] as String,
      codeName: json['code_name'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
