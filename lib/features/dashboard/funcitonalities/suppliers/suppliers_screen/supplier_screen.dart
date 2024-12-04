import 'package:flutter/material.dart';
import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  _SupplierScreenState createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final apiService = ApiService();
  List<Supplier> suppliers = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSuppliers();
  }

  // Fetch the suppliers data
  Future<void> fetchSuppliers() async {
    if (isLoading || currentPage > totalPages) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await apiService.fetchSuppliers(currentPage, 10);
      setState(() {
        suppliers.addAll(result['suppliers']);
        totalPages = result['totalPages'];
        currentPage++;
      });
    } catch (error) {
      // Handle error
      print("Error fetching suppliers: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to delete the supplier
  Future<void> deleteSupplier(String id) async {
    try {
      await apiService.deleteSupplier(id);
      setState(() {
        suppliers.removeWhere((supplier) => supplier.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Supplier deleted successfully!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting supplier: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Function to detect when to load more data
  void _onScroll() {
    if (isLoading || currentPage > totalPages) return;
    final scrollController = ScrollController();
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      fetchSuppliers();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the theme
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suppliers',
                style: TextStyle(fontSize: 20, color: theme.primary),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      suppliers.clear();
                      currentPage = 1;
                      fetchSuppliers();
                    });
                  },
                  icon: Icon(Icons.refresh, color: theme.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/supplier_add');
                  },
                  minTileHeight: 100,
                  tileColor: theme.primary,
                  leading: Icon(Icons.add, color: theme.onPrimary),
                  title: Text('Register a New Supplier',
                      style: TextStyle(color: theme.onPrimary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/supplier_search');
                  },
                  minTileHeight: 100,
                  tileColor: theme.secondary,
                  textColor: theme.primary,
                  leading: Icon(Icons.search, color: theme.onSurface),
                  title: Text('Search Suppliers',
                      style: TextStyle(color: theme.onSurface)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Showing ${suppliers.length} Suppliers',
              style: TextStyle(color: theme.onSurface)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount:
                  suppliers.length + 1, // Add +1 for the 'Load More' button
              padding: const EdgeInsets.symmetric(vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index == suppliers.length) {
                  // Show loading indicator when fetching more suppliers
                  return isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TextButton(
                          onPressed: fetchSuppliers,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Load more', style: TextStyle(fontSize: 15)),
                            ],
                          ),
                        );
                }

                final supplier = suppliers[index];
                return GestureDetector(
                  onLongPress: () {
                    _showDeleteDialog(supplier.id);
                  },
                  child: ExpansionTile(
                    collapsedBackgroundColor: theme.secondary,
                    backgroundColor: theme.primary,
                    leading: Icon(Icons.business, color: theme.onPrimary),
                    title: Text(supplier.name,
                        style: TextStyle(color: theme.onPrimary)),
                    subtitle: Text(supplier.contactPerson,
                        style: TextStyle(color: theme.onSecondary)),
                    children: [
                      ListTile(
                        title: Text('Email: ${supplier.contactEmail}',
                            style: TextStyle(color: theme.onPrimary)),
                      ),
                      ListTile(
                        title: Text('Phone: ${supplier.contactPhone}',
                            style: TextStyle(color: theme.onPrimary)),
                      ),
                      ListTile(
                        title: Text('Address: ${supplier.address}',
                            style: TextStyle(color: theme.onPrimary)),
                      ),
                      ListTile(
                        title: Text('Website: ${supplier.website}',
                            style: TextStyle(color: theme.onPrimary)),
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

  // Function to show delete confirmation dialog
  void _showDeleteDialog(String supplierId) {
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
                deleteSupplier(supplierId); // Delete the supplier
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
