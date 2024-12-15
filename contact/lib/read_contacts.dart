import 'dart:async';
import 'package:contact/MyHomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Onboarding/onboarding_view.dart';

class ReadContacts extends StatefulWidget {
  const ReadContacts({super.key});

  @override
  _ReadContactsState createState() => _ReadContactsState();
}

class _ReadContactsState extends State<ReadContacts> {
  List<Contact> listContacts = [];
  List<Contact> filteredContacts = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    readContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
            color: Colors.white,),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingView()),
            );
          },
        ),
        title: const Text(
          "Contacts",
          style: TextStyle(
            color: Colors.white, // Couleur blanche
            fontWeight: FontWeight.bold, // Gras
            fontStyle: FontStyle.italic, // Italique
            fontSize: 30, // Taille de la police (facultatif)
          ),
        ),

        backgroundColor: const Color(0xFF6C5676),
        actions: [
          IconButton(
            icon: const Icon(Icons.search,
              color: Colors.white,),
            onPressed: () {
              showSearchDialog();
            },
          ),

            IconButton(
              icon: const Icon(
                Icons.emoji_emotions, // Smile icon
                color: Colors.blueAccent,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()), // Replace with your destination page
                );
              },
            ),

        ],
      ),
      body: Container(
    decoration: const BoxDecoration(
    gradient: LinearGradient(
    colors: [Colors.grey, Colors.white60, Color(0xFFD7BDE2), Colors.grey],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),),
        child: (filteredContacts.isNotEmpty)
            ? ListView.builder(
          itemCount: filteredContacts.length,
          itemBuilder: (context, index) {
            Contact contact = filteredContacts[index];
            return Card(
              color: Colors.white, // Fond des cartes
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: (contact.photo != null && contact.photo!.isNotEmpty)
                      ? MemoryImage(contact.photo!)
                      : null,
                  backgroundColor: Color(0xFF3C2846), // Bleu pour avatar sans photo
                  child: (contact.photo == null || contact.photo!.isEmpty)
                      ? Text(
                    contact.displayName.isNotEmpty
                        ? contact.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  )
                      : null,
                ),
                title: Text(
                  contact.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  (contact.phones.isNotEmpty)
                      ? "${contact.phones[0].number}"
                      : "No contact",
                ),
                trailing: InkWell(
                  child: const Icon(Icons.call, color: Color(0xFF6C5676)),
                  onTap: () {
                    _makePhoneCall(
                        "tel:${contact.phones.isNotEmpty ? contact.phones[0].number : ''}");
                  },
                ),
              ),
            );
          },
        )
            : const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(backgroundColor: Colors.redAccent), // ProgressBar rouge doux
              SizedBox(height: 10),
              Text("Reading Contacts..."),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> readContacts() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      setState(() {
        listContacts = contacts;
        filteredContacts = contacts; // Par défaut, on affiche tous les contacts
      });
    }
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
      await [Permission.contacts].request();
      if (permissionStatus[Permission.contacts] != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission to access contacts is denied.")),
        );
      }
      return permissionStatus[Permission.contacts] ?? PermissionStatus.denied;
    } else {
      return permission;
    }
  }

  /// Ouvre une boîte de dialogue pour rechercher un contact
  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Search Contacts"),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter contact name"),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                filteredContacts = listContacts
                    .where((contact) => contact.displayName
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                    .toList();
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
