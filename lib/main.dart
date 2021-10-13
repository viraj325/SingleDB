import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:single_db/AuthenticateUI.dart';
import 'package:single_db/BlogUI.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

//Color.fromRGBO(51, 33, 122, 0)

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Single',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'Single'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isAuthenticated = false;
  SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() async {
    pref = await SharedPreferences.getInstance();
    /*int counter = (pref.getInt('counter') ?? 0) + 1;
    print('Pressed $counter times.');
    await pref.setInt('counter', counter);*/
    /*if(pref.getString("Number").isNotEmpty && pref.getString("Token").isNotEmpty){
      isAuthenticated = true;
    }*/

    isAuthenticated = (pref.getString("Number") ?? "").isNotEmpty && (pref.getString("Token") ?? "").isNotEmpty;
    print(isAuthenticated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
        //title: Text(widget.title),
      //),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: BlogUI(true)
      ),
      //BlogUI(true)
    );
  }
}

/*
ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(' Elevated Button')
                  )
              )
 */