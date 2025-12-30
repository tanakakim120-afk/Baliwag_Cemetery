import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyD_ltzwUEyG7aLbCH6ifP3msmiyf2f2KtA",
            authDomain: "tomb-nav-30luyb.firebaseapp.com",
            projectId: "tomb-nav-30luyb",
            storageBucket: "tomb-nav-30luyb.firebasestorage.app",
            messagingSenderId: "881264200419",
            appId: "1:881264200419:web:a1e7842bb1c471ecb013d6"));
  } else {
    await Firebase.initializeApp();
  }
}
