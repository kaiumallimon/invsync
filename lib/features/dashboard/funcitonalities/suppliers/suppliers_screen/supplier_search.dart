import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/search_cubit.dart';

class SupplierSearchScreen extends StatefulWidget {
  @override
  _SupplierSearchScreenState createState() => _SupplierSearchScreenState();
}

class _SupplierSearchScreenState extends State<SupplierSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Function to show delete confirmation dialog
  void _showDeleteDialog(BuildContext context, String supplierId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this supplier?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call the delete function from the cubit
                context.read<SupplierCubit>().deleteSupplier(supplierId);
                Navigator.of(context).pop(); // Close the dialog

                // Show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Supplier deleted successfully!')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text('Search Suppliers',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by Name, Email, or Contact Person',
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) {
                  if (query.isNotEmpty) {
                    context.read<SupplierCubit>().searchSuppliers(query);
                  }
                },
              ),
              SizedBox(height: 20),
              BlocBuilder<SupplierCubit, SupplierState>(
                builder: (context, state) {
                  if (state is SupplierLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (state is SupplierError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  if (state is SupplierLoaded) {
                    if (state.suppliers.isEmpty) {
                      return Center(child: Text('No suppliers found.'));
                    }

                    return Expanded(
                      child: Column(
                        children: [
                          Text('Found ${state.suppliers.length} suppliers'),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.suppliers.length,
                              itemBuilder: (context, index) {
                                final supplier = state.suppliers[index];
                                return GestureDetector(
                                  onLongPress: () {
                                    // Show delete confirmation dialog
                                    _showDeleteDialog(context, supplier.id);
                                  },
                                  child: ExpansionTile(
                                    leading: Icon(
                                      Icons.business,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    title: Text(supplier.name),
                                    children: [
                                      ListTile(
                                        title: Text(
                                            'Email: ${supplier.contactEmail}'),
                                      ),
                                      ListTile(
                                        title: Text(
                                            'Contact Person: ${supplier.contactPerson}'),
                                      ),
                                      ListTile(
                                        title: Text(
                                            'Phone: ${supplier.contactPhone}'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Center(child: Text('Start searching for suppliers.'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
