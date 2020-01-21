import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:teste/components/blocks.dart';
import 'package:teste/components/mark.dart';
import 'package:teste/controlls/gameController.dart';
import 'package:teste/models/enum_enemy.dart';
import 'package:teste/models/enum_game.dart';
import 'enum_enemy.dart';

class Enemy {

  final GameController gameController;
  int health = 100;
  int damage = 0;
  int dificuldade = 0;
   
  double speed;
  Rect enemyRect;
  bool isDead = false;
  bool isGoingToPrision = false;
  EnemieDirection direcao;
  EnemyType enemyType;
  double size = 10;
  
  Enemy( {this.gameController, double x, double y, int difficulty = 50, enemyType: EnemyType.gangster} ){
    health = 100;
    dificuldade = difficulty;
    speed = gameController.tileSize * dificuldade;
    direcao= EnemieDirection.righdown;
    if ( enemyType == EnemyType.gangster ){
      size = 10;
    }
    else if (enemyType == EnemyType.chefe){
      size = 15;
    }
    else if (enemyType == EnemyType.chefao){
      size = 24;
    }
    enemyRect = Rect.fromLTWH( x, y, size, size );

  }

  void render( Canvas c ){
    Color color;
    color = Color.fromRGBO( 0, 0, 0, 1 * health / 100 );
     
    Paint enemyColor = Paint()..color = color;
    c.drawRect( enemyRect, enemyColor);
  }

  void update( double t ){
    if (!isDead){
      double stepDistance = speed * t;
      Offset toDirection = Offset(0,0);
      // print(  gameController.screenSize.height.toString() );
      
      //print( direcao.toString() + '-' + enemyRect.left.toString() );

      
      
      /*if ( enemyRect.top >= gameController.screenSize.height ) {
         direcao = EnemieDirection.leftup;
      }*/
      // Limites?

      if ( ! this.isGoingToPrision ){
        detectColisionMarks();
        if ( ! detectColisionBlocks() ){ 
          detectColisionLimit();
        }
      }
        
      // Vai para 
      if ( direcao == EnemieDirection.up ){
         toDirection = Offset( 0, -10 );
      }
      if ( direcao == EnemieDirection.leftup ){
         toDirection = Offset( -10, -10 );
      }
      if ( direcao == EnemieDirection.leftdown ){
         toDirection = Offset( -10, 10 );
      }
      if ( direcao == EnemieDirection.righdown ){
         toDirection = Offset( 10, 10 );
      }
      if ( direcao == EnemieDirection.rightup ){
         toDirection = Offset( 10, -10 );
      }      
      Offset stepToPlayer = Offset.fromDirection( toDirection.direction, stepDistance );
      enemyRect = enemyRect.shift( stepToPlayer );

      if ( this.isGoingToPrision ){
         // Fazer contagem de inimigos e jogar no score
         this.gameController.score += this.enemyRect.top <= 0 && !isDead? 1:0;
         isDead = ( isDead || this.enemyRect.top <= 0 );
      }
      else
      {
         //print( enemyRect.bottom.toString() );
          if ( enemyRect.left < -50 ||
              enemyRect.top < -50 ||
              enemyRect.bottom > gameController.screenSize.height + 50 ||
              enemyRect.left > gameController.screenSize.width + 50 ){
            //isDead=true;    
            // Refaz o quadrado do boneco; 
            /*this.enemyRect = Rect.fromLTWH( 
                gameController.screenSize.width - size /2,
                gameController.screenSize.height - size /2, 
                size, size );*/
            // Refaz o quadrado do boneco; 
            reposiciona();
            print( 'reposicionado, saiu da arena: ' + this.hashCode.toString() );   
          }
          if (detectInnerBlock()){
            if ( this.gameController.gameLevel.count() > 1 ){
                print( 'Dentro do bloco [ morreu ]' + this.hashCode.toString() );  
                isDead = true;
            }
            else
            {
              print( 'Dentro do bloco [ último ]' + this.hashCode.toString() );              
            }
            //reposiciona();
          }
      }
              
    }

  }

  void reposiciona(){
    this.enemyRect = Rect.fromLTWH( 
             this.gameController.screenSize.width / 2,
             this.gameController.screenSize.height / 2,
             size, size );
  }

  void goPrision(){
    if (! this.isGoingToPrision ){
      print('Go to prision: ' + this.enemyRect.hashCode.toString() );
      this.isGoingToPrision = true;
      this.direcao = EnemieDirection.up;
      this.size = this.size * 1.15;
      this.enemyRect = Rect.fromLTWH( 
              this.enemyRect.left,
              this.gameController.screenSize.height - 20,
              size * 2, size * 2 );
     } 
  }

