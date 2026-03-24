import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../features/attendee/data/repositories/attendee_repository.dart';

class PendingUpload {
  final String id;
  final String eventId;
  final String localFilePath;

  PendingUpload({
    required this.id,
    required this.eventId,
    required this.localFilePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'localFilePath': localFilePath,
      };

  factory PendingUpload.fromJson(Map<String, dynamic> json) => PendingUpload(
        id: json['id'],
        eventId: json['eventId'],
        localFilePath: json['localFilePath'],
      );
}

final offlineUploadManagerProvider = NotifierProvider<OfflineUploadManager, List<PendingUpload>>(() {
  return OfflineUploadManager();
});

class OfflineUploadManager extends Notifier<List<PendingUpload>> {
  static const _prefsKey = 'eventshot_pending_uploads';
  bool _isSyncing = false;

  @override
  List<PendingUpload> build() {
    _loadFromPrefs();
    _listenToConnectivity();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_prefsKey) ?? [];
    final loaded = jsonStringList
        .map((s) => PendingUpload.fromJson(json.decode(s)))
        .toList();
    state = loaded;
    if (state.isNotEmpty) {
      _syncQueue();
    }
  }

  Future<void> _saveToPrefs(List<PendingUpload> uploads) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = uploads.map((u) => json.encode(u.toJson())).toList();
    await prefs.setStringList(_prefsKey, jsonStringList);
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        _syncQueue();
      }
    });
  }

  Future<void> enqueue(String eventId, File sourceFile) async {
    final id = const Uuid().v4();
    final ext = sourceFile.path.split('.').last;
    
    // Copy the file to a permanent application directory so the OS cache cleanup doesn't delete it
    final appDir = await getApplicationDocumentsDirectory();
    final localPath = '${appDir.path}/pending_$id.$ext';
    await sourceFile.copy(localPath);

    final job = PendingUpload(
      id: id,
      eventId: eventId,
      localFilePath: localPath,
    );

    state = [...state, job];
    await _saveToPrefs(state);
    
    // Try to sync immediately
    _syncQueue();
  }

  Future<void> _syncQueue() async {
    if (_isSyncing || state.isEmpty) return;

    final connectivityResult = await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.mobile) &&
        !connectivityResult.contains(ConnectivityResult.wifi)) {
      return; // No internet available
    }

    _isSyncing = true;

    try {
      while (state.isNotEmpty) {
        final job = state.first;

        // Ensure the file actually still survives on disk
        final file = File(job.localFilePath);
        if (await file.exists()) {
          // Perform the actual network upload via Repository
          final repo = ref.read(attendeeRepositoryProvider);
          await repo.executeOfflineUpload(job.eventId, file);
          await file.delete();
        }

        // Remove from queue whether it uploaded or the file was missing
        state = state.where((u) => u.id != job.id).toList();
        await _saveToPrefs(state);
      }
    } catch (e) {
      // Sync failed (e.g., connection drop mid-upload, server 500). Wait for next network trigger.
      debugPrint('SyncQueue Error: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
