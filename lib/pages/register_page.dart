import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _pass2C = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      var dio = Dio();
      var res = await dio.post("http://10.0.2.2:8000/api/register", data: {
        "username": _userC.text,
        "email": _emailC.text,
        "password": _passC.text,
        "password_confirmation": _pass2C.text,
      });
      if (res.statusCode == 201) {
        // auto-navigate to login and maybe pass message
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      }
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data['message'] ?? e.response?.data ?? 'Register failed';
      });
    } finally { setState((){ _loading=false; }); }
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
                const SizedBox(height: 8),
                Text('Daftar Akun', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple[700])),
                const SizedBox(height: 16),
                if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                TextField(controller: _userC, decoration: const InputDecoration(labelText: 'Username')),
                const SizedBox(height: 10),
                TextField(controller: _emailC, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 10),
                TextField(controller: _passC, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 10),
                TextField(controller: _pass2C, obscureText: true, decoration: const InputDecoration(labelText: 'Konfirmasi Password')),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading ? const CircularProgressIndicator(color: Colors.white): const Text('Daftar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Sudah punya akun? Masuk'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
