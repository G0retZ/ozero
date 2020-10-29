import 'package:flutter/material.dart';

class Item {
  final Color color;
  final IconData image;

  Item(this.color, this.image);
}

class CardsPage extends StatelessWidget {
  final List<Item> data = [
    Item(Color(0xffcb2028), Icons.image),
    Item(Color(0xffcb2028), Icons.money_off),
    Item(Color(0xffcb2028), Icons.alarm_on),
    Item(Color(0xffcb2028), Icons.adb),
    Item(Color(0xffcb2028), Icons.map),
    Item(Color(0xffcb2028), Icons.accessible_forward),
    Item(Color(0xffe96d25), Icons.ac_unit),
    Item(Color(0xffe96d25), Icons.backup),
    Item(Color(0xffe96d25), Icons.child_friendly),
    Item(Color(0xffe96d25), Icons.image),
    Item(Color(0xffe96d25), Icons.money_off),
    Item(Color(0xffe96d25), Icons.alarm_on),
    Item(Color(0xffa2206a), Icons.adb),
    Item(Color(0xffa2206a), Icons.map),
    Item(Color(0xffa2206a), Icons.accessible_forward),
    Item(Color(0xffa2206a), Icons.ac_unit),
    Item(Color(0xffa2206a), Icons.backup),
    Item(Color(0xffa2206a), Icons.child_friendly),
    Item(Color(0xffe4b422), Icons.image),
    Item(Color(0xffe4b422), Icons.money_off),
    Item(Color(0xffe4b422), Icons.alarm_on),
    Item(Color(0xffe4b422), Icons.adb),
    Item(Color(0xffe4b422), Icons.map),
    Item(Color(0xffe4b422), Icons.accessible_forward),
    Item(Color(0xff512a7b), Icons.ac_unit),
    Item(Color(0xff512a7b), Icons.backup),
    Item(Color(0xff512a7b), Icons.child_friendly),
    Item(Color(0xff512a7b), Icons.image),
    Item(Color(0xff512a7b), Icons.money_off),
    Item(Color(0xff512a7b), Icons.alarm_on),
    Item(Color(0xff359d44), Icons.adb),
    Item(Color(0xff359d44), Icons.map),
    Item(Color(0xff359d44), Icons.accessible_forward),
    Item(Color(0xff359d44), Icons.ac_unit),
    Item(Color(0xff359d44), Icons.backup),
    Item(Color(0xff359d44), Icons.child_friendly),
    Item(Color(0xff282e78), Icons.image),
    Item(Color(0xff282e78), Icons.money_off),
    Item(Color(0xff282e78), Icons.alarm_on),
    Item(Color(0xff282e78), Icons.adb),
    Item(Color(0xff282e78), Icons.map),
    Item(Color(0xff282e78), Icons.accessible_forward),
    Item(Color(0xff0b80a1), Icons.ac_unit),
    Item(Color(0xff0b80a1), Icons.backup),
    Item(Color(0xff0b80a1), Icons.child_friendly),
    Item(Color(0xff0b80a1), Icons.image),
    Item(Color(0xff0b80a1), Icons.money_off),
    Item(Color(0xff0b80a1), Icons.alarm_on),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cards"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GridView.builder(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            itemCount: data.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (BuildContext context, int position) {
              return GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Card(
                  color: data[position].color,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      data[position].image,
                      size: 64,
                      color: Colors.white70,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
