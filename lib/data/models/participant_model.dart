// class ParticipantModel {
//   final int participantId;
//   final String enrollmentNo;
//   final String participantName;
//   final String username;
//   final String? email;
//   final String? mobileNo;
//   final String? images;
//   final int progressStatus;
//   final int courseProgress;
//
//   const ParticipantModel({
//     required this.participantId,
//     required this.enrollmentNo,
//     required this.participantName,
//     required this.username,
//     this.email,
//     this.mobileNo,
//     this.images,
//     required this.progressStatus,
//     required this.courseProgress,
//   });
//
//   factory ParticipantModel.fromJson(Map<String, dynamic> json) {
//     return ParticipantModel(
//       participantId: json["participant_id"],
//       enrollmentNo: json["enrollment_no"],
//       participantName: json["participant_name"],
//       username: json["username"],
//       email: json["email"],
//       mobileNo: json["mobile_no"],
//       images: json["images"],
//       progressStatus: json["progress_status"] ?? 0,
//       courseProgress: json["course_progress"] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "participant_id": participantId,
//       "enrollment_no": enrollmentNo,
//       "participant_name": participantName,
//       "username": username,
//       "email": email,
//       "mobile_no": mobileNo,
//       "images": images,
//       "progress_status": progressStatus,
//       "course_progress": courseProgress,
//     };
//   }
// }

class ParticipantModel {
  final int participantId;
  final String enrollmentNo;
  final String participantName;
  final String username;
  final String? email;
  final String? mobileNo;
  final String? images;
  final int progressStatus;
  final int courseProgress;

  const ParticipantModel({
    required this.participantId,
    required this.enrollmentNo,
    required this.participantName,
    required this.username,
    this.email,
    this.mobileNo,
    this.images,
    required this.progressStatus,
    required this.courseProgress,
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      participantId: _toInt(json["participant_id"]),
      enrollmentNo: json["enrollment_no"]?.toString() ?? '',
      participantName: json["participant_name"]?.toString() ??
          json["username"]?.toString() ??
          'User',
      username: json["username"]?.toString() ?? '',
      email: json["email"]?.toString(),
      mobileNo: json["mobile_no"]?.toString(),
      images: json["images"]?.toString(),
      progressStatus: _toInt(json["progress_status"]),
      courseProgress: _toInt(json["course_progress"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "participant_id": participantId,
      "enrollment_no": enrollmentNo,
      "participant_name": participantName,
      "username": username,
      "email": email,
      "mobile_no": mobileNo,
      "images": images,
      "progress_status": progressStatus,
      "course_progress": courseProgress,
    };
  }
}
