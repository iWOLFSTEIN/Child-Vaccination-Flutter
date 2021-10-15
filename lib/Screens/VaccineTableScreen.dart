import 'package:child_vaccination/Database/DataProvider.dart';
import 'package:child_vaccination/Screens/UpdateVaccineDetails.dart';
import 'package:child_vaccination/Services/AdIds.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class VaccineTableScreen extends StatefulWidget {
  VaccineTableScreen({Key? key, this.tableName, this.childName})
      : super(key: key);
  final tableName;
  final childName;

  @override
  _VaccineTableScreenState createState() => _VaccineTableScreenState();
}

class _VaccineTableScreenState extends State<VaccineTableScreen> {
  // var vaccinesList = [
  //   'BCG',
  //   'OPV-0',
  //   'DTP-1',
  //   'IPV-1',
  //   'OPV-1',
  //   'HB-1',
  //   'HIB-1',
  //   'Conjugate Pneumococcal',
  //   'ROTARIX-1',
  //   'DTP-2',
  //   'IPV-2',
  //   'OPV-2',
  //   'HB-2',
  //   'HIB-2',
  //   'Conjugate Pneumococcal',
  //   'ROTARIX-2',
  //   'DTP-3',
  //   'IPV-3',
  //   'OPV-3',
  //   'HIB-3',
  //   'INFLUENZA-1',
  //   'INFLUENZA-2',
  //   'HB-3',
  //   'OPV-4',
  //   'MEASLES',
  //   'HEPATITIS-A1',
  //   'CHICKEN POX',
  //   'MMR+VIT-A',
  //   'DTP-BOOSTER 1',
  //   'IPV-BOOSTER',
  //   'OPV-BOOSTER 1',
  //   'HIB-B1',
  //   'HEPATITIS A2',
  //   'Pneumo',
  //   'TYPHOID',
  //   'DTP-BOOSTER 2',
  //   'OPV-BOOSTER 2',
  //   'HB-BOOSTER',
  //   'MMR+VIT-A',
  // ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      loadInterstitialAd();
  }


  var _interstitialAd;
  loadInterstitialAd() => InterstitialAd.load(
      adUnitId: INTERSTITIAL_AD_ID,
      
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          // Keep a reference to the ad so you can show it later.
          this._interstitialAd = ad;

          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ));
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var size = (height * width) / 1000;
    var x = 0;

    var data = Provider.of<DataProvider>(context);

    var itemsData = data.itemsVaccine;

    List<Widget> widgetList = [
      for (var i in itemsData)
        tableRow(height, width,
            rowColor: (x++ % 2 == 0) ? Colors.white : Color(0xFFBEC4D4),
            vaccine: i['Vaccine'],
            scheduled: i['Scheduled'],
            given: (i['Given'] == null) ? "" : i['Given'],
            status: (i['Status'] == null) ? "" : i['Status'], voidCallBack: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return UpdateVaccineDetails(
              vaccineDetails: i,
              tableName: widget.tableName,
            );
          }));
        })
    ];

    return Scaffold(
      backgroundColor: Color(0xFFEFF2FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF243463),
        title: Text(
          'Vaccine Due',
          style: TextStyle(color: Color(0xFFEFF2FA)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                height: height * 1 / 100,
              ),
              Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                    color: Color(0xFF243463),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0 / 100, vertical: height * 1.6 / 100),
                child: Text(
                  widget.childName,
                  style: TextStyle(
                      color: Color(0xFFEFF2FA),
                      fontSize: size * 6.5 / 100,
                      fontWeight: FontWeight.w600),
                ),
              ),
              tableHeadingRow(height, width,
                  rowColor: Color(0xFF243463),
                  textColor: Color(0xFFEFF2FA),
                  vaccine: 'Vaccine',
                  scheduled: 'Scheduled On',
                  given: 'Given On',
                  status: 'Status',
                  heading: true),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: height * 1 / 100),
              child: ListView(
                children: widgetList,
              ),
            ),
          ),
        ],
      ),
    );
  }

  tableRow(double height, double width,
      {var textColor = Colors.black,
      var voidCallBack,
      var rowColor = Colors.white,
      // const Color(0xFFEFF2FA),
      var vaccine,
      var scheduled,
      var given,
      var status,
      var heading = false}) {
    var row = Container(
      color: rowColor,
      padding: EdgeInsets.symmetric(vertical: height * 2 / 100),
      // height: (heading) ? height * 5 / 100 : 0,
      child: Row(
        children: [
          tableCell(width, height, heading: vaccine, textColor: textColor),
          tableCell(width, height, heading: scheduled, textColor: textColor),
          tableCell(width, height, heading: given, textColor: textColor),
          tableCell(width, height, heading: status, textColor: textColor),
        ],
      ),
    );
    return (!heading)
        ? Padding(
            padding: EdgeInsets.only(top: height * 1 / 100),
            child: GestureDetector(
              onTap: voidCallBack,
              child: row,
            ),
          )
        : row;
  }

  tableHeadingRow(double height, double width,
      {var textColor = Colors.black,
      var voidCallBack,
      var rowColor = Colors.white,
      // const Color(0xFFEFF2FA),
      var vaccine,
      var scheduled,
      var given,
      var status,
      var heading = false}) {
    var row = Container(
      color: rowColor,
      height: height * 5 / 100,
      child: Row(
        children: [
          tableCell(width, height, heading: vaccine, textColor: textColor),
          tableCell(width, height, heading: scheduled, textColor: textColor),
          tableCell(width, height, heading: given, textColor: textColor),
          tableCell(width, height, heading: status, textColor: textColor),
        ],
      ),
    );
    return (!heading)
        ? Padding(
            padding: EdgeInsets.only(top: height * 1 / 100),
            child: GestureDetector(
              onTap: voidCallBack,
              child: row,
            ),
          )
        : row;
  }

  Container tableCell(double width, double height,
      {var heading, var textColor}) {
    return Container(
      width: width / 4,
      child: Center(
        child: Text(
          heading,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
    );
  }
}
