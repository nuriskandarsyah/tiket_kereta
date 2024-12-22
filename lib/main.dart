import 'package:flutter/material.dart';
import 'db/db_helper.dart';

class TicketBookingPage extends StatefulWidget {
  @override
  _TicketBookingPageState createState() => _TicketBookingPageState();
}

class _TicketBookingPageState extends State<TicketBookingPage> {
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _routes = [];
  final _formKey = GlobalKey<FormState>();
  String _customerName = '';
  String _bookingDate = '';
  Map<String, dynamic>? _selectedRoute;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
    _fetchRoutes();
  }

  Future<void> _fetchTickets() async {
    final tickets = await DatabaseHelper.instance.fetchTickets();
    setState(() {
      _tickets = tickets;
    });
  }

  Future<void> _fetchRoutes() async {
    final routes = await DatabaseHelper.instance.fetchRoutes();
    setState(() {
      _routes = routes;
    });
  }

  Future<void> _saveTicket({int? ticketId}) async {
    if (_formKey.currentState!.validate() && _selectedRoute != null) {
      _formKey.currentState!.save();
      final ticket = {
        'customer_name': _customerName,
        'from_station': _selectedRoute!['from_station'],
        'to_station': _selectedRoute!['to_station'],
        'booking_date': _bookingDate,
        'price': _selectedRoute!['price'],
      };
      if (ticketId == null) {
        await DatabaseHelper.instance.insertTicket(ticket);
      } else {
        await DatabaseHelper.instance.updateTicket(ticketId, ticket);
      }
      Navigator.of(context).pop();
      _fetchTickets();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Ticket ${ticketId == null ? 'added' : 'updated'} successfully!')),
      );
    }
  }

  Future<void> _deleteTicket(int id) async {
    await DatabaseHelper.instance.deleteTicket(id);
    _fetchTickets();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket deleted successfully!')),
    );
  }

  void _showTicketDialog({Map<String, dynamic>? ticket}) {
    setState(() {
      if (ticket != null) {
        _customerName = ticket['customer_name'];
        _bookingDate = ticket['booking_date'];
        _selectedRoute = _routes.firstWhere(
          (route) =>
              route['from_station'] == ticket['from_station'] &&
              route['to_station'] == ticket['to_station'],
          orElse: () => {},
        );
      } else {
        _customerName = '';
        _bookingDate = '';
        _selectedRoute = null;
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ticket == null ? 'Add Ticket' : 'Edit Ticket'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                items: _routes.isNotEmpty
                    ? _routes
                        .map((route) => DropdownMenuItem(
                              value: route,
                              child: Text(
                                '${route['from_station']} → ${route['to_station']} (Rp ${route['price']})',
                              ),
                            ))
                        .toList()
                    : [],
                value: _selectedRoute,
                onChanged: (value) {
                  setState(() {
                    _selectedRoute = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Route',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Please select a route' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _customerName,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _customerName = value!;
                },
                validator: (value) =>
                    value!.isEmpty ? 'Please enter customer name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _bookingDate,
                decoration: InputDecoration(
                  labelText: 'Booking Date',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _bookingDate = value!;
                },
                validator: (value) {
                  final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (value == null || value.isEmpty) {
                    return 'Please enter booking date';
                  } else if (!dateRegex.hasMatch(value)) {
                    return 'Enter date in YYYY-MM-DD format';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                _saveTicket(ticketId: ticket == null ? null : ticket['id']),
            child: Text(ticket == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Train Tickets')),
      body: ListView.builder(
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title:
                  Text('${ticket['from_station']} → ${ticket['to_station']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${ticket['customer_name']}'),
                  Text('Date: ${ticket['booking_date']}'),
                  Text('Price: Rp ${ticket['price']}'),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
