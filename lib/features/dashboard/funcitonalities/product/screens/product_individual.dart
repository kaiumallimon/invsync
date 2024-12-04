import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  ProductDetailsPage({required this.productId});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<Product> product;

  @override
  void initState() {
    super.initState();
    product = fetchProductDetails(widget.productId);
  }

  Future<Product> fetchProductDetails(String productId) async {
    final response = await http.get(Uri.parse(
        'https://invsync.bcrypt.website/inventory/product/get/$productId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> productData = json.decode(response.body);

      print(productData['product']);

      return Product.fromJson(productData['product']);
    } else {
      throw Exception('Failed to load product');
    }
  }

  @override
  Widget build(BuildContext context) {
    //get theme
    final theme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 60,
              color: theme.surface,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Product Details',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<Product>(
                future: product,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No data available.'));
                  } else {
                    Product product = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      child: Center(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Handle images
                              if (product.images.isEmpty)
                                SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: Placeholder(
                                    color: Colors.grey,
                                    fallbackHeight: 200,
                                    fallbackWidth: double.infinity,
                                  ),
                                )
                              else
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: theme.primary)),
                                  width: double.infinity,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: product.images.length,
                                    itemBuilder: (context, index) {
                                      String imageUrl = product.images[index];
                                      return Container(
                                        padding:
                                            const EdgeInsets.only(right: 20.0),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.fitHeight,
                                          height: 300,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              70, // Set the width for each image
                                          progressIndicatorBuilder:
                                              (context, url, progress) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: progress.progress,
                                              ),
                                            );
                                          },
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.primary),
                                ),
                                child: ListTile(
                                  tileColor: theme.primary.withOpacity(.1),
                                  title: Text(product.name,
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.primary),
                                ),
                                child: ListTile(
                                  tileColor: theme.primary.withOpacity(.1),
                                  title: Text('SKU:',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(product.sku,
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              const SizedBox(height: 8),

                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.primary),
                                ),
                                child: ListTile(
                                  tileColor: theme.primary.withOpacity(.1),
                                  title: Text('Category:',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(product.category,
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              const SizedBox(height: 8),

                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.primary),
                                ),
                                child: ListTile(
                                  tileColor: theme.primary.withOpacity(.1),
                                  title: Text('Brand:',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(product.brand,
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              const SizedBox(height: 8),

                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.primary),
                                ),
                                child: ListTile(
                                  tileColor: theme.primary.withOpacity(.1),
                                  title: Text('Price:',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text('\$${product.price}',
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.primary),
                                ),
                                child: ListTile(
                                  tileColor: theme.primary.withOpacity(.1),
                                  title: Text('Quantity in Stock:',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text('${product.quantityInStock}',
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ),

                              const SizedBox(height: 8),

                              if (product.supplier.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primary),
                                  ),
                                  child: ListTile(
                                    tileColor: theme.primary.withOpacity(.1),
                                    title: Text('Supplier:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(product.supplier,
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),

                              const SizedBox(height: 8),

                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.primary),
                                ),
                                child: ListTile(
                                  tileColor: theme.primary.withOpacity(.1),
                                  title: Text('Condition:',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(product.condition,
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Display specifications

                              if (product.specifications.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primary),
                                  ),
                                  child: ListTile(
                                    tileColor: theme.primary.withOpacity(.1),
                                    title: Text('Specifications',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),

                              const SizedBox(height: 8),

                              if (product.specifications['processor'] != null &&
                                  product
                                      .specifications['processor'].isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primary),
                                  ),
                                  child: ListTile(
                                    tileColor: theme.primary.withOpacity(.1),
                                    title: Text('Processor:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        product.specifications['processor'],
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),

                              const SizedBox(height: 8),
                              if (product.specifications['ram'] != null &&
                                  product.specifications['ram'].isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primary),
                                  ),
                                  child: ListTile(
                                    tileColor: theme.primary.withOpacity(.1),
                                    title: Text('RAM:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        product.specifications['ram'],
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),

                              const SizedBox(height: 8),
                              if (product.specifications['storage'] != null &&
                                  product.specifications['storage'].isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primary),
                                  ),
                                  child: ListTile(
                                    tileColor: theme.primary.withOpacity(.1),
                                    title: Text('Storage:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        product.specifications['storage'],
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (product.specifications['displaySize'] !=
                                      null &&
                                  product
                                      .specifications['displaySize'].isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primary),
                                  ),
                                  child: ListTile(
                                    tileColor: theme.primary.withOpacity(.1),
                                    title: Text('Display Size:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        product.specifications['displaySize'],
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (product.specifications['operatingSystem'] !=
                                      null &&
                                  product.specifications['operatingSystem']
                                      .isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primary),
                                  ),
                                  child: ListTile(
                                    tileColor: theme.primary.withOpacity(.1),
                                    title: Text('Operating System:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        product
                                            .specifications['operatingSystem'],
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (product.specifications['color'] != null &&
                                  product.specifications['color'].isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primary),
                                  ),
                                  child: ListTile(
                                    tileColor: theme.primary.withOpacity(.1),
                                    title: Text('Color:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        product.specifications['color'],
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (product.specifications['camera'] != null &&
                                  product.specifications['camera'].isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primary),
                                  ),
                                  child: ListTile(
                                    tileColor: theme.primary.withOpacity(.1),
                                    title: Text('Camera:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        product.specifications['camera'],
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String category;
  final String brand;
  final String sku;
  final int quantityInStock;
  final double price;
  final String supplier;
  final String condition;
  final Map<String, dynamic> specifications;
  final List<String> images;

  Product({
    required this.name,
    required this.category,
    required this.brand,
    required this.sku,
    required this.quantityInStock,
    required this.price,
    required this.supplier,
    required this.condition,
    required this.specifications,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '', // Handle null and provide a default value
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      sku: json['sku'] ?? '',
      quantityInStock: json['quantityInStock'] ?? 0,
      price: (json['price'] ?? 0).toDouble(), // Ensure price is a double
      supplier: json['supplier'] ?? '', // Assuming supplier can be empty
      condition: json['condition'] ?? 'New', // Default to 'New' if null
      specifications:
          json['specifications'] ?? {}, // Default to an empty object if null
      images: List<String>.from(
          json['images'] ?? []), // Default to an empty list if null
    );
  }
}
