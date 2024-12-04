import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invsync/features/dashboard/funcitonalities/product/screens/product_individual.dart';

class ProductService {
  Future<Map<String, dynamic>> fetchProductAnalytics() async {
    const String url =
        'https://invsync.bcrypt.website/inventory/product/get/analytic';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load product analytics');
    }
  }

  Future<Map<String, dynamic>> fetchProducts(int page, int limit) async {
    const String url =
        'https://invsync.bcrypt.website/inventory/product/get/all';
    final response = await http.get(Uri.parse('$url?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> products = data['products'];
      return {
        'products': products,
        'totalPages': data['totalPages'],
      };
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchRecentProducts() async {
    try {
      final response = await http.get(
          Uri.parse('https://invsync.bcrypt.website/inventory/product/recent'));

      if (response.statusCode == 200) {
        // Decode the JSON response and return the products list

        final data = json.decode(response.body);

        return data['products'];
      } else {
        throw Exception('Failed to load recent products');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  // deleteProduct method

  Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(Uri.parse(
          'https://invsync.bcrypt.website/inventory/product/delete/$productId'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error deleting product: $error');
    }
  }

  Future<List<Product2>> searchProducts(String query) async {
    const String searchUrl =
        'https://invsync.bcrypt.website/inventory/product/search';
    final response = await http.get(Uri.parse('$searchUrl?q=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['products'];

      print(data);
      return data.map((product) => Product2.fromJson(product)).toList();
    } else {
      throw Exception("Failed to load products");
    }
  }
}

class Product2 {
  final String id;
  final String name;
  final String category;
  final String brand;
  final double price;
  final List<String>? images;

  // Add other properties as needed

  Product2({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.price,
    required this.images,
  });

  factory Product2.fromJson(Map<String, dynamic> json) {
    return Product2(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
      brand: json['brand'],
      price: json['price'] * 1.0,
      images: List<String>.from(json['images']),
    );
  }
}
