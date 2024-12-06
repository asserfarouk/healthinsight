import 'package:flutter/material.dart';
import 'package:health/health.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Insight',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int? _heartRate;
  String _report = "Your health report will appear here.";
  final TextEditingController _heartRateController = TextEditingController();
  bool _isLoading = false;
  late HealthFactory _healthFactory;

  @override
  void initState() {
    super.initState();
    _healthFactory = HealthFactory();  // Initialize HealthFactory
    _checkPermissions();
  }

  void _checkPermissions() async {
    final isAuthorized = await _healthFactory.requestAuthorization([HealthDataType.HEART_RATE]);

    if (!isAuthorized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please grant health data permissions')),
      );
    }
  }

  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final healthData = await _healthFactory.getHealthDataFromTypes(
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now(),
        [HealthDataType.HEART_RATE],
      );

      if (healthData.isNotEmpty) {
        setState(() {
          _heartRate = healthData
              .firstWhere((data) => data.type == HealthDataType.HEART_RATE)
              .value
              ?.toInt();
          _report = "Health data successfully fetched.";
        });
      } else {
        setState(() {
          _report = "No health data found for the selected period.";
        });
      }
    } catch (e) {
      setState(() {
        _report = 'Failed to fetch health data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _analyzeData() {
    final int? heartRate = int.tryParse(_heartRateController.text);

    if (heartRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid data')),
      );
      return;
    }

    setState(() {
      _heartRate = heartRate;

      // Basic prediction logic
      if (heartRate < 60) {
        _report = "Potential Issue: Low heart rate may indicate cardiovascular issues or other conditions.";
      } else if (heartRate > 100) {
        _report = "Potential Issue: High heart rate may indicate stress, anxiety, or fever.";
      } else {
        _report = "All readings appear normal. Continue monitoring your health regularly.";
      }
    });
  }

  @override
  void dispose() {
    _heartRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Health Insight'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Enter Your Data Below:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _heartRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Heart Rate (BPM)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _analyzeData,
                child: const Text('Analyze Data'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchData,
                child: const Text('Fetch Health Data from Device'),
              ),
              const SizedBox(height: 30),
              if (_isLoading) const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Health Report:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _report,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}