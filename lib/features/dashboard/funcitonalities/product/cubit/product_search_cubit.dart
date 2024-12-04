import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/product_service.dart';

// States
abstract class Product2State {}

class Product2Initial extends Product2State {}

class Product2Loading extends Product2State {}

class Product2Error extends Product2State {
  final String message;
  Product2Error(this.message);
}

class ProductLoaded extends Product2State {
  final List<Product2> products;
  ProductLoaded(this.products);
}

// Cubit
class ProductCubit2 extends Cubit<Product2State> {
  ProductCubit2() : super(Product2Initial());

  // Function to search products
  Future<void> searchProducts(String query) async {
    emit(Product2Loading());
    try {
      // Fetch data from the API (you can replace this with your actual API call)
      final response = await ProductService()
          .searchProducts(query); // Replace with actual API call
      emit(ProductLoaded(response));
    } catch (e) {
      emit(Product2Error('Failed to load products: $e'));
    }
  }

  // Function to delete product
  Future<void> deleteProduct(String productId) async {
    try {
      // Call your API to delete the product
      await ProductService()
          .deleteProduct(productId); // Replace with actual API call
      // After deletion, you might want to refetch the products
    } catch (e) {
      emit(Product2Error('Failed to delete product'));
    }
  }
}
