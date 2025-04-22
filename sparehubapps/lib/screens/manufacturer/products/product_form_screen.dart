import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
    // Ensure categories are fetched
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ManufacturerProvider>(context, listen: false);
      if (provider.categories.isEmpty) {
        provider.refreshCategories();
      }
      // Fetch subcategories for the initial category if editing a product
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
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategoryId == null || _selectedSubcategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select category and subcategory'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedImages.isEmpty && widget.product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one image'),
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

        // Create product object
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
          // Create new product
          await provider.addProduct(
            product: product,
            images: _selectedImages.map((x) => File(x.path)).toList(),
            technicalSpecificationPdf: _selectedTechnicalPdfFile != null ? File(_selectedTechnicalPdfFile!.path) : null,
            installationGuidePdf: _selectedInstallationPdfFile != null ? File(_selectedInstallationPdfFile!.path) : null,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          // Update existing product
          await provider.updateProduct(
            product: product,
            images: _selectedImages.isNotEmpty ? _selectedImages.map((x) => File(x.path)).toList() : null,
            technicalSpecificationPdf: _selectedTechnicalPdfFile != null ? File(_selectedTechnicalPdfFile!.path) : null,
            installationGuidePdf: _selectedInstallationPdfFile != null ? File(_selectedInstallationPdfFile!.path) : null,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product updated successfully'),
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
              content: Text(e.toString()),
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
    final provider = Provider.of<ManufacturerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || provider.isLoading,
        child: provider.error != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${provider.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.refreshCategories(),
                child: const Text('Retry'),
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
              Text(
                'Basic Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                ),
                validator: FormValidators.validateProductName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU',
                  hintText: 'Enter product SKU',
                ),
                validator: FormValidators.validateSKU,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter product description',
                ),
                validator: FormValidators.validateDescription,
              ),

              // Category Selection
              const SizedBox(height: 32),
              Text(
                'Category Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              provider.categories.isEmpty
                  ? const Text('No categories available. Please try again.')
                  : DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'Select category',
                ),
                items: provider.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                    _selectedSubcategoryId = null; // Reset subcategory
                  });
                  // Fetch subcategories for the selected category
                  final provider = Provider.of<ManufacturerProvider>(context, listen: false);
                  provider.refreshSubcategories(categoryId: value);
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedCategoryId != null)
                provider.getSubcategories(_selectedCategoryId!).isEmpty
                    ? const Text('No subcategories available for this category.')
                    : DropdownButtonFormField<int>(
                  value: _selectedSubcategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Subcategory',
                    hintText: 'Select subcategory',
                  ),
                  items: provider.getSubcategories(_selectedCategoryId!).map((subcategory) {
                    return DropdownMenuItem(
                      value: subcategory.id,
                      child: Text(subcategory.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubcategoryId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a subcategory' : null,
                ),

              // Brand Selection
              const SizedBox(height: 32),
              Text(
                'Brand Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedBrandId,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  hintText: 'Select brand',
                ),
                items: provider.brands.map((brand) {
                  return DropdownMenuItem(
                    value: brand.id,
                    child: Text(brand.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBrandId = value;
                  });
                },
              ),

              // Price and Stock Information
              const SizedBox(height: 32),
              Text(
                'Price and Stock Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'Enter product price',
                  prefixText: '₹',
                ),
                validator: FormValidators.validatePrice,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Discount (%)',
                  hintText: 'Enter discount percentage',
                  suffixText: '%',
                ),
                validator: FormValidators.validateDiscount,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  hintText: 'Enter available stock',
                ),
                validator: FormValidators.validateQuantity,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minOrderQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimum Order Quantity',
                  hintText: 'Enter minimum order quantity',
                ),
                validator: FormValidators.validateQuantity,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxOrderQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Maximum Order Quantity',
                  hintText: 'Enter maximum order quantity (optional)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final qty = int.tryParse(value);
                  if (qty == null) return 'Please enter a valid number';
                  if (qty < 0) return 'Quantity cannot be negative';
                  return null;
                },
              ),

              // Technical Specification PDF
              const SizedBox(height: 32),
              Text(
                'Technical Specification PDF',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              PdfUploadSection(
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
                          const SnackBar(
                            content: Text('Please select a PDF file'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error picking PDF: ${e.toString()}'),
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

              // Installation Guide PDF
              const SizedBox(height: 32),
              Text(
                'Installation Guide PDF',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              PdfUploadSection(
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
                          const SnackBar(
                            content: Text('Please select a PDF file'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error picking PDF: ${e.toString()}'),
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

              // Product Images
              const SizedBox(height: 32),
              Text(
                'Product Images',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
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
                            Image.file(
                              File(_selectedImages[index].path),
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close),
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
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Images'),
              ),

              // Physical Details
              const SizedBox(height: 32),
              Text(
                'Physical Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'Enter product weight',
                  suffixText: 'kg',
                ),
                validator: FormValidators.validateWeight,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dimensionsController,
                decoration: const InputDecoration(
                  labelText: 'Dimensions',
                  hintText: 'Enter dimensions (e.g., 10x20x30 cm)',
                ),
                validator: FormValidators.validateDimensions,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _materialController,
                decoration: const InputDecoration(
                  labelText: 'Material',
                  hintText: 'Enter material (optional)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  hintText: 'Enter color (optional)',
                ),
              ),

              // Shipping Details
              const SizedBox(height: 32),
              Text(
                'Shipping Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shippingCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Shipping Cost',
                  hintText: 'Enter shipping cost',
                  prefixText: '₹',
                ),
                validator: FormValidators.validateShippingCost,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shippingTimeController,
                decoration: const InputDecoration(
                  labelText: 'Shipping Time',
                  hintText: 'Enter shipping time (e.g., 3-5 days)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _originCountryController,
                decoration: const InputDecoration(
                  labelText: 'Origin Country',
                  hintText: 'Enter origin country (optional)',
                ),
              ),

              // Status and Flags
              const SizedBox(height: 32),
              Text(
                'Status and Flags',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Product Status'),
                subtitle: Text(_isActive ? 'Active' : 'Inactive'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Featured Product'),
                subtitle: Text(_isFeatured ? 'Featured' : 'Not Featured'),
                value: _isFeatured,
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value;
                  });
                },
              ),
              ListTile(
                title: const Text('Approval Status'),
                subtitle: Text(_isApproved ? 'Approved' : 'Pending Approval'),
                trailing: Icon(
                  _isApproved ? Icons.check_circle : Icons.hourglass_empty,
                  color: _isApproved ? Colors.green : Colors.grey,
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.product == null ? 'Add Product' : 'Save Changes'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
