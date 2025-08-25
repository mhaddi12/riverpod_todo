import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/model/role.dart';
import 'package:todo_simple/widgets/custom_button.dart';
import 'package:todo_simple/widgets/custom_text_field.dart';

import '../view_model/auth.dart';

class Auth extends ConsumerStatefulWidget {
  const Auth({super.key});

  @override
  ConsumerState<Auth> createState() => _AuthState();
}

class _AuthState extends ConsumerState<Auth> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  UserRole selectedRole = UserRole.employee; // default

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = ref.watch(authRepositoryProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        isLogin ? "Login" : "Sign Up",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      /// 🔹 Email
                      CustomFormField(
                        hintText: 'Email',
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          } else if (!RegExp(
                            r'^[^@]+@[^@]+\.[^@]+',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      /// 🔹 Password
                      CustomFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        hintText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),

                      /// 🔹 Show role selector only in Sign Up mode
                      if (!isLogin) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Register as:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<UserRole>(
                                title: const Text("Employee"),
                                value: UserRole.employee,
                                groupValue: selectedRole,
                                onChanged: (role) {
                                  setState(() => selectedRole = role!);
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<UserRole>(
                                title: const Text("Manager"),
                                value: UserRole.manager,
                                groupValue: selectedRole,
                                onChanged: (role) {
                                  setState(() => selectedRole = role!);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      /// 🔹 Main button
                      CustomButton(
                        text: isLogin ? 'Login' : 'Sign Up',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (isLogin) {
                              // Login
                              await authRepo.signIn(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            } else {
                              // Sign Up with chosen role
                              await authRepo.signUp(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                                selectedRole,
                              );
                            }
                          }
                        },
                        borderRadius: 30,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// 🔹 Switch login/signup
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: Text(
                          isLogin
                              ? "Don't have an account? Sign Up"
                              : "Already have an account? Login",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
