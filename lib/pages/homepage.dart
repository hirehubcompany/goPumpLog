import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:gopumplog/pages/drawe/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? fileName;
  List<Map<String, dynamic>> reportData = [];
  int numberOfDays = 8; // default period
  bool sortByPercentage = false;
  String? filePath;

  Future<void> choosePeriod() async {
    final controller = TextEditingController(text: numberOfDays.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set period (days)"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter number of days",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final days = int.tryParse(controller.text);
                if (days != null && days > 0) {
                  Navigator.pop(context, days);
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        numberOfDays = result;
      });
    }
  }

  Future<void> pickAndProcessExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      filePath = result.files.single.path!;
      fileName = result.files.single.name;

      final bytes = File(filePath!).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      List<Map<String, dynamic>> tempData = [];

      Sheet sheet = excel.tables[excel.tables.keys.first]!;

      int stationCol = -1;

      if (sheet.maxRows > 0) {
        List<Data?> firstRow = sheet.rows[0];
        for (int i = 0; i < firstRow.length; i++) {
          if ((firstRow[i]?.value ?? "").toString().toLowerCase().contains("station")) {
            stationCol = i;
          }
        }
      }

      Map<String, int> stationCounts = {};

      for (var row in sheet.rows.skip(1)) {
        String? station = stationCol >= 0 ? row[stationCol]?.value?.toString() : null;

        if (station != null && station.isNotEmpty) {
          stationCounts[station] = (stationCounts[station] ?? 0) + 1;
        }
      }

      stationCounts.forEach((station, count) {
        int adjustedCount = (count / 2).ceil();
        double percentage = (adjustedCount / numberOfDays) * 100;
        tempData.add({
          "station": station,
          "entries": adjustedCount,
          "percentageValue": percentage,
          "percentage": "${percentage.toStringAsFixed(2)}%"
        });
      });

      tempData.sort((a, b) => a["station"].compareTo(b["station"]));

      setState(() {
        reportData = tempData;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  Future<void> saveReportToFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("reports").get();
      int reportNumber = snapshot.size + 1;
      String reportName = "Report $reportNumber";

      await FirebaseFirestore.instance.collection("reports").doc(reportName).set({
        "fileName": fileName,
        "periodDays": numberOfDays,
        "createdAt": DateTime.now(),
        "data": reportData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$reportName saved to Firestore")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving report: $e")),
      );
    }
  }

  Map<String, dynamic> getDashboardSummary() {
    if (reportData.isEmpty) return {};
    double avgPercentage = reportData.map((e) => e["percentageValue"] as double).reduce((a, b) => a + b) / reportData.length;
    int totalEntries = reportData.map((e) => e["entries"] as int).reduce((a, b) => a + b);
    var bestStation = reportData.reduce((a, b) => a["percentageValue"] > b["percentageValue"] ? a : b);
    var worstStation = reportData.reduce((a, b) => a["percentageValue"] < b["percentageValue"] ? a : b);

    return {
      "average": avgPercentage.toStringAsFixed(2),
      "totalEntries": totalEntries,
      "best": bestStation["station"],
      "worst": worstStation["station"],
    };
  }

  void toggleSorting() {
    setState(() {
      sortByPercentage = !sortByPercentage;
      if (sortByPercentage) {
        reportData.sort((a, b) => b["percentageValue"].compareTo(a["percentageValue"]));
      } else {
        reportData.sort((a, b) => a["station"].compareTo(b["station"]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var summary = getDashboardSummary();

    return Scaffold(
      drawer: Drawer(
        child: AddDrawer(),
      ),
      appBar: AppBar(
        title: const Text(
          "GoSalesLog",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFD300),
        foregroundColor: Colors.black,
        actions: [
          if (reportData.isNotEmpty)
            IconButton(
              icon: Icon(sortByPercentage ? Icons.sort_by_alpha : Icons.bar_chart),
              onPressed: toggleSorting,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await choosePeriod();
                await pickAndProcessExcelFile();
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload goEntries Sheet File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Text(fileName ?? "No file selected", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text("Period: $numberOfDays days", style: const TextStyle(fontSize: 16)),

            if (reportData.isNotEmpty) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: saveReportToFirestore,
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            const SizedBox(height: 20),
            Expanded(
              child: reportData.isEmpty
                  ? const Center(child: Text("No data to display"))
                  : ListView.builder(
                itemCount: reportData.length,
                itemBuilder: (context, index) {
                  final item = reportData[index];
                  return Card(
                    child: ListTile(
                      title: Text(item["station"]),
                      subtitle: Text("Entries: ${item["entries"]}"),
                      trailing: Text(item["percentage"]),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
