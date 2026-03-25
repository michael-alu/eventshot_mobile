import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_storage_keys.dart';
import '../../../core/router/app_router.dart';

class LeaveEventDialog {
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Event?'),
        content: const Text(
          'To access and download these images later, you need an account.\n\n'
          'Would you like to create one now, or leave anonymously?',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove(AppStorageKeys.lastEventId);
              if (ctx.mounted) ctx.pop();
              if (context.mounted) context.go(AppRouter.welcome);
            },
            child: const Text('Leave Anonymously'),
          ),
          FilledButton(
            onPressed: () {
              if (ctx.mounted) ctx.pop();
              if (context.mounted) context.push(AppRouter.attendeeSignUp);
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }
}
