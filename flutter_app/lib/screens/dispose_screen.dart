import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/theme.dart';
import '../models/disposal.dart';
import '../providers/citizen_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DisposeScreen extends StatefulWidget {
  const DisposeScreen({super.key});

  @override
  State<DisposeScreen> createState() => _DisposeScreenState();
}

class _DisposeScreenState extends State<DisposeScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final _medicineNameController = TextEditingController();
  final _quantityController = TextEditingController();

  String _selectedAntibioticClass = 'penicillin';
  String _selectedAmrRisk = 'medium';
  DateTime? _expiryDate;
  Disposal? _disposal;
  bool _isSubmitting = false;

  final List<String> _antibioticClasses = [
    'penicillin',
    'cephalosporin',
    'macrolide',
    'fluoroquinolone',
    'tetracycline',
    'aminoglycoside',
    'sulfonamide',
    'carbapenem',
    'other',
  ];

  final Map<String, Map<String, dynamic>> _amrRiskConfig = {
    'critical': {'label': 'Critical', 'color': AppTheme.danger, 'icon': Icons.dangerous},
    'high': {'label': 'High', 'color': Color(0xFFEA580C), 'icon': Icons.warning},
    'medium': {'label': 'Medium', 'color': AppTheme.warning, 'icon': Icons.warning_amber},
    'low': {'label': 'Low', 'color': AppTheme.success, 'icon': Icons.check_circle_outline},
  };

  @override
  void dispose() {
    _medicineNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.meshBackground),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 24),
            if (_currentStep == 0) _buildFormStep(l10n),
            if (_currentStep == 1) _buildQrStep(l10n),
            if (_currentStep == 2) _buildSuccessStep(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          _stepCircle(0, 'Details'),
          _stepLine(0),
          _stepCircle(1, 'QR Code'),
          _stepLine(1),
          _stepCircle(2, 'Done'),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String label) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: (isActive || isDone) ? AppTheme.gradientMain : null,
              color: (isActive || isDone) ? null : AppTheme.borderLight,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: (isActive || isDone) ? Colors.white : AppTheme.textMuted,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? AppTheme.primary : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLine(int afterStep) {
    final isDone = _currentStep > afterStep;
    return Expanded(
      flex: 0,
      child: Container(
        width: 40,
        height: 2,
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          gradient: isDone ? AppTheme.gradientMain : null,
          color: isDone ? null : AppTheme.borderLight,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildFormStep(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientMain,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medication, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.disposeTitle, style: AppTheme.headingMD),
                  ],
                ),
                const SizedBox(height: 20),
                // Medicine name
                _buildLabel(l10n.medicineName),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _medicineNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Amoxicillin 500mg',
                    prefixIcon: const Icon(Icons.medical_services_outlined, color: AppTheme.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter medicine name' : null,
                ),
                const SizedBox(height: 16),

                // Antibiotic class
                _buildLabel('Antibiotic Class'),
                const SizedBox(height: 6),
                _buildDropdown(
                  value: _selectedAntibioticClass,
                  items: _antibioticClasses,
                  onChanged: (v) => setState(() => _selectedAntibioticClass = v!),
                  displayText: (v) => v.substring(0, 1).toUpperCase() + v.substring(1),
                ),
                const SizedBox(height: 16),

                // Quantity
                _buildLabel(l10n.quantity),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 10 tablets / 100ml',
                    prefixIcon: const Icon(Icons.numbers, color: AppTheme.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter quantity' : null,
                ),
                const SizedBox(height: 16),

                // Expiry date
                _buildLabel(l10n.expiryDate),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickExpiryDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppTheme.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _expiryDate != null
                              ? '${_expiryDate!.day.toString().padLeft(2, '0')}/${_expiryDate!.month.toString().padLeft(2, '0')}/${_expiryDate!.year}'
                              : 'Select expiry date',
                          style: _expiryDate != null
                              ? AppTheme.bodyLG.copyWith(color: AppTheme.textPrimary)
                              : AppTheme.bodySM,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // AMR Risk level
                _buildLabel(l10n.amrRiskLevel),
                const SizedBox(height: 8),
                _buildRiskSelector(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: l10n.generateQr,
            isLoading: _isSubmitting,
            leading: const Icon(Icons.qr_code, color: Colors.white, size: 20),
            onPressed: _submitForm,
            shimmerEffect: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTheme.labelMD.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) displayText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
          style: AppTheme.bodyLG.copyWith(color: AppTheme.textPrimary),
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(displayText(item)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRiskSelector() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: _amrRiskConfig.entries.map((entry) {
        final isSelected = _selectedAmrRisk == entry.key;
        final config = entry.value;
        final color = config['color'] as Color;
        final icon = config['icon'] as IconData;
        final label = config['label'] as String;

        return GestureDetector(
          onTap: () => setState(() => _selectedAmrRisk = entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? color : AppTheme.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? color : AppTheme.textMuted, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? color : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expiry date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<CitizenProvider>();
    final expiryStr =
        '${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}';

    final disposal = await provider.initiateDisposal(
      medicineName: _medicineNameController.text.trim(),
      antibioticClass: _selectedAntibioticClass,
      quantity: _quantityController.text.trim(),
      expiryDate: expiryStr,
      amrRiskLevel: _selectedAmrRisk,
    );

    setState(() {
      _isSubmitting = false;
      if (disposal != null) {
        _disposal = disposal;
        _currentStep = 1;
      }
    });
  }

  Widget _buildQrStep(AppLocalizations l10n) {
    if (_disposal == null) return const SizedBox.shrink();
    return Column(
      children: [
        GlassCard(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientMain,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.qr_code_2, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(l10n.qrReady, style: AppTheme.headingMD),
              const SizedBox(height: 6),
              Text(l10n.qrInstruction, style: AppTheme.bodyMD, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _disposal!.disposalId,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  errorStateBuilder: (ctx, err) => const Center(
                    child: Text('QR Error', style: TextStyle(color: AppTheme.danger)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Disposal details
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    _disposalDetail('Medicine', _disposal!.medicineName),
                    _disposalDetail('Disposal ID', _disposal!.disposalId.substring(0, 8) + '...'),
                    _disposalDetail('Status', _disposal!.status.toUpperCase()),
                    if (_disposal!.pointsAwarded > 0)
                      _disposalDetail('Points to earn', '+${_disposal!.pointsAwarded} pts'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GradientButton(
          label: 'Confirm Drop-off',
          gradient: AppTheme.gradientGreen,
          leading: const Icon(Icons.check_circle_outline, color: Colors.white),
          onPressed: () => setState(() => _currentStep = 2),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _currentStep = 0),
          child: const Text(
            'Back to Form',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _disposalDetail(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$key: ',
            style: AppTheme.labelMD.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          Expanded(
            child: Text(value, style: AppTheme.bodyMD.copyWith(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(AppLocalizations l10n) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Success animation
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                'Disposal Complete!',
                style: AppTheme.headingLG.copyWith(color: AppTheme.success),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for helping fight antimicrobial resistance. Your contribution matters!',
                style: AppTheme.bodyMD,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_disposal != null && _disposal!.pointsAwarded > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientGreen,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.success.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        '+${_disposal!.pointsAwarded} Points Earned!',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Impact stats
              Row(
                children: [
                  Expanded(
                    child: _impactStat(
                      icon: Icons.eco_outlined,
                      value: '100g',
                      label: 'Prevented from landfill',
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _impactStat(
                      icon: Icons.people_outline,
                      value: '5',
                      label: 'People protected',
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GradientButton(
          label: 'Dispose Another Medicine',
          leading: const Icon(Icons.add_circle_outline, color: Colors.white),
          onPressed: () {
            setState(() {
              _currentStep = 0;
              _disposal = null;
              _medicineNameController.clear();
              _quantityController.clear();
              _expiryDate = null;
              _selectedAntibioticClass = 'penicillin';
              _selectedAmrRisk = 'medium';
            });
          },
        ),
      ],
    );
  }

  Widget _impactStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(label, style: AppTheme.bodySM, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
