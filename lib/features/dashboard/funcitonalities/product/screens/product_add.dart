import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:invsync/common/widgets/custom_button.dart';
import '../cubit/product_cubit.dart';

class ProductFormPage extends StatefulWidget {
  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _productData = {'specifications': {}};
  final List<File> _images = [];

  List<dynamic> _suppliers = [];
  String? _selectedSupplierId;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _warrantyController = TextEditingController();

  // Controllers for specifications
  final TextEditingController _processorController = TextEditingController();
  final TextEditingController _ramController = TextEditingController();
  final TextEditingController _storageController = TextEditingController();
  final TextEditingController _displaySizeController = TextEditingController();
  final TextEditingController _osController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _resolutionController = TextEditingController();
  final TextEditingController _cameraController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _warrantyController.dispose();
    _processorController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _displaySizeController.dispose();
    _osController.dispose();
    _colorController.dispose();
    _resolutionController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  // Fetch suppliers from the API
  Future<void> _fetchSuppliers() async {
    final response = await http.get(Uri.parse(
        'https://invsync.bcrypt.website/inventory/supplier/get/all/without-pagination'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _suppliers = data['suppliers'];
      });
    } else {
      // Handle error, you can show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load suppliers'),
      ));
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && _images.length + pickedFiles.length <= 5) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    } else if (pickedFiles != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can upload up to 5 images only.')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  String _generateSKU(String name) {
    return '${name.replaceAll(' ', '').toUpperCase()}${Random().nextInt(10000)}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocListener<ProductCubit, ProductState>(
          listener: (context, state) {
            if (state is ProductLoading) {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevent closing the dialog by tapping outside
                builder: (context) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            } else if (state is ProductSuccess) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Product added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is ProductFailure) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Add Product',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          TextFormField(
                            controller: _nameController,
                            decoration:
                                InputDecoration(labelText: 'Product Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the product name';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _productData['sku'] = _generateSKU(value);
                              });
                            },
                            onSaved: (value) {
                              _productData['name'] = value;
                            },
                          ),
                          // SKU (auto-generated, non-editable)
                          TextFormField(
                            decoration: InputDecoration(labelText: 'SKU'),
                            initialValue: _productData['sku'] ?? '',
                            enabled: false,
                          ),
                          // Brand
                          TextFormField(
                            controller: _brandController,
                            decoration: InputDecoration(labelText: 'Brand'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the brand';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _productData['brand'] = value;
                            },
                          ),

                          // Category Dropdown
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(labelText: 'Category'),
                            items: [
                              'Laptop',
                              'Mobile',
                              'PreBuilt Desktop',
                              'Tablet',
                              'PC Parts',
                              'Accessory'
                            ]
                                .map((category) => DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              _productData['category'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          ),
                          // Quantity In Stock
                          TextFormField(
                            controller: _quantityController,
                            decoration:
                                InputDecoration(labelText: 'Quantity In Stock'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the quantity';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _productData['quantityInStock'] =
                                  int.tryParse(value ?? '0') ?? 0;
                            },
                          ),
                          // Price
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(labelText: 'Price'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the price';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _productData['price'] =
                                  double.tryParse(value ?? '0') ?? 0;
                            },
                          ),
                          // Supplier Dropdown
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(labelText: 'Supplier'),
                            items: _suppliers
                                .map((supplier) => DropdownMenuItem<String>(
                                      value: supplier['id'],
                                      child: Text(supplier['name']),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSupplierId = value;
                                _productData['supplier'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a supplier';
                              }
                              return null;
                            },
                          ),
                          // Other Fields (Category, Warranty Period, Specifications)
                          // (Same as your existing code for other fields like category, warranty, specifications etc.)

                          // Warranty Period
                          TextFormField(
                            controller: _warrantyController,
                            decoration:
                                InputDecoration(labelText: 'Warranty Period'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the warranty period';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _productData['warrantyPeriod'] =
                                  int.tryParse(value ?? '0') ?? 0;
                            },
                          ),

                          // Specifications
                          // Specifications fields

                          // Processor
                          TextFormField(
                            controller: _processorController,
                            decoration: InputDecoration(labelText: 'Processor'),
                            onSaved: (value) {
                              _productData['specifications']['processor'] =
                                  value;
                            },
                          ),

                          // RAM

                          TextFormField(
                            controller: _ramController,
                            decoration: InputDecoration(labelText: 'RAM'),
                            onSaved: (value) {
                              _productData['specifications']['ram'] = value;
                            },
                          ),

                          // Storage

                          TextFormField(
                            controller: _storageController,
                            decoration: InputDecoration(labelText: 'Storage'),
                            onSaved: (value) {
                              _productData['specifications']['storage'] = value;
                            },
                          ),

                          // Display Size

                          TextFormField(
                            controller: _displaySizeController,
                            decoration:
                                InputDecoration(labelText: 'Display Size'),
                            onSaved: (value) {
                              _productData['specifications']['displaySize'] =
                                  value;
                            },
                          ),

                          // OS

                          TextFormField(
                            controller: _osController,
                            decoration: InputDecoration(labelText: 'OS'),
                            onSaved: (value) {
                              _productData['specifications']['os'] = value;
                            },
                          ),

                          // Color

                          TextFormField(
                            controller: _colorController,
                            decoration: InputDecoration(labelText: 'Color'),
                            onSaved: (value) {
                              _productData['specifications']['color'] = value;
                            },
                          ),

                          // Resolution

                          TextFormField(
                            controller: _resolutionController,
                            decoration:
                                InputDecoration(labelText: 'Resolution'),
                            onSaved: (value) {
                              _productData['specifications']['resolution'] =
                                  value;
                            },
                          ),

                          // Camera

                          TextFormField(
                            controller: _cameraController,
                            decoration: InputDecoration(labelText: 'Camera'),
                            onSaved: (value) {
                              _productData['specifications']['camera'] = value;
                            },
                          ),

                          const SizedBox(height: 20),

                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _pickImages,
                            child: Text('Pick Images (1-5)'),
                          ),
                          if (_images.isNotEmpty)
                            GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                              ),
                              itemCount: _images.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Image.file(_images[index],
                                        fit: BoxFit.cover),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _removeImage(index),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          SizedBox(height: 20),
                          BlocBuilder<ProductCubit, ProductState>(
                            builder: (context, state) {
                              return CustomButton(
                                isLoading: false,
                                textColor: Colors.white,
                                width: double.infinity,
                                height: 50,
                                text: 'Add Product',
                                bgColor: Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _formKey.currentState?.save();
                                    // Send API request to add the product
                                    context.read<ProductCubit>().addProduct(
                                        _productData, _images, context);
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
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
