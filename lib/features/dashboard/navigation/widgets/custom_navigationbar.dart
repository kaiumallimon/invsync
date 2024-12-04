import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/navigation_cubit.dart';

class CustomNavigationbar extends StatelessWidget {
  const CustomNavigationbar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme for styling
    final theme = Theme.of(context).colorScheme;

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return NavigationBar(
          surfaceTintColor: theme.primary.withOpacity(.1),
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            // Update the selected index via the Cubit
            BlocProvider.of<NavigationCubit>(context).updateIndex(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Product',
            ),
            NavigationDestination(
              icon: Icon(Icons.handshake_outlined),
              selectedIcon: Icon(Icons.handshake),
              label: 'Supplier',
            ),
            NavigationDestination(
              icon: Icon(Icons.note_outlined),
              selectedIcon: Icon(Icons.note),
              label: 'Logs',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          elevation: 2,
          backgroundColor: theme.surface,
        );
      },
    );
  }
}
