import 'package:teste/controlls/gameController.dart';
import 'package:teste/models/enum_desafios.dart';
import 'package:teste/models/enum_enemy.dart';

class Desafios {

   List<DesafiosItem> items;
   GameController gameController;
   Desafios({this.gameController,this.items}){     
   }

   void add( DesafiosItem item ){
     this.items.add( item );
   }
   
   int countbyenemytype(EnemyType enemyTypehere ){
     int count=0;
     this.items.forEach((f){
        if ( f.enemytype == enemyTypehere ){
          count = f.quantidade;
        }
     });
     return count;
   }

}

class DesafiosItem {
   EnemyType enemytype;
   String name;
   DesafiosGame desafio;
   int quantidade;

   DesafiosItem({this.name, this.enemytype, this.desafio, this.quantidade});
}
