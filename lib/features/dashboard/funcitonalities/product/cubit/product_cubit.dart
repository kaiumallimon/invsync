import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductSuccess extends ProductState {
  final String message;

  const ProductSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ProductFailure extends ProductState {
  final String message;

  const ProductFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  Future<void> addProduct(Map<String, dynamic> productData, List<File> images,
      BuildContext context) async {
    emit(ProductLoading());

    try {
      var uri =
          Uri.parse('https://invsync.bcrypt.website/inventory/product/add');

      var request = http.MultipartRequest('POST', uri)
        ..headers['Content-Type'] = 'multipart/form-data';

      // Add product details
      productData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add images to the request
      for (var image in images) {
        var mimeType = lookupMimeType(image.path);
        var mimeTypeParts = mimeType?.split('/');
        var imageFile = await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType(
              mimeTypeParts?[0] ?? 'image', mimeTypeParts?[1] ?? 'jpeg'),
        );
        request.files.add(imageFile);
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 201) {
        emit(const ProductSuccess(message: 'Product added successfully!'));
      } else {
        print(json.decode(await response.stream.bytesToString()));
        emit(const ProductFailure(message: 'Failed to add product.'));
      }

      Navigator.of(context).pop();
    } catch (e) {
      emit(ProductFailure(message: e.toString()));
    }
  }
}
