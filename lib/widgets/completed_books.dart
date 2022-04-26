import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: ListTile(
                  leading: DropShadowImage(
                    offset: Offset(0, 0),
                    scale: 1,
                    blurRadius: 1,
                    borderRadius: 10,
                    image: Image.network(
                      readBooks[index]['thumb'],
                      scale: 1.4,

                    ),
                  ),
                    //leading: Image.network(readBooks[index]['thumb'], scale: 1.4,),
                    title: Text(readBooks[index]['name'], style: TextStyle(fontFamily: 'Hurme', color: customBlackColor),),
                    subtitle: Text(readBooks[index]['author'], style: TextStyle(fontFamily: 'Hurme', color: customBlackColor),)

                ),
              );
            }
        ),
      ],
    ),
  );
}