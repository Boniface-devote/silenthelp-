import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../settings/settings_provider.dart';

class SafetyPlanScreen extends ConsumerStatefulWidget {
  const SafetyPlanScreen({super.key});

  @override
  ConsumerState<SafetyPlanScreen> createState() => _SafetyPlanScreenState();
}

class _SafetyPlanScreenState extends ConsumerState<SafetyPlanScreen> {
  static const _safePlaceKey = 'personal_safety_plan_safe_place';
  static const _codeWordKey = 'personal_safety_plan_code_word';
  static const _stepsKey = 'personal_safety_plan_steps';
  static const _contactKey = 'personal_safety_plan_contact';

  final _safePlaceController = TextEditingController();
  final _codeWordController = TextEditingController();
  final _stepsController = TextEditingController();
  String? _contactNumber;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _safePlaceController.dispose();
    _codeWordController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _safePlaceController.text = prefs.getString(_safePlaceKey) ?? '';
        _codeWordController.text = prefs.getString(_codeWordKey) ?? '';
        _stepsController.text = prefs.getString(_stepsKey) ?? '';
        _contactNumber = prefs.getString(_contactKey);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          context.tr('safety_plan_title'),
          style: AppTextStyles.heading2,
        ),
        actions: [
          IconButton(
            tooltip: context.tr('safety_plan_clear'),
            onPressed: _saving || _loading ? null : _confirmClear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  Center(child: Text(context.tr('safety_plan_load_error'))),
              data: (profile) => _buildPlanForm(context, profile),
            ),
    );
  }

  Widget _buildPlanForm(BuildContext context, UserProfile profile) {
    final contacts = _contactsFor(profile);
    final selectedContact =
        contacts.any((contact) => contact.number == _contactNumber)
        ? _contactNumber
        : null;

    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        _notice(context, context.tr('safety_plan_intro'), AppColors.teal),
        SizedBox(height: 10.h),
        _notice(
          context,
          context.tr('safety_plan_privacy_warning'),
          AppColors.yellow,
        ),
        SizedBox(height: 22.h),
        Text(
          context.tr('safety_plan_contact_label'),
          style: AppTextStyles.labelLarge,
        ),
        SizedBox(height: 8.h),
        if (contacts.isEmpty)
          Card(
            color: AppColors.card,
            child: ListTile(
              title: Text(context.tr('safety_plan_no_contacts')),
              trailing: TextButton(
                onPressed: () => context.go(AppConstants.routeProfile),
                child: Text(context.tr('report_open_profile')),
              ),
            ),
          )
        else
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: selectedContact,
            decoration: InputDecoration(
              filled: true,
              labelText: context.tr('safety_plan_contact_hint'),
            ),
            items: contacts
                .map(
                  (contact) => DropdownMenuItem(
                    value: contact.number,
                    child: Text('${contact.name} · ${contact.number}'),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _contactNumber = value),
          ),
        SizedBox(height: 18.h),
        TextField(
          controller: _safePlaceController,
          maxLength: 120,
          decoration: InputDecoration(
            filled: true,
            labelText: context.tr('safety_plan_safe_place_label'),
            hintText: context.tr('safety_plan_safe_place_hint'),
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: _codeWordController,
          maxLength: 40,
          decoration: InputDecoration(
            filled: true,
            labelText: context.tr('safety_plan_code_word_label'),
            hintText: context.tr('safety_plan_code_word_hint'),
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: _stepsController,
          minLines: 3,
          maxLines: 6,
          maxLength: 600,
          decoration: InputDecoration(
            filled: true,
            alignLabelWithHint: true,
            labelText: context.tr('safety_plan_steps_label'),
            hintText: context.tr('safety_plan_steps_hint'),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saving ? null : () => _savePlan(contacts),
            icon: _saving
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              context.tr(_saving ? 'safety_plan_saving' : 'safety_plan_save'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: AppColors.background,
              padding: EdgeInsets.symmetric(vertical: 15.h),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          context.tr('safety_plan_no_auto_send'),
          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _notice(BuildContext context, String message, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  List<_PlanContact> _contactsFor(UserProfile profile) {
    final candidates = <_PlanContact>[
      _PlanContact(profile.emContactName, profile.emContactNumber),
      _PlanContact(profile.secondContactName, profile.secondContactNumber),
      _PlanContact(profile.medicalContactName, profile.medicalContactNumber),
    ];
    final seen = <String>{};
    return candidates
        .where((contact) => contact.number.trim().isNotEmpty)
        .where((contact) => seen.add(contact.number.trim()))
        .toList();
  }

  Future<void> _savePlan(List<_PlanContact> contacts) async {
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_safePlaceKey, _safePlaceController.text.trim());
      await prefs.setString(_codeWordKey, _codeWordController.text.trim());
      await prefs.setString(_stepsKey, _stepsController.text.trim());
      if (_contactNumber == null ||
          !contacts.any((contact) => contact.number == _contactNumber)) {
        await prefs.remove(_contactKey);
      } else {
        await prefs.setString(_contactKey, _contactNumber!);
      }
      if (mounted) _showMessage(context.tr('safety_plan_saved'));
    } catch (_) {
      if (mounted) _showMessage(context.tr('safety_plan_save_error'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmClear() async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('safety_plan_clear_title')),
        content: Text(context.tr('safety_plan_clear_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('safety_plan_clear')),
          ),
        ],
      ),
    );
    if (clear != true || !mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_safePlaceKey);
      await prefs.remove(_codeWordKey);
      await prefs.remove(_stepsKey);
      await prefs.remove(_contactKey);
      if (!mounted) return;
      _safePlaceController.clear();
      _codeWordController.clear();
      _stepsController.clear();
      setState(() => _contactNumber = null);
      _showMessage(context.tr('safety_plan_cleared'));
    } catch (_) {
      if (mounted) _showMessage(context.tr('safety_plan_clear_error'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PlanContact {
  const _PlanContact(String name, this.number)
    : name = name == '' ? 'Trusted contact' : name;

  final String name;
  final String number;
}
