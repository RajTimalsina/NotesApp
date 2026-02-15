import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  final supabase = Supabase.instance.client;

  void login() async {
    setState(() {
      loading = true;
    });
    try {
      final result = await supabase.auth.signInWithPassword(
          email: _emailController.text, password: _passwordController.text);
      if (result.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An unexpected error occurred.'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void continueWithGoogle() async {
    setState(() {
      loading = true;
    });
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['WEB_CLIENT']!,
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in. The `finally` block will handle turning off the loading indicator.
        return;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error signing in with Google: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email address',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              if (loading)
                const CircularProgressIndicator()
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          login();
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        continueWithGoogle();
                      },
                      child: const Text(
                        'Login with GOOGLE',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text('Don\'t have an account? Sign up'),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
