import 'dart:convert';
import 'dart:ui';

import 'package:bks/widgets/dialogs/book_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:simple_shadow/simple_shadow.dart';
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

Map todayToMap = {
  'year': DateTime.now().year,
  'month': DateTime.now().month,
  'day': DateTime.now().day,
};

// Future<Color> getImagePalette (ImageProvider imageProvider) async {
//   final PaletteGenerator paletteGenerator = await PaletteGenerator
//       .fromImageProvider(imageProvider);
//   return paletteGenerator.dominantColor.color;
// }

class bookmark extends StatefulWidget {
  final int totalPages;
  final int completedPages;
  final int id;
  final int index;
  bookmark({@required this.index, @required this.completedPages, @required this.totalPages, @required this.id});
  @override
  State<bookmark> createState() => _bookmarkState();
}

class _bookmarkState extends State<bookmark> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
            color: customWhiteColor,
            child: Column(
              children: [
                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (context) => BookCalculator(index: widget.index,)
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 7, 12, 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                                boxShadow: lightShadows,
                                borderRadius: BorderRadius.circular(50),
                                color: customWhiteColor
                            ),
                            child: IconButton(
                              icon: Icon(Icons.calculate, color: customBlackColor, size: 20.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 7, 12, 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                                boxShadow: lightShadows,
                                borderRadius: BorderRadius.circular(50),
                                color: customWhiteColor
                            ),
                            child: IconButton(
                              icon: Icon(Icons.clear, color: customBlackColor, size: 20.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                SimpleShadow(
                  offset: const Offset(3, 3),
                  opacity: 0.4,         // Default: 0.5
                  color: Colors.black,   // Default: Black
                  sigma: 7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: books[widget.index]['thumb'] == 'null' ? ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          ([Colors.redAccent, Colors.blue, Colors.orangeAccent, Colors.deepPurpleAccent, Colors.white]..shuffle()).first,
                          BlendMode.color,
                        ),
                        child: Image.asset('assets/img/ramwall.jpg', scale: 1.4)) : Image.network(
                      books[widget.index]['thumb'],
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
                const SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${books[widget.index]['name']}',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Hurme',
                        fontSize: 12.sp,
                        color: customBlackColor
                    ),
                  ),
                ),
                Text(
                  '${books[widget.index]['author']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'Hurme',
                      fontSize: 9.sp,
                      color: Colors.grey[700]
                  ),
                ),
                const SizedBox(height: 25),

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
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async{
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            minTime: DateTime(2010, 1, 1),
                            maxTime: DateTime.now(), onChanged: (date) {
                            }, onConfirm: (date) async{
                              setState((){
                                books[widget.index]['start'] = jsonEncode({
                                  'year': date.year,
                                  'month': date.month,
                                  'day': date.day,
                                });
                              });
                              Map<String, dynamic> row = {
                                DatabaseHelper.columnId: books[widget.index]['_id'],
                                DatabaseHelper.columnDayStarted: jsonEncode({
                                  'year': date.year,
                                  'month': date.month,
                                  'day': date.day,
                                })
                              };
                              final rowsAffected = await DatabaseHelper.instance.update(row);
                            }, currentTime: DateTime(
                              jsonDecode(books[widget.index]['start'])['year'],
                              jsonDecode(books[widget.index]['start'])['month'],
                              jsonDecode(books[widget.index]['start'])['day'],
                            ), locale: LocaleType.en);
                      },
                      child: Text(
                        'Started at ${jsonDecode(books[widget.index]['start'])['day']}-${jsonDecode(books[widget.index]['start'])['month']}-${jsonDecode(books[widget.index]['start'])['year']}',
                        style: TextStyle(
                            fontFamily: 'Hurme',
                            color: customBlackColor
                        ),
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 15),

                // const SizedBox(height: 10,),
                toggleIndex != 0 ? Container() : Padding(
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
                              maxWidth: 35,
                              minWidth: 20,
                              maxHeight: 60
                          ),
                          child: FocusScope(
                            child: Focus(
                              onFocusChange: (focus){
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
                ),              const SizedBox(height: 10,),
                toggleIndex == 0 ? GestureDetector(
                  onTap: () async{
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2010, 1, 1),
                        maxTime: DateTime.now(), onChanged: (date) {
                        }, onConfirm: (date) async{
                          setState(() {
                            todayToMap = {
                              'year': date.year,
                              'month': date.month,
                              'day': date.day
                            };
                          });
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                  child: Text(
                    'Bookmarking on ${DateFormat.yMMMd().format(DateTime(todayToMap['year'], todayToMap['month'], todayToMap['day']))}',
                      style: TextStyle(
                          color: customBlackColor,
                          fontFamily: 'Hurme'
                      ),
                  ),
                ) : Text(
                  'Total number of pages',
                    style: TextStyle(
                        color: customBlackColor,
                        fontFamily: 'Hurme'
                    ),
                ),
                // Text(
                //   toggleIndex == 0 ? 'Bookmark the page where you left' : 'Total number of pages in the book',
                //   style: TextStyle(
                //       color: customBlackColor,
                //       fontFamily: 'Hurme'
                //   ),
                // ),
                const SizedBox(height: 10,),
                // Text(books[widget.index]['color']),
                InkWell(
                  onTap: () async{
                    if(toggleIndex==0){

                      int readToday = 0;
                      int remaining = 0;
                      bool goalAchieved = false;
                      double average = books[widget.index]['done'] == 0 ? 0 : (int.parse(books[widget.index]['done']) / int.parse((DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      ).difference(
                          DateTime(
                            jsonDecode(books[widget.index]['start'])['year'],
                            jsonDecode(books[widget.index]['start'])['month'],
                            jsonDecode(books[widget.index]['start'])['day'],
                          )
                      ).inDays + 1).toString()) );

                      List datesReading = jsonDecode(books[widget.index]['data']).keys.toList();
                      final Map sessions = jsonDecode(books[widget.index]['data']);

                      if(datesReading.contains(jsonEncode(todayToMap))){
                        debugPrint('ayo!');
                        sessions.update(
                          jsonEncode(todayToMap),
                            (value) => {

                                'readToday': (value)['readToday'] + int.parse(pages.text) - int.parse(books[widget.index]['done']),
                                'remaining': int.parse(books[widget.index]['total']) - int.parse(pages.text),
                                'goalAchieved': (value)['readToday'] + int.parse(pages.text) - int.parse(books[widget.index]['done']) >= average ? true : false

                            }
                         );
                      }else{
                        debugPrint('not ayo!');
                        sessions[jsonEncode(todayToMap)] = ({
                          'readToday': int.parse(pages.text) - int.parse(books[widget.index]['done']),
                          'remaining': int.parse(books[widget.index]['total']) - int.parse(pages.text),
                          'goalAchieved':  int.parse(pages.text) - int.parse(books[widget.index]['done']) >= average ? true : false
                        });
                        print(sessions);
                      }

                      Map<String, dynamic> row = {
                        DatabaseHelper.columnId: widget.id,
                        DatabaseHelper.columnDone: pages.text.toString(),
                        DatabaseHelper.columnTotal: widget.totalPages.toString(),
                        DatabaseHelper.columnData: jsonEncode(sessions)
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
                    }
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width/2,
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: books[widget.index]['color'] == null ? Colors.blue :Color(int.parse(books[widget.index]['color'].split('(0x')[1].split(')')[0], radix: 16)),
                        boxShadow: lightShadows
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        toggleIndex == 0 ? 'Bookmark' : 'Save Total Pages',
                        style: TextStyle(
                            fontFamily: 'Hurme',
                            // color: customBlackColor,
                            // color: Colors.white,
                            color: Color(int.parse(books[widget.index]['color'].split('(0x')[1].split(')')[0], radix: 16)).red * 0.299 + Color(int.parse(books[widget.index]['color'].split('(0x')[1].split(')')[0], radix: 16)).green * 0.587 + Color(int.parse(books[widget.index]['color'].split('(0x')[1].split(')')[0], radix: 16)).blue * 0.114 > 128 ? customBlackColor : Colors.white,
                            fontSize: 15.sp
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8,),
                // focusNode ? SizedBox(height: MediaQuery.of(context).size.height/2.5,) : Container(),
                const Divider(thickness: 2,),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              reverse: true,
            itemCount: jsonDecode(books[widget.index]['data']).values.toList().length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context,int index){
                print(jsonDecode(books[widget.index]['data']));
              return Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(DateFormat.yMMMd().format(
                                  DateTime(
                                      jsonDecode(jsonDecode(books[widget.index]['data']).keys.toList()[index])['year'],
                                      jsonDecode(jsonDecode(books[widget.index]['data']).keys.toList()[index])['month'],
                                      jsonDecode(jsonDecode(books[widget.index]['data']).keys.toList()[index])['day']
                                  )
                              ),
                          style: const TextStyle(
                            fontFamily: 'Hurme'
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width/4,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: customBlackColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Read', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontFamily: 'hurme'),
                              ),
                              Text(
                                '${jsonDecode(books[widget.index]['data']).values.toList()[index]['readToday']}', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'hurme'),
                              ),
                              Text(
                                'pages', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontFamily: 'hurme'),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width/4,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: customBlackColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Left', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontFamily: 'hurme'),
                              ),
                              Text(
                                '${jsonDecode(books[widget.index]['data']).values.toList()[index]['remaining']}', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'hurme'),
                              ),
                              Text(
                                'pages', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontFamily: 'hurme'),
                              )
                            ],
                          ),
                        ),Container(
                          width: MediaQuery.of(context).size.width/4,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: customBlackColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Goal', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontFamily: 'hurme'),
                              ),
                              jsonDecode(books[widget.index]['data']).values.toList()[index]['goalAchieved'] == true ? Text(
                                'yes', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'hurme'),
                              ) : Text(
                                'no', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontFamily: 'hurme'),
                              ),
                              Text(
                                'Achieved', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontFamily: 'hurme'),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
              // return ListTile(
              //
              //     trailing: Text("GFG",
              //       style: TextStyle(
              //           color: Colors.green,fontSize: 15),),
              //     title:Text('$index')
              // );
            }
        ),
              ],
            )
        ),
      );
  }
}