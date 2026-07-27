import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/about_screen.dart';
import '../../features/add_item/add_edit_item_screen.dart';
import '../../features/box_link/box_link_screen.dart';
import '../../features/create_box/creation_wizard_screen.dart';
import '../../features/find/find_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/item_detail/item_detail_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings_global/global_settings_screen.dart';
import '../widgets/block_wipe_transition.dart';
import '../widgets/shell_scaffold.dart';

/// The app router. Home (the world + chest) is the launch screen; the three
/// tabs live inside a shell with the persistent hotbar; add/edit and item
/// detail are pushed above. Navigation between screens uses a Minecraft-style
/// block-wipe transition (blocks covering the screen that disappear
/// column-by-column like chunk loading).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create-box',
        pageBuilder: (context, state) =>
            blockWipePage(const CreationWizardScreen()),
      ),
      // Deep-link entry: printed QR codes / shared links resolve a box by
      // token, numeric id, or name and land in its inventory.
      GoRoute(
        path: '/box/:code',
        builder: (context, state) =>
            BoxLinkScreen(code: state.pathParameters['code'] ?? ''),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/inventory',
            pageBuilder: (context, state) =>
                blockWipePage(const InventoryScreen()),
          ),
          GoRoute(
            path: '/info',
            pageBuilder: (context, state) =>
                blockWipePage(const SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            blockWipePage(const GlobalSettingsScreen()),
      ),
      GoRoute(
        path: '/inventory/item/:id',
        pageBuilder: (context, state) => blockWipePage(
          ItemDetailScreen(
            itemId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ),
      GoRoute(
        path: '/find',
        pageBuilder: (context, state) => blockWipePage(const FindScreen()),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => blockWipePage(const AboutScreen()),
      ),
      GoRoute(
        path: '/add',
        pageBuilder: (context, state) {
          final editId = state.uri.queryParameters['editId'];
          return blockWipePage(
            AddEditItemScreen(
              editItemId: editId == null ? null : int.parse(editId),
            ),
          );
        },
      ),
      // Custom-scheme fallback: for `treasurebox://box/<code>` Android hands
      // the app only the PATH (`/<code>` - "box" is the URI host), so codes
      // arrive as a bare top-level segment. Declared last: every named route
      // above wins first. BoxLinkScreen shows a themed error for junk.
      GoRoute(
        path: '/:code',
        builder: (context, state) =>
            BoxLinkScreen(code: state.pathParameters['code'] ?? ''),
      ),
    ],
  );
});
