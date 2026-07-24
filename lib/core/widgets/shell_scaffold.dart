import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/inventory/widgets/hotbar_nav.dart';
import '../theme/minecraft_theme.dart';

/// Hosts the persistent hotbar navigation around the inventory / info tabs.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  static const _tabPaths = ['/inventory', '/info'];

  int _indexFor(String location) {
    for (var i = 0; i < _tabPaths.length; i++) {
      if (location.startsWith(_tabPaths[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _indexFor(location);
    return Scaffold(
      backgroundColor: context.mc.voidDark,
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: SafeArea(
        top: false,
        child: HotbarNav(
          currentIndex: index,
          onSelect: (i) => context.go(_tabPaths[i]),
          onAdd: () => context.push('/add'),
        ),
      ),
    );
  }
}
