import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:teste/controlls/gameController.dart';
import 'package:teste/models/enum_fails.dart';

class LevelGameOverText {
  
 final GameController gameController;
 TextPainter painter;
 TextPainter paintersecondary;
 TextPainter paintermotive;
 Offset position, positionsecondary, positionmotive;
 Rect respawnRect;

LevelGameOverText( {this.gameController} ){
  painter = TextPainter( textAlign:  TextAlign.center,
  textDirection: TextDirection.ltr );
  position = Offset.zero;
  paintersecondary = TextPainter( textAlign:  TextAlign.center,
  textDirection: TextDirection.ltr );
  paintermotive =  TextPainter( textAlign:  TextAlign.center,
  textDirection: TextDirection.ltr );
  respawnRect = Rect.fromLTWH( 0, 0, gameController.screenSize.width, gameController.screenSize.height );
}

void render(Canvas c){
  Paint color = Paint()..color = Color.fromRGBO(255, 0, 0, 0.90);
     c.drawRect(respawnRect, color);
  painter.paint(c, position);
  paintersecondary.paint(c, positionsecondary);
  paintermotive.paint(c, positionmotive);

   
}

void update(double t){
   if ((painter.text??'')!=this.gameController.score.toString()){
     painter.text = TextSpan( text: ':(',
     style: TextStyle( color: Colors.white,
     fontSize: 120.0,
     ),
    
    );
   
   painter.layout();
   position = 
      Offset( 
        ( this.gameController.screenSize.width - painter.width ) / 2, 
        ( this.gameController.screenSize.height-250 ) / 2,
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

   String motive;
     
   motive = 'Você foi eliminado';
   FailsGame falha;
   falha = this.gameController.gameLevel.fail();
   motive = ( falha == FailsGame.bosskilled )?'Você matou o chefe':motive;
   motive = ( falha == FailsGame.enemykilled )?'Você matou inimigos demais':motive;
   motive = ( falha == FailsGame.refemkilled )?'Você matou um refém':motive;
   motive = ( falha == FailsGame.timeout )?'Tempo esgotado':motive;
   motive = ( falha == FailsGame.victimkilled )?'Você matou um inoscente':motive;

   
   if ((paintermotive.text??'')!=motive){
     paintermotive.text = TextSpan( text: motive,
     style: TextStyle( color: Colors.white,
     fontSize: 20.0,
     ),
    
    );
   
   paintermotive.layout();
   positionmotive = 
      Offset( 
        ( this.gameController.screenSize.width - paintermotive.width ) / 2,
        (this.gameController.screenSize.height)/2+80,
        /*,
        ,*/
        );
   
   }


}


}