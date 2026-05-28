import 'package:flutter/material.dart';

/// Opens the root [ShellRoute] drawer, not a nested [Scaffold] without one.
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  static void openRootDrawer(BuildContext context) {
    ScaffoldState? drawerHost;
    context.visitAncestorElements((element) {
      if (element is StatefulElement && element.state is ScaffoldState) {
        final state = element.state as ScaffoldState;
        if (state.hasDrawer) drawerHost = state;
      }
      return true;
    });
    drawerHost?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      onPressed: () => openRootDrawer(context),
    );
  }
}
