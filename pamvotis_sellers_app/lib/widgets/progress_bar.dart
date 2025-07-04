import 'package:flutter/material.dart';

circularProgress(){
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 12),
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Colors.yellow,
      ),
    ),
  );
}

linearProgress(){
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 12),
    child: const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Colors.yellow,
      ),
    ),
  );
}