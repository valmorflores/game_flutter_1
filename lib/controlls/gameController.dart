import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teste/components/blocks.dart';
import 'package:teste/components/enemy.dart';
import 'package:teste/components/health_bar.dart';
import 'package:teste/components/level_counting.dart';
import 'package:teste/components/level_gameover.dart';
import 'package:teste/components/level_wait_text.dart';
import 'package:teste/components/mark.dart';
import 'package:teste/components/ocupacao_text.dart';
import 'package:teste/components/player.dart';
import 'package:teste/components/score_text.dart';
import 'package:teste/controlls/gameLevels.dart';
import 'package:teste/models/enum_coordinates.dart';
import 'package:teste/models/enum_enemy.dart';
import 'package:teste/models/enum_mark.dart';
import 'package:teste/models/enum_state.dart';

class GameController extends Game {
  Size screenSize;
  double tileSize = 10;
  Player player;
  List<Enemy> enemies = []; // = new Enemy(5);
  List<Blocks> blocks = [];
  List<Mark> marks = [];
  int inimigos = 100;
  int level = 100;
  int score = 0;
  double ocupacao = 0;
  HealthBar healthBar;
  ScoreText scoreText;
  LevelWaitText levelWaitText;
  LevelCounting levelCounting;
  LevelGameOverText levelGameOverText;
  Offset vdragposition;
  Offset hdragposition;
  StateGame state;
  OcupacaoText ocupacaoText;
  
  GameLevel gameLevel;

  GameController() {
    initialize();
  }

  void initialize() async {
    int diff;
    bool emSerie = false;
    resize(await Flame.util.initialDimensions());
    Flame.util.fullScreen();
    player = Player(this);
    gameLevel = GameLevel(gameController: this);
    healthBar = HealthBar(gameController: this);
    scoreText = ScoreText(gameController: this);    
    ocupacaoText = OcupacaoText(gameController: this);
    levelWaitText = LevelWaitText(gameController: this);
    levelCounting = LevelCounting(gameController: this);
    levelGameOverText = LevelGameOverText(gameController: this);
    this.inimigos = this.inimigos + 1;
    this.ocupacao = 0;
    state = StateGame.menu;

    // Criação inimigos
    double x, y;
    Random randomico1 = new Random(256);
    Random randomico2 = new Random(256);
    Random randomico3 = new Random(50);
    emSerie = randomico1.nextInt(1)==1?false:true;
    for (var i = 0; i < inimigos; i++) {
      randomico2 = Random(256 * i);
      x = randomico1.nextDouble() * 1000;
      y = randomico2.nextDouble() * 1000;
      if (emSerie){
        x = ( i * 5.1 );
         y = ( i * 5.1 );
      }
      diff = randomico3.nextInt(100);
      diff = diff < 50 ? 50 : diff;
      print('Enemies=' + x.toString() + '-' + y.toString());
      enemies.add(Enemy(gameController: this, x: x, y: y, difficulty: diff));
    }

    gameLevel.extras();

  }

  void render(Canvas c) {
    Rect background = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()
      ..color = Colors.amber; //Color.fromRGBO(255,255,255,1);
    c.drawRect(background, backgroundPaint);
    player.render(c);
    //enemies.map((eni) => eni.render(c));
    enemies.forEach((element) => element.render(c));
    if ( state == StateGame.menu ){
       levelWaitText.render(c);
    }
    else if ( state == StateGame.gameover ){
       blocks.forEach((element) => element.render(c));
       levelGameOverText.render(c);
    }
    else if ( state == StateGame.counting ){
       levelCounting.render(c);
    }
    else if ( state == StateGame.playing )
    {
        blocks.forEach((element) => element.render(c));
        marks.forEach((element) => !element.isDead ? element.render(c) : null);
        // enemies aqui <------  
        healthBar.render(c);        
        gameLevel.render(c);
    }
    scoreText.render(c);
    ocupacaoText.render(c);
  }

