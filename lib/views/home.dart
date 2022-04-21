import 'package:bks/helper/database_helper.dart';
import 'package:bks/main.dart';
import 'package:bks/widgets/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import 'package:toggle_switch/toggle_switch.dart';
import 'package:wave_slider/wave_slider.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

Timer _debounce;
TextEditingController search = TextEditingController();
StreamController _streamController;
Stream _stream;
double _dragPercentage = 0;
double _dragUpdate = 0;

List books = [];
bool loading = true;

int toggleIndex = 0;
_searchBooks() async{
  if (search.text == null || search.text.isEmpty) {
    _streamController.add(null);
    return;
  }
  String searchTerm;
  searchTerm = (search.text.trim()).replaceAll(' ', '+');
  print(search.text);
  print(searchTerm);
  _streamController.add("waiting");

  final response = await http.get(Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$searchTerm'));
  _streamController.add(json.decode(response.body));
  print(json.decode(response.body));


}
TextEditingController pages = TextEditingController();
class bookmark extends StatefulWidget {
  final int totalPages;
  final int completedPages;
  final int id;
  bookmark({@required this.completedPages, @required this.totalPages, @required this.id});
  @override
  State<bookmark> createState() => _bookmarkState();
}

class _bookmarkState extends State<bookmark> {
  @override
  Widget build(BuildContext context) {
    return
      Container(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width/2.5,
                height: 15,
                decoration: BoxDecoration(
                    color: lightBlack,
                    borderRadius: BorderRadius.circular(30)
                ),
              ),
              const SizedBox(height: 15),
              ToggleSwitch(
                minWidth: 60.0,
                minHeight: 45.0,
                fontSize: 16.0,
                cornerRadius: 18.0,
                initialLabelIndex: toggleIndex,
                activeBgColor: [lightBlack],
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey[350],
                inactiveFgColor: Colors.grey[900],
                totalSwitches: 2,
                iconSize: 24.sp,
                radiusStyle: true,
                icons: const [
                  Icons.bookmark,
                  Icons.book
                ],
                dividerColor: Colors.grey[300],
                onToggle: (index) {
                  print('switched to: $index');
                  setState(() {
                    toggleIndex = index;
                    if(index == 0){
                      _dragUpdate = widget.completedPages.toDouble() / widget.totalPages.toDouble() * 100;
                      pages.text = (widget.completedPages.toDouble() / widget.totalPages.toDouble() * 100).toStringAsFixed(0);
                    }
                    else{
                      _dragUpdate = 100;
                      pages.text = widget.totalPages.toString();

                    }
                  });
                },
              ),
              const SizedBox(height: 15),
              Text(
                toggleIndex == 0 ? 'Bookmark the page where you left' : 'Total number of pages in the book',
                style: TextStyle(
                  color: lightBlack,
                  fontFamily: 'Hurme'
                ),
              ),
              // const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  width: double.maxFinite,
                  child: CupertinoSlider(
                    value: _dragUpdate,
                    max: 100,
                    min: 0,
                    onChanged: (double dragUpdate) {
                      setState(() {
                        _dragUpdate = dragUpdate;
                        _dragPercentage = dragUpdate * widget.totalPages;
                        pages.text = (_dragPercentage / 100.0).toStringAsFixed(0); // dragUpdate is a fractional value between 0 and 1
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      // width: double.minPositive,
                      constraints: const BoxConstraints(
                        maxWidth: 40,
                        minWidth: 20,
                        maxHeight: 60
                      ),
                      child: TextFormField(
                        // initialValue: _dragPercentage.toStringAsFixed(0),
                        controller: pages,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 16.sp, fontFamily: 'Hurme'),
                        decoration: const InputDecoration(
                          // border: InputBorder.none,
                        ),
                      ),
                    ),
                    Text(
                       ' Pages',
                      style: TextStyle(fontSize: 16.sp, fontFamily: 'Hurme'),
                    ),
                  ],
                )
              ),
              const SizedBox(height: 10,),
              InkWell(
                onTap: () async{
                  if(toggleIndex==0){
                    Map<String, dynamic> row = {
                      DatabaseHelper.columnId   : widget.id,
                      DatabaseHelper.columnDone : pages.text.toString(),
                      DatabaseHelper.columnTotal  : widget.totalPages.toString()
                    };
                    final rowsAffected = await DatabaseHelper.instance.update(row);
                    print('updated $rowsAffected row(s)');
                  }
                  if(toggleIndex == 1){
                    Map<String, dynamic> row = {
                      DatabaseHelper.columnId   : widget.id,
                      DatabaseHelper.columnDone : widget.completedPages.toString(),
                      DatabaseHelper.columnTotal  : pages.text.toString()
                    };
                    final rowsAffected = await DatabaseHelper.instance.update(row);
                    print('updated $rowsAffected row(s)');
                  }
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width/2,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.lightBlueAccent,
                        Colors.lightBlue,
                        Colors.blue
                      ]
                    ),
                    boxShadow: lowOpaShadow
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      toggleIndex == 0 ? 'Bookmark' : 'Save Total Pages',
                      style: TextStyle(
                        fontFamily: 'Hurme',
                        color: Colors.white,
                        fontSize: 15.sp
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30,),
            ],
          )
      );
  }
}


