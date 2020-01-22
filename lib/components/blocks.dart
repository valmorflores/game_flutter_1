import 'package:flutter/rendering.dart';
import 'package:teste/controlls/gameController.dart';

class Blocks {
    
   final GameController gameController;
   double left;
   double top;
   double width;
   double height;
   Color blockColor;
   Rect blockRect;
   bool isDead;
   bool isSpoiled;
 
   Rect get qualBlock {
     return this.blockRect;
   }

   Blocks( {this.gameController, this.left, this.top, this.width, this.height, this.blockColor, this.isSpoiled = true } )
   {
      double barWidth = gameController.screenSize.width * 1;
      Offset maximus;
      double sizewidth, sizeheight;
      this.isDead = false;     
      maximus = this.gameController.arena.addblock(top: this.top, left:this.left, height: this.height, width: this.width );
      sizewidth = maximus.dx;
      sizeheight = maximus.dy;
      if ( this.isSpoiled ){
         if ( sizewidth > 50 ){
           sizewidth = 50;
         }
         if ( sizeheight > 50 ){
           sizeheight = 50;
         }
      }     
      blockRect = Rect.fromLTWH(
          left, top, sizewidth, sizeheight );
      this.gameController.killif();
      this.gameController.arena.printarena();
      incorporaGrupo();
      somaocupacao();
      
   }

   void render( Canvas c ){
     Paint useblockColor = Paint()..color = this.blockColor;
     c.drawRect( blockRect, useblockColor);
   }

   void update( double t ){

   }

   void incorporaGrupo(){
     Offset coordenada1, coordenada2, coordenada3, coordenada4;
     double l, t, b, r;
     this.gameController.blocks.forEach((f){
         l=f.blockRect.left>=0?f.blockRect.left:0;
         t=f.blockRect.top>=0?f.blockRect.top:0;
         b=(f.blockRect.bottom <= this.gameController.screenSize.height?f.blockRect.bottom:this.gameController.screenSize.height);
         r=(f.blockRect.right <= this.gameController.screenSize.width?f.blockRect.right:this.gameController.screenSize.width);
         coordenada1 = Offset( l, t );
         coordenada2 = Offset( l, b );
         coordenada3 = Offset( r, t );
         coordenada4 = Offset( r, b );
         if (!f.isSpoiled ) {
            print('block (not isSpoiled) normal ' + 't=' + t.toString() + ',' + 
                   'l=' + l.toString() + ',' + 
                   'b=' + b.toString() + ',' + 
                   'r=' + r.toString());

         }
         if ( f.isSpoiled ) {
            if ( this.blockRect.contains(coordenada1) || 
                 this.blockRect.contains(coordenada2) ||
                 this.blockRect.contains(coordenada3) || 
                 this.blockRect.contains(coordenada4) ){
                f.isSpoiled = false;
                f.blockColor = this.blockColor;
                print( '> Block: t=' + t.toString() + ',' + 
                   'l=' + l.toString() + ',' + 
                   'b=' + b.toString() + ',' + 
                   'r=' + r.toString()
                  );
                //f.incorporaGrupo();
            }
            else
            {
               print( 'Block nao contem: t=' + t.toString() + ',' + 
                   'l=' + l.toString() + ',' + 
                   'b=' + b.toString() + ',' + 
                   'r=' + r.toString()
                  );
            }
         }
     });
   }

   void somaocupacao(){
      this.gameController.ocupacao=this.gameController.arena.areaocupada();
   }

}