  void update(double t) {
    marks.removeWhere((Mark mark) => mark.isDead);
    blocks.removeWhere((Blocks block) => block.isDead);
    enemies.removeWhere((Enemy enemie) => enemie.isDead);
    enemies.forEach((element) => element.update(t));
    blocks.forEach((element) => element.update(t));
    marks.forEach((element) => element.update(t));
    scoreText.update(t);
    healthBar.update(t);
    gameLevel.update(t);
    levelWaitText.update(t);    
    //if ( state == StateGame.counting ){      
       //?
       
    //}
    levelCounting.update(t);
    levelGameOverText.update(t);
    ocupacaoText.update(t);
    if (gameLevel.ocupacao() > 90) {
      this.level = this.level +1;
      gameLevel.finalcount();
      if ( this.enemiesCount() <= 1 ){
         gameLevel.up();
         gameLevel.startlevel();
         gameLevel.start();
      }
      print( 'Level count: ' + gameLevel.count().toString() );
      print( 'Score: ' + this.score.toString() );
    }
    else if (player.currentHealt<=0){
      //this.score = 0;
      state = StateGame.gameover;
      gameLevel.finalgameover();
      //gameLevel.up();
      //gameLevel.startlevel();
      //gameLevel.start();
      print( 'Level count: ' + gameLevel.count().toString() );
      print( 'Score: ' + this.score.toString() );
    } 
  }

  void resize(Size size) {
    screenSize = size;
    //tileSize = ( screenSize / 30 );
  }

  void onTapDown(TapDownDetails d) {
    // todo: melhorar o randomico
    if ( state == StateGame.menu ) {
       state = StateGame.playing;
    }
    else if ( state == StateGame.gameover ) {
       sleep(const Duration(seconds:1));
       state = StateGame.playing;
       gameLevel.resetall();
       this.level = this.level -1;
       this.inimigos = this.inimigos -1;
       this.initialize();
    }
    else
    {
      Random randnumero = new Random();
      double size = ( 50 + randnumero.nextInt(100) / 2 );
      blocks.add(Blocks(
          gameController: this,
          top: d.globalPosition.dy - (size / 2),
          left: d.globalPosition.dx - (size / 2),
          width: size,
          height: size,
          blockColor: Colors.lightBlueAccent,
          isSpoiled: true));
      //print('tap' + d.globalPosition.dx.toString());
    }
  }

  void onVerticalDragStart(DragStartDetails d) {
    this.vdragposition = d.globalPosition;
    
    print('drag vertical.detail.start = ' +
        d.globalPosition.dx.toString() +
        '/' +
        d.globalPosition.dy.toString());
  }

  void onVerticalDragUpdate(DragUpdateDetails d) {
    this.vdragposition = d.globalPosition;
  }

  void onVerticalDragEnd(DragEndDetails d) {
    if ( state == StateGame.playing ){
      if ( this.vdragposition != null ){
        marks.add(Mark(
            gameController: this,
            top: this.vdragposition.dy,
            left: this.vdragposition.dx,
            width: 10,
            height: 150));
        //blocks.add( Blocks(gameController: this, top: this.vdragposition.dy, left: this.vdragposition.dx, width: 150, height: 150, blockColor: Colors.pinkAccent));
        print('drag vertical.detail.end.velocity = ' + d.velocity.toString());
      }
    }
  }

  void onHorizontalDragStart(DragStartDetails d) {
    print('drag horizontal detail.start = ' +
        d.globalPosition.dx.toString() +
        '/' +
        d.globalPosition.dy.toString());
  }

  void onHorizontalDragEnd(DragEndDetails d) {
    if ( state == StateGame.playing ){
        if ( this.hdragposition != null ){
          marks.add(Mark(
            gameController: this,
            top: this.hdragposition.dy,
            left: this.hdragposition.dx,
            width: 10,
            height: 10,
            direction: MarkDirection.horizontal));
        print('drag horizontal.end.velocity = ' + d.velocity.toString());
      }
    }
  }

  void onHorizontalDragUpdate(DragUpdateDetails d) {
    this.hdragposition = d.globalPosition;
  }

  void counting(){

  }

  void emininateOneEnemy(){
      this.enemies[0].goPrision();
      this.enemies[0].isDead = true;
  }

  void sendtoJailOneEnemy(){
    int i = 0;
    this.enemies.forEach( (f) { 
      if (!f.isDead){
        if ( i <= 0 ){
          if ( !f.isGoingToPrision ){
              f.goPrision();
              ++i;
          }
        }
      }
    });
    
  }

  int enemiesCount(){
    int i = 0;
    this.enemies.forEach((f)=>++i);
    return i;
  }

