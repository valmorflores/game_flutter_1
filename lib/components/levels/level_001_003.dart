import 'package:teste/components/enemy.dart';
import 'package:teste/components/tools.dart';
import 'package:teste/controlls/gameController.dart';
import 'package:teste/controlls/gameDesafios.dart';
import 'package:teste/models/enum_desafios.dart';
import 'package:teste/models/enum_enemy.dart';
import 'package:teste/models/enum_tools.dart';

class Level001003 {
  GameController gameController;

  Level001003({this.gameController}) {
    this.gameController.inimigos = 20;
    this.gameController.gameLevel.percentual = 40;
     
    this.gameController.tools.items.add(ToolsItem(
        gameController: this.gameController,
        tooltype: ToolsType.add_energyblock,
        name: 'Tools',
        quantidade: 20));

    this.gameController.tools.items.add( ToolsItem(
            gameController: this.gameController,
            tooltype: ToolsType.status_cutblock,
            name: 'Tools',
            quantidade: 100000000 ) );
    
  }
}
