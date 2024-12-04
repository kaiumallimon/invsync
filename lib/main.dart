import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invsync/features/auth/login/screens/login.dart';
import 'package:invsync/features/dashboard/funcitonalities/product/cubit/product_cubit.dart';
import 'package:invsync/features/dashboard/funcitonalities/suppliers/suppliers_screen/supplier_add.dart';
import 'package:invsync/features/dashboard/funcitonalities/suppliers/suppliers_screen/supplier_search.dart';
import 'package:invsync/features/dashboard/navigation/cubits/navigation_cubit.dart';

import 'common/themes/theme.dart';
import 'features/dashboard/funcitonalities/product/cubit/product_search_cubit.dart';
import 'features/dashboard/funcitonalities/product/screens/product_add.dart';
import 'features/dashboard/funcitonalities/suppliers/cubits/search_cubit.dart';
import 'features/dashboard/wrapper/screen/dashboard_wrapper.dart';
import 'features/startup/splash/screens/splash.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive box
  await Hive.openBox('user');

  runApp(const InvSyncApp());
}

class InvSyncApp extends StatelessWidget {
  const InvSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(create: (context) => NavigationCubit()),
        BlocProvider<SupplierCubit>(create: (context) => SupplierCubit()),
        BlocProvider<ProductCubit>(create: (context) => ProductCubit()),
        BlocProvider<ProductCubit2>(create: (context) => ProductCubit2()),
      ],
      child: MaterialApp(
        title: 'InvSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().getTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => const DashboardWrapperScreen(),
          '/supplier_add': (context) => AddSupplierScreen(),
          '/supplier_search': (context) => SupplierSearchScreen(),
          '/product_add': (context) => ProductFormPage(),
        },
      ),
    );
  }
}
