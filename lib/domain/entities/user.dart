import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int participantId;
  final String enrollmentNo;
  final String username;
  final String fullName;
  final String email;
  final String mobileNo;
  final String? image;

  const User({
    required this.participantId,
    required this.enrollmentNo,
    required this.username,
    required this.fullName,
    required this.email,
    required this.mobileNo,
    this.image,
  });

  @override
  List<Object?> get props => [
    participantId,
    enrollmentNo,
    username,
    fullName,
    email,
    mobileNo,
    image,
  ];

  User copyWith({
    int? participantId,
    String? enrollmentNo,
    String? username,
    String? fullName,
    String? email,
    String? mobileNo,
    String? image,
  }) {
    return User(
      participantId: participantId ?? this.participantId,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNo: mobileNo ?? this.mobileNo,
      image: image ?? this.image,
    );
  }
}