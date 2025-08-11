import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String _fullName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _phone = '';
  bool _agreed = false;

  bool _obscurePassword = true;
  bool _isLoading = false;

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the terms.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': _fullName,
        'email': _email,
        'phone': _phone,
        'createdAt': Timestamp.now(),
        'uid': userCredential.user!.uid,
        'role': 'Seller', // default for now
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
      String label,
      IconData icon,
      Function(String) onChanged,
      FocusNode focusNode,
      FocusNode? nextFocus, {
        TextInputType inputType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: inputType,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
        textInputAction:
        nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
        },
        validator: (value) =>
        value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildPasswordField({required bool isConfirm}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: _obscurePassword,
        focusNode: isConfirm ? _confirmFocusNode : _passwordFocusNode,
        decoration: InputDecoration(
          labelText: isConfirm ? 'Confirm Password' : 'Password',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) =>
        isConfirm ? _confirmPassword = val : _password = val,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Enter password';
          if (!isConfirm && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          if (isConfirm && value != _password) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Register to Sell Channel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.storefront,
                      size: 60, color: Colors.blueAccent),
                  const SizedBox(height: 12),
                  const Text(
                    "Create Your Seller Account",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fill in your details below to get started",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('Full Name', Icons.person,
                          (val) => _fullName = val, _nameFocusNode, _emailFocusNode),
                  _buildTextField(
                      'Email',
                      Icons.email,
                          (val) => _email = val,
                      _emailFocusNode,
                      _passwordFocusNode,
                      inputType: TextInputType.emailAddress),
                  _buildPasswordField(isConfirm: false),
                  _buildPasswordField(isConfirm: true),
                  _buildTextField(
                      'Phone Number',
                      Icons.phone,
                          (val) => _phone = val,
                      _phoneFocusNode,
                      null,
                      inputType: TextInputType.phone),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text(
                      'I agree to the Terms & Conditions',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: _agreed,
                    onChanged: (val) =>
                        setState(() => _agreed = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Register',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _register,
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
