import 'package:equatable/equatable.dart';

/// A "Did You Know" road-safety tip shown on the dashboard.
class DashboardTip extends Equatable {
  final int id;
  final String text;
  final String? imageUrl;

  const DashboardTip({
    required this.id,
    required this.text,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, text, imageUrl];
}
