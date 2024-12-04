import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:invsync/features/dashboard/funcitonalities/product/screens/product_individual.dart';
import 'package:invsync/features/dashboard/funcitonalities/product/services/product_service.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<Map<String, dynamic>> products = [];
  int currentPage = 1;
  int totalPages = 1;

  bool isLoading = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    if (isLoading || currentPage > totalPages) return;

    setState(() {
      isLoading = true;
      hasError = false; // Reset error state before fetching
    });

    try {
      final result = await ProductService().fetchProducts(currentPage, 10);

      final List<dynamic> fetchedProducts = result['products'];

      setState(() {
        products.addAll(fetchedProducts
            .map((product) => Map<String, dynamic>.from(product))
            .toList());
        totalPages = result['totalPages'];
        currentPage++;
      });
    } catch (error) {
      setState(() {
        hasError = true;
      });
      print("Error fetching products: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showDeleteDialog(String productId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                // Call the delete function from your service here
                await ProductService().deleteProduct(productId);
                setState(() {
                  products
                      .removeWhere((product) => product['_id'] == productId);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Product deleted successfully')));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: products.isEmpty && !isLoading
          ? Center(
              child: hasError
                  ? Text("Failed to load products")
                  : Text("No products available"))
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent) {
                  fetchProducts(); // Fetch more products when reaching the bottom
                }
                return false;
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        "All Products",
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      itemCount: products.length +
                          (isLoading ? 1 : 0), // Add 1 for loading indicator
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          mainAxisExtent: 265),
                      itemBuilder: (context, index) {
                        if (index == products.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final product = products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(
                                  productId: product['_id'],
                                ),
                              ),
                            );
                          },
                          onLongPress: () {
                            _showDeleteDialog(product['_id']);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.6),
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: (product['images'].isEmpty ||
                                          product['images'][0] == null)
                                      ? Placeholder(
                                          fallbackHeight: 180,
                                          fallbackWidth: double.infinity,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: product['images'][0],
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          progressIndicatorBuilder:
                                              (context, url, progress) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: progress.progress,
                                              ),
                                            );
                                          },
                                          errorWidget: (context, url, error) {
                                            return Icon(Icons.error);
                                          },
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '\$${product['price']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
    );
  }
}
