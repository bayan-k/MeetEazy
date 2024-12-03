import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({Key? key}) : super(key: key);

  @override
  _TestConnectionScreenState createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _connectionStatus = 'Not tested yet';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing connection...';
    });

    try {
      final response = await ApiService().get('/api/meetings/test-connection/');
      setState(() {
        _connectionStatus = 'Connected! Server says: ${response['message']}';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connection Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _testConnection,
                  child: const Text('Test Backend Connection'),
                ),
              const SizedBox(height: 20),
              Text(
                _connectionStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _connectionStatus.contains('Connected') 
                    ? Colors.green 
                    : _connectionStatus.contains('failed') 
                      ? Colors.red 
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
