import 'dart:convert';

import 'package:bks/widgets/data.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../helper/database_helper.dart';
import '../main.dart';

class BookOptions extends StatefulWidget {
  final int id;
  BookOptions({@required this.id});
  @override
  State<BookOptions> createState() => _BookOptionsState();
}

class _BookOptionsState extends State<BookOptions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: customWhiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        // height: MediaQuery.of(context).size.height/2,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20,),
            Text('Options', style: TextStyle(fontFamily: 'Hurme', fontSize: 15.sp, fontWeight: FontWeight.bold),),
            ListView(
              shrinkWrap: true,
              children: [
                const Divider(),
                ListTile(
                  onTap: () async{
                    DateTime now = DateTime.now();
                    Map<String, dynamic> row = {
                      DatabaseHelper.columnId: widget.id,
                      DatabaseHelper.columnMAF: 1,
                      DatabaseHelper.columnDayEnded: jsonEncode({
                        'year': now.year,
                        'month': now.month,
                        'day': now.day
                      })
                    };
                    final rowsAffected = await DatabaseHelper.instance.update(row);
                    print('updated $rowsAffected row(s)');
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                  },
                  leading: Icon(Icons.mark_email_read, size: 20.sp,),
                  title: Text('Mark as finished', style: TextStyle(fontFamily: 'Hurme', fontSize: 12.sp, color: customBlackColor),),
                  subtitle: const Text('Will remove the book from bookshelf', style: TextStyle(fontFamily: 'Hurme'),),
                ),
                const Divider(),
                ListTile(
                  onTap: () async{
                    await DatabaseHelper.instance.delete(widget.id);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                  },
                  leading: Icon(Icons.delete, size: 20.sp, color: Colors.red[400],),
                  title: Text('Delete', style: TextStyle(fontFamily: 'Hurme', fontSize: 12.sp, color: Colors.red),),
                  subtitle: Text('Will permanently delete book data', style: TextStyle(fontFamily: 'Hurme', color: Colors.red[200]),),
                ),
                const Divider(),
              ],
            ),
          ],
        )
    );
  }
}