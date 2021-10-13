import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthenticateUI extends StatefulWidget {
  const AuthenticateUI({Key key}) : super(key: key);

  @override
  _AuthenticateUIState createState() => _AuthenticateUIState();
}

class _AuthenticateUIState extends State<AuthenticateUI> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String checkEmail = "";
  String checkPassword = "";
  String email = "";
  String password = "";
  bool isCheckingCode = false;
  SharedPreferences pref;
  final DatabaseReference db = FirebaseDatabase().reference();

  @override
  void initState() {
    _loadPrefs();
    emailController.addListener(_saveEmailValue);
    passwordController.addListener(_savePasswordValue);
    super.initState();
  }

  void _saveEmailValue(){
    setState(() {
      email = emailController.text;
      print(email);
    });
  }

  void _savePasswordValue(){
    setState(() {
      password = passwordController.text;
      print(password);
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Clean up the controller when the Widget is disposed
    emailController.dispose();
    passwordController.dispose();
  }

  void _loadPrefs() async {
    pref = await SharedPreferences.getInstance();
    db.child("Login").child("email").once().then((value) => checkEmail = value.value);
    db.child("Login").child("password").once().then((value) => checkPassword = value.value);
  }

  void _login() async {
    if(email == checkEmail && password == checkPassword){
      pref.setBool("Creator", true);
      Navigator.pop(context);
    } else {
      //show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(200, 200, 200, 0.5),
      body: Center(
        child:Container(
          width:450,
          height: 550,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.white10.withOpacity(1),
                spreadRadius: 3,
                blurRadius: 1,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 50.0),
                child: Text(
                  "Single Blog",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                      fontFamily: 'RaleWay',
                      fontFamilyFallback: <String>[
                        'Noto Sans CJK SC',
                        'Noto Color Emoji',
                      ],
                    fontSize: 40.0,
                    color: Colors.lime
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                  width: double.infinity,
                  child: TextField(
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    cursorColor: Colors.grey,
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color.fromRGBO(200, 200, 200, 0.5),
                    ),
                  )
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                  width: double.infinity,
                  child: TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    cursorColor: Colors.grey,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color.fromRGBO(200, 200, 200, 0.5),
                    ),
                  )
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                width: 150,
                child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: _login,
                  child: const Text('Login', style: TextStyle(color: Colors.lime)),
                ),
              ),
              Container(
                  width: 450,
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: MaterialButton(
                        onPressed: () { Navigator.pop(context); },
                        color: Colors.lime,
                        textColor: Colors.white,
                        child: Icon(
                          Icons.arrow_back,
                          size: 24,
                        ),
                        padding: EdgeInsets.all(16),
                        shape: CircleBorder(),
                      )
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}