  Coordinates quadranteMenosImportante(){
    double topLeft = 0, topRight = 0, bottom = 0;
    int i=0;

    int inTopLeft = 0;
    int inTopRight = 0;
    int inBottomLeft = 0;
    int inBottomRight = 0;
    // pegando a menor e maior coordenada 
    // onde ha inimigo
    this.enemies.forEach( (f) {
      if ( f.enemyRect.left <= topLeft ){
         topLeft = f.enemyRect.left;
      }  
      if ( f.enemyRect.left > topRight ){
         topRight = f.enemyRect.right;
      }
      if ( f.enemyRect.bottom > bottom ){
         bottom = f.enemyRect.bottom;
      }
    });
 
    inTopLeft = 0;
    inTopRight = 0;
    inBottomLeft = 0;
    inBottomRight = 0;

    this.enemies.forEach( (f) {
      if ( ( f.enemyRect.left <= topRight / 2 ) &&
           ( f.enemyRect.bottom <= bottom / 2 ) ) {
          ++inTopLeft;
      }  
      else if ( ( f.enemyRect.left <= topRight / 2 ) &&
           ( f.enemyRect.bottom > bottom / 2 ) ) {
          ++inBottomLeft;
      }  
      else if ( ( f.enemyRect.left > topRight / 2 ) &&
           ( f.enemyRect.bottom < bottom / 2 ) ) {
          ++inTopRight;
      }
      else if ( ( f.enemyRect.left > topRight / 2 ) &&
           ( f.enemyRect.bottom > bottom / 2 ) ) {
          ++inBottomRight;
      } 
    });

    if ( ( inTopRight >= inTopLeft ) && 
         ( inTopRight >= inBottomLeft ) &&
         ( inTopRight >= inBottomRight ) ) {
           return Coordinates.topRight;
    }
    if ( ( inTopLeft >= inTopRight ) && 
         ( inTopLeft >= inBottomLeft ) &&
         ( inTopLeft >= inBottomRight ) ) {
           return Coordinates.topLeft;
    }
    if ( ( inBottomLeft >= inTopRight ) && 
         ( inBottomLeft >= inTopLeft ) &&
         ( inBottomLeft >= inBottomRight ) ) {
           return Coordinates.bottomLeft;
    }
    if ( ( inBottomRight >= inTopRight ) && 
         ( inBottomRight >= inTopLeft ) &&
         ( inBottomRight >= inBottomLeft ) ) {
           return Coordinates.bottomRight;
    }

  }


  Coordinates quadranteMaisImportanteHorizontal( double lin ){
    int inTop = 0, inBottom = 0;
    int i=0;
 
    // pegando a menor e maior coordenada 
    // onde ha inimigo
    this.enemies.forEach( (f) {
      if ( f.enemyRect.bottom >= lin ){
         inBottom+=( f.enemyType == EnemyType.chefao )?1000:1;
         inBottom+=( f.enemyType == EnemyType.chefe )?0500:1;
         inBottom+=( f.enemyType == EnemyType.vitima )?2000:1;     
      }
      else
      {
         inTop+=( f.enemyType == EnemyType.chefao )?1000:1;
         inTop+=( f.enemyType == EnemyType.chefe )?0500:1;
         inTop+=( f.enemyType == EnemyType.vitima )?2000:1;     ;
      }
    });
 
    if ( inTop >= inBottom ) {
       return Coordinates.top;
    }
    else
    {
       return Coordinates.bottom;
    }
  }



  Coordinates quadranteMaisImportanteVertical( double col ){
    int inLeft = 0, inRight = 0;
    int i=0;
 
    // pegando a menor e maior coordenada 
    // onde ha inimigo
    this.enemies.forEach( (f) {
      if ( f.enemyRect.left >= col ){
         inRight+=( f.enemyType == EnemyType.chefao )?1000:1;
         inRight+=( f.enemyType == EnemyType.chefe )?0500:1;
         inRight+=( f.enemyType == EnemyType.vitima )?2000:1;         
      }
      else
      {
         inLeft+=( f.enemyType == EnemyType.chefao )?1000:1;
         inLeft+=( f.enemyType == EnemyType.chefe )?0500:1;
         inLeft+=( f.enemyType == EnemyType.vitima )?2000:1;         
      }
    });
 
    if ( inRight >= inLeft ) {
       return Coordinates.rigth;
    }
    else
    {
       return Coordinates.left;
    }
  }
  
}
