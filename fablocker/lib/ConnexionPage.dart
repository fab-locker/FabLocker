// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, avoid_print, library_private_types_in_public_api, use_super_parameters

import 'dart:convert';
import 'package:fablocker/PrincipalePage.dart';
import 'package:fablocker/add_items.dart';
import 'package:fablocker/add_user.dart';
import 'package:fablocker/remove_user.dart';
import 'package:flutter/material.dart';
import 'Style/style.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final RegExp usernameRegExp = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
  final RegExp passwordRegExp = RegExp(r'^[a-zA-Z0-9]{8,}$'); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('FabLocker'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'), 
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment(0, -0.85),
                child: Text(
                  'Bienvenue sur votre application FabLocker !',
                  style: titleStyle
                ),
              ),
              const SizedBox(height: 50.0),
              SizedBox(
                height: 50,
                width: 440,
                child: TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    labelStyle: inputDecorationStyle,
                    border: OutlineInputBorder(),
                  ),
                  style: inputStyle,
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                height: 50,
                width: 440,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: inputDecorationStyle,
                    border: OutlineInputBorder(),
                  ),
                  style: inputStyle,
                ),
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: () {
                  String username = usernameController.text;
                  String password = passwordController.text;
                  void _login(String username, String password) async {
                    try {
                      final response = await http.post(
                        Uri.parse('http://localhost:3000/auth/login'),
                        body: {
                          'email': username,
                          'password': password,
                        },
                      );

                      if (response.statusCode == 200) {
                        final responseData = json.decode(response.body);
                        final token = responseData['access_token'];
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString('token', token);
                        String? userToken = prefs.getString('token');
                        print(userToken);
                        _showSnackBar('Bienvenue $username');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => removeUsers()),
                          );
                      } else {
                         _showSnackBar('Adresse e-mail ou mot de passe incorrect !');
                      }
                    } catch (e) {
                      _showSnackBar('Erreur de connexion');
                    }
                  }
                  _login(username, password);
                  
                },
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
