import 'package:teste/components/enemy.dart';
import 'package:teste/components/tools.dart';
import 'package:teste/controlls/gameController.dart';
import 'package:teste/controlls/gameDesafios.dart';
import 'package:teste/models/enum_desafios.dart';
import 'package:teste/models/enum_enemy.dart';
import 'package:teste/models/enum_tools.dart';

class Level001004 {
  GameController gameController;

  Level001004({this.gameController}) {
    this.gameController.inimigos = 50;
    this.gameController.gameLevel.percentual = 20;
    this.gameController.enemies.add(new Enemy(
        gameController: this.gameController,
        x: 50,
        y: 50,
        difficulty: 20,
        enemyType: EnemyType.chefao));
    this.gameController.enemies.add(new Enemy(
        gameController: this.gameController,
        x: 50,
        y: 50,
        difficulty: 30,
        enemyType: EnemyType.gerente));
    this.gameController.enemies.add(new Enemy(
        gameController: this.gameController,
        x: 50,
        y: 50,
        difficulty: 50,
        enemyType: EnemyType.gangster));
    this.gameController.enemies.add(new Enemy(
        gameController: this.gameController,
        x: 50,
        y: 50,
        difficulty: 40,
        enemyType: EnemyType.gangster));
    this.gameController.tools.items.add(ToolsItem(
        gameController: this.gameController,
        tooltype: ToolsType.add_energyblock,
        name: 'Tools',
        quantidade: 5));

    this.gameController.tools.items.add(ToolsItem(
        gameController: this.gameController,
        tooltype: ToolsType.status_cutblock,
        name: 'Tools',
        quantidade: 100000000));
  }
}
