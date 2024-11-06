import 'package:airtown_app/commonFunctions/keys.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as commons;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:airtown_app/screens/components/section_builder.dart';
import 'package:airtown_app/screens/components/temp_const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:airtown_app/commonFunctions/dataRequest.dart';
import 'package:airtown_app/screens/ExplorePage/location_list.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:airtown_app/.test_data/simulationUsersMaps.dart';

//REFERS TO https://github.com/nurshat13/Flutter-Spotify-UI-Clone

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Search text
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 20),
              child: Text(
                "What are you\nlooking for?",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Raleway",
                    fontStyle: FontStyle.normal,
                    fontSize: 32.0),
              ),
            ),
          ),
          // search-text-field
          /*SliverAppBar(
            backgroundColor: Colors.white, // const Color(0xff121212),
            expandedHeight: 56,
            floating: true,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              centerTitle: true,
              titlePadding: EdgeInsets.symmetric(vertical: 5),
              title: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                    color: Color(0xff747474),
                  ),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: const TextField(
                  style: TextStyle(
                      color: Color(0xff747474),
                      fontWeight: FontWeight.w700,
                      fontFamily: "Raleway",
                      fontStyle: FontStyle.normal,
                      fontSize: 13.0),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),

                      //ImageIcon(AssetImage('$kAssetIconsWay/search.png'),

                      //),
                      contentPadding: EdgeInsets.only(top: 15),
                      hintText: 'Where do you like to go?'),
                ),
              ),
            ),
          ),
          
          */
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 18, left: 16, right: 16, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionBuilder(
                      sectionTitle: 'Your favorite places',
                      titlePadding: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.only(bottom: 16),
                      sectionBodyBuilder: (context) {
                        return SearchSectionItemBuilder(
                          list: kPlaylistSdded,
                        );
                      }),
                  SectionBuilder(
                      sectionTitle: 'Browse All',
                      padding: EdgeInsets.zero,
                      titlePadding: const EdgeInsets.only(bottom: 10),
                      sectionBodyBuilder: (context) {
                        return SearchSectionItemBuilder(
                          list: kAllSearh,
                        );
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchSectionItemBuilder extends StatelessWidget {
  SearchSectionItemBuilder({
    Key? key,
    required this.list,
  }) : super(key: key);

  final List list;
  final destinationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    void findHealtierPlace() async {
      Position position;
      void getLocation() async {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        //print("[!] POSITION: $position --- ${position.latitude}");
      }

      getLocation(); // get user position

      if (destinationController.text != "") {
        
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        print("[!] POSITION: $position --- ${position.latitude}");
        
        Fluttertoast.showToast(
          msg: "Searching for ${destinationController.text} ",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.black,
          fontSize: 16,
          backgroundColor: Colors.grey[200],
        );
        
        // Ask nearby places with AQI integration:
        var activityData = await getNearActivity(
            // get nearby places
            place_type: destinationController.text,
            lat: position.latitude,
            lng: position.longitude);
        

        /*
        // for simulation purpose:
        if (simulationSetting == 3){
          print("[S] Simulation setting $simulationSetting.");
          print("[S] Simulate user 1.");
          String jsonData = await retrieveModel(commons.userId);
          commons.modelManager.initialize(jsonData, get_test_user(1));    

          List<double> alphas = [0, 0.3, 0.5, 0.7, 1];

          Map<double,Map<String,Map<String,double>>> summary = {};
          alphas.forEach((alpha) { 
            // Set weigth 
            commons.modelManager.set_alpha(alpha);

            // Make predictions
            Map recsData = commons.modelManager.predict(activityData);

            // Print prediction:
            print("[S3] For ALPHA: $alpha");

            Map<String,Map<String,double>> alphaSummary = {};
            recsData.forEach((placeName, data) { 
              print("$placeName: AQI: ${activityData[placeName]['AQI']}, score: ${data}");
              Map<String,double> temp = {};
              temp["AQI"] = activityData[placeName]['AQI'];
              temp["score"] = data;
              alphaSummary[placeName] = temp;
            });
            summary[alpha] = alphaSummary;


            
          });

            Map<String, Map<double, Map<String, Map<String, double>>>> finalMap = {};
            finalMap["summary"] = summary;
            postEvaluation(finalMap);

        }
        */
        // * user 1
        if (simulationSetting == 1){ 
            print("[S] Simulate user $simulationSetting.");       
            String jsonData = await retrieveModel(commons.userId);
            commons.modelManager.initialize(jsonData, get_test_user(simulationSetting));
        }
        
        // * user 2
        if (simulationSetting == 2){
            print("[S] Simulate user $simulationSetting.");
            String jsonData = await retrieveModel(commons.userId);
            commons.modelManager.initialize(jsonData, get_test_user(simulationSetting));
        }

        

        // Set weigths
        List<double> alphas = [0.0, 0.3, 0.5, 0.7, 1];
        Map <double, dynamic> dataToDisplay = {};
        alphas.forEach((alpha) { 
          
          commons.modelManager.set_alpha(alpha);
          Map<String,double> recsData = commons.modelManager.predict(activityData);

          // Order data retrieved from google by recommandation score and add prediction
          Map<String, dynamic> alphaData = {};
          recsData.forEach((key, value) {
            
            Map temp_data = activityData[key];
            
            temp_data["rating"] = activityData[key]["rating"].toDouble();
          
            alphaData[key] = temp_data;
            alphaData[key]["recScore"] = value;
            alphaData[key]["isExpanded"] = false;
            alphaData[key]["containsPhoto"] = false;

            dataToDisplay[alpha] = alphaData;
          });
        });

        // commons.modelManager.set_alpha(CPAlpha);

        // Make predictions
        // Map recsData = commons.modelManager.predict(activityData);
        // recsData is a Map <placeName,prediction> sorted descending by predictions
          
        print("------------------EDITING");

          /*
        // Now we re-organize data:
        Map<String,dynamic> dataToDisplay = {};

        // Order data retrieved from google by recommandation score and add prediction
        recsData.forEach((key, value) {
          
          Map temp_data = activityData[key];

          // Sometimes rating are double, sometimes are int; to overcome errors,
          // convert all in double
          temp_data["rating"] = activityData[key]["rating"].toDouble();
          
          dataToDisplay[key] = temp_data;
          dataToDisplay[key]["recScore"] = value;
          dataToDisplay[key]["isExpanded"] = false;
          dataToDisplay[key]["containsPhoto"] = false;

        });
        */
        var polygonsData = await getPolygons();

        Navigator.push(
          context,
          MaterialPageRoute(

            builder: (context) => LocationList(
              myPosition: LatLng(position.latitude,position.longitude),
              datas: dataToDisplay,
              polygons: polygonsData,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Please, enter destination",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.black,
          fontSize: 16,
          backgroundColor: Colors.grey[200],
        );
      }

      // hide loader:
      if (context.loaderOverlay.visible){
        context.loaderOverlay.hide();
      }
    }

    return SizedBox(
      // ignore: division_optimization
      height: 120 * ((list.length / 2 + 1).toInt()).toDouble(),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 11),
          itemCount: list.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
                onTap: () {
                  // Show loading spinner
                  context.loaderOverlay.show();
                  
                  print(
                      "Tap ${list[index].title}, search for ${list[index].value}");
                  destinationController.text = list[index].value;
                  // Search places
                  findHealtierPlace();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: list[index].color,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Stack(
                    children: [
                      // img
                      Positioned(
                        right: -15,
                        bottom: -10,
                        child: RotationTransition(
                          turns: const AlwaysStoppedAnimation(10 / 360),
                          child: Container(
                            width: 83,
                            height: 83,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(list[index].img),
                                  fit: BoxFit.cover),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                      // text
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 11),
                        child: Text(list[index].title,
                            style: const TextStyle(
                                color: Color(0xffffffff),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Raleway",
                                fontStyle: FontStyle.normal,
                                fontSize: 13.0),
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ));
          }),
    );
  }
}
