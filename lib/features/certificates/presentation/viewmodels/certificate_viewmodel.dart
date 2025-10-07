import 'package:flutter/foundation.dart';
import '../../domain/entities/certificate_entity.dart';
import '../../domain/usecases/certificate_usecases.dart';
import '../../../../core/usecases/usecase.dart';

/// Certificate ViewModel for state management
class CertificateViewModel extends ChangeNotifier {
  final GetUserCertificates _getUserCertificates;
  final GetCertificateById _getCertificateById;
  final RequestCertificate _requestCertificate;
  final GenerateCertificatePDF _generateCertificatePDF;
  final ApproveCertificate _approveCertificate;
  final RejectCertificate _rejectCertificate;
  final VerifyCertificate _verifyCertificate;
  final GetPendingCertificates _getPendingCertificates;
  final DownloadCertificate _downloadCertificate;

  CertificateViewModel({
    required GetUserCertificates getUserCertificates,
    required GetCertificateById getCertificateById,
    required RequestCertificate requestCertificate,
    required GenerateCertificatePDF generateCertificatePDF,
    required ApproveCertificate approveCertificate,
    required RejectCertificate rejectCertificate,
    required VerifyCertificate verifyCertificate,
    required GetPendingCertificates getPendingCertificates,
    required DownloadCertificate downloadCertificate,
  }) : _getUserCertificates = getUserCertificates,
       _getCertificateById = getCertificateById,
       _requestCertificate = requestCertificate,
       _generateCertificatePDF = generateCertificatePDF,
       _approveCertificate = approveCertificate,
       _rejectCertificate = rejectCertificate,
       _verifyCertificate = verifyCertificate,
       _getPendingCertificates = getPendingCertificates,
       _downloadCertificate = downloadCertificate;

  // State variables
  List<CertificateEntity> _certificates = [];
  CertificateEntity? _selectedCertificate;
  List<CertificateEntity> _pendingCertificates = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CertificateEntity> get certificates => _certificates;
  CertificateEntity? get selectedCertificate => _selectedCertificate;
  List<CertificateEntity> get pendingCertificates => _pendingCertificates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters
  List<CertificateEntity> get approvedCertificates =>
      _certificates.where((c) => c.isApproved).toList();
  List<CertificateEntity> get pendingApprovalCertificates =>
      _certificates.where((c) => c.isPending).toList();
  int get totalCertificates => _certificates.length;
  int get approvedCount => approvedCertificates.length;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Load user certificates
  Future<void> loadUserCertificates(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await _getUserCertificates(userId);
    result.fold((failure) => _setError(failure.message), (certificates) {
      _certificates = certificates;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load certificate by ID
  Future<void> loadCertificateById(String certificateId) async {
    _setLoading(true);
    _clearError();

    final result = await _getCertificateById(certificateId);
    result.fold((failure) => _setError(failure.message), (certificate) {
      _selectedCertificate = certificate;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Request a new certificate
  Future<bool> requestCertificate(
    String userId,
    String courseId,
    int score,
    String level,
  ) async {
    _setLoading(true);
    _clearError();

    final params = RequestCertificateParams(
      userId: userId,
      courseId: courseId,
      score: score,
      level: level,
    );

    final result = await _requestCertificate(params);
    final success = result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (certificate) {
        _certificates.add(certificate);
        _selectedCertificate = certificate;
        notifyListeners();
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Generate certificate PDF
  Future<String?> generatePDF(String certificateId) async {
    _setLoading(true);
    _clearError();

    final result = await _generateCertificatePDF(certificateId);
    final pdfUrl = result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (url) {
        // Update certificate with PDF URL
        final index = _certificates.indexWhere((c) => c.id == certificateId);
        if (index != -1) {
          _certificates[index] = _certificates[index].copyWith(pdfUrl: url);
        }
        if (_selectedCertificate?.id == certificateId) {
          _selectedCertificate = _selectedCertificate?.copyWith(pdfUrl: url);
        }
        notifyListeners();
        return url;
      },
    );

    _setLoading(false);
    return pdfUrl;
  }

  /// Approve certificate
  Future<bool> approveCertificate(
    String certificateId,
    String approvedBy,
  ) async {
    _setLoading(true);
    _clearError();

    final params = ApproveCertificateParams(
      certificateId: certificateId,
      approvedBy: approvedBy,
    );

    final result = await _approveCertificate(params);
    final success = result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (certificate) {
        final index = _certificates.indexWhere((c) => c.id == certificateId);
        if (index != -1) {
          _certificates[index] = certificate;
        }
        _pendingCertificates.removeWhere((c) => c.id == certificateId);
        if (_selectedCertificate?.id == certificateId) {
          _selectedCertificate = certificate;
        }
        notifyListeners();
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Reject certificate
  Future<bool> rejectCertificate(
    String certificateId,
    String rejectedBy,
    String reason,
  ) async {
    _setLoading(true);
    _clearError();

    final params = RejectCertificateParams(
      certificateId: certificateId,
      rejectedBy: rejectedBy,
      reason: reason,
    );

    final result = await _rejectCertificate(params);
    final success = result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (certificate) {
        final index = _certificates.indexWhere((c) => c.id == certificateId);
        if (index != -1) {
          _certificates[index] = certificate;
        }
        _pendingCertificates.removeWhere((c) => c.id == certificateId);
        if (_selectedCertificate?.id == certificateId) {
          _selectedCertificate = certificate;
        }
        notifyListeners();
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Verify certificate
  Future<CertificateEntity?> verifyCertificate(String verificationCode) async {
    _setLoading(true);
    _clearError();

    final result = await _verifyCertificate(verificationCode);
    final certificate = result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (cert) {
        _selectedCertificate = cert;
        notifyListeners();
        return cert;
      },
    );

    _setLoading(false);
    return certificate;
  }

  /// Load pending certificates
  Future<void> loadPendingCertificates() async {
    _setLoading(true);
    _clearError();

    final result = await _getPendingCertificates(NoParams());
    result.fold((failure) => _setError(failure.message), (certificates) {
      _pendingCertificates = certificates;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Download certificate
  Future<String?> downloadCertificate(String certificateId) async {
    _setLoading(true);
    _clearError();

    final result = await _downloadCertificate(certificateId);
    final filePath = result.fold((failure) {
      _setError(failure.message);
      return null;
    }, (path) => path);

    _setLoading(false);
    return filePath;
  }

  /// Clear selected certificate
  void clearSelectedCertificate() {
    _selectedCertificate = null;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _certificates.clear();
    _selectedCertificate = null;
    _pendingCertificates.clear();
    _error = null;
    notifyListeners();
  }
}
