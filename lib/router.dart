import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:offnet/data/objectbox.dart';
import 'package:offnet/presentation/home/home.dart';
import 'package:offnet/presentation/signup/signup.dart';
import 'package:offnet/presentation/chat/chat_page.dart'; // Add this import

GoRouter createRouter(ObjectBox objectBox) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Redirect to signup if not authenticated
      if (!objectBox.isAuthenticated() && state.uri.toString() != '/signup') {
        return '/signup';
      }
      // Redirect to home if authenticated and trying to access signup
      if (objectBox.isAuthenticated() && state.uri.toString() == '/signup') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(objectBox: objectBox),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignupPage(objectBox: objectBox),
      ),
      GoRoute(
        path: '/chat/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ChatPage(
            objectBox: objectBox,
            otherUserUniqueId: userId,
          );
        },
      ),
    ],
  );
}
