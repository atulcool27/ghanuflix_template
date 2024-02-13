import 'package:flutter/material.dart';


class VersionUpdateAlert extends StatelessWidget {
  final String version;
  final List<String> changes;
  final VoidCallback onDownloadPressed;
  final VoidCallback onDismissPressed;

  VersionUpdateAlert({
    required this.version,
    required this.changes,
    required this.onDownloadPressed,
    required this.onDismissPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Version Available: $version'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Changes in this version:'),
          SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.10,
            child: ListView.builder(
              itemCount: changes.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Icon(Icons.arrow_right),
                  title: Text(changes[index]),
                );
              },
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onDismissPressed,
          child: Text('Dismiss'),
        ),
        ElevatedButton(
          onPressed: onDownloadPressed,
          child: Text('Download'),
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
          ),
        ),
      ],
    );
  }
}
