import 'package:flutter/material.dart';
import 'package:note_taking_app/home.dart';
import 'package:note_taking_app/auth/login.dart';
import 'package:note_taking_app/auth/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Login(),
      '/home': (context) => Home(),
      '/signup': (context) => SignUp(),
    },
  ));
}
