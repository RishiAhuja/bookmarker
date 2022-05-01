import 'dart:convert';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_shadow/simple_shadow.dart';

import '../helper/database_helper.dart';
import '../main.dart';
import '../views/home.dart';
import 'data.dart';

DateTime selectedDate = DateTime.now();
TextEditingController _dateController = TextEditingController();
Widget completedBooks(context){
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        color: customWhiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height/1.4,
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(
              width: MediaQuery.of(context).size.width/2.5,
              height: 15,
              decoration: BoxDecoration(
                color: customBlackColor,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 20),
            readBooks.isEmpty ? Container(child: Center(child: Column(
              children: [
                Lottie.asset('assets/json/notfound.json'),
                Text(
                  'No books are completed',
                  style: TextStyle(
                      fontSize: 14,
                      color: customBlackColor,
                      fontFamily: 'Hurme'
                  ),
                ),
                const SizedBox(height: 30,),
              ],
            ),),): Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Completed books',
                    style: TextStyle(
                      fontFamily: 'Hurme',
                      fontSize: 18.sp,
                      color: customBlackColor
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height/1.5,
                  child: ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: readBooks.length,
                      itemBuilder: (BuildContext context,int index){
                        print(readBooks);
                        print(jsonDecode(readBooks[index]['start'])['day']);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
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
                                      readBooks[index]['thumb'],
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
                                          readBooks[index]['name'],
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
                                          readBooks[index]['author'],
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
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20.0),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () async{
                                                DatePicker.showDatePicker(context,
                                                    showTitleActions: true,
                                                    minTime: DateTime(2010, 1, 1),
                                                    maxTime: DateTime.now(), onChanged: (date) {
                                                      print('change $date');
                                                    }, onConfirm: (date) async{
                                                      print('confirm $date');
                                                      setState((){
                                                        readBooks[index]['start'] = jsonEncode({
                                                          'year': date.year,
                                                          'month': date.month,
                                                          'day': date.day,
                                                        });
                                                      });
                                                      Map<String, dynamic> row = {
                                                        DatabaseHelper.columnId: readBooks[index]['_id'],
                                                        DatabaseHelper.columnDayStarted: jsonEncode({
                                                          'year': date.year,
                                                          'month': date.month,
                                                          'day': date.day,
                                                        })
                                                      };
                                                      final rowsAffected = await DatabaseHelper.instance.update(row);
                                                      print('updated $rowsAffected row(s)');
                                                    }, currentTime: DateTime(
                                                      jsonDecode(readBooks[index]['start'])['year'],
                                                      jsonDecode(readBooks[index]['start'])['month'],
                                                      jsonDecode(readBooks[index]['start'])['day'],
                                                    ), locale: LocaleType.en);
                                              },
                                              child: Text(
                                                'From ${jsonDecode(readBooks[index]['start'])['day']}-${jsonDecode(readBooks[index]['start'])['month']}-${jsonDecode(readBooks[index]['start'])['year']}',
                                                style: TextStyle(
                                                    fontFamily: 'Hurme',
                                                    color: customBlackColor
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async{
                                                DatePicker.showDatePicker(context,
                                                    showTitleActions: true,
                                                    minTime: DateTime(
                                                      jsonDecode(readBooks[index]['start'])['year'],
                                                      jsonDecode(readBooks[index]['start'])['month'],
                                                      jsonDecode(readBooks[index]['start'])['day'],
                                                    ),
                                                    maxTime: DateTime.now(), onChanged: (date) {
                                                      print('change $date');
                                                    }, onConfirm: (date) async{
                                                      print('confirm $date');
                                                      setState((){
                                                        readBooks[index]['end'] = jsonEncode({
                                                          'year': date.year,
                                                          'month': date.month,
                                                          'day': date.day,
                                                        });
                                                      });
                                                      Map<String, dynamic> row = {
                                                        DatabaseHelper.columnId: readBooks[index]['_id'],
                                                        DatabaseHelper.columnDayEnded: jsonEncode({
                                                          'year': date.year,
                                                          'month': date.month,
                                                          'day': date.day,
                                                        })
                                                      };
                                                      final rowsAffected = await DatabaseHelper.instance.update(row);
                                                      print('updated $rowsAffected row(s)');
                                                    }, currentTime: DateTime(
                                                      jsonDecode(readBooks[index]['end'])['year'],
                                                      jsonDecode(readBooks[index]['end'])['month'],
                                                      jsonDecode(readBooks[index]['end'])['day'],
                                                    ), locale: LocaleType.en);
                                              },
                                              child: Text(
                                                ' to ${jsonDecode(readBooks[index]['end'])['day']}-${jsonDecode(readBooks[index]['end'])['month']}-${jsonDecode(readBooks[index]['end'])['year']}',
                                                style: TextStyle(
                                                    fontFamily: 'Hurme',
                                                    color: customBlackColor
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20),
                                            child: Text(
                                              'Completed in ${
                                                  DateTime(
                                                    jsonDecode(readBooks[index]['end'])['year'],
                                                    jsonDecode(readBooks[index]['end'])['month'],
                                                    jsonDecode(readBooks[index]['end'])['day'],
                                                  ).difference(
                                                      DateTime(
                                                        jsonDecode(readBooks[index]['start'])['year'],
                                                        jsonDecode(readBooks[index]['start'])['month'],
                                                        jsonDecode(readBooks[index]['start'])['day'],
                                                      )
                                                  ).inDays
                                              } days',
                                              style: TextStyle(
                                                  fontFamily: 'Hurme',
                                                  color: customBlackColor
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () async{
                                                await DatabaseHelper.instance.delete(readBooks[index]['_id']);
                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                                              },
                                              icon: const Icon(Icons.delete, color: Colors.red,)
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: Text(
                                          '${
                                              (int.parse(readBooks[index]['total']) /
                                                DateTime(
                                                  jsonDecode(readBooks[index]['end'])['year'],
                                                  jsonDecode(readBooks[index]['end'])['month'],
                                                  jsonDecode(readBooks[index]['end'])['day'],
                                                ).difference(
                                                    DateTime(
                                                      jsonDecode(readBooks[index]['start'])['year'],
                                                      jsonDecode(readBooks[index]['start'])['month'],
                                                      jsonDecode(readBooks[index]['start'])['day'],
                                                    )
                                                ).inDays).toStringAsFixed(1)
                                          } every day',
                                          style: TextStyle(
                                              fontFamily: 'Hurme',
                                              color: customBlackColor
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}