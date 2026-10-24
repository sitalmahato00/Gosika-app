import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/geo_provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/custom_text_field.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  
  int? _selectedProvince;
  int? _selectedDistrict;
  int? _selectedMunicipality;
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final provinces = ref.watch(provincesProvider);
    final districts = _selectedProvince != null ? ref.watch(districtsProvider(_selectedProvince!)) : null;
    final municipalities = _selectedDistrict != null ? ref.watch(municipalitiesProvider(_selectedDistrict!)) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Address')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPad),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _labelController,
                label: 'Address Label',
                hint: 'Home, Office, etc.',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Recipient name',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+977xxxxxxxxxx',
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              
              // Province
              provinces.when(
                data: (list) => _buildDropdown('Province', list.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), (val) {
                  setState(() {
                    _selectedProvince = val;
                    _selectedDistrict = null;
                    _selectedMunicipality = null;
                  });
                }, _selectedProvince),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),

              // District
              if (districts != null) districts.when(
                data: (list) => _buildDropdown('District', list.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), (val) {
                  setState(() {
                    _selectedDistrict = val;
                    _selectedMunicipality = null;
                  });
                }, _selectedDistrict),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),

              // Municipality
              if (municipalities != null) municipalities.when(
                data: (list) => _buildDropdown('Municipality', list.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), (val) {
                  setState(() => _selectedMunicipality = val);
                }, _selectedMunicipality),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _address1Controller,
                label: 'Street Address',
                hint: 'House no, Street, Area',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Set as Default Address', style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
                activeColor: kPrimary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<DropdownMenuItem<int>> items, ValueChanged<int?> onChanged, int? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: kInk, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: kPad)),
          validator: (v) => v == null ? 'Selection required' : null,
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        await ref.read(addressListProvider.notifier).addAddress({
          'label': _labelController.text,
          'full_name': _nameController.text,
          'phone': _phoneController.text,
          'address_line_1': _address1Controller.text,
          'province_id': _selectedProvince,
          'district_id': _selectedDistrict,
          'municipality_id': _selectedMunicipality,
          'is_default': _isDefault,
        });
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: kDanger));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }
}
