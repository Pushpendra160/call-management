import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/pages/Home.dart';
import 'package:user/pages/Sign_up.dart';
import 'package:user/services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in'),
     
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _loginUser();
                  }
                },
                child: Text('Login'),
              ),
               SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.black),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      },
                      child: Text(
                        " Sign in here",
                        style: TextStyle(color: Colors.blue),
                      ))
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }

void _loginUser() async {
  String email = _emailController.text;
  String password = _passwordController.text;

  bool result = await ApiService.loginUser(
    email: email,
    password: password,
  );

  if (result) {
    // Save username to shared preferences
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('username', result['username']);
    // await prefs.setBool('isLoggedIn', true);

    // Navigate to home page with username
    Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) => HomePage(email: email,)),
                                              
                                        );
  } else {
    // Display error message or handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login failed. Please try again.'),
      ),
    );
  }
}

}
