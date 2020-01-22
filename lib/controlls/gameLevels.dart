import 'dart:ui';

import 'package:teste/components/enemy.dart';
import 'package:teste/controlls/gameController.dart';
import 'package:teste/controlls/gameDesafios.dart';
import 'package:teste/models/enum_desafios.dart';
import 'package:teste/models/enum_enemy.dart';
import 'package:teste/models/enum_fails.dart';
import 'package:teste/models/enum_state.dart';

class GameLevel {

   int level = 0;
   int enemies = 1;
   int highscore = 0;
   int difficulty = 30;
   double percentual = 50;
   
   GameController gameController;
   GameLevel({this.gameController, this.percentual}){


   }

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
      if ( this.gameController.level == 3 ){
         this.gameController.gameLevel.percentual = 70;
      }
      else if ( this.gameController.level >= 5 ){
         this.gameController.gameLevel.percentual = 70;
         this.gameController.enemies.add( new Enemy(gameController: this.gameController, x: 50, y: 50, difficulty: 20, enemyType: EnemyType.chefao ));
         this.gameController.enemies.add( new Enemy(gameController: this.gameController, x: 50, y: 50, difficulty: 30, enemyType: EnemyType.gerente ));
         this.gameController.enemies.add( new Enemy(gameController: this.gameController, x: 50, y: 50, difficulty: 50, enemyType: EnemyType.gangster ));
         this.gameController.enemies.add( new Enemy(gameController: this.gameController, x: 50, y: 50, difficulty: 40, enemyType: EnemyType.gangster ));        
         this.gameController.desafios.add( new DesafiosItem(
            name: 'Gerente', 
            enemytype: EnemyType.gerente,
            desafio: DesafiosGame.capturar, quantidade: 1, ));
         this.gameController.desafios.add( new DesafiosItem(
            name: 'Gangster', 
            enemytype: EnemyType.gangster,
            desafio: DesafiosGame.capturar, quantidade: 3, ) );
        this.gameController.desafios.add( new DesafiosItem(
            name: 'Chefao', 
            enemytype: EnemyType.chefao,
            desafio: DesafiosGame.capturar, quantidade: 1, ) );
      }
      else if ( this.gameController.level >= 100 ){         
         this.gameController.enemies.add( new Enemy(gameController: this.gameController, x: 50, y: 50, difficulty: 10, enemyType: EnemyType.chefao ));
         this.gameController.enemies.add( new Enemy(gameController: this.gameController, x: 150, y: 150, difficulty: 25, enemyType: EnemyType.chefao ));
      }
   }


   FailsGame fail()
   {
       FailsGame fail = FailsGame.none;
       int captura;
       this.gameController.desafios.items.forEach((f){
           if ( f.desafio == DesafiosGame.capturar ){
              captura = 0;
              this.gameController.enemies.forEach((enemy){
                 if ( enemy.enemyType == f.enemytype ){
                    ++captura;
                 }
              });
              if ( captura < f.quantidade ){
                fail = FailsGame.enemykilled;
                fail = ( f.enemytype == EnemyType.chefao )?FailsGame.bosskilled:fail;
                fail = ( f.enemytype == EnemyType.gerente )?FailsGame.enemykilled:fail;
                fail = ( f.enemytype == EnemyType.gangster )?FailsGame.enemykilled:fail;
              }
           }
       });
       //fail = FailsGame.none;
       if (this.gameController.player.currentHealt<=0){
           fail = FailsGame.health;
       }
       return fail;
   }


}