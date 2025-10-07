import 'package:equatable/equatable.dart';

/// Certificate types
enum CertificateType {
  completion, // Course completion
  proficiency, // Language proficiency level
  achievement, // Special achievement
  participation, // Participation certificate
}

/// Certificate status
enum CertificateStatus {
  pending, // Waiting for approval
  approved, // Approved and issued
  rejected, // Rejected
  revoked, // Revoked after issuance
}

/// Certificate entity
class CertificateEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String courseId;
  final String courseName;
  final String languageName;
  final CertificateType type;
  final CertificateStatus status;
  final DateTime issuedDate;
  final DateTime? approvedDate;
  final String? approvedBy;
  final String? rejectionReason;
  final int score;
  final String level; // A1, A2, B1, B2, C1, C2
  final String certificateNumber;
  final String? verificationCode;
  final String? pdfUrl;
  final Map<String, dynamic> metadata;

  const CertificateEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.courseId,
    required this.courseName,
    required this.languageName,
    required this.type,
    required this.status,
    required this.issuedDate,
    this.approvedDate,
    this.approvedBy,
    this.rejectionReason,
    required this.score,
    required this.level,
    required this.certificateNumber,
    this.verificationCode,
    this.pdfUrl,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    courseId,
    courseName,
    languageName,
    type,
    status,
    issuedDate,
    approvedDate,
    approvedBy,
    rejectionReason,
    score,
    level,
    certificateNumber,
    verificationCode,
    pdfUrl,
    metadata,
  ];

  CertificateEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? courseId,
    String? courseName,
    String? languageName,
    CertificateType? type,
    CertificateStatus? status,
    DateTime? issuedDate,
    DateTime? approvedDate,
    String? approvedBy,
    String? rejectionReason,
    int? score,
    String? level,
    String? certificateNumber,
    String? verificationCode,
    String? pdfUrl,
    Map<String, dynamic>? metadata,
  }) {
    return CertificateEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      languageName: languageName ?? this.languageName,
      type: type ?? this.type,
      status: status ?? this.status,
      issuedDate: issuedDate ?? this.issuedDate,
      approvedDate: approvedDate ?? this.approvedDate,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      score: score ?? this.score,
      level: level ?? this.level,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      verificationCode: verificationCode ?? this.verificationCode,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isPending => status == CertificateStatus.pending;
  bool get isApproved => status == CertificateStatus.approved;
  bool get isRejected => status == CertificateStatus.rejected;
  bool get isRevoked => status == CertificateStatus.revoked;
}

/// Certificate template entity
class CertificateTemplateEntity extends Equatable {
  final String id;
  final String name;
  final CertificateType type;
  final String designUrl;
  final String htmlTemplate;
  final Map<String, dynamic> variables;
  final bool isActive;

  const CertificateTemplateEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.designUrl,
    required this.htmlTemplate,
    required this.variables,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    designUrl,
    htmlTemplate,
    variables,
    isActive,
  ];
}
