import 'package:alert/alert.dart';
import 'package:child_vaccination/Database/DataProvider.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateVaccineDetails extends StatefulWidget {
  UpdateVaccineDetails({Key? key, this.vaccineDetails, this.tableName})
      : super(key: key);

  final vaccineDetails;
  final tableName;

  @override
  _UpdateVaccineDetailsState createState() => _UpdateVaccineDetailsState();
}

class _UpdateVaccineDetailsState extends State<UpdateVaccineDetails> {
  String? dateS;
  String? dateG;
  String? given;
  TextEditingController hospitalController = TextEditingController();
  TextEditingController chargesController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.vaccineDetails != null) {
      setState(() {
        dateS = widget.vaccineDetails["Scheduled"] ?? "";
        dateG = widget.vaccineDetails["Given"] ?? "";
        given = widget.vaccineDetails["Status"] ?? "";
        hospitalController.text = widget.vaccineDetails["Hospital"] ?? "";
        chargesController.text = widget.vaccineDetails["Charges"] ?? "";
        notesController.text = widget.vaccineDetails["Notes"] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var size = (height * width) / 1000;
    return Scaffold(
      backgroundColor: Color(0xFFEFF2FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF243463),
        title: Text(
          'Vaccination Details',
          style: TextStyle(color: Color(0xFFEFF2FA)),
        ),
      ),
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
              padding: EdgeInsets.symmetric(
                  horizontal: width * 2 / 100, vertical: height * 0 / 100),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: height * 1 / 100),
                    child: Container(
                      height: height * 74 / 100,
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 4 / 100,
                          vertical: height * 1.5 / 100),
                      decoration: BoxDecoration(
                          color: Color(0xFFBEC4D4),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Update Vaccination Details',
                            style: TextStyle(
                                color: Color(0xFF243463),
                                fontSize: size * 7 / 100,
                                fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: height * 1 / 100),
                            child: Row(
                              children: [
                                Text(
                                  'Vaccine',
                                  style: TextStyle(fontSize: size * 6 / 100),
                                ),
                                Expanded(child: Container()),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: width * 2 / 100,
                                      left: width * 2 / 100),
                                  child: Container(
                                    width: width * 60 / 100,
                                    child: Text(
                                      widget.vaccineDetails['Vaccine'],
                                      textAlign: TextAlign.right,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: size * 6 / 100,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DateTimePicker(
                            initialValue: dateS,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            dateLabelText: 'Scheduled Date',
                            onChanged: (value) {
                              setState(() {
                                dateS = value;
                              });
                            },
                            onSaved: (val) => print(val),
                          ),
                          DateTimePicker(
                            initialValue:
                                (widget.vaccineDetails["Given"] == null)
                                    ? ""
                                    : dateG,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            dateLabelText: 'Given Date',
                            onChanged: (value) {
                              setState(() {
                                dateG = value;
                                given = 'Given';
                              });
                            },
                            onSaved: (val) => print(val),
                          ),
                          TextField(
                            controller: hospitalController,
                            decoration: InputDecoration(
                              labelText: "Hospital",
                            ),
                          ),
                          TextField(
                            controller: chargesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Fee/Charges",
                            ),
                          ),
                          TextField(
                            controller: notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: "Notes",
                            ),
                          ),
                          Container()
                        ],
                      ),
                    ),
                  ),
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
                            onPressed: () async{
                              try {
                                Map<String, dynamic> row = {
                                  "Cid": widget.vaccineDetails['Cid'],
                                  "Vaccine": widget.vaccineDetails["Vaccine"],
                                  "Scheduled": dateS,
                                  "Given": dateG,
                                  "Status": given,
                                  "Hospital": hospitalController.text,
                                  "Charges": chargesController.text,
                                  "Notes": notesController.text
                                };
                              await Provider.of<DataProvider>(context,
                                        listen: false)
                                    .updateVaccineTableRow(
                                        widget.tableName, row);

                                         Navigator.pop(context);

                                Alert(
                                    message:
                                        "Information is updated successfully").show();
                              } catch (e) {
                                Alert(
                                    message:
                                        "An error occurred").show();
                              }
                            },
                            child: Text(
                              'Update',
                              style: TextStyle(color: Color(0xFFEFF2FA)),
                            ))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // dateFormatConverter(value) {
  //   var modifiedValue = value.split('/');
  //   var newValue = modifiedValue.reversed.join('-');
  //   return newValue;
  // }
}
