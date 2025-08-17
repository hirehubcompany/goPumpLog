import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gopumplog/admin/stations/add%20stations.dart';
import 'package:gopumplog/pages/drawe/reports/homepage.dart';
import 'package:gopumplog/pages/ranking/homepage.dart';
import 'package:gopumplog/pages/stations/stations.dart';

class AddDrawer extends StatefulWidget {
  const AddDrawer({super.key});

  @override
  State<AddDrawer> createState() => _AddDrawerState();
}

class _AddDrawerState extends State<AddDrawer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body:  Column(
        children: [

          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red
            ),
            child: Center(child: Text('Go Sales WEEKLY eNTRY rEPORTS', style: TextStyle(
              color: Colors.white
            ),)),
          ),

          ListTile(
            title: Text('All Reports'),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return ReportsPage();
              }));
            },
          ),



          ListTile(
            title: Text('Station Ranking'),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return StationRankings();
              }));
            },
          ),

          ListTile(
            title: Text('Log Out'),
            onTap: (){
              FirebaseAuth.instance.signOut();
            },
          ),




        ],
      ),
    );
  }
}
