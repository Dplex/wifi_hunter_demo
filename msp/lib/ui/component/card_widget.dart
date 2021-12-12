import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class CardWidget extends StatefulWidget {
  final String _leadingTitle;
  final String _titleText;
  final String _currentValue;
  final void Function(String changedValue) _changeCallback;

  const CardWidget(this._leadingTitle, this._titleText, this._currentValue, this._changeCallback);

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool _visible = false;

  late String currentValue;
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentValue = widget._currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        shadowColor: Colors.red,
        elevation: 5,
        color: Colors.lightBlue,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Text(
                widget._leadingTitle,
                style: const TextStyle(fontSize: 20, color: Colors.deepPurple),
              ),
              title: Text(
                widget._titleText,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            TextField(
              controller: textController,
              onChanged: (string) => setState(() => _visible = true),
              decoration:
                  InputDecoration( labelText: currentValue, hintText: 'type value', contentPadding: const EdgeInsets.all(20)),
            ),
            Visibility(
              visible: _visible,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                      onPressed: () {
                        developer.log('check');
                        currentValue = textController.text;
                        widget._changeCallback(currentValue);
                        resetTextField();
                      },
                      icon: const Icon(Icons.check)),
                  IconButton(
                      onPressed: () {
                        developer.log('cancel');
                        resetTextField();
                      },
                      icon: const Icon(Icons.cancel)),
                  const SizedBox(width: 8),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void resetTextField() {
    FocusScope.of(context).unfocus();
    setState(() {
      _visible = false;
      textController.text = '';
    });
  }
}
