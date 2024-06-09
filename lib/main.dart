import 'package:flutter/material.dart';
import 'package:vihanga_cabs_user_portal/authentication/login_company_manager.dart';
import 'package:vihanga_cabs_user_portal/authentication/user_login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:vihanga_cabs_user_portal/manager_pages/manager_home_page.dart';
import 'package:vihanga_cabs_user_portal/user_pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("API_KEY: ${dotenv.env['API_KEY']}");
  } catch (e) {
    print("Failed to load .env file: $e");
  }

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: dotenv.env['API_KEY']!,
          appId: dotenv.env['APP_ID']!,
          messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
          projectId: dotenv.env['PROJECT_ID']!,
          storageBucket: dotenv.env['STORAGE_BUCKET']!,
          databaseURL: dotenv.env['DATABASE_URL']!,
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Vihanga Cabs - User Web Portal',
      initialRoute: '/',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UserLoginScreen(),
    );
  }
}

