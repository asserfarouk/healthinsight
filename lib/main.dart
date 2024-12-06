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
  int? _spO2;
  String _report = "Your health report will appear here.";
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _spO2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissions();  // Check permissions when the app starts
  }

  void _checkPermissions() async {
    // Request health permissions
    final health = HealthFactory();
    final isAuthorized = await health.requestAuthorization([HealthDataType.HEART_RATE, HealthDataType.SP02]);
    if (!isAuthorized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please grant health data permissions')),
      );
    }
  }

  void _analyzeData() {
    final int? heartRate = int.tryParse(_heartRateController.text);
    final int? spO2 = int.tryParse(_spO2Controller.text);

    if (heartRate == null || spO2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid data')),
      );
      return;
    }

    setState(() {
      _heartRate = heartRate;
      _spO2 = spO2;

      // Basic prediction logic
      if (heartRate < 60 && spO2 < 95) {
        _report =
        "Potential Issue: Low heart rate and SpO2 levels might indicate sleep apnea, cardiovascular problems, or general low body function.";
      } else if (heartRate > 100) {
        _report = "Potential Issue: High heart rate may indicate stress, anxiety, or other conditions such as fever.";
      } else if (spO2 < 92) {
        _report = "Potential Issue: Critically low SpO2 levels may indicate severe respiratory problems, such as COPD or even early-stage COVID-19.";
      } else if (heartRate >= 60 && heartRate <= 100 && spO2 >= 92) {
        _report = "All readings appear normal. Continue monitoring your health regularly.";
      } else {
        _report = "Please enter valid health data.";
      }
    });
  }

  @override
  void dispose() {
    _heartRateController.dispose();
    _spO2Controller.dispose();
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
              TextField(
                controller: _spO2Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'SpO2 (%)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _analyzeData,
                child: const Text('Analyze Data'),
              ),
              const SizedBox(height: 30),
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