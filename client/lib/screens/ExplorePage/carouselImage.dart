import 'package:flutter/material.dart';

import '../../commonFunctions/dataRequest.dart';


Widget buildCarousel(BuildContext context, myphotoList) {
  var photoList = myphotoList;
  print("PHOTOLIST: $photoList");
  return Container(
      padding: EdgeInsets.all(5),
      child: photoList != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  // you may want to use an aspect ratio here for tablet support
                  height: 200.0,
                  child: PageView.builder(
                    itemCount: photoList.length,
                    // store this controller in a State to save the carousel scroll position
                    controller: PageController(viewportFraction: 0.8),
                    itemBuilder: (BuildContext context, int itemIndex) {
                      return _buildCarouselItem(context, photoList[itemIndex]);
                    },
                  ),
                )
              ],
            )
          : Text("No photos available"));
}

Widget _buildCarouselItem(BuildContext context, dynamic itemUrl) {

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: /*getPhotoFromServer(itemUrl[
          "photo_reference"]),*/
      Image.network(fetchPhotoUrlForServer(itemUrl[
          "photo_reference"]),   
          /*  
          loadingBuilder: (context, child, progress){
            return progress == null
            ? child
            : const CircularProgressIndicator(strokeWidth = 1.0);
          }*/), 
    ),
  );
}

