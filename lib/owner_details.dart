import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart';
import 'package:pinterest_clone/home_screen.dart';
import 'package:pinterest_clone/widgets/rectangular_button.dart';

class OwnerDetails extends StatefulWidget {
  String img;
  String userImg;
  String name;
  DateTime date;
  String docId;
  String userId;
  int downloads;

  OwnerDetails({
    required this.img,
    required this.userImg,
    required this.date,
    required this.docId,
    required this.downloads,
    required this.name,
    required this.userId,
});

  @override
  State<OwnerDetails> createState() => _OwnerDetailsState();
}

class _OwnerDetailsState extends State<OwnerDetails> {

  int? total;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  color: Colors.red,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20.0, top: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.arrow_back),
                                iconSize: 22,
                                tooltip: 'Back to Home',
                                onPressed: (){
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                                },
                              ),
                            ],
                        ),
                      ),
                      Container(
                        child: Image.network(
                          widget.img,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30,),

                Text(
                  'Owner Information',
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 15,),

                Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        widget.userImg,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                
                Text(
                  'Uploaded by: ' + widget.name,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 10,),

                Text(
                  DateFormat("dd MMMM, yyyy - hh:mm a").format(widget.date).toString(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                    Text(
                      " " + widget.downloads.toString(),
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 50,),

                Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: RectangularButton(text: 'Download', colors1: Colors.green, colors2: Colors.lightGreen,
                    press: () async{
                      try{
                        var imageId = await ImageDownloader.downloadImage(widget.img);
                        if(imageId == null){
                          return;
                        }
                        Fluttertoast.showToast(msg: "Image Saved to Gallery");
                        total = widget.downloads + 1;
                        FirebaseFirestore.instance.collection('wallpaper').doc(widget.docId).update({
                          'downloads' : total,
                        }).then((value) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                        });
                      } on PlatformException catch (error){
                        print(error);
                      }
                    },
                  ),
                ),
                FirebaseAuth.instance.currentUser!.uid == widget.userId ?

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: RectangularButton(text: 'Delete', colors1: Colors.green, colors2: Colors.lightGreen,
                    press: () async{
                    FirebaseFirestore.instance.collection('wallpaper').doc(widget.docId).delete()
                        .then((value){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                    });
                    },
                  ),
                ) : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
