import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AddStations extends StatefulWidget {
  const AddStations({super.key});

  @override
  State<AddStations> createState() => _AddStationsState();
}

class _AddStationsState extends State<AddStations> {
  // Replace with your full station list (kept as you provided)
  final List<String> stations = [
    "ABATTOIR",
    "ABEHENASE-AMASAMAN",
    "ABEKA LAPAZ",
    "ABLEKUMA",
    "ABLEKUMA NSUFA",
    "ABOADZE AGONA NKWANTA",
    "ABREPO KESE",
    "ABREPO KUMA",
    "ABURI GYANKAMA",
    "ACP POKUASE",
    "ADA FOAH",
    "ADDY JUNCTION",
    "ADENTA-AVIATION ROAD",
    "ADISADEL (CAPE COAST)",
    "ADJRINGANOR",
    "ADUMANYA S/S",
    "AFIENYA TOLL-BOOTH",
    "AFLAO",
    "AFRANCHO",
    "AGBOGBA",
    "AGONA AMENFI",
    "AGONA MENSAKROM",
    "AGONA SWEDRU",
    "AHAFO HWIDIEM",
    "AJUMAKO",
    "AKATSI BY PASS",
    "AKIM ACHIASE",
    "AKIM ODA",
    "AKIM ODA GUGGISBURG",
    "AKIM SUBI",
    "AKROPONG",
    "AKUMADAN",
    "AKWETEYMAN",
    "AKYAWKROM",
    "ALBERT DADZIE(BATANYAA)",
    "AMAKOM",
    "AMANFROM BAREKESE",
    "AMPOMAH JUNCTION",
    "ANLOGA",
    "ANYAA MARKET",
    "ANYINAM",
    "APOLONIA CITY",
    "APREMDO",
    "ASAFO MARKET",
    "ASAMANKESE",
    "ASHAIMAN ZENU",
    "ASHALLEY BOTWE HIGHWAYS",
    "ASHIAMAN SEC. SCH",
    "ASHIAMAN VALCO FLATS",
    "ASHIYIE FULANI JUNCTION",
    "ASOKORE MAMPONG",
    "ASONABA ODUOM",
    "ASSIN BROFOYEDURU",
    "ASSIN PRASO",
    "ATASEMANSO",
    "ATIBIE AMANFROM",
    "ATIMPOKU",
    "ATUABO",
    "AWUDU ISSAKA(WASSA AKROPONG)",
    "AYIKA DOBLO JIDA/SOWUTUOM",
    "AYIKAI DOBLO",
    "AYIKAI DOBLO (ASHALAGA)",
    "AYORYA",
    "BANTAMA",
    "BAWKU BY-PASS",
    "BECHEM TEPA JUNCTION",
    "BEDIESO-OBUASI",
    "BENUE NKWANTA",
    "BEREKUM MAIN",
    "BEREKUM SEIKWA RD",
    "BEREKUM-DORMAA ROAD",
    "BETHLEHEM",
    "BIBIANI LINESO",
    "BIBIANI MANUKROM",
    "BIMBILLA",
    "BOANKRA",
    "BOLGA - BAWKU ROAD",
    "BOLGA MAIN",
    "BOLGA SOE",
    "BOMFA JUNCTION",
    "BONGO",
    "BORTEYMAN",
    "BREAMANG RICHAM",
    "BREMAN ASIKUMA",
    "BUIPE",
    "BUNSO",
    "BUOKROM",
    "BURMA CAMP",
    "CAPE COAST BYPASS",
    "CAPITAL HILL",
    "CENTRAL VITTIN",
    "CIRCLE CAPRICE",
    "CIRCLE OVERHEAD",
    "DAABAN",
    "DAMBAI",
    "DAMFA",
    "DANSOMAN MAIN",
    "DANSOMAN ROUNDABOUT",
    "DARKUMAN",
    "DARKUMAN KOKOMPE",
    "DARKUMAN POST OFFICE",
    "DAWHENYA",
    "DAWHENYA - ADJUMADOR",
    "DENCHIRA",
    "DENU TORKOR",
    "DICHEMSO",
    "DODOWA MARKET",
    "DORIMON",
    "DORMA AHENKRO",
    "DORYUMU",
    "DROBO",
    "DUNGU",
    "DZODZE AKANU",
    "EDWARD LARBI KWAPONG(AKWAKROM)",
    "EFFIDUASE",
    "EJISU",
    "EMENA",
    "ESSIAMA",
    "FAUSTINA MARTIN DANIELS-BAKAANO CAPE COAST",
    "FETTEH  KAKRABA",
    "FIAPRE",
    "GBAWE ZERO",
    "GOASO HWEDIEM ROAD",
    "GOMOA BIAKOYE",
    "GOMOA FETTEH",
    "HALF ASSINI",
    "HO HOSPITAL ROAD",
    "HO MAIN",
    "HO OLA",
    "HOHOE FIRE SERVICE",
    "HOHOE KPOETA",
    "HOHOE MAIN",
    "HOSPITAL ROAD",
    "IRON CITY",
    "JACHIE PRAMSO",
    "JASIKAN",
    "JISONAYILY - TAMALE",
    "JOSEPH AIDOO (FIJIA - TAKORADI)",
    "JUABEN - YAW NKRUMAH",
    "JUABEN NO.1",
    "JUBA BARRACKS - BURMA CAMP",
    "KAASE",
    "KADE",
    "KALADAN",
    "KASOA KRISPOL CITY",
    "KASOA NEW MARKET",
    "KEGYASE",
    "KEJETIA-MBROM",
    "KENTINKRONO KNUST",
    "KETA KEDZI",
    "KETE KRACHI NO.1",
    "KINTAMPO",
    "KLAGON",
    "KOFORIDUA HUHUNYA",
    "KOFORIDUA OKOENYA",
    "KOFORIDUA OKORASE",
    "KOFORIDUA SUHUM",
    "KOJOKROM",
    "KOKROBITE",
    "KONGO",
    "KONONGO ODUMASE",
    "KORLE GONNO",
    "KOTWI",
    "KPANDO",
    "KPESHIE",
    "KPONE KOKOMPE",
    "KPONG KOTOKOLI",
    "KROFROM",
    "KROMOASE",
    "KUBEASE",
    "KUKURANTUMI",
    "KUNTUNSE",
    "KWABENYA MAIN",
    "KWABENYA TAXI RANK",
    "KWAMO",
    "LA  NKWANTANANG",
    "LARPLEKU",
    "LASHIBI",
    "LAWRA",
    "LIBERATION ROAD (AIRPORT)",
    "LINK ROAD",
    "MAASE",
    "MADINA  ESTATE S/S",
    "MADINA ZONGO JUNCTION",
    "MALLAM JUNCTION",
    "MALLAM MARKET",
    "MAMPONG AKWAPIM",
    "MAMPONG BYPASS",
    "MAMPONG TOWN",
    "MANHYIA",
    "MANHYIA HOSPITAL",
    "MAYERA",
    "MEMPEASEM",
    "MILE 11",
    "MMT CAPE COAST",
    "MMT TAKORADI",
    "NAVRONGO",
    "NEW BORTIANOR",
    "NEW KENTINKRONO",
    "NIMA",
    "NKAWANDA",
    "NKAWIE",
    "NKORANZA",
    "NSAWAM LORRY PARK",
    "NSAWAM POLICE STATION",
    "NUNGUA CHANNEL 5",
    "NYANKYERENIASI",
    "NYANYANO KAKRABA",
    "NYANYANO RD",
    "NYANYANYO TOWN",
    "NYANYNOR ADADE",
    "OBEYEYIE",
    "OBUOM RD",
    "ODOKOR BUSIA S/S",
    "OFFINSO ABOFOUR",
    "OFFINSO ASAMANKAMA",
    "OFFINSO DENASE",
    "OFFINSO DENTIN",
    "OFFINSO TOLLBOTH",
    "OFFINSO TUTUASE 1",
    "OKOBEYEYIE NSAWAM",
    "OLD TAFO",
    "OPEIKUMA",
    "OYARIFA",
    "PALLADIUM",
    "PANKRONU KODUA JUNCTION",
    "Pokuase Junction",
    "PRESEC",
    "RACE COURSE",
    "REXFORD DZAMPSON(APOWA)",
    "RICE CITY - TAMALE",
    "RIVOLI",
    "SAFEWHEEL",
    "SALAGA",
    "SAMPA",
    "SANDEMA",
    "SANKORE",
    "SANTASI-ANYINAM",
    "SANTOE",
    "SAPEIMAN",
    "SEBREBO",
    "SEFWI DWENASE",
    "SHAI HILLS",
    "SOGAKOPE",
    "SOUTH LA",
    "SOUTH VITTIN",
    "SOWUTUOM",
    "STC",
    "SUAME ROUNDABOUT",
    "SUNYANI ABESIM",
    "SUNYANI BYPASS",
    "SUNYANI NEW DORMAA RD",
    "SUNYANI ODUMASI",
    "SUNYANI RIDGE",
    "SUNYANI TANOSO",
    "SUNYANI ZONGO",
    "SUPERIOR OIL-ELMINA",
    "SUPERIOR OIL-ELUBO",
    "TABORA",
    "TAFO WESLEY",
    "TAKYIKROM",
    "TANOSO MELCOM",
    "TANTRA HILL",
    "TECHIMAN ANYINABREM",
    "Techiman Bankoma Estate",
    "TECHIMAN KUNTUNSO",
    "TECHIMAN MARKET",
    "TECHIMAN TUOBODOM ROAD 1",
    "TEIMAN (ABOKOBI)",
    "TEMA COMM.1 MARKET",
    "TEMA COMM.9",
    "TEMA VRA JUNCTION",
    "TEWOBAABI",
    "TOMAN",
    "TOUGA JUNCTION",
    "TRUST LOGISTICS LIMITED - TEMA",
    "TSE ADDO",
    "TSOPOLI",
    "TUBA  BY PASS",
    "TUMU 1",
    "TUMU NO.2",
    "TUOBODOM RD 2",
    "UCC",
    "VERA DORKUTSO(ADANDZIE)",
    "WA AIRPORT 1",
    "WA MAIN",
    "WA POLY RD",
    "WA PWD",
    "WEIJA 2",
    "WEIJA WHITE CROSS",
    "WENCHI MAIN",
    "WENCHI WA ROAD",
    "WINNEBA UNIVERSITY",
    "YAWKWEI",
    "YEJI",
    "YENDI ROAD",
    "YENDI TOWN",
    "ZEBILLA"
  ];

