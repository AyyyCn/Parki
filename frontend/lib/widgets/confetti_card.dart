import 'package:flutter/material.dart';

class ConfettiCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Image.asset(
              'images/confetti.gif',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Parking is free. \nThank you!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 60, 89, 143),
              ),
            ),
          ),
        ],
      ),
    );
  }
}