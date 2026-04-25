import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to landscape — primary platform is 10" tablet (spec 01).
  // Skip on web (not applicable).
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Anonymous identity for session writes under /sessions/{uid}/records.
  // Parent email+password login (MVP item #2) will later link to this UID.
  await AuthService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  ).ensureAnonymousChildSession();

  runApp(const ProviderScope(child: DailyLifeApp()));
}

class DailyLifeApp extends StatelessWidget {
  const DailyLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Daily Life',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: buildAppRouter(),
    );
  }
}
