import 'package:flutter/material.dart';
import 'package:ozero/players_stats.dart';

class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 32, bottom: 32),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: PlayersStats(),
        ),
      ),
    );
  }
}
