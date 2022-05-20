import 'dart:convert';
import 'dart:ui';

import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../helper/database_helper.dart';
import '../main.dart';
import '../views/home.dart';
import 'data.dart';

class AddCustomBook extends StatefulWidget {
  const AddCustomBook({Key key}) : super(key: key);

  @override
  State<AddCustomBook> createState() => _AddCustomBookState();
}

class _AddCustomBookState extends State<AddCustomBook> {
  TextEditingController book = TextEditingController();
  TextEditingController author = TextEditingController();
  TextEditingController totalPages = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: customWhiteColor,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Lottie.asset('assets/json/flipbook.json', repeat: false),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                width: MediaQuery.of(context).size.width/1.5,
                decoration: BoxDecoration(
                  boxShadow: lightShadows,
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[200],
                ),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter book name';
                    }
                    return null;
                  },
                  controller: book,
                  style: const TextStyle(fontFamily: 'Hurme'),
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(fontFamily: 'Hurme'),
                    hintText: 'Type book name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter author name';
                    }
                    return null;
                  },
                  controller: author,
                  style: const TextStyle(fontFamily: 'Hurme'),
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(fontFamily: 'Hurme'),
                    hintText: 'Type Author Name',
                    border: InputBorder.none,
                  ),
                ),
              ),const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                width: MediaQuery.of(context).size.width/1.5,
                decoration: BoxDecoration(
                  boxShadow: lightShadows,
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[200],
                  // border: Border.all(color: Colors.grey)
                ),
                child: TextFormField(keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter total pages';
                    }
                    return null;
                  },
                  controller: totalPages,
                  style: const TextStyle(fontFamily: 'Hurme'),
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(fontFamily: 'Hurme'),
                    hintText: 'Type total pages',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              AnimatedButton(
                child: Text(
                  'Add book!',
                  style: TextStyle(
                    fontFamily: 'Hurme',
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                color: Colors.blue,
                onPressed: () async{
                  if(_formKey.currentState.validate()){
                    Map<String, dynamic> row = {};
                    if(table == 'current_books'){
                      row = {
                        DatabaseHelper.columnName: book.text.trim(),
                        DatabaseHelper.columnAuthor: author.text.trim(),
                        DatabaseHelper.columnThumbnail: 'null',
                        DatabaseHelper.columnTotal: totalPages.text.trim(),
                        DatabaseHelper.columnDone: '0',
                        DatabaseHelper.columnMAF: 0,
                        DatabaseHelper.columnDayStarted: jsonEncode({
                          'year': DateTime.now().year,
                          'month': DateTime.now().month,
                          'day': DateTime.now().day
                        }),
                        DatabaseHelper.columnDayEnded: null,
                        DatabaseHelper.columnData: jsonEncode(
                            {
                              jsonEncode({'year': DateTime.now().year, 'month': DateTime.now().month, 'day': DateTime.now().day}) : {
                                'readToday': 0,
                                'remaining': 0,
                                'goalAchieved': false,
                              }
                            }
                        )
                      };
                    }
                    if(table == 'wishlist'){
                      row = {
                        DatabaseHelper.columnName: book.text.trim(),
                        DatabaseHelper.columnAuthor: author.text.trim(),
                        DatabaseHelper.columnThumbnail: 'null',
                        DatabaseHelper.columnTotal: totalPages.text.trim(),
                        DatabaseHelper.columnLove: '0'
                      };
                    }
                    books.add(row);
                    final id = await DatabaseHelper.instance.insert(row);
                    print('inserted row id: $id');
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                  }
                },
                enabled: true,
                shadowDegree: ShadowDegree.light,
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
