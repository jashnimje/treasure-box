/// Treasure Box - a Minecraft-themed companion app for a real chest.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fullscreen immersive: the game world owns the whole screen. Swiping
  // from an edge peeks the system bars, which then auto-hide again.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ProviderScope(child: TreasureBoxApp()));
}
