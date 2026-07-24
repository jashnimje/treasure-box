import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/drift_inventory_repository.dart';
import '../data/repositories/inventory_repository.dart';
import 'database_providers.dart';

/// The inventory repository, backed by Drift. Override in tests to swap the
/// persistence layer.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return DriftInventoryRepository(ref.watch(databaseProvider));
});
