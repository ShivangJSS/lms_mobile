import '../../domain/entities/dashboard_tip.dart';

class DashboardTipModel extends DashboardTip {
  const DashboardTipModel({
    required super.id,
    required super.text,
    super.imageUrl,
  });

  factory DashboardTipModel.fromJson(Map<String, dynamic> json) {
    final id = json['didyouknow_id'];

    return DashboardTipModel(
      id: id is int ? id : int.tryParse('$id') ?? 0,
      text: json['text'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
    );
  }
}
