import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db/db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SewaBukuPage(),
    );
  }
}

class SewaBukuPage extends StatefulWidget {
  @override
  _SewaBukuPageState createState() => _SewaBukuPageState();
}

class _SewaBukuPageState extends State<SewaBukuPage> {
  final dbHelper = DatabaseHelper.instance;

  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _namaBukuController = TextEditingController();
  final _tanggalSewaController = TextEditingController();
  final _tanggalKembaliController = TextEditingController();

  final int _hargaPerHari = 10000;

  List<Map<String, dynamic>> _notes = [];
  Map<String, dynamic>? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    final notes = await dbHelper.getAllSewa();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _saveData() async {
    if (_namaController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _namaBukuController.text.isEmpty ||
        _tanggalSewaController.text.isEmpty ||
        _tanggalKembaliController.text.isEmpty) {
      _showSnackbar("Harap isi semua kolom!");
      return;
    }

    final tanggalSewa = DateTime.parse(_tanggalSewaController.text);
    final tanggalKembali = DateTime.parse(_tanggalKembaliController.text);

    if (tanggalKembali.isBefore(tanggalSewa)) {
      _showSnackbar("Tanggal Kembali harus setelah Tanggal Sewa!");
      return;
    }

    int lamaSewa = tanggalKembali.difference(tanggalSewa).inDays;
    lamaSewa = lamaSewa == 0 ? 1 : lamaSewa;
    print("lama Sewa: $lamaSewa hari");
    final totalBayar = lamaSewa * _hargaPerHari;

    if (_selectedItem == null) {
      // Tambah Data Baru
      await dbHelper.addSewa({
        'nama': _namaController.text,
        'alamat': _alamatController.text,
        'nama_buku': _namaBukuController.text,
        'tanggal_sewa': _tanggalSewaController.text,
        'tanggal_kembali': _tanggalKembaliController.text,
        'total_bayar': totalBayar,
      });
    } else {
      // Edit Data
      await dbHelper.updateSewa({
        'id': _selectedItem!['id'],
        'nama': _namaController.text,
        'alamat': _alamatController.text,
        'nama_buku': _namaBukuController.text,
        'tanggal_sewa': _tanggalSewaController.text,
        'tanggal_kembali': _tanggalKembaliController.text,
        'total_bayar': totalBayar,
      });
      _selectedItem = null;
    }

    _clearInput();
    _loadNotes();
    _showSnackbar("Data berhasil disimpan!");
  }

  void _clearInput() {
    _namaController.clear();
    _alamatController.clear();
    _namaBukuController.clear();
    _tanggalSewaController.clear();
    _tanggalKembaliController.clear();
    _selectedItem = null;
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }

  void _editData(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _namaController.text = item['nama'];
      _alamatController.text = item['alamat'];
      _namaBukuController.text = item['nama_buku'];
      _tanggalSewaController.text = item['tanggal_sewa'];
      _tanggalKembaliController.text = item['tanggal_kembali'];
    });
  }

  void _deleteData(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus data'),
          content: Text('Apakah Anda yakin ingin menghapus data ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await dbHelper.deleteSewa(id);
                _loadNotes();
                Navigator.of(context).pop();
                _showSnackbar("Data berhasil dihapus!");
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 31, 18),
        title: Text(
          'Sewa Buku',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Form Input di Atas
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildTextField(_namaController, 'Nama'),
                  SizedBox(height: 10),
                  _buildTextField(_alamatController, 'Alamat'),
                  SizedBox(height: 10),
                  _buildTextField(_namaBukuController, 'Nama Buku'),
                  SizedBox(height: 10),
                  _buildDatePicker(_tanggalSewaController, 'Tanggal Sewa'),
                  SizedBox(height: 10),
                  _buildDatePicker(
                      _tanggalKembaliController, 'Tanggal Pengembalian'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 66, 31, 18),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            // List Data di Bawah
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final item = _notes[index];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                    mainAxisSize:
                        MainAxisSize.min, // Menghindari ruang kosong ekstra
                    children: [
                      Text(
                        item['nama'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        item['nama_buku'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text("Total Bayar: Rp ${item['total_bayar']}"),
                  onTap: () => _editData(item),
                  onLongPress: () => _deleteData(item['id']),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
