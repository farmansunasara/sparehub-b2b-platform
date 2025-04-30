import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/product.dart';
import '../../../providers/manufacturer_provider.dart';
import '../../../utils/form_validators.dart';
import '../../../widgets/common/common.dart';
import 'pdf_upload_section.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockController = TextEditingController();
  final _minOrderQuantityController = TextEditingController();
  final _maxOrderQuantityController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _materialController = TextEditingController();
  final _colorController = TextEditingController();
  final _shippingCostController = TextEditingController();
  final _shippingTimeController = TextEditingController();
  final _originCountryController = TextEditingController();

  final _nameFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _skuFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _discountFocus = FocusNode();
  final _stockFocus = FocusNode();
  final _minOrderQuantityFocus = FocusNode();
  final _maxOrderQuantityFocus = FocusNode();
  final _weightFocus = FocusNode();
  final _dimensionsFocus = FocusNode();
  final _materialFocus = FocusNode();
  final _colorFocus = FocusNode();
  final _shippingCostFocus = FocusNode();
  final _shippingTimeFocus = FocusNode();
  final _originCountryFocus = FocusNode();

  int? _selectedBrandId;
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  final List<XFile> _selectedImages = [];
  XFile? _selectedTechnicalPdfFile;
  XFile? _selectedInstallationPdfFile;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isApproved = false;
  bool _isLoading = false;

  bool _isBasicExpanded = true;
  bool _isCategoryExpanded = true;
  bool _isPriceStockExpanded = true;
  bool _isPhysicalExpanded = true;
  bool _isShippingExpanded = true;
  bool _isStatusExpanded = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _skuController.text = widget.product!.sku;
      _priceController.text = widget.product!.price.toString();
      _discountController.text = widget.product!.discount.toString();
      _stockController.text = widget.product!.stockQuantity.toString();
      _minOrderQuantityController.text = widget.product!.minOrderQuantity.toString();
      _maxOrderQuantityController.text = widget.product!.maxOrderQuantity?.toString() ?? '';
      _weightController.text = widget.product!.weight.toString();
      _dimensionsController.text = widget.product!.dimensions ?? '';
      _materialController.text = widget.product!.material ?? '';
      _colorController.text = widget.product!.color ?? '';
      _shippingCostController.text = widget.product!.shippingCost.toString();
      _shippingTimeController.text = widget.product!.shippingTime ?? '';
      _originCountryController.text = widget.product!.originCountry ?? '';

      _selectedBrandId = widget.product!.brandId;
      _selectedCategoryId = widget.product!.categoryId;
      _selectedSubcategoryId = widget.product!.subcategoryId;
      _isActive = widget.product!.isActive;
      _isFeatured = widget.product!.isFeatured;
      _isApproved = widget.product!.isApproved;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ManufacturerProvider>(context, listen: false);
      if (provider.categories.isEmpty) {
        provider.refreshCategories();
      }
      if (_selectedCategoryId != null) {
        provider.refreshSubcategories(categoryId: _selectedCategoryId);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _minOrderQuantityController.dispose();
    _maxOrderQuantityController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _materialController.dispose();
    _colorController.dispose();
    _shippingCostController.dispose();
    _shippingTimeController.dispose();
    _originCountryController.dispose();
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    _skuFocus.dispose();
    _priceFocus.dispose();
    _discountFocus.dispose();
    _stockFocus.dispose();
    _minOrderQuantityFocus.dispose();
    _maxOrderQuantityFocus.dispose();
    _weightFocus.dispose();
    _dimensionsFocus.dispose();
    _materialFocus.dispose();
    _colorFocus.dispose();
    _shippingCostFocus.dispose();
    _shippingTimeFocus.dispose();
    _originCountryFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      for (var image in images) {
        final file = File(image.path);
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);
        if (sizeInMB > 2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Each image must be less than 2MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategoryId == null || _selectedSubcategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select category and subcategory', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedImages.isEmpty && widget.product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least one image', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final provider = Provider.of<ManufacturerProvider>(context, listen: false);

        final product = Product(
          id: widget.product?.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          sku: _skuController.text.trim(),
          brandId: _selectedBrandId,
          categoryId: _selectedCategoryId!,
          subcategoryId: _selectedSubcategoryId!,
          manufacturerId: int.parse(provider.manufacturerId),
          price: double.parse(_priceController.text.trim()),
          discount: double.tryParse(_discountController.text.trim()) ?? 0.0,
          stockQuantity: int.parse(_stockController.text.trim()),
          minOrderQuantity: int.tryParse(_minOrderQuantityController.text.trim()) ?? 1,
          maxOrderQuantity: int.tryParse(_maxOrderQuantityController.text.trim()),
          weight: double.parse(_weightController.text.trim()),
          dimensions: _dimensionsController.text.trim().isEmpty ? null : _dimensionsController.text.trim(),
          material: _materialController.text.trim().isEmpty ? null : _materialController.text.trim(),
          color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
          technicalSpecificationPdf: widget.product?.technicalSpecificationPdf,
          installationGuidePdf: widget.product?.installationGuidePdf,
          shippingCost: double.tryParse(_shippingCostController.text.trim()) ?? 0.0,
          shippingTime: _shippingTimeController.text.trim().isEmpty ? null : _shippingTimeController.text.trim(),
          originCountry: _originCountryController.text.trim().isEmpty ? null : _originCountryController.text.trim(),
          isActive: _isActive,
          isFeatured: _isFeatured,
          isApproved: _isApproved,
          images: widget.product?.images ?? [],
        );

        if (widget.product == null) {
          await provider.addProduct(
            product: product,
            images: _selectedImages.map((x) => File(x.path)).toList(),
            technicalSpecificationPdf: _selectedTechnicalPdfFile != null ? File(_selectedTechnicalPdfFile!.path) : null,
            installationGuidePdf: _selectedInstallationPdfFile != null ? File(_selectedInstallationPdfFile!.path) : null,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product created successfully', style: GoogleFonts.poppins()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          await provider.updateProduct(
            product: product,
            images: _selectedImages.isNotEmpty ? _selectedImages.map((x) => File(x.path)).toList() : null,
            technicalSpecificationPdf: _selectedTechnicalPdfFile != null ? File(_selectedTechnicalPdfFile!.path) : null,
            installationGuidePdf: _selectedInstallationPdfFile != null ? File(_selectedInstallationPdfFile!.path) : null,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product updated successfully', style: GoogleFonts.poppins()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString(), style: GoogleFonts.poppins()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ManufacturerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add Product' : 'Edit Product',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || provider.isLoading,
        child: provider.error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${provider.error}',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.refreshCategories(),
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                      ),
                      child: Text('Retry', style: GoogleFonts.poppins()),
                    ),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Basic Information
                    _buildExpansionCard(
                      context,
                      title: 'Basic Information',
                      isExpanded: _isBasicExpanded,
                      onTap: () => setState(() => _isBasicExpanded = !_isBasicExpanded),
                      content: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: 'Product Name',
                              hintText: 'Enter product name',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: FormValidators.validateProductName,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_skuFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _skuController,
                            focusNode: _skuFocus,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: 'SKU',
                              hintText: 'Enter product SKU',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: FormValidators.validateSKU,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_descriptionFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            focusNode: _descriptionFocus,
                            style: GoogleFonts.poppins(),
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter product description',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: FormValidators.validateDescription,
                          ),
                        ],
                      ),
                    ),

                    // Category Information
                    _buildExpansionCard(
                      context,
                      title: 'Category Information',
                      isExpanded: _isCategoryExpanded,
                      onTap: () => setState(() => _isCategoryExpanded = !_isCategoryExpanded),
                      content: Column(
                        children: [
                          provider.categories.isEmpty
                              ? Text(
                                  'No categories available. Please try again.',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                                )
                              : DropdownButtonFormField<int>(
                                  value: _selectedCategoryId,
                                  style: GoogleFonts.poppins(),
                                  decoration: InputDecoration(
                                    labelText: 'Category',
                                    hintText: 'Select category',
                                    labelStyle: GoogleFonts.poppins(),
                                    hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                    filled: true,
                                    fillColor: theme.inputDecorationTheme.fillColor,
                                    border: theme.inputDecorationTheme.border,
                                  ),
                                  items: provider.categories.map((category) {
                                    return DropdownMenuItem(
                                      value: category.id,
                                      child: Text(category.name, style: GoogleFonts.poppins()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategoryId = value;
                                      _selectedSubcategoryId = null;
                                    });
                                    provider.refreshSubcategories(categoryId: value);
                                  },
                                  validator: (value) => value == null ? 'Please select a category' : null,
                                ),
                          if (_selectedCategoryId != null) ...[
                            const SizedBox(height: 16),
                            provider.getSubcategories(_selectedCategoryId!).isEmpty
                                ? Text(
                                    'No subcategories available for this category.',
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                                  )
                                : DropdownButtonFormField<int>(
                                    value: _selectedSubcategoryId,
                                    style: GoogleFonts.poppins(),
                                    decoration: InputDecoration(
                                      labelText: 'Subcategory',
                                      hintText: 'Select subcategory',
                                      labelStyle: GoogleFonts.poppins(),
                                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                      filled: true,
                                      fillColor: theme.inputDecorationTheme.fillColor,
                                      border: theme.inputDecorationTheme.border,
                                    ),
                                    items: provider.getSubcategories(_selectedCategoryId!).map((subcategory) {
                                      return DropdownMenuItem(
                                        value: subcategory.id,
                                        child: Text(subcategory.name, style: GoogleFonts.poppins()),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSubcategoryId = value;
                                      });
                                    },
                                    validator: (value) => value == null ? 'Please select a subcategory' : null,
                                  ),
                          ],
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedBrandId,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: 'Brand',
                              hintText: 'Select brand',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            items: provider.brands.map((brand) {
                              return DropdownMenuItem(
                                value: brand.id,
                                child: Text(brand.name, style: GoogleFonts.poppins()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBrandId = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Price and Stock Information
                    _buildExpansionCard(
                      context,
                      title: 'Price and Stock Information',
                      isExpanded: _isPriceStockExpanded,
                      onTap: () => setState(() => _isPriceStockExpanded = !_isPriceStockExpanded),
                      content: Column(
                        children: [
                          TextFormField(
                            controller: _priceController,
                            focusNode: _priceFocus,
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Price',
                              hintText: 'Enter product price',
                              prefixText: '₹',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: FormValidators.validatePrice,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_discountFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _discountController,
                            focusNode: _discountFocus,
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Discount (%)',
                              hintText: 'Enter discount percentage',
                              suffixText: '%',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: FormValidators.validateDiscount,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_stockFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _stockController,
                            focusNode: _stockFocus,
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Stock Quantity',
                              hintText: 'Enter available stock',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: FormValidators.validateQuantity,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_minOrderQuantityFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _minOrderQuantityController,
                            focusNode: _minOrderQuantityFocus,
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Minimum Order Quantity',
                              hintText: 'Enter minimum order quantity',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: FormValidators.validateQuantity,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_maxOrderQuantityFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _maxOrderQuantityController,
                            focusNode: _maxOrderQuantityFocus,
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Maximum Order Quantity',
                              hintText: 'Enter maximum order quantity (optional)',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return null;
                              final qty = int.tryParse(value);
                              if (qty == null) return 'Please enter a valid number';
                              if (qty < 0) return 'Quantity cannot be negative';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    // Product Images
                    _buildExpansionCard(
                      context,
                      title: 'Product Images',
                      isExpanded: true,
                      onTap: () {},
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedImages.isNotEmpty)
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            File(_selectedImages[index].path),
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Icon(
                                              Icons.error,
                                              size: 120,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          child: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                _selectedImages.removeAt(index);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 16),
                          Semantics(
                            label: 'Add product images',
                            child: ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: Text('Add Images', style: GoogleFonts.poppins()),
                              style: theme.elevatedButtonTheme.style?.copyWith(
                                backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
                                foregroundColor: MaterialStateProperty.all(Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Technical Specification PDF
                    _buildExpansionCard(
                      context,
                      title: 'Technical Specification PDF',
                      isExpanded: true,
                      onTap: () {},
                      content: PdfUploadSection(
                        selectedPdfFile: _selectedTechnicalPdfFile,
                        existingPdfUrl: widget.product?.technicalSpecificationPdf,
                        onPickPdf: () async {
                          final ImagePicker picker = ImagePicker();
                          try {
                            final XFile? file = await picker.pickMedia();
                            if (file != null && file.path.toLowerCase().endsWith('.pdf')) {
                              setState(() {
                                _selectedTechnicalPdfFile = file;
                              });
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please select a PDF file', style: GoogleFonts.poppins()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error picking PDF: ${e.toString()}', style: GoogleFonts.poppins()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        onClearPdf: () {
                          setState(() {
                            _selectedTechnicalPdfFile = null;
                          });
                        },
                      ),
                    ),

                    // Installation Guide PDF
                    _buildExpansionCard(
                      context,
                      title: 'Installation Guide PDF',
                      isExpanded: true,
                      onTap: () {},
                      content: PdfUploadSection(
                        selectedPdfFile: _selectedInstallationPdfFile,
                        existingPdfUrl: widget.product?.installationGuidePdf,
                        onPickPdf: () async {
                          final ImagePicker picker = ImagePicker();
                          try {
                            final XFile? file = await picker.pickMedia();
                            if (file != null && file.path.toLowerCase().endsWith('.pdf')) {
                              setState(() {
                                _selectedInstallationPdfFile = file;
                              });
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please select a PDF file', style: GoogleFonts.poppins()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error picking PDF: ${e.toString()}', style: GoogleFonts.poppins()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        onClearPdf: () {
                          setState(() {
                            _selectedInstallationPdfFile = null;
                          });
                        },
                      ),
                    ),

                    // Physical Details
                    _buildExpansionCard(
                      context,
                      title: 'Physical Details',
                      isExpanded: _isPhysicalExpanded,
                      onTap: () => setState(() => _isPhysicalExpanded = !_isPhysicalExpanded),
                      content: Column(
                        children: [
                          TextFormField(
                            controller: _weightController,
                            focusNode: _weightFocus,
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Weight (kg)',
                              hintText: 'Enter product weight',
                              suffixText: 'kg',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: FormValidators.validateWeight,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_dimensionsFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _dimensionsController,
                            focusNode: _dimensionsFocus,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: 'Dimensions',
                              hintText: 'Enter dimensions (e.g., 10x20x30 cm)',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: FormValidators.validateDimensions,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_materialFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _materialController,
                            focusNode: _materialFocus,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: 'Material',
                              hintText: 'Enter material (optional)',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_colorFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _colorController,
                            focusNode: _colorFocus,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: 'Color',
                              hintText: 'Enter color (optional)',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Shipping Details
                    _buildExpansionCard(
                      context,
                      title: 'Shipping Details',
                      isExpanded: _isShippingExpanded,
                      onTap: () => setState(() => _isShippingExpanded = !_isShippingExpanded),
                      content: Column(
                        children: [
                          TextFormField(
                            controller: _shippingCostController,
                            focusNode: _shippingCostFocus,
                            style: GoogleFonts.poppins(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Shipping Cost',
                              hintText: 'Enter shipping cost',
                              prefixText: '₹',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            validator: FormValidators.validateShippingCost,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_shippingTimeFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _shippingTimeController,
                            focusNode: _shippingTimeFocus,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: 'Shipping Time',
                              hintText: 'Enter shipping time (e.g., 3-5 days)',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_originCountryFocus),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _originCountryController,
                            focusNode: _originCountryFocus,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: 'Origin Country',
                              hintText: 'Enter origin country (optional)',
                              labelStyle: GoogleFonts.poppins(),
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                              border: theme.inputDecorationTheme.border,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status and Flags
                    _buildExpansionCard(
                      context,
                      title: 'Status and Flags',
                      isExpanded: _isStatusExpanded,
                      onTap: () => setState(() => _isStatusExpanded = !_isStatusExpanded),
                      content: Column(
                        children: [
                          Semantics(
                            label: 'Toggle product status',
                            child: SwitchListTile(
                              title: Text('Product Status', style: GoogleFonts.poppins()),
                              subtitle: Text(
                                _isActive ? 'Active' : 'Inactive',
                                style: GoogleFonts.poppins(color: Colors.grey[600]),
                              ),
                              value: _isActive,
                              activeColor: theme.primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                            ),
                          ),
                          Semantics(
                            label: 'Toggle featured product',
                            child: SwitchListTile(
                              title: Text('Featured Product', style: GoogleFonts.poppins()),
                              subtitle: Text(
                                _isFeatured ? 'Featured' : 'Not Featured',
                                style: GoogleFonts.poppins(color: Colors.grey[600]),
                              ),
                              value: _isFeatured,
                              activeColor: theme.primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _isFeatured = value;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: Text('Approval Status', style: GoogleFonts.poppins()),
                            subtitle: Text(
                              _isApproved ? 'Approved' : 'Pending Approval',
                              style: GoogleFonts.poppins(color: Colors.grey[600]),
                            ),
                            trailing: Icon(
                              _isApproved ? Icons.check_circle : Icons.hourglass_empty,
                              color: _isApproved ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Semantics(
                      label: 'Save product',
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: theme.elevatedButtonTheme.style?.copyWith(
                          backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                widget.product == null ? 'Add Product' : 'Save Changes',
                                style: GoogleFonts.poppins(),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildExpansionCard(
    BuildContext context, {
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: theme.cardTheme.elevation,
        shape: theme.cardTheme.shape,
        color: theme.cardTheme.color,
        child: Column(
          children: [
            ListTile(
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey[600],
              ),
              onTap: onTap,
            ),
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Padding(
                padding: const EdgeInsets.all(16),
                child: content,
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}