import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:teste/controlls/gameController.dart';

class HealthBar {

  final GameController gameController;
  Rect healthBarRect;
  Rect progressBarRect;
  double _barWidth;

  HealthBar({this.gameController}){
    double barWidth = gameController.screenSize.width * 1;
    this._barWidth = barWidth;
    healthBarRect = Rect.fromLTWH(
         ( gameController.screenSize.width - barWidth ) / 2, 
         gameController.screenSize.height-5, barWidth, 5 );

    progressBarRect = Rect.fromLTWH(
         ( gameController.screenSize.width - barWidth ) / 2, 
         gameController.screenSize.height-5, barWidth, 5 );

  }

  void render( Canvas c ){
     Paint healthBarColor = Paint()..color = Colors.black54;
     Paint healthProgressBarColor = Paint()..color = Colors.greenAccent;
     c.drawRect(healthBarRect, healthBarColor);
     c.drawRect(progressBarRect, healthProgressBarColor);
  }

  void update( double t ){
     double percent = gameController.player.currentHealt / gameController.player.maxHealt;
     double barWidth = this._barWidth * percent;
     progressBarRect = Rect.fromLTWH( 
         ( gameController.screenSize.width - this._barWidth ) / 2, 
         gameController.screenSize.height-5, barWidth, 5 );
  }


}