  // Verdadeiro somente se colidir os 4 cantos do enemy
  bool detectInnerBlock(){
     double ptop, pleft, pbottom, pright;
     Offset posicao;
     ptop = this.enemyRect.top;
     pleft = this.enemyRect.left;
     pbottom = this.enemyRect.bottom;
     pright = this.enemyRect.right;
     
     int ncolide = 0;
     bool lcolide = false;
     gameController.blocks.forEach( ( Blocks element ) {
        // Teste 1 - left top
        if ( !lcolide ){
            ncolide = 0;
            ncolide += ( element.blockRect.contains( Offset( pleft, ptop )  ) ? 1 : 0 );
            ncolide += ( element.blockRect.contains( Offset( pleft, pbottom )  ) ? 1 : 0 );
            ncolide += ( element.blockRect.contains( Offset( pright, ptop )  ) ? 1 : 0 );     
            ncolide += ( element.blockRect.contains( Offset( pright, pbottom )  ) ? 1 : 0 );     
            if ( ncolide >= 4 ){
              lcolide = true;
            }
        }
     });
     return lcolide;
  }

  bool detectColisionBlocks(){
    Offset posicao;
    bool lcolide = false;
     gameController.blocks.forEach(( Blocks element)  
        { 
            //element.colide(enemyRect));
            if ( direcao == EnemieDirection.leftdown ) {
                posicao = Offset( enemyRect.left, enemyRect.bottom ); 
            }
            else if ( direcao == EnemieDirection.leftup ) {
                posicao = Offset( enemyRect.left, enemyRect.top ); 
            }
            else if ( direcao == EnemieDirection.righdown ) {
                posicao = Offset( enemyRect.right, enemyRect.bottom ); 
            }
            else if ( direcao == EnemieDirection.rightup) {
                posicao = Offset( enemyRect.right, enemyRect.top ); 
            }

            if ( element.blockRect.contains( posicao  ) ) {
              if ( direcao == EnemieDirection.leftdown ){
                 if ( ( posicao.dx + 10 ) >= element.blockRect.right ) {
                     direcao = EnemieDirection.righdown;
                 }
                 else if ( posicao.dy - 10 <= element.blockRect.top ){ 
                    direcao = EnemieDirection.leftup;
                 }
                 else
                 {
                    direcao = EnemieDirection.righdown;
                 }
              }
              else if ( direcao == EnemieDirection.leftup ){
                 if ( posicao.dy <= element.blockRect.bottom ){ 
                    if ( posicao.dx+10 <= element.blockRect.right ){
                        direcao = EnemieDirection.leftdown;
                    } 
                    else {
                        direcao = EnemieDirection.rightup;
                    }                    
                 }
                 else {
                    direcao = EnemieDirection.rightup;
                 }
              }
              else if ( direcao == EnemieDirection.rightup ){                 
                 if ( posicao.dy <= element.blockRect.bottom ){
                    if ( posicao.dx-10 <= element.blockRect.left ){
                        direcao = EnemieDirection.leftup;
                    } 
                    else
                    {
                        direcao = EnemieDirection.righdown;
                    }   
                 }
                 else
                 { 
                    direcao = EnemieDirection.leftup;
                 }
              }
              else if ( direcao == EnemieDirection.righdown ){
                if ( posicao.dy - 10 <= element.blockRect.top ){ 
                   direcao = EnemieDirection.rightup;
                }
                else if ( posicao.dx - 10 <= element.blockRect.left ){   
                   direcao = EnemieDirection.leftdown;
                }
                else
                {
                   direcao = EnemieDirection.leftdown;
                }

              }
              if ( element.isSpoiled ){ 
                  gameController.player.currentHealt--;
              }
              //print( 'Tocou:' + element.blockColor.toString() );
              lcolide = true;
          }
     
         } );

     return lcolide;
  }



  bool detectColisionMarks(){
    Offset posicao;
    bool lcolide = false;
     this.gameController.marks.forEach(( Mark element)  
        { 
            //element.colide(enemyRect)); 
            posicao = Offset( enemyRect.left, enemyRect.top ); 
            
            if ( element.markRect.contains( posicao  ) ) {
              //gameController.player.currentHealt-=50;
              //print( 'Mark-pegou:' );
              //matar mark -> element.isDead= true;
              lcolide = true;
            }
     
         } );

     return lcolide;
  }


  void detectColisionLimit(){
      if ( direcao == EnemieDirection.leftdown )
      {
          if ( enemyRect.left <= 0 ) {
            direcao = EnemieDirection.righdown;
          }
          if ( enemyRect.top >= gameController.screenSize.height ) {
            direcao = EnemieDirection.leftup;
          }
      } 
      else if ( direcao == EnemieDirection.leftup )
      {
          if ( enemyRect.left <= 0 ) {
            direcao = EnemieDirection.rightup;
          }
          if ( enemyRect.top <= 0 ) {
            direcao = EnemieDirection.leftdown;
          }
      }  
      else if ( direcao == EnemieDirection.rightup )
      {
          if ( enemyRect.left >= gameController.screenSize.width ) {
            direcao = EnemieDirection.leftup;
          }
          if ( enemyRect.top <= 0 ) {
            direcao = EnemieDirection.righdown;
          }
      }  
      else if ( direcao == EnemieDirection.righdown )
      {
          if ( enemyRect.top >= gameController.screenSize.height ) {
            direcao = EnemieDirection.rightup;
          }
          if ( enemyRect.left >= gameController.screenSize.width ) {
            direcao = EnemieDirection.leftdown;
          }
      }
   }
    
 

  

}
