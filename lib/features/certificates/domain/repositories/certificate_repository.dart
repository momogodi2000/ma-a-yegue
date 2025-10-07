import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/certificate_entity.dart';

/// Certificate repository interface
abstract class CertificateRepository {
  /// Get certificates for a user
  Future<Either<Failure, List<CertificateEntity>>> getUserCertificates(
    String userId,
  );

  /// Get certificate by ID
  Future<Either<Failure, CertificateEntity>> getCertificateById(
    String certificateId,
  );

  /// Request a certificate
  Future<Either<Failure, CertificateEntity>> requestCertificate(
    String userId,
    String courseId,
    int score,
    String level,
  );

  /// Generate certificate PDF
  Future<Either<Failure, String>> generateCertificatePDF(String certificateId);

  /// Approve certificate (Admin/Teacher)
  Future<Either<Failure, CertificateEntity>> approveCertificate(
    String certificateId,
    String approvedBy,
  );

  /// Reject certificate (Admin/Teacher)
  Future<Either<Failure, CertificateEntity>> rejectCertificate(
    String certificateId,
    String rejectedBy,
    String reason,
  );

  /// Revoke certificate (Admin)
  Future<Either<Failure, bool>> revokeCertificate(
    String certificateId,
    String revokedBy,
    String reason,
  );

  /// Verify certificate
  Future<Either<Failure, CertificateEntity>> verifyCertificate(
    String verificationCode,
  );

  /// Get pending certificates (Admin/Teacher)
  Future<Either<Failure, List<CertificateEntity>>> getPendingCertificates();

  /// Get all certificates (Admin)
  Future<Either<Failure, List<CertificateEntity>>> getAllCertificates();

  /// Get certificate templates
  Future<Either<Failure, List<CertificateTemplateEntity>>> getTemplates();

  /// Share certificate
  Future<Either<Failure, String>> shareCertificate(
    String certificateId,
    String platform,
  );

  /// Download certificate
  Future<Either<Failure, String>> downloadCertificate(String certificateId);

  /// Get certificate statistics
  Future<Either<Failure, Map<String, dynamic>>> getCertificateStatistics(
    String? userId,
  );
}
