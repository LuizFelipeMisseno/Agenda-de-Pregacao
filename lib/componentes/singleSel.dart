import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SingleSel extends StatefulWidget {
  List<String> sortNumber;

  SingleSel(this.sortNumber);
  @override
  _SingleSelState createState() => _SingleSelState();
}

class _SingleSelState extends State<SingleSel> {
  String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.sortNumber.first;
  }

  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        return Container(
          child: Row(
            children: <Widget>[
              Radio(
                  value: widget.sortNumber[index],
                  groupValue: selectedValue,
                  onChanged: (s) {
                    selectedValue = s;
                    setState(() {});
                  }),
              Text(widget.sortNumber[index])
            ],
          ),
        );
      },
      itemCount: widget.sortNumber.length,
    );
  }
}
