import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/phone_verif_screen.dart';
import 'package:dio/dio.dart';
class RegScreen extends StatefulWidget {
  const RegScreen({Key? key}) : super(key: key);

  @override
  _RegScreenState createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  List<Widget> vehiclePlateFields = [];

  Future<void> registerUser() async
  {
    print("Calling register");
    var dio = Dio();
    var url = 'http://10.0.2.2:8000/registerAPI';
    try {
      var response = await dio.post(url,data:
      {'first_name' : 'Ahsen',
      'last_name' : 'Mohsen',
      'phone_number' : '+12125552360',
      'email' : "ahmedmohsen@gmail.com ",
      'password1' : 'slmkhoua12!',
      'password2' : 'slmkhoua12!'

      },options: Options(
        contentType: Headers.jsonContentType,
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ));
      print("CODE:");
      print(response.statusCode);
      if (response.statusCode == 201) {
        print('User registered successfully');
        // Handle success, such as navigation or showing a success message
      } else {
        print('Failed to register user: ${response.statusCode}');
        // Handle failure, such as showing an error message
      }
    } on DioError catch (e) {
      print('Dio error: $e');
      // Handle Dio error here
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: [
          Container(
            height: 200, // Adjust the height according to your design
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFC4DEF6),
                  Color.fromARGB(255, 102, 187, 236),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Create Your\nAccount',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.check, color: Colors.grey),
                        label: Text(
                          'Full Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ], // Accepts only numeric input
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.phone, color: Colors.grey),
                        label: Text(
                          'Phone Number',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
                        label: Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
                        label: Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        registerUser();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhoneVerifScreen(), 
                          ),
                        );
                      },
                      child: Container(
                        height: 55,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFC4DEF6),
                              Color.fromARGB(255, 102, 187, 236),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => loginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
