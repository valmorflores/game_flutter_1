import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teste/arena.dart';
import 'package:teste/components/blocks.dart';
import 'package:teste/components/desafio_status.dart';
import 'package:teste/components/enemy.dart';
import 'package:teste/components/enemy_text.dart';
import 'package:teste/components/health_bar.dart';
import 'package:teste/components/level_counting.dart';
import 'package:teste/components/level_gameover.dart';
import 'package:teste/components/level_percent.dart';
import 'package:teste/components/level_wait_text.dart';
import 'package:teste/components/mark.dart';
import 'package:teste/components/ocupacao_text.dart';
import 'package:teste/components/player.dart';
import 'package:teste/components/score_text.dart';
import 'package:teste/components/tools.dart';
import 'package:teste/components/tools/block_energy.dart';
import 'package:teste/controlls/gameDesafios.dart';
import 'package:teste/controlls/gameLevels.dart';
import 'package:teste/main.dart';
import 'package:teste/models/enum_coordinates.dart';
import 'package:teste/models/enum_enemy.dart';
import 'package:teste/models/enum_fails.dart';
import 'package:teste/models/enum_mark.dart';
import 'package:teste/models/enum_state.dart';
import 'package:teste/models/enum_tools.dart';
import 'package:teste/screens/view_video_get_live.dart';

class GameController extends Game {
  Size screenSize;
  BuildContext context;  
  ToolsType toolsType;
  Arena arena;
  double tileSize = 10;
  double toolSize = 50;
  Player player;
  List<Enemy> enemies = []; // = new Enemy(5);
  List<Blocks> blocks = [];
  List<Mark> marks = [];
  int inimigos = 0;
  int level = 1;
  int score = 0;
  int inAnalise = 0;
  int lives = 0;
  int livedown = 3;
  double ocupacao = 0;
  bool firstTap = false;
  HealthBar healthBar;
  ScoreText scoreText;
  LevelWaitText levelWaitText;
  LevelCounting levelCounting;
  LevelGameOverText levelGameOverText;
  Offset vdragposition;
  Offset hdragposition;
  StateGame state;
  OcupacaoText ocupacaoText;
  DesafioStatus desafioStatus;
  EnemyText enemyText;
  Desafios desafios;
  Tools tools;
  LevelPercent levelPercent;
  
  GameLevel gameLevel;

  GameController({this.context}) {
    initialize();
  }

  void initialize() async {
    int diff;
    
    bool emSerie = false;
    resize(await Flame.util.initialDimensions());
    Flame.util.fullScreen();    
    player = Player(this);   
    arena = Arena(gameController: this);
    desafios = Desafios(gameController: this, items: [] );
    gameLevel = GameLevel(gameController: this);
    healthBar = HealthBar(gameController: this);
    scoreText = ScoreText(gameController: this);    
    ocupacaoText = OcupacaoText(gameController: this);   
    enemyText = EnemyText(gameController: this);
    levelWaitText = LevelWaitText(gameController: this);
    levelCounting = LevelCounting(gameController: this);
    levelGameOverText = LevelGameOverText(gameController: this);
    tools = Tools(gameController: this);
    tools.items.clear();
    toolsType = ToolsType.none;
    firstTap = false;
    this.inimigos = this.inimigos + 1;
    this.ocupacao = 0;
    this.gameLevel.percentual = 50;
    state = StateGame.menu;
    levelPercent = LevelPercent(gameController: this);
    this.livedown = 1;
    // Criação inimigos
    double x, y;
    Random randomico1 = new Random(256);
    Random randomico2 = new Random(256);
    Random randomico3 = new Random(50);
    emSerie = randomico1.nextInt(1)==1?false:true;
    for (var i = 0; i < this.inimigos; i++) {
      randomico2 = Random(256 * i);
      x = randomico1.nextDouble() * 1000;
      y = randomico2.nextDouble() * 1000;
      if (emSerie){
        x = ( i * 5.1 );
         y = ( i * 5.1 );
      }
      diff = randomico3.nextInt(100);
      diff = diff < 50 ? 50 : diff;
      //print('Enemies=' + x.toString() + '-' + y.toString());
      this.enemies.add(Enemy(gameController: this, x: x, y: y, difficulty: diff));
    }

    this.gameLevel.extras();
    this.arena.printarena();
    desafioStatus = DesafioStatus(gameController: this);
  }

