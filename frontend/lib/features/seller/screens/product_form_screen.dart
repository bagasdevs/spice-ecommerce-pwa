import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../products/models/product_model.dart';
import '../../products/providers/product_provider.dart';

import '../widgets/image_picker_widget.dart';
import '../widgets/ai_price_insight_widget.dart';
import '../widgets/specifications_widget.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product; // null for create, Product for edit

  const ProductFormScreen({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late TabController _tabController;

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _originController = TextEditingController();
  final _certificationsController = TextEditingController();

  // Form state
  String _selectedCategory = '';
  String _selectedSpiceType = '';
  String _selectedUnit = 'kg';
  String _selectedQuality = 'Standard';
  bool _isOrganic = false;
  DateTime? _harvestDate;
  List<String> _tags = [];
  Map<String, dynamic> _specifications = {};

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isEditing = widget.product != null;

    if (_isEditing) {
      _initializeWithProduct();
    }

    // Initialize form in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditing) {
        ref
            .read(productFormProvider.notifier)
            .initializeWithProduct(widget.product!);
      } else {
        ref.read(productFormProvider.notifier).resetForm();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minOrderController.dispose();
    _originController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  void _initializeWithProduct() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _stockController.text = product.stock.toString();
    _minOrderController.text = product.minOrder.toString();
    _originController.text = product.origin;
    _certificationsController.text = product.certifications ?? '';

    _selectedCategory = product.category;
    _selectedSpiceType = product.spiceType;
    _selectedUnit = product.unit;
    _selectedQuality = product.quality;
    _isOrganic = product.isOrganic;
    _harvestDate = DateTime.tryParse(product.harvestDate);
    _tags = List.from(product.tags);
    _specifications = Map.from(product.specifications ?? {});
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(productFormProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(formState),
      bottomNavigationBar: _buildBottomActions(formState),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isEditing ? 'Edit Produk' : 'Tambah Produk',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => _showExitConfirmation(),
      ),
      actions: [
        if (!_isEditing)
          TextButton(
            onPressed: () => _showDraftSaveDialog(),
            child: const Text(
              'Simpan Draft',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(
            icon: Icon(Icons.info_outline),
            text: 'Informasi Dasar',
          ),
          Tab(
            icon: const Icon(Icons.photo_camera_outlined),
            text: 'Foto & Detail',
          ),
          Tab(
            icon: const Icon(Icons.insights_outlined),
            text: 'Harga & AI',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProductFormState formState) {
    return Form(
      key: _formKey,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(formState),
          _buildPhotosAndDetailsTab(formState),
          _buildPricingAndAITab(formState),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab(ProductFormState formState) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Informasi Produk',
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nama Produk',
                hint: 'Contoh: Jahe Merah Premium',
                isRequired: true,
                onChanged: (value) => ref
                    .read(productFormProvider.notifier)
                    .updateField('name', value),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Nama produk wajib diisi';
                  }
                  if (value!.length < 3) {
                    return 'Nama produk minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Deskripsi Produk',
                hint: 'Jelaskan produk Anda secara detail...',
                maxLines: 4,
                isRequired: true,
                onChanged: (value) => ref
                    .read(productFormProvider.notifier)
                    .updateField('description', value),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Deskripsi produk wajib diisi';
                  }
                  if (value!.length < 20) {
                    return 'Deskripsi minimal 20 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildCategorySelector(formState),
              const SizedBox(height: 16),
              _buildSpiceTypeSelector(formState),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Detail Produk',
            children: [
              _buildOriginField(),
              const SizedBox(height: 16),
              _buildHarvestDateField(),
              const SizedBox(height: 16),
              _buildQualitySelector(),
              const SizedBox(height: 16),
              _buildOrganicSwitch(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosAndDetailsTab(ProductFormState formState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Foto Produk',
            subtitle: 'Tambahkan minimal 1 foto produk berkualitas',
            children: [
              ImagePickerWidget(
                images: [
                  ...formState.existingImages,
                  ...formState.imageFiles.map((f) => f.path),
                ],
                onAddImage: _addImage,
                onRemoveImage: _removeImage,
                maxImages: 5,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Spesifikasi Teknis',
            subtitle: 'Informasi tambahan untuk pembeli',
            children: [
              SpecificationsWidget(
                specifications: _specifications,
                spiceType: _selectedSpiceType,
                onSpecificationChanged: (key, value) {
                  setState(() {
                    _specifications[key] = value;
                  });
                  ref
                      .read(productFormProvider.notifier)
                      .updateSpecification(key, value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Sertifikasi',
            children: [
              CustomTextField(
                controller: _certificationsController,
                label: 'Sertifikasi (Opsional)',
                hint: 'Contoh: Organik, HACCP, ISO',
                onChanged: (value) => ref
                    .read(productFormProvider.notifier)
                    .updateField('certifications', value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Tags',
            children: [
              _buildTagsWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingAndAITab(ProductFormState formState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Harga & Stok',
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Harga',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      prefixIcon: Icons.attach_money,
                      onChanged: (value) {
                        final price = double.tryParse(value);
                        ref
                            .read(productFormProvider.notifier)
                            .updateField('price', price);
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Harga wajib diisi';
                        }
                        final price = double.tryParse(value!);
                        if (price == null || price <= 0) {
                          return 'Harga harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUnitSelector(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      label: 'Stok',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      suffixText: _selectedUnit,
                      onChanged: (value) {
                        final stock = int.tryParse(value);
                        ref
                            .read(productFormProvider.notifier)
                            .updateField('stock', stock);
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Stok wajib diisi';
                        }
                        final stock = int.tryParse(value!);
                        if (stock == null || stock < 0) {
                          return 'Stok harus 0 atau lebih';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _minOrderController,
                      label: 'Min. Order',
                      hint: '1',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      suffixText: _selectedUnit,
                      onChanged: (value) {
                        final minOrder = int.tryParse(value);
                        ref
                            .read(productFormProvider.notifier)
                            .updateField('minOrder', minOrder);
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Min. order wajib diisi';
                        }
                        final minOrder = int.tryParse(value!);
                        if (minOrder == null || minOrder <= 0) {
                          return 'Min. order harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Rekomendasi Harga AI',
            subtitle: 'Dapatkan saran harga optimal dari AI',
            children: [
              AiPriceInsightWidget(
                spiceType: _selectedSpiceType,
                quality: _selectedQuality,
                origin: _originController.text,
                isOrganic: _isOrganic,
                specifications: _specifications,
                onPriceSelected: (price) {
                  _priceController.text = price.toString();
                  ref
                      .read(productFormProvider.notifier)
                      .updateField('price', price);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildCategorySelector(ProductFormState formState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Rempah *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              hint: const Text('Pilih kategori'),
              isExpanded: true,
              items: SpiceCategories.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? '';
                  _selectedSpiceType = '';
                });
                ref
                    .read(productFormProvider.notifier)
                    .updateField('category', value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpiceTypeSelector(ProductFormState formState) {
    final spiceTypes = SpiceCategories.getSpiceTypes(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Rempah *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSpiceType.isEmpty ? null : _selectedSpiceType,
              hint: Text(_selectedCategory.isEmpty
                  ? 'Pilih kategori dulu'
                  : 'Pilih jenis rempah'),
              isExpanded: true,
              items: spiceTypes.isEmpty
                  ? null
                  : spiceTypes.map((spiceType) {
                      return DropdownMenuItem(
                        value: spiceType,
                        child: Text(spiceType),
                      );
                    }).toList(),
              onChanged: spiceTypes.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _selectedSpiceType = value ?? '';
                      });
                      ref
                          .read(productFormProvider.notifier)
                          .updateField('spiceType', value);
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOriginField() {
    return CustomTextField(
      controller: _originController,
      label: 'Asal Daerah',
      hint: 'Contoh: Bogor, Jawa Barat',
      isRequired: true,
      prefixIcon: Icons.location_on_outlined,
      onChanged: (value) =>
          ref.read(productFormProvider.notifier).updateField('origin', value),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Asal daerah wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildHarvestDateField() {
    return GestureDetector(
      onTap: () => _selectHarvestDate(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Panen *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _harvestDate != null
                        ? DateFormat('dd MMMM yyyy').format(_harvestDate!)
                        : 'Pilih tanggal panen',
                    style: TextStyle(
                      fontSize: 14,
                      color: _harvestDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySelector() {
    const qualities = ['Standard', 'Premium', 'Super Premium'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kualitas Produk',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: qualities.map((quality) {
            final isSelected = _selectedQuality == quality;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedQuality = quality;
                  });
                  ref
                      .read(productFormProvider.notifier)
                      .updateField('quality', quality);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quality,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrganicSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk Organik',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Produk tanpa pestisida kimia',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Switch(
          value: _isOrganic,
          onChanged: (value) {
            setState(() {
              _isOrganic = value;
            });
            ref
                .read(productFormProvider.notifier)
                .updateField('isOrganic', value);
          },
          activeColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildUnitSelector() {
    const units = ['kg', 'gram', 'ons'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Satuan *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUnit,
              isExpanded: true,
              items: units.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value ?? 'kg';
                });
                ref
                    .read(productFormProvider.notifier)
                    .updateField('unit', value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Tambah Tag',
                hint: 'Masukkan tag dan tekan Enter',
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty && !_tags.contains(value)) {
                    setState(() {
                      _tags.add(value);
                    });
                    ref.read(productFormProvider.notifier).addTag(value);
                  }
                },
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                  ref.read(productFormProvider.notifier).removeTag(tag);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActions(ProductFormState formState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Batal',
              onPressed: () => _showExitConfirmation(),
              variant: CustomButtonVariant.outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: _isEditing ? 'Update Produk' : 'Publish Produk',
              onPressed: formState.isLoading ? null : () => _submitForm(),
              isLoading: formState.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 80,
                );
                if (image != null) {
                  ref
                      .read(productFormProvider.notifier)
                      .addImageFile(File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 80,
                );
                if (image != null) {
                  ref
                      .read(productFormProvider.notifier)
                      .addImageFile(File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    final formState = ref.read(productFormProvider);
    if (index < formState.existingImages.length) {
      ref.read(productFormProvider.notifier).removeExistingImage(index);
    } else {
      final fileIndex = index - formState.existingImages.length;
      ref.read(productFormProvider.notifier).removeImageFile(fileIndex);
    }
  }

  Future<void> _selectHarvestDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _harvestDate) {
      setState(() {
        _harvestDate = picked;
      });
      ref
          .read(productFormProvider.notifier)
          .updateField('harvestDate', DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      SnackbarUtils.showError(context, 'Mohon lengkapi semua field yang wajib');
      return;
    }

    if (_selectedCategory.isEmpty) {
      SnackbarUtils.showError(context, 'Mohon pilih kategori rempah');
      return;
    }

    if (_selectedSpiceType.isEmpty) {
      SnackbarUtils.showError(context, 'Mohon pilih jenis rempah');
      return;
    }

    if (_harvestDate == null) {
      SnackbarUtils.showError(context, 'Mohon pilih tanggal panen');
      return;
    }

    final formState = ref.read(productFormProvider);
    if (formState.imageFiles.isEmpty && formState.existingImages.isEmpty) {
      SnackbarUtils.showError(context, 'Mohon tambahkan minimal 1 foto produk');
      return;
    }

    try {
      Product? result;
      if (_isEditing) {
        result = await ref
            .read(productFormProvider.notifier)
            .updateProduct(widget.product!.id);
      } else {
        result = await ref.read(productFormProvider.notifier).createProduct();
      }

      if (result != null) {
        SnackbarUtils.showSuccess(
          context,
          _isEditing
              ? 'Produk berhasil diupdate'
              : 'Produk berhasil ditambahkan',
        );
        Navigator.of(context).pop(result);
      } else {
        final error = formState.error ?? 'Terjadi kesalahan';
        SnackbarUtils.showError(context, error);
      }
    } catch (e) {
      SnackbarUtils.showError(context, e.toString());
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Form'),
        content: const Text(
          'Perubahan yang belum disimpan akan hilang. Yakin ingin keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showDraftSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simpan sebagai Draft'),
        content: const Text(
          'Produk akan disimpan sebagai draft dan dapat dilanjutkan nanti.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement draft save
              SnackbarUtils.showSuccess(context, 'Draft berhasil disimpan');
            },
            child: const Text('Simpan Draft'),
          ),
        ],
      ),
    );
  }
}
