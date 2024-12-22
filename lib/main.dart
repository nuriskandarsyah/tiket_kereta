import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiket_kereta/db/db_helper.dart';

void main() {
  runApp(MaterialApp(home: TicketBookingApp()));
}

class TicketBookingApp extends StatefulWidget {
  @override
  _TicketBookingAppState createState() => _TicketBookingAppState();
}

class _TicketBookingAppState extends State<TicketBookingApp> {
  List<Map<String, dynamic>> _tickets = [];
  final _formKey = GlobalKey<FormState>();
  String _customerName = '';
  String _bookingDate = '';
  String _fromStation = '';
  String _toStation = '';
  int _price = 0;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    final tickets = await DatabaseHelper.instance.fetchTickets();
    setState(() {
      _tickets = tickets;
    });
  }

  Future<void> _saveTicket({int? id}) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final ticket = {
        'customer_name': _customerName,
        'booking_date': _bookingDate,
        'from_station': _fromStation,
        'to_station': _toStation,
        'price': _price,
      };

      if (id == null) {
        await DatabaseHelper.instance.insertTicket(ticket);
      } else {
        await DatabaseHelper.instance.updateTicket(id, ticket);
      }

      Navigator.of(context).pop();
      _fetchTickets();
    }
  }

  Future<void> _deleteTicket(int id) async {
    await DatabaseHelper.instance.deleteTicket(id);
    _fetchTickets();
  }

  void _showTicketDialog({Map<String, dynamic>? ticket}) {
    if (ticket != null) {
      _customerName = ticket['customer_name'];
      _bookingDate = ticket['booking_date'];
      _fromStation = ticket['from_station'];
      _toStation = ticket['to_station'];
      _price = ticket['price'];
    } else {
      _customerName = '';
      _bookingDate = '';
      _fromStation = '';
      _toStation = '';
      _price = 0;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ticket == null ? 'Tambah Tiket' : 'Edit Tiket'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _customerName,
                  decoration: InputDecoration(labelText: 'Nama Pelanggan'),
                  onSaved: (value) => _customerName = value ?? '',
                  validator: (value) =>
                      value!.isEmpty ? 'Masukkan nama pelanggan' : null,
                ),
                TextFormField(
                  initialValue: _bookingDate,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Pemesanan',
                    hintText: 'YYYY-MM-DD',
                  ),
                  onSaved: (value) => _bookingDate = value ?? '',
                  validator: (value) {
                    try {
                      DateFormat('yyyy-MM-dd').parseStrict(value!);
                      return null;
                    } catch (_) {
                      return 'Format tanggal salah';
                    }
                  },
                ),
                TextFormField(
                  initialValue: _fromStation,
                  decoration:
                      InputDecoration(labelText: 'Stasiun Keberangkatan'),
                  onSaved: (value) => _fromStation = value ?? '',
                  validator: (value) =>
                      value!.isEmpty ? 'Masukkan stasiun keberangkatan' : null,
                ),
                TextFormField(
                  initialValue: _toStation,
                  decoration: InputDecoration(labelText: 'Stasiun Tujuan'),
                  onSaved: (value) => _toStation = value ?? '',
                  validator: (value) =>
                      value!.isEmpty ? 'Masukkan stasiun tujuan' : null,
                ),
                TextFormField(
                  initialValue: _price == 0 ? '' : _price.toString(),
                  decoration: InputDecoration(labelText: 'Harga Tiket'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _price = int.tryParse(value ?? '') ?? 0,
                  validator: (value) =>
                      (value == null || int.tryParse(value) == null)
                          ? 'Masukkan harga yang valid'
                          : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => _saveTicket(id: ticket?['id']),
            child: Text(ticket == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 14, 49, 162),
          title: Text(
            'Tiket Kereta',
            style: TextStyle(color: Colors.white),
          )),
      body: _tickets.isEmpty
          ? Center(child: Text('Belum ada data tiket.'))
          : ListView.builder(
              itemCount: _tickets.length,
              itemBuilder: (context, index) {
                final ticket = _tickets[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                        '${ticket['from_station']} → ${ticket['to_station']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pelanggan: ${ticket['customer_name']}'),
                        Text('Tanggal: ${ticket['booking_date']}'),
                        Text('Harga: Rp ${ticket['price']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showTicketDialog(ticket: ticket),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTicket(ticket['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTicketDialog(),
        backgroundColor: const Color.fromARGB(255, 14, 49, 162),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
