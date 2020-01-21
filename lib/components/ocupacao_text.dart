import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:teste/controlls/gameController.dart';

class OcupacaoText {
  
 final GameController gameController;
 TextPainter painter;
 Offset position;

OcupacaoText( {this.gameController} ){
  painter = TextPainter( textAlign:  TextAlign.right,
  textDirection: TextDirection.ltr );
  position = Offset.zero;

}

void render(Canvas c){
  painter.paint(c, position);
}

void update(double t){
   if ((painter.text??'')!=this.gameController.gameLevel.ocupacao().toStringAsPrecision(2)+'%'){
     painter.text = TextSpan( text: this.gameController.gameLevel.ocupacao().toStringAsPrecision(2)+'%',
     style: TextStyle( color: Colors.black,
     fontSize: 20.0,
     ),
    
    );
   
   painter.layout();
   position = 
      Offset( 
        30,
        15.0 
        );
   
   }
}


}