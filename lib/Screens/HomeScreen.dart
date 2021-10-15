import 'package:alert/alert.dart';
import 'package:animations/animations.dart';
import 'package:child_vaccination/Database/DataProvider.dart';
import 'package:child_vaccination/Database/DatabaseHelper.dart';
import 'package:child_vaccination/Screens/ChildDetailsScreen.dart';
import 'package:child_vaccination/Screens/VaccineTableScreen.dart';
import 'package:child_vaccination/Services/AdIds.dart';
import 'package:child_vaccination/main.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var database = DatabaseHelper.instance;
  var bannerAd;
  Offset? _tapDownPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bannerAd = myBanner();
    bannerAd.load();
  }

  data() async {
    var a = await database.queryAllChildrenRows();
    var b = await database.queryRowCount();
    print(a);
    print(b);
    var c = await database.queryAllVaccineRows(
        a[12]['Name'].replaceAll(' ', '') + a[12]['Id'].toString());
    print(a[12]['Name'].replaceAll(' ', '') + a[12]['Id'].toString());
    for (var i in c) {
      print(i);
    }
  }

  bool isBannerLoaded = false;

  BannerAd myBanner() => BannerAd(
        adUnitId: BANNER1_AD_ID,
        size: AdSize.getSmartBanner(Orientation.portrait),
        //AdSize.smartBanner,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Ad loaded.');
            setState(() {
              isBannerLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            setState(() {
              isBannerLoaded = false;
            });
            ad.dispose();
            print('Ad failed to load: $error');
          },
          onAdOpened: (Ad ad) => print('Ad opened.'),
          onAdClosed: (Ad ad) => print('Ad closed.'),
          onAdImpression: (Ad ad) => print('Ad impression.'),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var size = (height * width) / 1000;

    AdWidget adWidget = AdWidget(
      ad: bannerAd,
    );

    var data = Provider.of<DataProvider>(context);
    var itemsData = data.items.reversed;
    var x = 0;
    List<Widget> items = [
      for (var i in itemsData)
        childContainer(height, width, size,
            imageAddress: (i['Gender'] == 'Boy')
                ? 'images/knight.png'
                : 'images/princess.png',
            color: (x++ % 2 == 0) ? Color(0xFFBEC4D4) : Color(0xFF243463),
            name: i['Name'],
            voidCallBackInfo: () {}, voidCallBackSignleTap: () {
          var tableName = i['Name'] + i['Id'].toString();
          try {
            Provider.of<DataProvider>(context, listen: false).itemsVaccine =
                tableName;
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return VaccineTableScreen(
                tableName: tableName,
                childName: i['Name'],
              );
            }));
          } catch (e) {
            Alert(
                    message:
                        //e.toString()
                        'An error occurred')
                .show();
          }
        }, voidCallBackLongPressed: () {
          showMenu(
            position: RelativeRect.fromLTRB(
                _tapDownPosition!.dx, _tapDownPosition!.dy, 0, 0),
            items: <PopupMenuEntry>[
              PopupMenuItem(
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      navigationKey.currentState!
                          .push(MaterialPageRoute(builder: (context) {
                        return ChildDetailsScreen(
                          editChildDetails: true,
                          childData: i,
                        );
                      }));
                    },
                    child: Text("Edit Details")),
              ),
              PopupMenuItem(
                onTap: () async {
                  try {
                    await Provider.of<DataProvider>(context, listen: false)
                        .deleteChildrenTableRow(i['Id'], i['Name']);
                  } catch (e) {
                    print(e.toString());
                  }
                },
                child: Text("Delete"),
              ),
            ],
            context: context,
          );
        }, dob: i['Date']),
    ];

    // items.insert(0, ad);

    return Scaffold(
      //   key: navigationKey,
      appBar: AppBar(
        title: Text(
          'Child Vaccination',
          style: TextStyle(color: Color(0xFFEFF2FA)),
        ),
        backgroundColor: Color(0xFF243463),
      ),
      backgroundColor: Color(0xFFEFF2FA),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Image.asset('images/design1.png'),
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: (isBannerLoaded)
                  ? EdgeInsets.only(top: 90)
                  : EdgeInsets.only(top: 0),
              child: Column(children: items
                  // childrenWidgetsList(context, height, width, size, itemsData),
                  ),
            ),
          ),
          Container(
            // color: Colors.blue.withOpacity(0.6),
            child: adWidget,
            width: width,
            height: (isBannerLoaded) ? 90 : 0,
          )
        ],
      )
      //     ;
      //   }
      // )
      ,
      floatingActionButton: OpenContainer(
        closedElevation: 2,
        // transitionDuration: Duration(milliseconds: 2000),
        openColor: Color(0xFF243463),
        closedColor: Color(0xFF243463),
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(75)
                // BorderRadius.all(Radius.circular(20))
                ),
        openShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        closedBuilder: (context, action) => Material(
          color: Color(0xFF243463),
          borderRadius: BorderRadius.circular(75),
          child: CircleAvatar(
            backgroundColor: Color(0xFF243463),
            radius: 29,
            child: Center(
              child: Icon(
                Icons.add,
                color: Color(0xFFEFF2FA),
              ),
            ),
          ),
        ),
        openBuilder: (context, action) => ChildDetailsScreen(),
      ),
    );
  }

  Padding childContainer(double height, double width, double size,
      {var imageAddress,
      var name,
      var dob,
      var color,
      var voidCallBackInfo,
      var voidCallBackSignleTap,
      var voidCallBackLongPressed}) {
    return Padding(
      padding: EdgeInsets.only(
          top: height * 1 / 100, left: width * 3 / 100, right: width * 3 / 100),
      child: GestureDetector(
        onTapDown: (TapDownDetails details) {
          setState(() {
            _tapDownPosition = details.globalPosition;
          });
        },
        onTap: voidCallBackSignleTap,
        onLongPress: voidCallBackLongPressed,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          height: height * 14 / 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(),
              Image.asset(
                imageAddress,
                height: height * 11 / 100,
                width: width * 17 / 100,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(),
                  Text(
                    name,
                    style: TextStyle(
                        color: (color == Color(0xFF243463))
                            ? Color(0xFFEFF2FA)
                            : Colors.black.withOpacity(0.7),
                        fontSize: size * 6.7 / 100,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: height * 1.4 / 100,
                  ),
                  Text(
                    'Birth Date:  $dob',
                    style: TextStyle(
                        color: (color == Color(0xFF243463))
                            ? Color(0xFFEFF2FA).withOpacity(0.4)
                            : Colors.black.withOpacity(0.4)),
                  ),
                  // Container(),
                ],
              ),
              Container(),
              Container(),
              IconButton(
                onPressed: voidCallBackInfo,
                splashColor: Colors.white,
                icon: Icon(Icons.info_outline),
                color: (color == Color(0xFF243463))
                    ? Color(0xFFEFF2FA).withOpacity(0.4)
                    : Colors.black.withOpacity(0.4),
              ),
              Container(),
            ],
          ),
        ),
      ),
      // openBuilder: (context, action) => VaccineTableScreen(),
      //  ),
    );
  }
}
