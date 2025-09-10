import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gopumplog/IT/homepage.dart';
import 'package:gopumplog/ME/homepage.dart';
import 'package:gopumplog/Manager/homepage.dart';
import 'package:gopumplog/authentication/register.dart';
import 'package:gopumplog/pages/homepage.dart';
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
          title: const Text(
            'Login Error',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
          content: Text(error),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6600)),
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
      return;
    }

    // Role-based navigation
    if (_loginEmail == "megoil@gmail.com" && _loginPassword == "goilme") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomepageME()));
    } else if (_loginEmail == "admingoil@gmail.com" && _loginPassword == "goiladmin") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage()));
    } else if (_loginEmail == "itgoil@gmail.com" && _loginPassword == "goilit") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage()));
    } else if (_loginEmail == "managergoil@gmail.com" && _loginPassword == "goilmanager") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomepageManager()));
    } else {
      _alertDialogBuilder("Invalid credentials for any role.");
    }

    setState(() => _loginFormLoading = false);
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
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.local_gas_station,
                        size: 20.w, color: Color(0xFFFF6600)),
                    SizedBox(height: 2.h),
                    Text(
                      'GOIL Log In',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6600),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Access your GOIL account',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),

                    // Email
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomInput(
                        hintText: 'Email Address',
                        onChanged: (value) => _loginEmail = value,
                        textInputAction: TextInputAction.next,
                        isPasswordField: false,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocusNode),
                        focusNode: _emailFocusNode,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Password
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomInput(
                        hintText: 'Password',
                        onChanged: (value) => _loginPassword = value,
                        isPasswordField: true,
                        focusNode: _passwordFocusNode,
                        onSubmitted: (_) => _submitForm(),
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Login Button
                    GestureDetector(
                      onTap: _submitForm,
                      child: CustomBtn(
                        text: 'Login',
                        outlineBtn: false,
                        isLoading: _loginFormLoading,
                        color: Color(0xFFFF6600),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Create Account
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
                        color: Color(0xFFFF6600),
                      ),
                    ),

                    SizedBox(height: 3.h),
                    Text(
                      'Forgot your password?',
                      style: TextStyle(
                        color: Color(0xFFFF6600),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
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
