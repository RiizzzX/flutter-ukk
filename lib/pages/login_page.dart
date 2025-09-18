import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      var dio = Dio();
      var res = await dio.post("http://10.0.2.2:8000/api/login", data: {
        "username": _userC.text,
        "password": _passC.text,
      });
      var data = res.data;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('username', data['user']['username'] ?? '');
      await prefs.setString('role', data['user']['role'] ?? '');
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } on DioException catch (e) {
      setState(() { _error = e.response?.data['message'] ?? e.response?.data ?? 'Login gagal'; });
    } finally { setState(() { _loading = false; }); }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: Column(
              children: [
                CircleAvatar(radius: 36, backgroundColor: Colors.purple[100], child: Icon(Icons.person, size: 36, color: Colors.purple[700])),
                const SizedBox(height: 10),
                Text('Login Sarpras', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple[700])),
                const SizedBox(height: 16),
                if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                TextField(controller: _userC, decoration: const InputDecoration(labelText: 'Username')),
                const SizedBox(height: 10),
                TextField(controller: _passC, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _loading?null:_login, child: _loading?const CircularProgressIndicator(color: Colors.white):const Text('Login'), style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700])),
                ),
                TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/register'), child: const Text('Belum punya akun? Daftar'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
