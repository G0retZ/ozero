import 'package:flutter/material.dart';

class TurnPage extends StatelessWidget {
  final int turn;

  const TurnPage({Key key, this.turn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(0x40000000),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Color.fromARGB(0xFF, 0xFF, 0xFF, 0xFF),
          child: Center(
            child: Text(
              'This turn is ${turn}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xFF, 0, 0, 0),
                fontSize: 35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
