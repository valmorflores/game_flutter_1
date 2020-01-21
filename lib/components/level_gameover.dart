import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:teste/controlls/gameController.dart';

class LevelGameOverText {
  
 final GameController gameController;
 TextPainter painter;
 TextPainter paintersecondary;
 Offset position, positionsecondary;
 Rect respawnRect;

LevelGameOverText( {this.gameController} ){
  painter = TextPainter( textAlign:  TextAlign.center,
  textDirection: TextDirection.ltr );
  position = Offset.zero;
  paintersecondary = TextPainter( textAlign:  TextAlign.center,
  textDirection: TextDirection.ltr );
  respawnRect = Rect.fromLTWH( 0, 0, gameController.screenSize.width, gameController.screenSize.height );
}

void render(Canvas c){
  Paint color = Paint()..color = Color.fromRGBO(255, 0, 0, 0.90);
     c.drawRect(respawnRect, color);
  painter.paint(c, position);
  paintersecondary.paint(c, positionsecondary);
   
}

void update(double t){
   if ((painter.text??'')!=this.gameController.score.toString()){
     painter.text = TextSpan( text: 'Quase ;)',
     style: TextStyle( color: Colors.white,
     fontSize: 80.0,
     ),
    
    );
   
   painter.layout();
   position = 
      Offset( 
        ( this.gameController.screenSize.width - painter.width ) / 2, 
        (this.gameController.screenSize.height-100)/2,
        /*,
        ,*/
        );
   
   }
   String texto = 'Clique na tela para jogar';
   if ((paintersecondary.text??'')!=texto){
     paintersecondary.text = TextSpan( text: texto,
     style: TextStyle( color: Colors.white,
     fontSize: 22.0,
     ),
    
    );
   
   paintersecondary.layout();
   positionsecondary = 
      Offset( 
        ( this.gameController.screenSize.width - paintersecondary.width ) / 2,
        (this.gameController.screenSize.height)/2+50,
        /*,
        ,*/
        );
   
   }


}


}