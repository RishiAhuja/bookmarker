import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:sizer/sizer.dart';

import '../helper/database_helper.dart';
import '../main.dart';
import '../views/home.dart';
import 'data.dart';

int toggleIndex = 0;
double dragPercentage = 0;
double dragUpdate = 0;

bool focusNode = false;
//variables common to both main widget and this widget


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
          color: customWhiteColor,
          child: Column(
            children: [
              const SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width/2.5,
                height: 15,
                decoration: BoxDecoration(
                    color: customBlackColor,
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
                activeBgColor: [customBlackColor],
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
                      dragUpdate = widget.completedPages.toDouble() / widget.totalPages.toDouble() * 100;
                      pages.text = widget.completedPages.toString();
                    }
                    else{
                      dragUpdate = 100;
                      pages.text = widget.totalPages.toString();

                    }
                  });
                },
              ),
              const SizedBox(height: 15),
              Text(
                toggleIndex == 0 ? 'Bookmark the page where you left' : 'Total number of pages in the book',
                style: TextStyle(
                    color: customBlackColor,
                    fontFamily: 'Hurme'
                ),
              ),
              // const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  width: double.maxFinite,

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Text(
                          '${(dragUpdate).toStringAsFixed(0)}%',
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
                                value: dragUpdate/100,
                                backgroundColor: Colors.grey[350],
                              )
                          ),
                        ),
                        const SizedBox(width: 10)

                      ],
                    ),
                  )
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
                        child: FocusScope(
                          child: Focus(
                            onFocusChange: (focus){
                              print(focus);
                              setState(() {
                                focusNode = focus;
                              });
                            },
                            child: TextFormField(
                              controller: pages,
                              onChanged: (_){
                                setState(() {
                                  if(int.parse(pages.text) <= widget.totalPages){
                                    dragUpdate = double.parse(pages.text) / double.parse(('${widget.totalPages}')) * 100;
                                  }
                                });
                              },
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 16.sp, fontFamily: 'Hurme', color: customBlackColor),
                              decoration: const InputDecoration(
                                // border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        ' Pages',
                        style: TextStyle(fontSize: 16.sp, fontFamily: 'Hurme', color: customBlackColor),
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
                      // color: customWhiteColor,
                      gradient: const LinearGradient(
                          colors: [
                            Colors.lightBlueAccent,
                            Colors.lightBlue,
                            Colors.blue
                          ]
                      ),
                      boxShadow: lightShadows
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      toggleIndex == 0 ? 'Bookmark' : 'Save Total Pages',
                      style: TextStyle(
                          fontFamily: 'Hurme',
                          // color: customBlackColor,
                          color: Colors.white,
                          fontSize: 15.sp
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              focusNode ? SizedBox(height: MediaQuery.of(context).size.height/2.5,) : Container()
            ],
          )
      );
  }
}