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
  final _modelNumberController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _shippingCostController = TextEditingController();

  int? _selectedBrandId;
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  final List<int> _selectedCompatibleCarIds = [];
  final List<XFile> _selectedImages = [];
  XFile? _selectedPdfFile;
  final Map<String, TextEditingController> _specificationControllers = {};
  bool _isActive = true;
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
      _modelNumberController.text = widget.product!.modelNumber ?? '';
      _weightController.text = widget.product!.weight.toString();
      _dimensionsController.text = widget.product!.dimensions ?? '';
      _shippingCostController.text = widget.product!.shippingCost.toString();

      _selectedBrandId = widget.product!.brandId;
      _selectedCategoryId = widget.product!.categoryId;
      _selectedSubcategoryId = widget.product!.subcategoryId;
      _selectedCompatibleCarIds.addAll(widget.product!.compatibleCarIds);
      _isActive = widget.product!.isActive;

      widget.product!.specifications.forEach((key, value) {
        _specificationControllers[key] = TextEditingController(text: value.toString());
      });
    }
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
    _modelNumberController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _shippingCostController.dispose();
    _specificationControllers.values.forEach((controller) => controller.dispose());
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

  void _addSpecification() {
    showDialog(
      context: context,
      builder: (context) {
        final keyController = TextEditingController();
        final valueController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Specification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'Specification Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Value',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
                  setState(() {
                    _specificationControllers[keyController.text] =
                        TextEditingController(text: valueController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final provider = Provider.of<ManufacturerProvider>(context, listen: false);
        final manufacturerId = provider.manufacturerId;

        if (_selectedCategoryId == null || _selectedSubcategoryId == null) {
          throw Exception('Please select category and subcategory');
        }

        final product = Product(
          id: widget.product?.id,
          name: _nameController.text,
          description: _descriptionController.text,
          sku: _skuController.text,
          modelNumber: _modelNumberController.text.isEmpty ? null : _modelNumberController.text,
          brandId: _selectedBrandId,
          categoryId: _selectedCategoryId!,
          subcategoryId: _selectedSubcategoryId!,
          manufacturerId: int.parse(manufacturerId),
          compatibleCarIds: _selectedCompatibleCarIds,
          price: double.parse(_priceController.text),
          discount: double.tryParse(_discountController.text) ?? 0.0,
          stockQuantity: int.parse(_stockController.text),
          minOrderQuantity: int.tryParse(_minOrderQuantityController.text) ?? 1,
          specifications: Map.fromEntries(
            _specificationControllers.entries.map(
                  (e) => MapEntry(e.key, e.value.text),
            ),
          ),
          weight: double.parse(_weightController.text),
          dimensions: _dimensionsController.text.isEmpty ? null : _dimensionsController.text,
          shippingCost: double.tryParse(_shippingCostController.text) ?? 0.0,
          isActive: _isActive,
          images: const [], // Will be handled by the provider
        );

        if (widget.product == null) {
          await provider.addProduct(
            product: product,
            images: _selectedImages.map((x) => File(x.path)).toList(),
            technicalSpecificationPdf: _selectedPdfFile != null ? File(_selectedPdfFile!.path) : null,
          );
        } else {
          await provider.updateProduct(product);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
        isLoading: _isLoading,
        child: Form(
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
              DropdownButtonFormField<int>(
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
                    _selectedSubcategoryId = null; // Reset subcategory when category changes
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedCategoryId != null)
                DropdownButtonFormField<int>(
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

              // Compatible Cars
              const SizedBox(height: 32),
              Text(
                'Compatible Cars',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: provider.cars.map((car) {
                  final isSelected = _selectedCompatibleCarIds.contains(car.id);
                  return FilterChip(
                    label: Text(car.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCompatibleCarIds.add(car.id);
                        } else {
                          _selectedCompatibleCarIds.remove(car.id);
                        }
                      });
                    },
                  );
                }).toList(),
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

              // Technical Specification PDF
              const SizedBox(height: 32),
              Text(
                'Technical Specification',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              PdfUploadSection(
                selectedPdfFile: _selectedPdfFile,
                existingPdfUrl: widget.product?.technicalSpecificationPdf,
                onPickPdf: () async {
                  final ImagePicker picker = ImagePicker();
                  try {
                    final XFile? file = await picker.pickMedia();
                    if (file != null && file.path.toLowerCase().endsWith('.pdf')) {
                      setState(() {
                        _selectedPdfFile = file;
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
                    _selectedPdfFile = null;
                  });
                },
              ),

              // Specifications
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Specifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSpecification,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._specificationControllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: entry.value,
                          decoration: InputDecoration(
                            labelText: entry.key,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _specificationControllers.remove(entry.key);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),

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
                controller: _modelNumberController,
                decoration: const InputDecoration(
                  labelText: 'Model Number',
                  hintText: 'Enter model number (optional)',
                ),
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
                controller: _shippingCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Shipping Cost',
                  hintText: 'Enter shipping cost',
                  prefixText: '₹',
                ),
                validator: FormValidators.validateShippingCost,
              ),

              // Active Status
              const SizedBox(height: 32),
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
