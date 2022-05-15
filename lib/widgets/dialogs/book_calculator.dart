import 'dart:convert';

import 'package:bks/widgets/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import 'package:sizer/sizer.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

import '../../views/home.dart';

class BookCalculator extends StatefulWidget {
  final int index;
  const BookCalculator({Key key, this.index}) : super(key: key);
  @override
  State<BookCalculator> createState() => _BookCalculatorState();
}

class _BookCalculatorState extends State<BookCalculator> {
  @override
  void initState() {
    _selectedDate = DateTime(
      jsonDecode(books[widget.index]['start'])['year'],
    jsonDecode(books[widget.index]['start'])['month'],
    jsonDecode(books[widget.index]['start'])['day'],

    );
    super.initState();
  }
  @override
  double readingEveryDay = 0;
  DateTime _selectedDate;
  DateTime _endDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter state){
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child:  AlertDialog(
              title: Text('Calculator', style: TextStyle(fontFamily: 'Hurme', color: customBlackColor),),
              content: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${books[widget.index]['name']}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Hurme',
                          fontSize: 12.sp,
                          color: customBlackColor
                      ),
                    ),
                    Text(
                      'started on ${
                          jsonDecode(books[widget.index.toInt()]['start'])['day']
                      }-${jsonDecode(books[widget.index.toInt()]['start'])['month']
                      }-${jsonDecode(books[widget.index.toInt()]['start'])['year']
                      }',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Hurme',
                          fontSize: 9.sp,
                          color: Colors.grey[700]
                      ),
                    ),
                    Text(
                      'contains ${books[widget.index]['total']} pages',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Hurme',
                          fontSize: 9.sp,
                          color: Colors.grey[700]
                      ),
                    ),
                    const SizedBox(height: 20,),
                    const Divider(),
                    Text(
                      'Will be reading each day',
                      style: TextStyle(
                          fontFamily: 'Hurme',
                          fontSize: 12.sp,
                          color: customBlackColor
                      ),
                    ),
                    CupertinoSlider(
                      value: readingEveryDay,
                      divisions: int.parse(books[widget.index]['total']),
                      onChanged: (_){
                        state((){
                          readingEveryDay = _;

                          _endDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day + int.parse(
                              '${

                                  (
                                    int.parse(books[widget.index]['total'])
                                      /
                                        (int.parse(books[widget.index]['total']) * readingEveryDay)

                                  ).toStringAsFixed(0)

                              }'

                            )
                          );
debugPrint(
    '${
        int.parse(books[widget.index]['total'])
            / (int.parse(books[widget.index]['total']) * readingEveryDay)
    }'
);
                        });
                      },
                    ),
                    Text(
                      '${(int.parse(books[widget.index]['total']) * readingEveryDay).toStringAsFixed(0)} Pages',
                      style: TextStyle(
                          fontFamily: 'Hurme',
                          fontSize: 12.sp,
                          color: customBlackColor
                      ),
                    ),const SizedBox(height: 20,),
                    const Divider(),
                    Text(
                      'Start date',
                      style: TextStyle(
                          fontFamily: 'Hurme',
                          fontSize: 12.sp,
                          color: customBlackColor
                      ),
                    ),
                    const SizedBox(height: 6,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width/2.0,
                      child: DatePicker(
                        DateTime(
                          jsonDecode(books[widget.index]['start'])['year'],
                          jsonDecode(books[widget.index]['start'])['month'],
                          jsonDecode(books[widget.index]['start'])['day'],
                        ),
                        initialSelectedDate: DateTime(
                          jsonDecode(books[widget.index]['start'])['year'],
                          jsonDecode(books[widget.index]['start'])['month'],
                          jsonDecode(books[widget.index]['start'])['day'],
                        ),
                        selectionColor: Colors.black,
                        selectedTextColor: Colors.white,
                        onDateChange: (date) {
                          state(() {
                            _selectedDate = date;
                            _endDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day + int.parse(
                                    '${

                                        (
                                            int.parse(books[widget.index]['total'])
                                                /
                                                (int.parse(books[widget.index]['total']) * readingEveryDay)

                                        ).toStringAsFixed(0)

                                    }'

                                )
                            );
                          });
                        },
                      ),
                    ),const Divider(),
                    Text(
                      'End date',
                      style: TextStyle(
                          fontFamily: 'Hurme',
                          fontSize: 12.sp,
                          color: customBlackColor
                      ),
                    ),
                    const SizedBox(height: 6,),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${DateFormat('MMM').format(_endDate).toUpperCase()}', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontFamily: 'hurme'),
                          ),
                          Text(
                            '${_endDate.day}', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'hurme'),
                          ),
                          Text(
                            '${DateFormat('EEE').format(_endDate).toUpperCase()}', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontFamily: 'hurme'),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                        'will take ${

                            (
                                int.parse(books[widget.index]['total'])
                                    /
                                    (int.parse(books[widget.index]['total']) * readingEveryDay)

                            ).toStringAsFixed(0)

                        } day(s)',
                      style: TextStyle(
                        fontFamily: 'Hurme',
                        fontSize: 9.sp,
                        color: Colors.grey[700]
                    ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancel", style: TextStyle(fontFamily: 'Hurme', color: customBlackColor),),
                  onPressed: () => Navigator.pop(context),
                ),

              ],
            ));
      },
    );
  }
}
