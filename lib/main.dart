import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Survey Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Survey Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Survey {
  String id;
  final String name;
  final int vote;

  Survey({this.id = "", required this.name, required this.vote});

  Map<String, dynamic> toJson() => {
        "id": id,
        "Name": name,
        "Vote": vote,
      };

  static Survey fromJson(Map<String, dynamic> json) => Survey(
        id: json["id"],
        name: json["Name"],
        vote: json["Vote"],
      );
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Survey Demo"),
      ),
      body: StreamBuilder<List<Survey>>(
        stream: readSurvey(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong! ${snapshot.error}");
          } else if (snapshot.hasData) {
            final surveys = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: surveys.map(buildSurvey).toList(),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Widget buildSurvey(Survey survey) => ListTile(
    leading: CircleAvatar(
      child: Text("${survey.vote}"),
    ),
    title: Text(survey.name),
    trailing: GestureDetector(
        onTap: () {
          final docSurvey = FirebaseFirestore.instance
              .collection("language survey")
              .doc(survey.id);
          docSurvey.update({
            "Vote": survey.vote + 1,
          });
        },
        child: const Icon(
          Icons.add_circle_outline_outlined,
          size: 40.0,
        )));

Stream<List<Survey>> readSurvey() => FirebaseFirestore.instance
    .collection("language survey")
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((e) => Survey.fromJson(e.data())).toList());
