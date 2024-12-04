import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invsync/common/widgets/custom_button.dart';

import '../cubits/search_cubit.dart';
import '../models/supplier_model.dart';

class AddSupplierScreen extends StatefulWidget {
  @override
  _AddSupplierScreenState createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text('Add Supplier',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary)),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocConsumer<SupplierCubit, SupplierState>(
                  listener: (context, state) {
                    if (state is SupplierAdded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Supplier added successfully!')),
                      );
                      // You can navigate to another page or clear the form here.
                      Navigator.pop(context);
                    }

                    if (state is SupplierError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${state.message}')),
                      );
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      // Wrap the form with SingleChildScrollView
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(labelText: 'Name'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter supplier name';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _contactPersonController,
                              decoration:
                                  InputDecoration(labelText: 'Contact Person'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter contact person';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _contactEmailController,
                              decoration:
                                  InputDecoration(labelText: 'Contact Email'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter contact email';
                                } else if (!RegExp(r'\S+@\S+\.\S+')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _contactPhoneController,
                              decoration:
                                  InputDecoration(labelText: 'Contact Phone'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter contact phone';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(labelText: 'Address'),
                            ),
                            TextFormField(
                              controller: _websiteController,
                              decoration: InputDecoration(labelText: 'Website'),
                            ),
                            const SizedBox(height: 20),
                            state is SupplierLoading
                                ? const CircularProgressIndicator()
                                : CustomButton(
                                    width: 300,
                                    height: 50,
                                    text: "Register Supplier",
                                    bgColor:
                                        Theme.of(context).colorScheme.primary,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        // Create a new Supplier object
                                        final newSupplier = Supplier(
                                          id: '',
                                          name: _nameController.text,
                                          contactPerson:
                                              _contactPersonController.text,
                                          contactEmail:
                                              _contactEmailController.text,
                                          contactPhone:
                                              _contactPhoneController.text,
                                          address: _addressController.text,
                                          website: _websiteController.text,
                                        );
                                        // Call the Cubit to add the supplier
                                        context
                                            .read<SupplierCubit>()
                                            .addSupplier(newSupplier);
                                      }
                                    },
                                    isLoading: false)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
