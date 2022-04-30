import 'package:bks/helper/database_helper.dart';
import 'package:bks/main.dart';
import 'package:bks/widgets/data.dart';
import 'package:bks/widgets/search_content.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:sizer/sizer.dart';

import 'dart:async';

import '../widgets/book_options.dart';
import '../widgets/bookmark.dart';
import '../widgets/completed_books.dart';

int toggleIndex = 0;
double dragPercentage = 0;
double dragUpdate = 0;

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

List books = [];
bool loading = true;
List readBooks = [];


List<AnimationController> animatedControllers = [];

TextEditingController pages = TextEditingController();

class _HomeState extends State<Home> with TickerProviderStateMixin{
  double turns = 0.0;
  bool isClicked = false;
  @override
  void initState() {
    // TODO: implement initState
    streamController = StreamController();
    stream = streamController.stream;

    fetchInitData();
    super.initState();
  }
  @override
  void dispose() {
    animatedControllers.forEach((element) {
      element.dispose();
      print('disposing...');
    });
    super.dispose();
  }
  fetchInitData() async{
    //-------getting-data-------//
    if(table == 'current_books'){
      setState(() {
        loading = true;
      });
      final allRows = await DatabaseHelper.instance.queryAllRows();
      print('query all rows:');
      setState(() {
        books.clear();
        readBooks.clear();
        allRows.forEach((row){
          print(row);
          Map<String, dynamic> map = Map<String, dynamic>.from(row);

          if(row['maf'] == 0){
            books.add(map);
            animatedControllers.add(AnimationController(vsync: this, duration: const Duration(milliseconds: 1000),));
          }else{
            readBooks.add(map);
          }
          print('books: $books');
          print('readBooks: $readBooks');
        });
        loading = false;
      });
    }else{
      setState(() {
        loading = true;
      });
      final allRows = await DatabaseHelper.instance.queryAllRows();
      print('query all rows:');
      setState(() {
        books.clear();
        allRows.forEach((row){
          print(row);
          Map<String, dynamic> map = Map<String, dynamic>.from(row);

          books.add(map);
        });
        loading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return loading ? const Scaffold(body: Center(child: CircularProgressIndicator(),)) : Scaffold(
      backgroundColor: customWhiteColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          elevation: 0,
          backgroundColor: customWhiteColor,
          title: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                table == 'wishlist' ? 'wishlist' :'bookshelf',
                style: TextStyle(
                  fontFamily: 'Hurme',
                  fontSize: 23.sp,
                  color: customBlackColor,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 7, 12, 0),
              child: Column(
                children: [
                  // const SizedBox(height: 5),
                  Container(

                    decoration: BoxDecoration(
                        boxShadow: lightShadows,
                        borderRadius: BorderRadius.circular(50),
                        color: customWhiteColor
                    ),
                    child: IconButton(
                      tooltip: table == 'wishlist' ? 'bookshelf' :'wishlist',
                      icon: Icon(table == 'wishlist' ? Icons.book_rounded : Icons.list_alt_outlined, color: customBlackColor, size: 20.sp,), onPressed: () {
                      if(table == 'current_books'){
                        print('switched_to_wishlist');
                        setState(() {
                          table = 'wishlist';
                        });
                      }
                      else{
                        print('switched_to_books');
                        setState(() {
                          table = 'current_books';
                        });
                      }
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                    },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 7, 12, 0),
              child: Column(
                children: [
                  // const SizedBox(height: 5),
                  Container(

                    decoration: BoxDecoration(
                      boxShadow: lightShadows,
                      borderRadius: BorderRadius.circular(50),
                      color: customWhiteColor
                    ),
                    child: IconButton(
                    icon: Icon(Icons.add, color: customBlackColor, size: 20.sp), onPressed: () {
                      streamController = StreamController();
                      stream = streamController.stream;
                      setState(() {
                        search.text = '';
                      });
                      showMaterialModalBottomSheet(
                        context: context,
                        bounce: true,
                        duration: const Duration(milliseconds: 600),
                        builder: (context) => SingleChildScrollView(
                          controller: ModalScrollController.of(context),
                          child: Container(child: modalContent(context)),
                        ),
                      );
                    },
                      ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: books.length,
                itemBuilder: (BuildContext context,int index){
                  return GestureDetector(
                    onTap: (){
                      if(table == 'current_books'){
                        setState(() {
                          toggleIndex = 0;
                          pages.text = books[index]['done'];
                          dragPercentage = double.parse(books[index]['done']);
                          dragUpdate = double.parse(books[index]['done']) / double.parse(books[index]['total']) * 100;
                        });
                        showMaterialModalBottomSheet(
                          context: context,
                          bounce: true,
                          duration: const Duration(milliseconds: 600),
                          builder: (context) => SingleChildScrollView(
                            controller: ModalScrollController.of(context),
                            child: bookmark(id: books[index]['_id'], totalPages: int.parse(books[index]['total']), completedPages: int.parse(books[index]['done']),)

                        ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          SimpleShadow(
                            offset: const Offset(3, 3),
                            opacity: 0.4,         // Default: 0.5
                            color: Colors.black,   // Default: Black
                            sigma: 7,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                books[index]['thumb'],
                                scale: 1.4,

                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                                  child: Text(
                                    books[index]['name'],
                                    style: TextStyle(
                                      fontFamily: 'Hurme',
                                      fontSize: 13.sp,
                                      color: customBlackColor
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    books[index]['author'],
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                        fontFamily: 'Hurme',
                                      color: Colors.grey[700]
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10
                                ),
                                table == 'wishlist' ? Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: RatingStars(
                                    value: int.parse(books[index]['love']).toDouble(),
                                    onValueChanged: (v) async{
                                      print(v);
                                      setState(() {
                                        books[index]['love'] = v.toStringAsFixed(0);
                                      });
                                      print(books[index]['_id']);
                                      print(v.toStringAsFixed(0));
                                      Map<String, dynamic> row = {
                                        DatabaseHelper.columnId: books[index]['_id'],
                                        DatabaseHelper.columnLove: v.toStringAsFixed(0),
                                      };
                                      final rowsAffected = await DatabaseHelper.instance.update(row);
                                      print('updated $rowsAffected row(s)');
                                    },
                                    starBuilder: (index, color) => Icon(
                                      CupertinoIcons.heart_fill,
                                      color: color,
                                      size: 30,
                                    ),
                                    starCount: 3,
                                    starSize: 40,
                                    maxValue: 3,
                                    starSpacing: 5,
                                    valueLabelVisibility: false,
                                    animationDuration: Duration(milliseconds: 1000),
                                    valueLabelPadding:
                                    const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                                    valueLabelMargin: const EdgeInsets.only(right: 8),
                                    starOffColor: const Color(0xffe7e8ea),
                                    starColor: Colors.red,
                                  ),
                                ) : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${(int.parse(books[index]['done'])/int.parse(books[index]['total']) * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontFamily: 'hurme',
                                          color: Colors.grey[700]
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: LinearProgressIndicator(
                                              value: int.parse(books[index]['done'])/int.parse(books[index]['total']),
                                              backgroundColor: Colors.grey[350],
                                            )
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: (){
                                          showMaterialModalBottomSheet(
                                            context: context,
                                            bounce: true,
                                            duration: const Duration(milliseconds: 600),
                                            builder: (context) => SingleChildScrollView(
                                              controller: ModalScrollController.of(context),
                                              child: Container(child: BookOptions(id: books[index]['_id'],)),
                                            ),
                                          );
                                        },
                                          child: Icon(Icons.more_vert))

                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
              }
          ),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 245, 245, 245),
            borderRadius: const BorderRadius.all(
              Radius.circular(100),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10.0,
                offset: const Offset(10, 10),
                color: Colors.grey[350],
              ),
              const BoxShadow(
                blurRadius: 20.0,
                offset: Offset(-10, -10),
                color: Colors.white,
              )
            ],
          ),
          child: Icon(Icons.done, color: Colors.grey[700], size: 20.sp,),
        ),
        onPressed: () {
          showMaterialModalBottomSheet(
                          context: context,
                          bounce: true,
                          duration: const Duration(milliseconds: 600),
                          builder: (context) => SingleChildScrollView(
                            controller: ModalScrollController.of(context),
                            child: Container(child: completedBooks(context)),
                          ),
                        );
        },
      ),

    );
  }
}


