import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gopumplog/authentication/register.dart';
import 'package:sizer/sizer.dart';
import '../widgets/constant.dart';
import '../widgets/custom button.dart';
import '../widgets/custom input.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Login Error', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(error),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _loginAccount() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _loginEmail,
        password: _loginPassword,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  void _submitForm() async {
    setState(() => _loginFormLoading = true);

    String? _loginFeedback = await _loginAccount();
    if (_loginFeedback != null) {
      _alertDialogBuilder(_loginFeedback);
      setState(() => _loginFormLoading = false);
    }
  }

  bool _loginFormLoading = false;
  String _loginEmail = '';
  String _loginPassword = '';

  late FocusNode _passwordFocusNode;
  late FocusNode _emailFocusNode;

  @override
  void initState() {
    _passwordFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 20.w, color: Colors.black87),
                    SizedBox(height: 2.h),
                    Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: Constants.boldHeading.copyWith(fontSize: 22.sp),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Log in to your account to continue',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),

                    // Email Input
                    CustomInput(
                      hintText: 'Email Address',
                      onChanged: (value) => _loginEmail = value,
                      textInputAction: TextInputAction.next,
                      isPasswordField: false,
                      onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                      focusNode: _emailFocusNode,
                    ),
                    SizedBox(height: 2.h),

                    // Password Input
                    CustomInput(
                      hintText: 'Password',
                      onChanged: (value) => _loginPassword = value,
                      isPasswordField: true,
                      focusNode: _passwordFocusNode,
                      onSubmitted: (_) => _submitForm(),
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 4.h),

                    // Login Button
                    GestureDetector(
                      onTap: _submitForm,
                      child: CustomBtn(
                        text: 'Login',
                        outlineBtn: false,
                        isLoading: _loginFormLoading,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Create Account Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: CustomBtn(
                        text: 'Create New Account',
                        outlineBtn: true,
                        isLoading: false,
                      ),
                    ),

                    SizedBox(height: 3.h),
                    Text(
                      'Forgot your password?',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
