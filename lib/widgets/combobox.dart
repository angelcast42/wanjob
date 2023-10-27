import 'dart:ui';
import 'package:flutter/material.dart';
class ComboBox extends StatefulWidget{
  ComboBox({this.comboList,this.changeValue,this.dropdownValue,this.title,this.tipo});
  final Map<String,Map> comboList;
  final Function changeValue;
  final String title;
  final String tipo;
  String dropdownValue;
  @override
  State<StatefulWidget> createState() =>_ComboBoxState();
}
class _ComboBoxState extends State<ComboBox>{
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value:widget.dropdownValue,
      icon:Icon(Icons.arrow_drop_down),
      iconSize: 20,
      elevation: 16,
      isDense: true,
      decoration:new InputDecoration(
        labelText:widget.title,
      ),
      onChanged: (String newValue){
        widget.changeValue(int.parse(newValue));
        
      },
      items:widget.comboList.entries.map<DropdownMenuItem<String>>((MapEntry<String,Map> e){
        return DropdownMenuItem<String>(
          value:e.key.toString(),
          child: Text(e.value[widget.tipo])
        );
      }).toList(),
    );
  }
}