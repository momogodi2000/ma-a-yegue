import 'package:flutter/material.dart';
import '../../../../core/config/environment_config.dart';

/// Stripe Payment Widget for credit card payments
class StripePaymentWidget extends StatefulWidget {
  final double amount;
  final String currency;
  final String description;
  final Function(Map<String, dynamic>) onPaymentSuccess;
  final Function(String) onPaymentError;

  const StripePaymentWidget({
    super.key,
    required this.amount,
    required this.currency,
    required this.description,
    required this.onPaymentSuccess,
    required this.onPaymentError,
  });

  @override
  State<StripePaymentWidget> createState() => _StripePaymentWidgetState();
}

class _StripePaymentWidgetState extends State<StripePaymentWidget> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeStripe();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  Future<void> _initializeStripe() async {
    try {
      // Initialize Stripe with publishable key
      // Note: This is a placeholder implementation
      // In a real app, you would initialize Stripe here
      if (EnvironmentConfig.stripePublishableKey.isEmpty) {
        setState(() {
          _errorMessage = 'Stripe publishable key not configured';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize Stripe: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Carte Bancaire',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de carte',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validateCardNumber,
                onChanged: _formatCardNumber,
              ),
              const SizedBox(height: 16),

              // Expiry Date and CVV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: 'Date d\'expiration',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateExpiryDate,
                      onChanged: _formatExpiryDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: _validateCVV,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cardholder Name
              TextFormField(
                controller: _cardholderNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du titulaire',
                  hintText: 'John Doe',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: _validateCardholderName,
              ),
              const SizedBox(height: 16),

              // Amount Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Montant à payer:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${widget.amount.toStringAsFixed(0)} ${widget.currency}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _processPayment,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payment),
                  label: Text(
                    _isLoading ? 'Traitement...' : 'Payer avec Stripe',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Vos informations de paiement sont sécurisées et cryptées par Stripe.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de carte est requis';
    }
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Numéro de carte invalide';
    }
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La date d\'expiration est requise';
    }
    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Format invalide (MM/YY)';
    }
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null || month < 1 || month > 12) {
      return 'Date invalide';
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le CVV est requis';
    }
    if (value.length < 3 || value.length > 4) {
      return 'CVV invalide';
    }
    return null;
  }

  String? _validateCardholderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom du titulaire est requis';
    }
    if (value.length < 2) {
      return 'Nom trop court';
    }
    return null;
  }

  void _formatCardNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    final formatted = cleaned
        .replaceAllMapped(RegExp(r'.{1,4}'), (match) => '${match.group(0)} ')
        .trim();
    if (formatted != value) {
      _cardNumberController.value = _cardNumberController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _formatExpiryDate(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    String formatted = cleaned;
    if (cleaned.length >= 2) {
      formatted = '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    if (formatted != value) {
      _expiryDateController.value = _expiryDateController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate payment processing
      // In a real app, this would integrate with Stripe SDK
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, simulate a successful payment
      widget.onPaymentSuccess({
        'transaction_id': 'stripe_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'completed',
        'amount': widget.amount,
        'currency': widget.currency,
        'provider': 'stripe',
      });
    } catch (e) {
      widget.onPaymentError('Payment error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
