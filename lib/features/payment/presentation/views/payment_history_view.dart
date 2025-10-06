import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/payment_viewmodel.dart';
import '../widgets/transaction_item.dart';

/// Payment History View
class PaymentHistoryView extends StatefulWidget {
  const PaymentHistoryView({super.key});

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> {
  @override
  void initState() {
    super.initState();
    // Load payment history when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final userId = authViewModel.currentUser?.id ?? 'guest_user';

      final viewModel = context.read<PaymentViewModel>();
      viewModel.loadPaymentHistory(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des paiements'),
      ),
      body: Consumer<PaymentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur: ${viewModel.error}'),
                  ElevatedButton(
                    onPressed: () {
                      final authViewModel = context.read<AuthViewModel>();
                      final userId = authViewModel.currentUser?.id ?? 'guest_user';
                      viewModel.loadPaymentHistory(userId);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final payments = viewModel.paymentHistory;
          if (payments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun paiement trouvé',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authViewModel = context.read<AuthViewModel>();
              final userId = authViewModel.currentUser?.id ?? 'guest_user';
              await viewModel.loadPaymentHistory(userId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TransactionItem(payment: payment),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
