import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invsync/features/dashboard/funcitonalities/suppliers/services/supplier_service.dart';

import '../models/supplier_model.dart';

class SupplierCubit extends Cubit<SupplierState> {
  SupplierCubit() : super(SupplierInitial());

  final ApiService _supplierService = ApiService();

  Future<void> searchSuppliers(String query) async {
    try {
      emit(SupplierLoading());
      final suppliers = await _supplierService.searchSuppliers(query);
      emit(SupplierLoaded(suppliers: suppliers));
    } catch (error) {
      emit(SupplierError(message: error.toString()));
    }
  }

  // Method to add a new supplier
  Future<void> addSupplier(Supplier supplier) async {
    try {
      emit(SupplierLoading());
      await _supplierService.addSupplier(supplier);
      emit(SupplierAdded());
    } catch (error) {
      emit(SupplierError(message: error.toString()));
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      emit(SupplierLoading());
      await _supplierService.deleteSupplier(id);
      emit(SupplierAdded());
    } catch (error) {
      emit(SupplierError(message: error.toString()));
    }
  }
}

// State classes
abstract class SupplierState {}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierAdded extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<Supplier> suppliers;
  SupplierLoaded({required this.suppliers});
}

class SupplierError extends SupplierState {
  final String message;
  SupplierError({required this.message});
}
