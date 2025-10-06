import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:mayegue/core/errors/failures.dart';
import 'package:mayegue/features/payment/domain/entities/payment_entity.dart';
import 'package:mayegue/features/payment/domain/repositories/payment_repository.dart';
import 'package:mayegue/features/payment/domain/usecases/process_payment_usecase.dart';

// Mock class
class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late ProcessPaymentUseCase usecase;
  late MockPaymentRepository mockPaymentRepository;

  setUp(() {
    mockPaymentRepository = MockPaymentRepository();
    usecase = ProcessPaymentUseCase(mockPaymentRepository);
  });

  const tUserId = 'test-user-id';
  const tAmount = 100.0;
  const tMethod = 'campay';
  const tPhoneNumber = '+237612345678';

  const tParams = ProcessPaymentParams(
    userId: tUserId,
    amount: tAmount,
    method: tMethod,
    phoneNumber: tPhoneNumber,
  );

  final tPaymentEntity = PaymentEntity(
    id: 'payment-id',
    userId: tUserId,
    amount: tAmount,
    currency: 'XAF',
    method: tMethod,
    status: 'completed',
    transactionId: 'txn-123',
    createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
  );

  group('ProcessPaymentUseCase', () {
    test(
      'should return PaymentEntity when payment processing is successful',
      () async {
        // arrange
        when(mockPaymentRepository.processPayment(
          userId: tUserId,
          amount: tAmount,
          method: tMethod,
          phoneNumber: tPhoneNumber,
        )).thenAnswer((_) async => Right(tPaymentEntity));

        // act
        final result = await usecase.call(tParams);

        // assert
        expect(result, Right(tPaymentEntity));
        verify(mockPaymentRepository.processPayment(
          userId: tUserId,
          amount: tAmount,
          method: tMethod,
          phoneNumber: tPhoneNumber,
        )).called(1);
        verifyNoMoreInteractions(mockPaymentRepository);
      },
    );

    test(
      'should return Failure when payment processing fails',
      () async {
        // arrange
        const tFailure = ServerFailure('Payment processing failed');
        when(mockPaymentRepository.processPayment(
          userId: tUserId,
          amount: tAmount,
          method: tMethod,
          phoneNumber: tPhoneNumber,
        )).thenAnswer((_) async => const Left(tFailure));

        // act
        final result = await usecase.call(tParams);

        // assert
        expect(result, const Left(tFailure));
        verify(mockPaymentRepository.processPayment(
          userId: tUserId,
          amount: tAmount,
          method: tMethod,
          phoneNumber: tPhoneNumber,
        )).called(1);
        verifyNoMoreInteractions(mockPaymentRepository);
      },
    );
  });
}