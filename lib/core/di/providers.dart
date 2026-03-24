import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../router/app_router.dart';


/// Single app router instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = AppRouter.createRouter(ref);
  ref.listen(authStateProvider, (previous, next) {
    router.refresh();
  });
  return router;
});

/// Firebase instances (for optional override in tests).
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);
