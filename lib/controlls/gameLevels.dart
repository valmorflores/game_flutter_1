import 'dart:ui';

import 'package:teste/components/enemy.dart';
import 'package:teste/controlls/gameController.dart';
import 'package:teste/models/enum_enemy.dart';
import 'package:teste/models/enum_state.dart';

class GameLevel {

   int level = 0;
   int enemies = 1;
   int highscore = 0;
   int difficulty = 30;

   GameController gameController;
   GameLevel({this.gameController});

   void up(){
      this.level++;
      this.gameController.level=this.gameController.level+1;
   }

   void down(){
      this.level--;
   }

   void startlevel(){
     this.enemies = this.level;
     this.difficulty = this.difficulty + 2; 
     if ( this.level == 10 ){
        this.enemies = 25;
     }
   }

   double ocupacao(){
      double lin, col;
      double areatotal = 0;
      double areaocupada = 0;
      Offset posicao;
      areatotal = this.gameController.screenSize.width * 
           this.gameController.screenSize.height;

      /*
      for ( lin =0; lin <= this.gameController.screenSize.height-1; lin++ ){
        for ( col = 0; col <= this.gameController.screenSize.width-1; col++ ){
            posicao = Offset( col, lin );
            this.gameController.blocks.forEach((f) => areaocupada += (f.blockRect.contains(posicao))?1:0); 
        }
      }
      */
      // metodo 2
      //this.gameController.blocks.forEach((f) => areaocupada += (f.blockRect.width * f.blockRect.height)); 
      areaocupada = this.gameController.ocupacao;
      if ( ( ( areaocupada / areatotal ) * 100 ) < 1.0 ) {
        return 0;
      }
      else if ( ( ( areaocupada / areatotal ) * 100 ) >= 99.0 ) {
        return 99;
      }
      else 
      {
        return ( areaocupada / areatotal ) * 100;
      }
      
   } 

   double start(){
     this.gameController.blocks.forEach(( f ) => f.isDead = true );
     this.gameController.enemies.forEach(( f ) => f.isDead = true );
     this.enemies += 1; 
     print( 'Start' + this.enemies.toString() );
     this.gameController.initialize();
     this.startlevel();
   }

   void resetall(){
     this.gameController.blocks.forEach(( f ) => f.isDead = true );
     this.gameController.enemies.forEach(( f ) => f.isDead = true );
     this.enemies += 0; 
     print( 'Reset' + this.enemies.toString() );
   }

   void render( Canvas c ){

   }

   void update( double t ){

   }

   void finalcount(){
     // Mostrar contagem
     this.gameController.state = StateGame.counting;
   }

   void finalgameover(){
     //this.gameController.score += 1;
   }

   int count(){
     int i=0;
     this.gameController.enemies.forEach((f)=> i++);
     return i;
   }

   void extras(){
      print( 'Extras para fase: ' + this.gameController.level.toString() );
      if ( this.gameController.level >= 100 ){         
         this.gameController.enemies.add(
             Enemy(gameController: this.gameController, x: 50, y: 50, difficulty: 10, enemyType: EnemyType.chefao ));
         this.gameController.enemies.add(
             Enemy(gameController: this.gameController, x: 150, y: 150, difficulty: 25, enemyType: EnemyType.chefao ));
      }
   }

}