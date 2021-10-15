import 'package:alert/alert.dart';
import 'package:animations/animations.dart';
import 'package:child_vaccination/Database/DataProvider.dart';
import 'package:child_vaccination/Database/DatabaseHelper.dart';
import 'package:child_vaccination/Services/AdIds.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class ChildDetailsScreen extends StatefulWidget {
  ChildDetailsScreen({Key? key, this.editChildDetails = false, this.childData})
      : super(key: key);
  final editChildDetails;
  final childData;
  @override
  _ChildDetailsScreenState createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen>
    with SingleTickerProviderStateMixin {
  var bannerAd;

  String? name;
  String? date;

  String? selectedGender = 'Boy';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.editChildDetails) {
      setState(() {
        name = widget.childData['Name'];
        date = widget.childData['Date'];
        // phoneNumber = widget.childData['Number'];
        // email = widget.childData['Email'];
        selectedGender = widget.childData['Gender'];
      });
    }

    bannerAd = myBanner();
    bannerAd.load();
  }

  bool isBannerLoaded = false;

  BannerAd myBanner() => BannerAd(
        adUnitId: BANNER2_AD_ID,
        size: AdSize.getSmartBanner(Orientation.portrait),
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Ad loaded.');
            setState(() {
              isBannerLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            print('Ad failed to load: $error');
            setState(() {
              isBannerLoaded = false;
            });
          },
          onAdOpened: (Ad ad) => print('Ad opened.'),
          onAdClosed: (Ad ad) => print('Ad closed.'),
          onAdImpression: (Ad ad) => print('Ad impression.'),
        ),
      );

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var size = (height * width) / 1000;
    AdWidget adWidget = AdWidget(
      ad: bannerAd,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Child Information',
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
                  ? EdgeInsets.symmetric(
                      horizontal: width * 2 / 100, vertical: 90)
                  : EdgeInsets.symmetric(
                      horizontal: width * 2 / 100, vertical: height * 0 / 100),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height * 1 / 100),
                      child: Container(
                        height: height / 2.5,
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 4 / 100,
                            vertical: height * 1.5 / 100),
                        decoration: BoxDecoration(
                            color: Color(0xFFBEC4D4),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Child Personal Info',
                              style: TextStyle(
                                  color: Color(0xFF243463),
                                  fontSize: size * 7 / 100,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextFormField(
                              initialValue: (widget.editChildDetails)
                                  ? widget.childData['Name']
                                  : '',
                              onChanged: (value) {
                                setState(() {
                                  name = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please enter a name';
                                }
                                if (value.isEmpty) {
                                  return 'Please enter a name';
                                }
                              },
                              decoration: InputDecoration(
                                labelText: "Name",
                              ),
                            ),
                            DateTimePicker(
                              initialValue: (widget.editChildDetails)
                                  ? widget.childData['Date']
                                  : '',
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              dateLabelText: 'Date',
                              onChanged: (value) {
                                setState(() {
                                  date = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a date';
                                }
                                if (value.isEmpty) {
                                  return 'Please select a date';
                                }
                              },
                              onSaved: (val) => print(val),
                            ),
                            DropdownButton<String>(
                              style: TextStyle(
                                  fontSize: size * 5.5 / 100,
                                  color: Colors.black),
                              value: selectedGender,
                              isExpanded: true,
                              items:
                                  <String>['Boy', 'Girl'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                });
                              },
                            ),
                            Container()
                          ],
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(top: height * 1 / 100),
                    //   child: Container(
                    //     height: height / 2.9,
                    //     padding: EdgeInsets.symmetric(
                    //         horizontal: width * 4 / 100,
                    //         vertical: height * 1.5 / 100),
                    //     decoration: BoxDecoration(
                    //         color: Color(0xFFBEC4D4),
                    //         borderRadius:
                    //             BorderRadius.all(Radius.circular(25))),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //       children: [
                    //         Text(
                    //           'Child Personal Info',
                    //           style: TextStyle(
                    //               color: Color(0xFF243463),
                    //               fontSize: size * 7 / 100,
                    //               fontWeight: FontWeight.w600),
                    //         ),
                    //         TextFormField(
                    //           initialValue: (widget.editChildDetails)
                    //               ? widget.childData['Number']
                    //               : '',
                    //           keyboardType: TextInputType.number,
                    //           decoration: InputDecoration(
                    //             labelText: "Mobile",
                    //           ),
                    //           onChanged: (value) {
                    //             setState(() {
                    //               phoneNumber = value;
                    //             });
                    //           },
                    //           validator: (value) {
                    //             if (value == null) {
                    //               return 'Please enter a number';
                    //             }
                    //             if (value.isEmpty) {
                    //               return 'Please enter a number';
                    //             }
                    //           },
                    //         ),
                    //         TextFormField(
                    //           initialValue: (widget.editChildDetails)
                    //               ? widget.childData['Email']
                    //               : '',
                    //           keyboardType: TextInputType.emailAddress,
                    //           decoration: InputDecoration(
                    //             labelText: "Email",
                    //           ),
                    //           onChanged: (value) {
                    //             setState(() {
                    //               email = value;
                    //             });
                    //           },
                    //           validator: (value) {
                    //             if (value == null) {
                    //               return 'Please enter an email';
                    //             }
                    //             if (value.isEmpty) {
                    //               return 'Please enter an email';
                    //             }
                    //           },
                    //         ),
                    //         Container(),
                    //         Container()
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: EdgeInsets.only(top: height * 1.5 / 100),
                      child: Container(
                          width: width,
                          height: height * 5.5 / 100,
                          decoration: BoxDecoration(
                              color: Color(0xFF243463),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: TextButton(
                              onPressed: (widget.editChildDetails)
                                  ? () async {
                                      if (formKey.currentState!.validate()) {
                                        try {
                                          Map<String, dynamic> row = {
                                            'Id': widget.childData['Id'],
                                            'Name': name,
                                            'Date': date,
                                            'Gender': selectedGender,
                                            // 'Number': phoneNumber,
                                            // 'Email': email
                                          };
                                          // print(row);

                                          // DatabaseHelper db =
                                          //     DatabaseHelper.instance;

                                          if (!(date ==
                                              widget.childData['Date'])) {
                                            await Provider.of<DataProvider>(
                                                    context,
                                                    listen: false)
                                                .deleteChildrenTableRow(
                                                    widget.childData['Id'],
                                                    name);

                                            await Provider.of<DataProvider>(
                                                    context,
                                                    listen: false)
                                                .addChildrenTableRow(row);
                                          } else {
                                            await Provider.of<DataProvider>(
                                                    context,
                                                    listen: false)
                                                .updateChildrenTableRow(row);
                                          }
                                          Navigator.pop(context);

                                          Alert(
                                                  message:
                                                      'Information is updated successfully!')
                                              .show();
                                        } catch (e) {
                                          print(e.toString());
                                          Alert(message: 'An error occurred')
                                              .show();
                                        }
                                      }
                                    }
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        try {
                                          Map<String, dynamic> row = {
                                            'Name': name,
                                            'Date': date,
                                            'Gender': selectedGender,
                                            // 'Number': phoneNumber,
                                            // 'Email': email
                                          };

                                          await Provider.of<DataProvider>(
                                                  context,
                                                  listen: false)
                                              .addChildrenTableRow(row);

                                          Navigator.pop(context);

                                          Alert(
                                                  message:
                                                      'Information is saved successfully!')
                                              .show();
                                        } catch (e) {
                                          print(e.toString());
                                          Alert(message: 'An error occurred')
                                              .show();
                                        }
                                      }
                                    },
                              child: Text(
                                (widget.editChildDetails) ? 'Update' : 'Add',
                                style: TextStyle(color: Color(0xFFEFF2FA)),
                              ))),
                    ),
                  ],
                ),
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
      ),
    );
  }
}
