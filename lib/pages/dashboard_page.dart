import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> _history = [];
  bool _loading = false;
  String? _token;
  final _desC = TextEditingController();
  String? _selectedItem;
  String? _selectedLokasi;

  @override
  void initState() {
    super.initState();
    _initTokenAndLoad();
  }

  Future<void> _initTokenAndLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    await _loadHistory();
  }

  Future<Dio> _dio() async {
    var d = Dio();
    if (_token != null) d.options.headers['Authorization'] = 'Bearer $_token';
    return d;
  }

  Future<void> _loadHistory() async {
    setState(() { _loading = true; });
    try {
      var d = await _dio();
      var res = await d.get('http://10.0.2.2:8000/api/pengaduan/history');
      setState(() { _history = res.data; });
    } catch (e) {
      // ignore or show
    } finally { setState(() { _loading = false; }); }
  }

  // create new pengaduan minimal (here we just use deskripsi and dummy ids; in production fetch real items/lokasi)
  Future<void> _createPengaduan() async {
    if (_desC.text.isEmpty) return;
    setState(() { _loading = true; });
    try {
      var d = await _dio();
      var form = FormData.fromMap({
        'id_item': _selectedItem ?? 1,
        'id_lokasi': _selectedLokasi ?? 1,
        'deskripsi': _desC.text,
      });
      var res = await d.post('http://10.0.2.2:8000/api/pengaduan', data: form);
      _desC.clear();
      await _loadHistory();
    } catch (e) {
      // handle
    } finally { setState(() { _loading = false; }); }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('role');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [ IconButton(onPressed: _logout, icon: const Icon(Icons.logout)) ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // create section (todo input)
            TextField(controller: _desC, decoration: const InputDecoration(labelText: 'Laporkan masalah (todo)'),),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: _loading?null:_createPengaduan, child: _loading?const CircularProgressIndicator(color: Colors.white):const Text('Kirim'))),
            ]),
            const SizedBox(height: 12),

            Expanded(
              child: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
                onRefresh: _loadHistory,
                child: _history.isEmpty
                  ? ListView(children: const [Center(child: Padding(padding: EdgeInsets.all(12), child: Text('Belum ada pengaduan')))])
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (_, i){
                        var p = _history[i];
                        return Card(
                          child: ListTile(
                            title: Text(p['deskripsi'] ?? '-'),
                            subtitle: Text('Status: ${p['status']} • ${p['created_at'] ?? ''}'),
                            trailing: p['foto'] != null ? IconButton(icon: const Icon(Icons.image), onPressed: (){
                              // show image dialog
                              showDialog(context: context, builder: (_) => Dialog(child: Image.network('http://10.0.2.2:8000/storage/${p['foto']}')));
                            }) : null,
                          ),
                        );
                      },
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
