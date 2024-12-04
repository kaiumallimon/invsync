import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invsync/features/dashboard/funcitonalities/log/screens/logs_screen.dart';
import 'package:invsync/features/dashboard/funcitonalities/profile/screens/profile_screen.dart';
import 'package:invsync/features/dashboard/funcitonalities/suppliers/suppliers_screen/supplier_screen.dart';
import 'package:invsync/features/dashboard/navigation/widgets/custom_navigationbar.dart';

import '../../funcitonalities/product/screens/product_screen.dart';
import '../../navigation/cubits/navigation_cubit.dart';

class DashboardWrapperScreen extends StatelessWidget {
  const DashboardWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // retain status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // get theme
    final theme = Theme.of(context).colorScheme;

    // set status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: theme.surface,
      statusBarIconBrightness: theme.brightness,
      systemNavigationBarColor: theme.surface,
      systemNavigationBarIconBrightness: theme.brightness,
    ));

    return SafeArea(
      child: Scaffold(
        body: BlocBuilder(
          bloc: BlocProvider.of<NavigationCubit>(context),
          builder: (context, state) {
            if (state == 0) {
              return ProductScreen();
            } else if (state == 1) {
              return SupplierScreen();
            } else if (state == 2) {
              return LogScreen();
            } else if (state == 3) {
              return ProfileScreen();
            } else {
              return Container();
            }
          },
        ),
        bottomNavigationBar: CustomNavigationbar(),
      ),
    );
  }
}
