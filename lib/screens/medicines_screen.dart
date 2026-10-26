import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_blobs.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_card.dart';

class MedicinesScreen extends StatefulWidget {
  final StorageService storage;
  const MedicinesScreen({super.key, required this.storage});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  List<Medicine> _medicines = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _load();
  }

  Future<void> _load() async {
    final m = await widget.storage.getMedicines();
    if (mounted) setState(() => _medicines = m);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showAddMedicineSheet() {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF141A33),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textDim,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Add Medicine', style: AppText.h2),
                const SizedBox(height: 6),
                Text('Keep track of your daily routine',
                    style: AppText.small),
                const SizedBox(height: 20),
                _field('Medicine Name', nameCtrl,
                    icon: Icons.medication_outlined),
                const SizedBox(height: 12),
                _field('Dosage (e.g. 50mg)', dosageCtrl,
                    icon: Icons.straighten_rounded),
                const SizedBox(height: 12),
                _field('Frequency (e.g. twice daily)', freqCtrl,
                    icon: Icons.schedule_rounded),
                const SizedBox(height: 12),
                _field('Notes (optional)', notesCtrl,
                    icon: Icons.edit_note_rounded, maxLines: 2),
                const SizedBox(height: 22),
                GradientButton(
                  text: 'Save Medicine',
                  icon: Icons.check_rounded,
                  gradient: AppGradients.calm,
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    await widget.storage.saveMedicine(Medicine(
                      id: const Uuid().v4(),
                      name: nameCtrl.text.trim(),
                      dosage: dosageCtrl.text.trim(),
                      frequency: freqCtrl.text.trim(),
                      notes: notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                    ));
                    if (mounted) Navigator.pop(ctx);
                    await _load();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Medicine added ✓'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String hint, TextEditingController ctrl,
      {IconData? icon, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: AppText.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.small,
        prefixIcon:
        icon != null ? Icon(icon, color: AppColors.textDim, size: 20) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: AppColors.g3, width: 1.5),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Medicine m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141A33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Delete?', style: AppText.h3),
        content: Text(
          'Remove ${m.name} from your list?',
          style: AppText.small,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppText.body.copyWith(
                    color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: AppText.body.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.storage.deleteMedicine(m.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingBlobs(
      child: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    colors: [
                      AppColors.g5,
                      AppColors.g2,
                      AppColors.g3,
                    ],
                  ).createShader(rect),
                  child: Text(
                    'Medicines',
                    textAlign: TextAlign.center,
                    style: AppText.h1.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'your daily routine',
                  textAlign: TextAlign.center,
                  style: AppText.small,
                ),
                const SizedBox(height: 20),

                GradientButton(
                  text: 'Add Medicine',
                  icon: Icons.add_rounded,
                  gradient: AppGradients.primary,
                  onPressed: _showAddMedicineSheet,
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: _medicines.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.calm,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.g5
                                    .withOpacity(0.4),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.medication_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('No medicines yet',
                            style: AppText.h3),
                        const SizedBox(height: 6),
                        Text(
                          'Tap "Add Medicine" to begin',
                          style: AppText.small,
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    padding:
                    const EdgeInsets.only(bottom: 120),
                    itemCount: _medicines.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _MedicineCard(
                      medicine: _medicines[i],
                      index: i,
                      onDelete: () =>
                          _confirmDelete(_medicines[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatefulWidget {
  final Medicine medicine;
  final int index;
  final VoidCallback onDelete;

  const _MedicineCard({
    required this.medicine,
    required this.index,
    required this.onDelete,
  });

  @override
  State<_MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<_MedicineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450 + (widget.index * 80)),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.25, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppGradients.calm,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color:
                          AppColors.g5.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.medication_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.medicine.name,
                      style: AppText.h3,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                          AppColors.danger.withOpacity(0.4),
                        ),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.danger, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _row('Dosage', widget.medicine.dosage),
              const SizedBox(height: 8),
              _row('Frequency', widget.medicine.frequency),
              if (widget.medicine.notes != null &&
                  widget.medicine.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _row('Notes', widget.medicine.notes!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: AppText.small.copyWith(
                color: AppColors.g5,
                fontWeight: FontWeight.w600,
              )),
        ),
        Expanded(
          child: Text(value, style: AppText.body),
        ),
      ],
    );
  }
}