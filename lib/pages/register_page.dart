import 'package:flutter/material.dart';
import 'package:scooter_form/services/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {
  final Function onTap;
  RegisterPage({super.key, required this.onTap});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  void register(BuildContext context) async {
    //firstly get the auth service
    final _auth = AuthService();

    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        await _auth.signUp(_emailController.text, _passwordController.text,
            _nameController.text);
      } catch (e) {
        showDialog(
            context: context,
            builder: ((context) => AlertDialog(title: Text(e.toString()))));
      }
    } else {
      showDialog(
          context: context,
          builder: ((context) =>
              const AlertDialog(title: Text("Şifreler uyuşmuyor"))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 100),
            const Icon(Icons.app_registration, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Kayıt Ol',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Adınızı giriniz',
                labelText: 'Adınız',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Mail adresinizi giriniz',
                labelText: 'Mail Adresiniz',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Şifre giriniz',
                labelText: 'Şifreniz',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                hintText: 'Şifreyi tekrar giriniz',
                labelText: 'Şifreyi Onaylayın',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => register(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Kayıt Ol', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Zaten hesabınız var mı?"),
                TextButton(
                  onPressed: () => onTap(),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