  void render(Canvas c) {
    Rect background = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()
      ..color = Colors.blueGrey; //Color.fromRGBO(255,255,255,1);
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
        levelPercent.render(c);
        marks.forEach((element) => !element.isDead ? element.render(c) : null);
        // enemies aqui <------  
        healthBar.render(c);        
        gameLevel.render(c);       
        tools.render(c);
        desafioStatus.render(c);
        
    }
    state!=StateGame.gameover?scoreText.render(c):null;  
    state!=StateGame.gameover?enemyText.render(c):null;
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
    levelCounting.update(t);
    levelGameOverText.update(t);
    ocupacaoText.update(t);
    enemyText.update(t);
    desafioStatus.update(t);
    levelPercent.update(t);
    if (this.gameLevel.ocupacao().toInt() >= this.gameLevel.percentual.toInt()) {
      //this.level = this.level +1;
      gameLevel.finalcount();
      if ( this.enemiesCount() <= 1 ){
         gameLevel.up();
         gameLevel.startlevel();
         gameLevel.start();
      }      
    }
    else if ( this.gameLevel.fail() != FailsGame.none)
    {
      this.lives -= this.livedown;
      this.livedown = 0;
      state = StateGame.gameover;
      gameLevel.finalgameover();
    }
    tools.update(t);
    //else if (player.currentHealt<=0){
    //  state = StateGame.gameover;
    //  gameLevel.finalgameover();
    //}

    
  }

  rodavideo(){
    if ( state == StateGame.getlivebyvideo ){
       this.state = StateGame.runningVideo;
       Navigator.push( this.context,
                MaterialPageRoute(builder: (context) => ViewVideoGetLive( parametro: '',)));
       //new ViewVideoGetLive( parametro: '',);  

    }
  }

  void resize(Size size) {
    screenSize = size;     
  }

  void onTapDown(TapDownDetails d) {
    
    if ( state == StateGame.menu ) {
       state = StateGame.playing;
    }
    else if ( state == StateGame.getlivebyvideo ){
      if ( this.lives > 0 ){
        state = StateGame.playing;
        gameLevel.resetall();       
        this.inimigos = this.inimigos -1;
        this.initialize();
      }
      else
      {
        rodavideo();//state == StateGame.runningVideo;
      }
    }
    else if ( state == StateGame.gameover ) {
       if ( d.globalPosition.dy < 70 ){
          if ( this.lives <= 0 ){
            // Abre área de sugestão de vídeo
            /*Navigator.push(
                null,
                MaterialPageRoute(builder: (context) => ViewVideoGetLive()),
            );*/
            print( 'Sem vidas');
            state = StateGame.getlivebyvideo;
            print( 'Rodar video');
            rodavideo();

          }
          else
          {
            print( 'Com vidas');
            state = StateGame.playing;
            gameLevel.resetall();       
            this.inimigos = this.inimigos -1;
            this.initialize();
          }
       }
    }
    else if ( state == StateGame.playing )  
    {      
      if ( d.globalPosition.dy > this.screenSize.height - this.tools.height ){
          // Pegar um item do menu
          //print( 'Menu acionado (haha)');
          /*
          if ( toolsType == ToolsType.none ){
             toolsType = ToolsType.add_energyblock;
          }
          else
          {
             toolsType = ToolsType.none;
          }*/    
          //if ( this.toolsType == ToolsType.none ){      
          this.toolsType = this.tools.onTapDown(d);
          //}
          //else
          //{
             //this.toolsType = ToolsType.none;
          //}
          print( this.toolsType.toString());
      }
      else
      {
          // Padrão, colocar blocos
          if ( this.toolsType == ToolsType.none || this.toolsType == ToolsType.add_normalblock ){
              // todo: melhorar o randomico
              Random randnumero = new Random();
              double size = ( 50 + randnumero.nextInt(100) / 2 );
              if ( size > 100 ){
                size = 20;
              }
              this.blocks.add(Blocks(
                  gameController: this,
                  top: d.globalPosition.dy - (size / 2),
                  left: d.globalPosition.dx - (size / 2),
                  width: size,
                  height: size,
                  blockColor: Colors.greenAccent, //.lightBlueAccent,
                  isSpoiled: true));
              //print('tap' + d.globalPosition.dx.toString());
          }
          else if ( this.toolsType == ToolsType.add_energyblock ){
              if ( this.tools.getQuantidade( ToolsType.add_energyblock ) > 0 ){
                double size = toolSize;
                this.blocks.add(BlockEnergy(
                    gameController: this,
                    top: d.globalPosition.dy - (size / 2),
                    left: d.globalPosition.dx - (size / 2),
                    width:50, height: 50));
                this.tools.decrement( ToolsType.add_energyblock );  
              }
          }
          firstTap = true;
        }
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

        if ( this.tools.getQuantidade( ToolsType.status_cutblock ) > 0 ){
        
          marks.add(Mark(
                  gameController: this,
                  top: this.vdragposition.dy,
                  left: this.vdragposition.dx,
                  width: 10,
                  height: 150));

          this.tools.decrement( ToolsType.status_cutblock );

        }
         
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
          if ( this.tools.getQuantidade( ToolsType.status_cutblock ) > 0 ){
            marks.add(Mark(
              gameController: this,
              top: this.hdragposition.dy,
              left: this.hdragposition.dx,
              width: 10,
              height: 10,
              direction: MarkDirection.horizontal));
            this.tools.decrement( ToolsType.status_cutblock );
          }
         
          print( 'Qtd=' + this.tools.getQuantidade( ToolsType.status_cutblock ).toString());
          
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

  int enemyCount( EnemyType enemyTypeNow ){
    int count=0;
    this.enemies.forEach((f){
       if (f.enemyType == enemyTypeNow ){
          ++count;
       }
    });
    return count;
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

  void eliminaporcoordenadaLTRB( double left, top, right, bottom ){
     this.enemies.forEach((f){
       
       if (f.enemyRect.left >= left &&
           f.enemyRect.top >= top &&
           f.enemyRect.right <= right &&
           f.enemyRect.bottom <= bottom ){
         f.isDead = true;
         print( 'morte por coordenada');
      }

     });
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

  void killif(){
     this.inAnalise = this.enemiesCount()*2;
     this.enemies.forEach((f) => f.killif());    
  }
  
}