Widget modalContent (context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height/1.1,
    child: Column(
      children: [
        const SizedBox(height: 15),
        Container(
          width: MediaQuery.of(context).size.width/2.5,
          height: 15,
          decoration: BoxDecoration(
            color: lightBlack,
            borderRadius: BorderRadius.circular(30)
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              width: MediaQuery.of(context).size.width/1.5,
              decoration: BoxDecoration(
                boxShadow: lowOpaShadow,
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey)
              ),
              child: TextFormField(
                controller: search,
                onChanged: (value){
                  if (_debounce?.isActive ?? false) _debounce.cancel();
                  _debounce = Timer(const Duration(milliseconds: 2000), () {
                    _searchBooks();
                  });
                },
                style: const TextStyle(fontFamily: 'Hurme'),
                decoration: const InputDecoration(
                  hintStyle: TextStyle(fontFamily: 'Hurme'),
                  hintText: 'Search a book',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 15,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                  boxShadow: lowOpaShadow,
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey)
              ),
              child: IconButton(
                icon: Icon(Icons.search, size: 22.sp,),
                onPressed: (){
                  _searchBooks();
                },
              )
            ),
          ],
        ),
        StreamBuilder(
          stream: _stream,
          builder: (BuildContext ctx, AsyncSnapshot snapshot){
            if (snapshot.data == null) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Lottie.asset('assets/json/plane.json'),
                  const SizedBox(height: 10),
                  Text('type in search bar to find books',
                    style: TextStyle(
                      fontFamily: 'Hurme',
                      fontSize: 12.sp,
                      color: lightBlack
                    ),
                  ),
                ],
              );
            }

            if (snapshot.data == "waiting") {

              return Center(
                child: Lottie.asset('assets/json/find.json'),

              );
            }
            return SizedBox(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 60.h,
                    child: ListView.builder(
                      shrinkWrap: true,
                        itemCount: snapshot.data['items'].length,
                        itemBuilder: (BuildContext context, int index){
                          return Column(
                            children: [
                              InkWell(
                                onTap: () async{
                                  Map<String, dynamic> row = {
                                    DatabaseHelper.columnName: (snapshot.data['items'][index]['volumeInfo']['title']).toString(),
                                    DatabaseHelper.columnAuthor: (snapshot.data['items'][index]['volumeInfo']['authors'][0]).toString(),
                                    DatabaseHelper.columnThumbnail: (snapshot.data['items'][index]['volumeInfo']['imageLinks']['thumbnail']).toString(),
                                    DatabaseHelper.columnTotal: (snapshot.data['items'][index]['volumeInfo']['pageCount']).toString(),
                                    DatabaseHelper.columnDone: '0'
                                  };
                                  books.add(row);
                                  final id = await DatabaseHelper.instance.insert(row);
                                  print('inserted row id: $id');
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: ListTile(
                                      leading: Image.network(snapshot.data['items'][index]['volumeInfo']['imageLinks']['thumbnail']),
                                      title: Text(snapshot.data['items'][index]['volumeInfo']['title'], style: const TextStyle(fontFamily: 'Hurme'),),
                                      subtitle: Text(snapshot.data['items'][index]['volumeInfo']['authors'][0], style: const TextStyle(fontFamily: 'Hurme'),)

                                ),
                                ),
                              ),
                              Divider(color: Colors.grey[350],)
                            ],
                          );
                        }
                    ),
                  ),
                  // const SizedBox(height: 10,),
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(width: 20,),
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue
                          ),
                          child:
                            Icon(Icons.add, color: Colors.white, size: 30.sp,)
                        ),
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: const [
                              ListTile(
                                title: Text(
                                  "Can't find it?",
                                  style: TextStyle(fontFamily: 'Hurme'),
                                ),
                                subtitle: Text(
                                  "Add book manually",
                                  style: TextStyle(fontFamily: 'Hurme'),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        )
      ],
    )
  );
}


class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    _streamController = StreamController();
    _stream = _streamController.stream;

    fetchInitData();

    super.initState();
  }
  fetchInitData() async{
    //-------getting-data-------//
    setState(() {
      loading = true;
    });
    final allRows = await DatabaseHelper.instance.queryAllRows();
    print('query all rows:');
    setState(() {
      books.clear();
      allRows.forEach((row){
        print(row);
        books.add(row);
      });
      loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return loading ? Center(child: CircularProgressIndicator(),) : Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                'bookshelf',
                style: TextStyle(
                  fontFamily: 'Hurme',
                  fontSize: 23.sp,
                  color: textColor,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Container(

                    decoration: BoxDecoration(
                      boxShadow: lightShadows,
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white
                    ),
                    child: IconButton(
                    icon: Icon(Icons.add, color: Colors.black, size: 20.sp), onPressed: () {
                      _streamController = StreamController();
                      _stream = _streamController.stream;
                      showMaterialModalBottomSheet(
                        context: context,
                        bounce: true,
                        duration: const Duration(milliseconds: 1200),
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
                      setState(() {
                        toggleIndex = 0;
                        pages.text = books[index]['done'];
                        _dragPercentage = double.parse(books[index]['done']);
                        _dragUpdate = double.parse(books[index]['done']) / double.parse(books[index]['total']) * 100;
                      });
                      showMaterialModalBottomSheet(
                        context: context,
                        bounce: true,
                        duration: const Duration(milliseconds: 1200),
                        builder: (context) => SingleChildScrollView(
                          controller: ModalScrollController.of(context),
                          child: Container(child: bookmark(id: books[index]['_id'], totalPages: int.parse(books[index]['total']), completedPages: int.parse(books[index]['done']),)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              books[index]['thumb'],
                              scale: 1.4,
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
                                      fontSize: 13.sp
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
                                  height: 20
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: int.parse(books[index]['done'])/int.parse(books[index]['total']),
                                    ),
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
    );
  }
}
