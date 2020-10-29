import 'package:flutter/material.dart';
import 'package:ozero/earnings.dart';

import 'cards_page.dart';
import 'di/di.dart';

class TurnPage extends StatelessWidget {
  final List<int> turns;

  const TurnPage({Key key, @required this.turns}) : super(key: key);

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
          padding: EdgeInsets.all(16),
          color: Color(0xFFFFFFFF),
          child: Column(
            children: [
              Text(
                'Ход №${turns[0] + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                  fontSize: 18,
                ),
              ),
              StreamBuilder<String>(
                initialData: 'images/Splash.jpeg',
                stream: Providers.playersBloc.data
                    .map((event) => event[turns[0] % event.length].image),
                builder: (context, snapshot) {
                  return Image(
                    width: 240,
                    height: 240,
                    image: AssetImage(snapshot.data),
                  );
                },
              ),
              Earnings(turn: turns),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CardsPage()),
                    );
                  },
                  child: Text('Add Card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
