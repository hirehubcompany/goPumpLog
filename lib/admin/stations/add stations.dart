import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadStationsFromCSV {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> pickAndUploadStations() async {
    try {
      // Pick CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        print("❌ No file selected");
        return;
      }

      final file = File(result.files.single.path!);
      final rawData = await file.readAsString();

      // Convert CSV text → List of rows
      final List<List<dynamic>> csvData = LineSplitter.split(rawData)
          .map((line) => line.split(","))
          .toList();

      if (csvData.isEmpty) {
        print("❌ CSV file is empty");
        return;
      }

      // Assuming first row is header: [Station Name, Zone, ME]
      for (int i = 1; i < csvData.length; i++) {
        final station = csvData[i][0].trim();
        final zone = csvData[i][1].trim();
        final me = csvData[i][2].trim();

        // Firestore docId must not contain invalid chars
        final docId = station.replaceAll(RegExp(r'[\/\\\[\]#\$]'), '-');

        await db.collection("All Stations").doc(docId).set({
          "name": station,
          "zone": zone,
          "ME": me,
          "createdAt": FieldValue.serverTimestamp(),
        });

        print("✅ Uploaded station: $station");
      }

      print("🎉 All stations uploaded successfully!");
    } catch (e) {
      print("❌ Error uploading stations: $e");
    }
  }
}
