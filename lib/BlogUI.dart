import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:single_db/PostItem.dart';
import 'AuthenticateUI.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class BlogUI extends StatefulWidget {
  const BlogUI(this.isCreator);
  final bool isCreator;

  @override
  _BlogUIState createState() => _BlogUIState();
}

class _BlogUIState extends State<BlogUI> with WidgetsBindingObserver {
  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  TextEditingController imagesController = TextEditingController();
  List<PostItem> postList = [];
  String title = "";
  String body = "";
  String tags = "";
  String link = "";
  List<String> imageList = [];
  bool isCreator = false;
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  bool isMobile = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPrefs();
    _loadPosts();
    setState(() {
      if (kIsWeb) {
        // Web
        print("Web");
        isMobile = false;
      } else {
        if (Platform.isAndroid || Platform.isIOS) {
          // Mobile
          print("Mobile");
          isMobile = true;
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPrefs();
    }
  }

  _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isCreator = prefs.getBool("Creator") ?? false;
  }

  Future<void> _createPost() async {
    if(isCreator) {
      setState(() {
        if (title.isNotEmpty && body.isNotEmpty && tags.isNotEmpty) {
          if(imagesController.text.isNotEmpty){
            var images = imagesController.text.split(",");
            for(String image in images){
              imageList.add(image);
            }
          }
          postList.add(
              PostItem(title: title, body: body, tags: tags, link: link, images: imageList));
          posts.doc().set({
            'title': title,
            'body': body,
            'tags': tags,
            'link': link,
            'images': json.encode(imageList)
          }).then((value) => print("Post Created")).catchError((error) =>
              print("Failed to create a post. $error"));
        } else {
          print("Nothing to post");
        }
        title = "";
        body = "";
        tags = "";
        link = "";
        imageList.clear();
      });
    } else {
      showAlertDialog(context);
    }
  }

  _loadPosts(){
    setState(() {
      posts.get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          print(doc["title"]);
          print(doc["body"]);
          print(doc["tags"]);
          print(doc["link"]);
          print(doc["images"]);
          List<String> tempImageList = json.decode(doc["images"]).cast<String>() ?? [].cast<String>();
          postList.add(PostItem(title: doc["title"], body: doc["body"], tags: doc["tags"], link: doc["link"], images: tempImageList));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            width: 700,
            child: TextField(
              controller: searchController,
              cursorColor: Colors.lime,
              decoration: InputDecoration(
                //prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty ? null : InkWell(
                  onTap: () => searchController.clear(),
                  child: Icon(Icons.search, color: Colors.lime.withOpacity(0.85)),
                ),
                hintText: "Search",
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
              ),
              onChanged: (text) {
                setState(() {
                  title = text;
                });
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            width: isMobile ? double.infinity : 700,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                    width: double.infinity,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      controller: titleController,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        suffixIcon: titleController.text.isEmpty ? null : InkWell(
                          onTap: () => titleController.clear(),
                          child: Icon(Icons.clear, color: Colors.red.withOpacity(0.85)),
                        ),
                        hintText: "Title",
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color.fromRGBO(200, 200, 200, 0.5),
                      ),
                      onChanged: (text) {
                        setState(() {
                          title = text;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    width: double.infinity,
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: bodyController,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        hintText: "Body",
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color.fromRGBO(200, 200, 200, 0.5),
                      ),
                      onChanged: (text) {
                        setState(() {
                          body = text;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    width: double.infinity,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      controller: tagsController,
                      cursorColor: Colors.grey, decoration: InputDecoration(
                        hintText: "Tags seperated by ,",
                        suffixIcon: tagsController.text.isEmpty ? null : InkWell(
                          onTap: () => tagsController.clear(),
                          child: Icon(Icons.clear, color: Colors.red.withOpacity(0.85)),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color.fromRGBO(200, 200, 200, 0.5),
                      ),
                      onChanged: (text) {
                        setState(() {
                          tags = text;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    width: double.infinity,
                    child: TextField(
                      keyboardType: TextInputType.url,
                      maxLines: null,
                      controller: linkController,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        hintText: "Resource Link",
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color.fromRGBO(200, 200, 200, 0.5),
                      ),
                      onChanged: (text) {
                        setState(() {
                          link = text;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    width: double.infinity,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      maxLines: null,
                      controller: imagesController,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        hintText: "Images seperated by ,",
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color.fromRGBO(200, 200, 200, 0.5),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                    child:TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: _createPost,
                      child: const Text('Create', style: TextStyle(color: Colors.lime)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: postList.length,
            itemBuilder: (context, index) {
              return CardUI(postList[index], isMobile);
            },
          ),
        ],
    );
  }
}

class CardUI extends StatelessWidget {
  CardUI(this.post, this.isMobile);
  final PostItem post;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: SizedBox(
        width: isMobile ? double.infinity : 700,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child:Container(
              padding: EdgeInsets.all(20),
              width: isMobile ? double.infinity : 700,
              child: Column(
                children: [
                  Text(post.title),
                  Text(post.body),
                  Text(post.tags)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(
      "Cancel",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red
      ),
    ),
    onPressed:  () { Navigator.of(context).pop(); },
  );
  Widget continueButton = TextButton(
    child: Text(
      "Login",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.lime
      ),
    ),
    onPressed:  () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => AuthenticateUI()));
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Error"),
    content: Text("You're not authorized to create a post."),
    actions: [
      cancelButton,
      continueButton,
    ],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

/*
for the Jaini heart app
Container(
            height: 300,
            width: 400,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment(-1, -1),
                    end: Alignment(1, 1),
                    colors: [Colors.lime, Colors.limeAccent]),
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.lime.withOpacity(.5),
                  blurRadius: 20.0, // soften the shadow
                  spreadRadius: 0.0, //extend the shadow
                  offset: Offset(
                    3.0, // Move to right 10  horizontally
                    3.0, // Move to bottom 10 Vertically
                  ),
                ),
                BoxShadow(
                  color: Colors.limeAccent.withOpacity(.2),
                  blurRadius: 20.0, // soften the shadow
                  spreadRadius: 0.0, //extend the shadow
                  offset: Offset(
                    6.0, // Move to right 10  horizontally
                    6.0, // Move to bottom 10 Vertically
                  ),
                )
              ],
            ),
            child: Center(
              child: Text('Gradients are cool!',
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                ),
              ),
            ),
          ),
 */