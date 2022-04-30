import 'dart:convert';

import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_shadow/simple_shadow.dart';

import '../views/home.dart';
import 'data.dart';

Widget completedBooks(context){
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
        ),),): ListView.builder(
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
                      Column(
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
                                Text(
                                  'From ${jsonDecode(readBooks[index]['start'])['day']}-${jsonDecode(readBooks[index]['start'])['month']}-${jsonDecode(readBooks[index]['start'])['year']}',
                                  style: TextStyle(
                                      fontFamily: 'Hurme',
                                      color: customBlackColor
                                  ),
                                ),
                                Text(
                                  ' to ${jsonDecode(readBooks[index]['end'])['day']}-${jsonDecode(readBooks[index]['end'])['month']}-${jsonDecode(readBooks[index]['end'])['year']}',
                                  style: TextStyle(
                                      fontFamily: 'Hurme',
                                      color: customBlackColor
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              'In ${
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
                                fontFamily: 'Hurme'
                              ),
                            ),
                          )

                        ],
                      )
                    ],
                  ),
                ),
              );
            }
        ),
      ],
    ),
  );
}