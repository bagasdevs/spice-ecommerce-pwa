import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';

class SpecificationsWidget extends StatefulWidget {
  final Map<String, dynamic> specifications;
  final String spiceType;
  final Function(String, dynamic) onSpecificationChanged;

  const SpecificationsWidget({
    Key? key,
    required this.specifications,
    required this.spiceType,
    required this.onSpecificationChanged,
  }) : super(key: key);

  @override
  State<SpecificationsWidget> createState() => _SpecificationsWidgetState();
}

class _SpecificationsWidgetState extends State<SpecificationsWidget> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    final specs = _getSpecificationFields();
    for (var spec in specs) {
      final key = spec['key'] as String;
      final controller = TextEditingController(
        text: widget.specifications[key]?.toString() ?? '',
      );
      _controllers[key] = controller;

      controller.addListener(() {
        final value = controller.text;
        if (value.isNotEmpty) {
          final type = spec['type'] as SpecificationType;
          dynamic parsedValue;

          switch (type) {
            case SpecificationType.number:
              parsedValue = double.tryParse(value);
              break;
            case SpecificationType.percentage:
              parsedValue = double.tryParse(value);
              break;
            case SpecificationType.text:
              parsedValue = value;
              break;
          }

          if (parsedValue != null) {
            widget.onSpecificationChanged(key, parsedValue);
          }
        }
      });
    }
  }

  List<Map<String, dynamic>> _getSpecificationFields() {
    final baseSpecs = [
      {
        'key': 'moisture_content',
        'label': 'Kadar Air (%)',
        'hint': 'Contoh: 12.5',
        'type': SpecificationType.percentage,
        'icon': Icons.water_drop_outlined,
        'required': true,
      },
      {
        'key': 'shelf_life',
        'label': 'Masa Simpan (bulan)',
        'hint': 'Contoh: 24',
        'type': SpecificationType.number,
        'icon': Icons.schedule_outlined,
        'required': true,
      },
      {
        'key': 'storage_condition',
        'label': 'Kondisi Penyimpanan',
        'hint': 'Contoh: Tempat sejuk dan kering',
        'type': SpecificationType.text,
        'icon': Icons.inventory_2_outlined,
        'required': false,
      },
    ];

    // Add spice-specific specifications
    final spiceSpecs = _getSpiceSpecificFields(widget.spiceType);
    return [...baseSpecs, ...spiceSpecs];
  }

  List<Map<String, dynamic>> _getSpiceSpecificFields(String spiceType) {
    switch (spiceType.toLowerCase()) {
      case 'jahe merah':
      case 'jahe putih':
        return [
          {
            'key': 'gingerol_content',
            'label': 'Kandungan Gingerol (%)',
            'hint': 'Contoh: 2.5',
            'type': SpecificationType.percentage,
            'icon': Icons.science_outlined,
            'required': false,
          },
          {
            'key': 'pungency_level',
            'label': 'Tingkat Kepedasan',
            'hint': 'Mild, Medium, Hot',
            'type': SpecificationType.text,
            'icon': Icons.local_fire_department_outlined,
            'required': false,
          },
        ];

      case 'kunyit':
        return [
          {
            'key': 'curcumin_content',
            'label': 'Kandungan Kurkumin (%)',
            'hint': 'Contoh: 3.2',
            'type': SpecificationType.percentage,
            'icon': Icons.science_outlined,
            'required': false,
          },
          {
            'key': 'color_intensity',
            'label': 'Intensitas Warna',
            'hint': 'Light, Medium, Deep',
            'type': SpecificationType.text,
            'icon': Icons.palette_outlined,
            'required': false,
          },
        ];

      case 'merica hitam':
      case 'merica putih':
        return [
          {
            'key': 'piperine_content',
            'label': 'Kandungan Piperine (%)',
            'hint': 'Contoh: 5.0',
            'type': SpecificationType.percentage,
            'icon': Icons.science_outlined,
            'required': false,
          },
          {
            'key': 'mesh_size',
            'label': 'Ukuran Mesh',
            'hint': 'Contoh: 20-40',
            'type': SpecificationType.text,
            'icon': Icons.filter_alt_outlined,
            'required': false,
          },
        ];

      case 'cengkeh':
        return [
          {
            'key': 'eugenol_content',
            'label': 'Kandungan Eugenol (%)',
            'hint': 'Contoh: 85.0',
            'type': SpecificationType.percentage,
            'icon': Icons.science_outlined,
            'required': false,
          },
          {
            'key': 'oil_content',
            'label': 'Kandungan Minyak (%)',
            'hint': 'Contoh: 15.0',
            'type': SpecificationType.percentage,
            'icon': Icons.opacity_outlined,
            'required': false,
          },
        ];

      case 'pala':
        return [
          {
            'key': 'volatile_oil',
            'label': 'Minyak Atsiri (%)',
            'hint': 'Contoh: 8.0',
            'type': SpecificationType.percentage,
            'icon': Icons.opacity_outlined,
            'required': false,
          },
          {
            'key': 'grade',
            'label': 'Grade Pala',
            'hint': 'ABCD, ABC, AB, etc.',
            'type': SpecificationType.text,
            'icon': Icons.grade_outlined,
            'required': false,
          },
        ];

      default:
        return [
          {
            'key': 'active_compound',
            'label': 'Senyawa Aktif (%)',
            'hint': 'Kandungan senyawa utama',
            'type': SpecificationType.percentage,
            'icon': Icons.science_outlined,
            'required': false,
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final specs = _getSpecificationFields();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (specs.isNotEmpty) ...[
          _buildSpecificationsList(specs),
          const SizedBox(height: 16),
          _buildAddCustomSpecButton(),
        ] else
          _buildEmptyState(),
      ],
    );
  }

  Widget _buildSpecificationsList(List<Map<String, dynamic>> specs) {
    return Column(
      children: specs.map((spec) => _buildSpecificationField(spec)).toList(),
    );
  }

  Widget _buildSpecificationField(Map<String, dynamic> spec) {
    final key = spec['key'] as String;
    final label = spec['label'] as String;
    final hint = spec['hint'] as String;
    final type = spec['type'] as SpecificationType;
    final icon = spec['icon'] as IconData;
    final required = spec['required'] as bool;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomTextField(
        controller: _controllers[key]!,
        label: label,
        hint: hint,
        isRequired: required,
        prefixIcon: icon,
        keyboardType: type == SpecificationType.number ||
                type == SpecificationType.percentage
            ? TextInputType.number
            : TextInputType.text,
        inputFormatters: type == SpecificationType.number ||
                type == SpecificationType.percentage
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
            : null,
        suffixText: type == SpecificationType.percentage ? '%' : null,
        validator: required
            ? (value) {
                if (value?.isEmpty ?? true) {
                  return '$label wajib diisi';
                }
                if (type == SpecificationType.number ||
                    type == SpecificationType.percentage) {
                  final numValue = double.tryParse(value!);
                  if (numValue == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (type == SpecificationType.percentage &&
                      (numValue < 0 || numValue > 100)) {
                    return 'Persentase harus antara 0-100';
                  }
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildAddCustomSpecButton() {
    return GestureDetector(
      onTap: _showAddCustomSpecDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.info,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_outlined,
              color: AppColors.info,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tambah Spesifikasi Khusus',
              style: TextStyle(
                color: AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.science_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Spesifikasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih jenis rempah untuk menampilkan spesifikasi yang relevan',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddCustomSpecDialog() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    String selectedType = 'text';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Spesifikasi Khusus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: nameController,
              label: 'Nama Spesifikasi',
              hint: 'Contoh: Kandungan Protein',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipe Data',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'text', child: Text('Teks')),
                DropdownMenuItem(value: 'number', child: Text('Angka')),
                DropdownMenuItem(
                    value: 'percentage', child: Text('Persentase')),
              ],
              onChanged: (value) {
                selectedType = value ?? 'text';
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: valueController,
              label: 'Nilai',
              hint: 'Masukkan nilai spesifikasi',
              keyboardType: selectedType != 'text'
                  ? TextInputType.number
                  : TextInputType.text,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final value = valueController.text.trim();

              if (name.isNotEmpty && value.isNotEmpty) {
                final key = name.toLowerCase().replaceAll(' ', '_');
                dynamic parsedValue;

                if (selectedType == 'number' || selectedType == 'percentage') {
                  parsedValue = double.tryParse(value) ?? value;
                } else {
                  parsedValue = value;
                }

                widget.onSpecificationChanged(key, parsedValue);

                // Add controller for the new field
                final controller = TextEditingController(text: value);
                _controllers[key] = controller;
                controller.addListener(() {
                  widget.onSpecificationChanged(key, controller.text);
                });

                setState(() {});
                Navigator.of(context).pop();
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}

enum SpecificationType {
  text,
  number,
  percentage,
}

// Predefined specification templates for common spices
class SpiceSpecificationTemplates {
  static Map<String, List<Map<String, dynamic>>> getTemplates() {
    return {
      'Jahe': [
        {
          'key': 'gingerol_content',
          'label': 'Kandungan Gingerol (%)',
          'type': 'percentage'
        },
        {'key': 'pungency_level', 'label': 'Tingkat Kepedasan', 'type': 'text'},
        {
          'key': 'fiber_content',
          'label': 'Kandungan Serat (%)',
          'type': 'percentage'
        },
      ],
      'Kunyit': [
        {
          'key': 'curcumin_content',
          'label': 'Kandungan Kurkumin (%)',
          'type': 'percentage'
        },
        {'key': 'color_intensity', 'label': 'Intensitas Warna', 'type': 'text'},
        {
          'key': 'essential_oil',
          'label': 'Minyak Atsiri (%)',
          'type': 'percentage'
        },
      ],
      'Merica': [
        {
          'key': 'piperine_content',
          'label': 'Kandungan Piperine (%)',
          'type': 'percentage'
        },
        {'key': 'mesh_size', 'label': 'Ukuran Mesh', 'type': 'text'},
        {
          'key': 'volatile_oil',
          'label': 'Minyak Atsiri (%)',
          'type': 'percentage'
        },
      ],
      'Cengkeh': [
        {
          'key': 'eugenol_content',
          'label': 'Kandungan Eugenol (%)',
          'type': 'percentage'
        },
        {
          'key': 'oil_content',
          'label': 'Kandungan Minyak (%)',
          'type': 'percentage'
        },
        {
          'key': 'stem_content',
          'label': 'Kandungan Batang (%)',
          'type': 'percentage'
        },
      ],
      'Pala': [
        {
          'key': 'volatile_oil',
          'label': 'Minyak Atsiri (%)',
          'type': 'percentage'
        },
        {'key': 'grade', 'label': 'Grade Pala', 'type': 'text'},
        {
          'key': 'size_uniformity',
          'label': 'Keseragaman Ukuran',
          'type': 'text'
        },
      ],
    };
  }
}