  bool isUploading = false;
  double progress = 0.0;

  String _sanitizeId(String s) {
    // replace slashes/backslashes with dash, remove problematic chars, trim
    return s
        .replaceAll(RegExp(r'[\/\\]'), '-')
        .replaceAll(RegExp(r'[\[\]#\$]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> uploadStations() async {
    setState(() {
      isUploading = true;
      progress = 0.0;
    });

    // initialize Firebase if not already done
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    final db = FirebaseFirestore.instance;
    const int batchSize = 500; // Firestore limit per batch
    final int total = stations.length;

    try {
      for (int start = 0; start < total; start += batchSize) {
        final int end = min(start + batchSize, total);
        final WriteBatch batch = db.batch();

        for (int i = start; i < end; i++) {
          final rawName = stations[i];
          final docId = _sanitizeId(rawName);
          final docRef = db.collection('All Stations').doc(docId);
          batch.set(docRef, {
            'name': rawName,
            'ME': 'ME ${i + 1}', // sequential ME 1, ME 2...
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
        setState(() {
          progress = end / total;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stations uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPct = (progress * 100).toStringAsFixed(0);
    return Scaffold(
      appBar: AppBar(title: const Text("Add Stations")),
      body: Center(
        child: isUploading
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(value: progress),
            const SizedBox(height: 12),
            Text("Uploading... $progressPct%"),
          ],
        )
            : ElevatedButton(
          onPressed: uploadStations,
          child: const Text("Upload Stations to Firestore"),
        ),
      ),
    );
  }
}
