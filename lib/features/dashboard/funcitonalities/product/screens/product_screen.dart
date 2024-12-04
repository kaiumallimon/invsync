import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:invsync/features/dashboard/funcitonalities/product/screens/all_products.dart';
import 'package:invsync/features/dashboard/funcitonalities/product/screens/product_individual.dart';
import 'package:invsync/features/dashboard/funcitonalities/product/services/product_service.dart';

import 'product_search.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<Map<String, dynamic>> _productAnalyticsFuture;
  late Future<List<dynamic>> _recentProductsFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
    _fetchRecentProducts();
  }

  // Function to fetch data
  Future<void> _fetchData() async {
    setState(() {
      _productAnalyticsFuture = ProductService().fetchProductAnalytics();
    });
  }

  // Function to fetch recent products
  Future<void> _fetchRecentProducts() async {
    setState(() {
      _recentProductsFuture = ProductService().fetchRecentProducts();
    });
  }

  final Map<String, dynamic> menuItems = {
    'Add Product': Icons.add,
    'Search Products': Icons.search,
    'View Products': Icons.view_list,
    'Update Product': Icons.edit,
  };

  // Refresh function to be called when pull-to-refresh is triggered
  Future<void> _onRefresh() async {
    await _fetchData();
    await _fetchRecentProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: RefreshIndicator(
        onRefresh: _onRefresh, // Trigger the refresh
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Text(
              'Products',
              style: TextStyle(
                fontSize: 20,
                color: theme.primary,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>>(
              future: _productAnalyticsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('No data available'));
                }

                final Map<String, dynamic> data = snapshot.data!;
                final totalProducts = data['totalProducts'] ?? 0;
                final totalValue = data['totalValue'] ?? 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(2, (index) {
                        return Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.only(right: index == 0 ? 10 : 0),
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: theme.primary.withOpacity(.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        index == 0
                                            ? 'Total Products'
                                            : 'Inventory Value',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: Text(
                                        index == 0
                                            ? '$totalProducts'
                                            : '\$$totalValue',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: theme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 120,
                      ),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final String title = menuItems.keys.elementAt(index);
                        final IconData icon = menuItems.values.elementAt(index);

                        return GestureDetector(
                          onTap: () {
                            if (index == 0) {
                              // Add Product
                              Navigator.pushNamed(context, '/product_add')
                                  .then((_) {
                                // Refresh after returning from Add Product screen
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  setState(() {
                                    _fetchData();
                                    _fetchRecentProducts();
                                  });
                                });
                              });
                            } else if (index == 1) {
                              // Search Products
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductSearchScreen(),
                                ),
                              );
                            } else if (index == 2) {
                              // View Products
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllProductsScreen(),
                                ),
                              );
                            } else if (index == 3) {
                              // Update Product
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Feature not implemented yet'),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: index == 0 || index == 3
                                  ? CupertinoColors.activeBlue
                                  : theme.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(icon, color: theme.onPrimary),
                                  const SizedBox(height: 10),
                                  Text(title,
                                      style: TextStyle(color: theme.onPrimary)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            // Recent Products
            const SizedBox(height: 20),

            Text(
              'Recently added Products',
              style: TextStyle(
                fontSize: 20,
                color: theme.primary,
              ),
            ),

            const SizedBox(height: 10),

            FutureBuilder<List<dynamic>>(
              future: _recentProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('No data available'));
                }

                final List<dynamic> productsList = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productsList.length,
                  itemBuilder: (context, index) {
                    final product = productsList[index];
                    final name = product['name'] ?? 'Unknown';
                    final price = product['price'] ?? 0.0;
                    // Get the first image if available
                    final image = product['images']?.isNotEmpty ?? false
                        ? product['images'][0]
                        : null;

                    final String dateAdded = product['dateAdded'] ?? 'Unknown';

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.primary.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        splashColor: Colors.transparent,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: image != null && image.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: image,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: theme.surface,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          color: theme.onSurface,
                                        ),
                                      ),
                                    );
                                  },
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 50,
                                    height: 50,
                                    color: theme.surface,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: theme.onSurface,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: theme.surface,
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      color: theme.onSurface,
                                    ),
                                  ),
                                ),
                        ),
                        title: Text(
                          name,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.primary,
                          ),
                        ),
                        subtitle: Text('\$$price',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.onSurface.withOpacity(.5),
                            )),
                        onTap: () {
                          // Handle product tap, e.g., navigate to product details screen

                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(
                                    productId: product['_id'])),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
