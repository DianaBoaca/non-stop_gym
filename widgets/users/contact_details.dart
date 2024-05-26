import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:non_stop_gym/widgets/users/custom_row.dart';

class ContactDetails extends StatefulWidget {
  const ContactDetails({
    super.key,
    required this.contactDetails,
  });

  final DocumentSnapshot<Map<String, dynamic>> contactDetails;

  @override
  ContactDetailsState createState() => ContactDetailsState();
}

class ContactDetailsState extends State<ContactDetails> {
  final String _apiKey = 'AIzaSyAjnIwY9BBxT-rT6g4qnv2xyqIR1FWqGho';
  double _lat = 0;
  double _long = 0;

  @override
  void initState() {
    super.initState();
    _getCoordinates();
  }

  Future<void> _getCoordinates() async {
    String address = widget.contactDetails['location'];
    Response response = await get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data =
          Map<String, dynamic>.from(json.decode(response.body));

      if (data['results'] != null && data['results'].isNotEmpty) {
        if (mounted) {
          setState(() {
            _lat = data['results'][0]['geometry']['location']['lat'];
            _long = data['results'][0]['geometry']['location']['lng'];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomRow(
            icon: Icons.alternate_email,
            text: widget.contactDetails['email'],
          ),
          CustomRow(
            icon: Icons.phone,
            text: widget.contactDetails['phone'],
          ),
          CustomRow(
            icon: Icons.web,
            text: widget.contactDetails['website'],
          ),
          const CustomRow(
            icon: Icons.watch_later_outlined,
            text: 'Deschis 24/7',
          ),
          CustomRow(
            icon: Icons.book,
            text: widget.contactDetails['location'],
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: () {
              MapsLauncher.launchCoordinates(_lat, _long);
            },
            child: _lat != 0 && _long != 0
                ? Image.network(
              'https://maps.googleapis.com/maps/api/staticmap?center=$_lat,$_long&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$_lat,$_long&key=$_apiKey',
              fit: BoxFit.cover,
            )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
