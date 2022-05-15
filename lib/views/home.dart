import 'dart:convert';

import 'package:bks/helper/database_helper.dart';
import 'package:bks/main.dart';
import 'package:bks/widgets/data.dart';
import 'package:bks/widgets/search_content.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:sizer/sizer.dart';

import 'dart:async';

import '../widgets/book_options.dart';
import '../widgets/bookmark.dart';
import '../widgets/completed_books.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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
        });
        loading = false;
      });
    }else{
      setState(() {
        loading = true;
      });
      final allRows = await DatabaseHelper.instance.queryAllRows();
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
      key: _scaffoldKey,
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
      body: books.isEmpty ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/json/empty.json',),
            const Text(
              'Add books by clicking the + button at top right',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Hurme'
              ),
            ),
            const SizedBox(height: 40,)
          ],
        ),
      ) : SingleChildScrollView(
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
                      setState(() {
                        toggleIndex = 0;
                        pages.text = books[index]['done'];
                        dragPercentage = double.parse(books[index]['done']);
                        dragUpdate = double.parse(books[index]['done']) / double.parse(books[index]['total']) * 100;
                      });
                      if(table == 'current_books'){

                        showMaterialModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30.0),
                            ),
                          ),
                          context: context,
                          //bounce: true,
                          expand: false,
                          enableDrag: true,
                          duration: const Duration(milliseconds: 600),
                          builder: (context) => SingleChildScrollView(
                              controller: ModalScrollController.of(context),
                              child: bookmark(index: index, id: books[index]['_id'], totalPages: int.parse(books[index]['total']), completedPages: int.parse(books[index]['done']),)

                        ),
                        //   builder: (context) => bookmark(index: index, id: books[index]['_id'], totalPages: int.parse(books[index]['total']), completedPages: int.parse(books[index]['done']),),
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
                                loadingBuilder: (BuildContext context, Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                                            child: Text(
                                              books[index]['name'],
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: 'Hurme',
                                                  fontSize: 12.sp,
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
                                                  color: Colors.grey[700],
                                                  fontSize: 10.sp,
                                                fontWeight: FontWeight.w200
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    table == 'wishlist' ? Container() : Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        children: [
                                          Tooltip(
                                            message: 'Tentative expected date of completion of the book, ${books[index]['name']}',
                                            triggerMode: TooltipTriggerMode.tap,
                                            showDuration: const Duration(seconds: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[400],
                                            ),
                                            waitDuration: const Duration(seconds: 0),
                                            textStyle: TextStyle(
                                              fontFamily: 'Hurme',
                                              color: customBlackColor,
                                            ),
                                            height: 100,
                                            child: Icon(Icons.info, color: Colors.grey[400],),
                                          ),
                                          const SizedBox(width: 6,),
                                          Container(
                                            child: (int.parse(books[index]['done']) / int.parse((DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day,
                                            ).difference(
                                                DateTime(
                                                  jsonDecode(books[index]['start'])['year'],
                                                  jsonDecode(books[index]['start'])['month'],
                                                  jsonDecode(books[index]['start'])['day'],
                                                )
                                            ).inDays + 1).toString()) ).toStringAsFixed(1) == '0.0' ? Container() : Text(
                                               DateFormat('dd-MM-yyyy').format(DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day +
                                                      int.parse(

                                                          ( (int.parse(books[index]['total']) -
                                                              int.parse(books[index]['done']) )
                                                              /
                                                              (int.parse(books[index]['done']) / int.parse((DateTime(
                                                                DateTime.now().year,
                                                                DateTime.now().month,
                                                                DateTime.now().day,
                                                              ).difference(
                                                                  DateTime(
                                                                    jsonDecode(books[index]['start'])['year'],
                                                                    jsonDecode(books[index]['start'])['month'],
                                                                    jsonDecode(books[index]['start'])['day'],
                                                                  )
                                                              ).inDays + 1).toString()) ) ).toStringAsFixed(0)
                                                      ))
                                              ),
                                              style: TextStyle(
                                                  fontFamily: 'Hurme',
                                                  fontSize: 12,
                                                  color: customBlackColor
                                                // color: Colors.white
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 10
                                ),
                                table == 'wishlist' ? Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RatingStars(
                                        value: int.parse(books[index]['love']).toDouble(),
                                        onValueChanged: (v) async{
                                          setState(() {
                                            books[index]['love'] = v.toStringAsFixed(0);
                                          });
                                          Map<String, dynamic> row = {
                                            DatabaseHelper.columnId: books[index]['_id'],
                                            DatabaseHelper.columnLove: v.toStringAsFixed(0),
                                          };
                                          final rowsAffected = await DatabaseHelper.instance.update(row);
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
                                        animationDuration: const Duration(milliseconds: 1000),
                                        valueLabelPadding:
                                        const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                                        valueLabelMargin: const EdgeInsets.only(right: 8),
                                        starOffColor: Colors.grey[350],
                                        starColor: Colors.red,
                                      ),
                                      IconButton(
                                          onPressed: () async{
                                            _scaffoldKey.currentState.showSnackBar(const SnackBar(duration: Duration(milliseconds: 500),content: Text('Deleting data...', style: TextStyle(fontFamily: 'Hurme'))));
                                            await DatabaseHelper.instance.delete(readBooks[index]['_id']).then((value) {
                                              _scaffoldKey.currentState.showSnackBar(const SnackBar(content: Text('Deleted successfully', style: TextStyle(fontFamily: 'Hurme'))));
                                              });
                                            setState(() {
                                              books.removeAt(index);
                                            });
                                            },
                                          icon: Icon(Icons.delete, color: Colors.grey[600],)
                                      ),
                                    ],
                                  ),
                                ) : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${(int.parse(books[index]['done'])/int.parse(books[index]['total']) * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontFamily: 'hurme',
                                              color: Colors.grey[700],
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
                                              child: const Icon(Icons.more_vert))

                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${
                                              (int.parse(books[index]['done']) / int.parse((DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                DateTime.now().day,
                                              ).difference(
                                                  DateTime(
                                                    jsonDecode(books[index]['start'])['year'],
                                                    jsonDecode(books[index]['start'])['month'],
                                                    jsonDecode(books[index]['start'])['day'],
                                                  )
                                              ).inDays + 1).toString()) ).toStringAsFixed(1)
                                          } pages / day',
                                          style: TextStyle(
                                              fontFamily: 'Hurme',
                                              color: Colors.grey[800],
                                            fontWeight: FontWeight.w300
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
            shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),
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


