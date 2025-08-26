import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/model/role.dart';
import 'package:todo_simple/provider/auth_provider.dart';
import 'package:todo_simple/utils/colors.dart';
import 'package:todo_simple/widgets/custom_button.dart';
import 'package:todo_simple/widgets/custom_text_field.dart';

class Auth extends ConsumerStatefulWidget {
  const Auth({super.key});

  @override
  ConsumerState<Auth> createState() => _AuthState();
}

class _AuthState extends ConsumerState<Auth> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool isLogin = true;
  UserRole selectedRole = UserRole.employee;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authViewModelProvider);
    final authVM = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400), // keeps it neat
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// 🔹 Logo
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.task_alt,
                      size: 40,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 🔹 Title
                  Text(
                    isLogin ? "Welcome Back 👋" : "Create Your Account",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin
                        ? "Login to continue your journey"
                        : "Sign up to get started",
                    style: TextStyle(fontSize: 14, color: AppColors.grey600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (!isLogin) ...[
                    CustomFormField(
                      keyboardType: TextInputType.name,
                      controller: nameController,
                      hintText: 'Full Name',
                      validator: (p0) {
                        if (p0 == null || p0.isEmpty) {
                          return 'Plase Enter the Full Name';
                        }
                        return null;
                      },
                    ),
                  ],
                  SizedBox(height: 16.0),

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

                  /// 🔹 Role Selection (Signup only)
                  // if (!isLogin) ...[
                  //   Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Text(
                  //       "Register as",
                  //       style: TextStyle(
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.w600,
                  //         color: Colors.grey[800],
                  //       ),
                  //     ),
                  //   ),
                  //   const SizedBox(height: 8),
                  //   Wrap(
                  //     spacing: 12,
                  //     children: [
                  //       ChoiceChip(
                  //         label: const Text("Employee"),
                  //         selected: selectedRole == UserRole.employee,
                  //         onSelected: (_) {
                  //           setState(() => selectedRole = UserRole.employee);
                  //         },
                  //       ),
                  //       ChoiceChip(
                  //         label: const Text("Manager"),
                  //         selected: selectedRole == UserRole.manager,
                  //         onSelected: (_) {
                  //           setState(() => selectedRole = UserRole.manager);
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  //   const SizedBox(height: 16),
                  // ],

                  /// 🔹 Main Button
                  CustomButton(
                    width: double.infinity,
                    text: isLoading
                        ? 'Loading...'
                        : (isLogin ? 'Login' : 'Sign Up'),
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              if (isLogin) {
                                await authVM.signIn(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
                              } else {
                                await authVM.signUp(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                  nameController.text,
                                  UserRole.employee,
                                );
                              }
                            }
                          },
                    borderRadius: 10,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                  ),
                  const SizedBox(height: 16),

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
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
