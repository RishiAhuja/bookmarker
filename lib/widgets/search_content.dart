import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../helper/database_helper.dart';
import '../main.dart';
import '../views/home.dart';
import 'data.dart';

Timer _debounce;
TextEditingController search = TextEditingController();
StreamController streamController;
Stream stream;

DateTime now = DateTime.now();

_searchBooks() async{
  if (search.text == null || search.text.isEmpty) {
    streamController.add(null);
    return;
  }
  String searchTerm;
  searchTerm = (search.text.trim()).replaceAll(' ', '+');
  print(search.text);
  print(searchTerm);
  streamController.add("waiting");

  final response = await http.get(Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$searchTerm'));
  streamController.add(json.decode(response.body));
  print(json.decode(response.body));


}

Widget modalContent (context) {
  return Container(
      color: customWhiteColor,
      height: MediaQuery.of(context).size.height/1.1,
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            width: MediaQuery.of(context).size.width/2.5,
            height: 15,
            decoration: BoxDecoration(
                color: customWhiteColor,
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
                    boxShadow: lightShadows,
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[200],
                    // border: Border.all(color: Colors.grey)
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
                    boxShadow: lightShadows,
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[200],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.search, size: 22.sp, color: customBlackColor,),
                    onPressed: (){
                      _searchBooks();
                    },
                  )
              ),
            ],
          ),
          StreamBuilder(
            stream: stream,
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
                          color: customBlackColor
                      ),
                    ),
                  ],
                );
              }

              if (snapshot.data == "waiting") {

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Lottie.asset('assets/json/find.json', width: MediaQuery.of(context).size.width),
                  ),

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
                                    Map<String, dynamic> row = {};
                                    if(table == 'current_books'){
                                      row = {
                                        DatabaseHelper.columnName: (snapshot.data['items'][index]['volumeInfo']['title']).toString(),
                                        DatabaseHelper.columnAuthor: (snapshot.data['items'][index]['volumeInfo']['authors'][0]).toString(),
                                        DatabaseHelper.columnThumbnail: (snapshot.data['items'][index]['volumeInfo']['imageLinks']['thumbnail']).toString(),
                                        DatabaseHelper.columnTotal: (snapshot.data['items'][index]['volumeInfo']['pageCount']).toString(),
                                        DatabaseHelper.columnDone: '0',
                                        DatabaseHelper.columnMAF: 0,
                                        DatabaseHelper.columnDayStarted: jsonEncode({
                                          'year': DateTime.now().year,
                                          'month': DateTime.now().month,
                                          'day': DateTime.now().day
                                        }),
                                        DatabaseHelper.columnDayEnded: null
                                      };
                                    }
                                    if(table == 'wishlist'){
                                      row = {
                                        DatabaseHelper.columnName: (snapshot.data['items'][index]['volumeInfo']['title']).toString(),
                                        DatabaseHelper.columnAuthor: (snapshot.data['items'][index]['volumeInfo']['authors'][0]).toString(),
                                        DatabaseHelper.columnThumbnail: (snapshot.data['items'][index]['volumeInfo']['imageLinks']['thumbnail']).toString(),
                                        DatabaseHelper.columnTotal: (snapshot.data['items'][index]['volumeInfo']['pageCount']).toString(),
                                        DatabaseHelper.columnLove: '0'
                                      };
                                    }
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