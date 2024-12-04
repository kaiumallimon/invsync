import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invsync/features/dashboard/funcitonalities/product/screens/product_individual.dart';
import '../cubit/product_search_cubit.dart';

// ProductCubit and ProductState should be defined similarly to the SupplierCubit.
class ProductSearchScreen extends StatefulWidget {
  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Function to show delete confirmation dialog
  void _showDeleteDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this product?'),
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
                context.read<ProductCubit2>().deleteProduct(productId);
                Navigator.of(context).pop(); // Close the dialog

                // Show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product deleted successfully!')),
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
                  Text('Search Products',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by Name, Category, or Brand',
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) {
                  if (query.isNotEmpty) {
                    context.read<ProductCubit2>().searchProducts(query);
                  }
                },
              ),
              SizedBox(height: 20),
              BlocBuilder<ProductCubit2, Product2State>(
                builder: (context, state) {
                  if (state is Product2Loading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  print(state);

                  if (state is Product2Error) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  if (state is ProductLoaded) {
                    if (state.products.isEmpty) {
                      return Center(child: Text('No products found.'));
                    }

                    return Expanded(
                      child: Column(
                        children: [
                          Text('Found ${state.products.length} products'),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.products.length,
                              itemBuilder: (context, index) {
                                final product = state.products[index];
                                return GestureDetector(
                                    onLongPress: () {
                                      // Show delete confirmation dialog
                                      _showDeleteDialog(context, product.id);
                                    },
                                    onTap: () {
                                      // Navigate to product details screen
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetailsPage(
                                                      productId: product.id)));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: product.images![0],
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'Category: ${product.category}',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'Brand: ${product.brand}',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ));
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Center(child: Text('Start searching for products.'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
