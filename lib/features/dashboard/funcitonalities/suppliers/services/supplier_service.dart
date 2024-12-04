import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supplier_model.dart';

class ApiService {
  static const String baseUrl = "https://invsync.bcrypt.website/inventory";

  Future<Map<String, dynamic>> fetchSuppliers(int page, int limit) async {
    final url = Uri.parse('$baseUrl/supplier/get/all?page=$page&limit=$limit');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Supplier> suppliers = (data['suppliers'] as List)
          .map((supplierJson) => Supplier.fromJson(supplierJson))
          .toList();
      return {
        'suppliers': suppliers,
        'totalPages': data['totalPages'],
      };
    } else {
      throw Exception('Failed to load suppliers: ${response.statusCode}');
    }
  }

  Future<List<Supplier>> searchSuppliers(String query) async {
    const String searchUrl =
        'https://invsync.bcrypt.website/inventory/supplier/search';
    final response = await http.get(Uri.parse('$searchUrl?q=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['suppliers'];
      return data.map((supplier) => Supplier.fromJson(supplier)).toList();
    } else {
      throw Exception("Failed to load suppliers");
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    const String apiUrl =
        'https://invsync.bcrypt.website/inventory/supplier/add';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': supplier.name,
        'contactPerson': supplier.contactPerson,
        'contactEmail': supplier.contactEmail,
        'contactPhone': supplier.contactPhone,
        'address': supplier.address,
        'website': supplier.website,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add supplier");
    }
  }


  // Delete supplier function using DELETE method
  Future<void> deleteSupplier(String id) async {
    final String apiUrl =
        'https://invsync.bcrypt.website/inventory/supplier/delete/$id';  // Adjust the endpoint if needed

    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete supplier");
    }
  }
}
