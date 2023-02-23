class TTRStatus {
  bool open;
  String? banner;

  TTRStatus({required this.open, this.banner});


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TTRStatus &&
          runtimeType == other.runtimeType &&
          open == other.open &&
          banner == other.banner;

  @override
  int get hashCode => open.hashCode ^ banner.hashCode;


  @override
  String toString() {
    return 'TTRStatus{open: $open, banner: $banner}';
  }

  TTRStatus.fromJson(Map<String, dynamic> json)
      : open = json['open'] as bool,
        banner = json['banner'] as String?;

  Map<String, dynamic> toBson() {
    final Map<String, dynamic> data = {};
    data['open'] = open;
    data['banner'] = banner;
    return data;
  }
}
