import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class paybutton extends StatelessWidget {
  const paybutton({super.key, required this.click});


  final VoidCallback click;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGreen.withOpacity(0.3),
        ),
      ),
      child: TextButton(
        onPressed: () async {
          click();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payments_rounded,
              color: CupertinoColors.systemGreen,
            ),
            SizedBox(width: 8),
            Text(
              'تسديد',
              style: TextStyle(
                color: CupertinoColors.systemGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
