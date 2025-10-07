import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/certificate_entity.dart';
import '../repositories/certificate_repository.dart';

// Get User Certificates
class GetUserCertificates implements UseCase<List<CertificateEntity>, String> {
  final CertificateRepository repository;
  const GetUserCertificates(this.repository);

  @override
  Future<Either<Failure, List<CertificateEntity>>> call(String userId) async {
    return await repository.getUserCertificates(userId);
  }
}

// Get Certificate By ID
class GetCertificateById implements UseCase<CertificateEntity, String> {
  final CertificateRepository repository;
  const GetCertificateById(this.repository);

  @override
  Future<Either<Failure, CertificateEntity>> call(String certificateId) async {
    return await repository.getCertificateById(certificateId);
  }
}

// Request Certificate
class RequestCertificate
    implements UseCase<CertificateEntity, RequestCertificateParams> {
  final CertificateRepository repository;
  const RequestCertificate(this.repository);

  @override
  Future<Either<Failure, CertificateEntity>> call(
    RequestCertificateParams params,
  ) async {
    return await repository.requestCertificate(
      params.userId,
      params.courseId,
      params.score,
      params.level,
    );
  }
}

class RequestCertificateParams extends Equatable {
  final String userId;
  final String courseId;
  final int score;
  final String level;

  const RequestCertificateParams({
    required this.userId,
    required this.courseId,
    required this.score,
    required this.level,
  });

  @override
  List<Object?> get props => [userId, courseId, score, level];
}

// Generate Certificate PDF
class GenerateCertificatePDF implements UseCase<String, String> {
  final CertificateRepository repository;
  const GenerateCertificatePDF(this.repository);

  @override
  Future<Either<Failure, String>> call(String certificateId) async {
    return await repository.generateCertificatePDF(certificateId);
  }
}

// Approve Certificate
class ApproveCertificate
    implements UseCase<CertificateEntity, ApproveCertificateParams> {
  final CertificateRepository repository;
  const ApproveCertificate(this.repository);

  @override
  Future<Either<Failure, CertificateEntity>> call(
    ApproveCertificateParams params,
  ) async {
    return await repository.approveCertificate(
      params.certificateId,
      params.approvedBy,
    );
  }
}

class ApproveCertificateParams extends Equatable {
  final String certificateId;
  final String approvedBy;

  const ApproveCertificateParams({
    required this.certificateId,
    required this.approvedBy,
  });

  @override
  List<Object?> get props => [certificateId, approvedBy];
}

// Reject Certificate
class RejectCertificate
    implements UseCase<CertificateEntity, RejectCertificateParams> {
  final CertificateRepository repository;
  const RejectCertificate(this.repository);

  @override
  Future<Either<Failure, CertificateEntity>> call(
    RejectCertificateParams params,
  ) async {
    return await repository.rejectCertificate(
      params.certificateId,
      params.rejectedBy,
      params.reason,
    );
  }
}

class RejectCertificateParams extends Equatable {
  final String certificateId;
  final String rejectedBy;
  final String reason;

  const RejectCertificateParams({
    required this.certificateId,
    required this.rejectedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [certificateId, rejectedBy, reason];
}

// Verify Certificate
class VerifyCertificate implements UseCase<CertificateEntity, String> {
  final CertificateRepository repository;
  const VerifyCertificate(this.repository);

  @override
  Future<Either<Failure, CertificateEntity>> call(
    String verificationCode,
  ) async {
    return await repository.verifyCertificate(verificationCode);
  }
}

// Get Pending Certificates
class GetPendingCertificates
    implements UseCase<List<CertificateEntity>, NoParams> {
  final CertificateRepository repository;
  const GetPendingCertificates(this.repository);

  @override
  Future<Either<Failure, List<CertificateEntity>>> call(NoParams params) async {
    return await repository.getPendingCertificates();
  }
}

// Download Certificate
class DownloadCertificate implements UseCase<String, String> {
  final CertificateRepository repository;
  const DownloadCertificate(this.repository);

  @override
  Future<Either<Failure, String>> call(String certificateId) async {
    return await repository.downloadCertificate(certificateId);
  }
}
