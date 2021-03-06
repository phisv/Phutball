import 'dart:collection';
import 'dart:math';
import 'package:phutball/board.dart';
import 'package:phutball/player.dart';
import 'package:flutter/material.dart';

enum ImageType {
  player,
  ball,
  select,
  redend,
  blueend,
}

class LocalMultiplayer extends StatefulWidget {
  @override
  _LocalMultiplayerState createState() => _LocalMultiplayerState();
}

class _LocalMultiplayerState extends State<LocalMultiplayer> {
  // List<List<BoardSquare>> board; //board xd
  //classic is 19 rows 15 cols
  static int rowCount = 19;
  static int columnCount = 15;
  Board board;
  Player a, b, winner;
  bool turn;
  Queue q = new Queue();

  @override
  void initState() {
    super.initState();
    _initialiseGame();
  }

  void _initialiseGame() {
    //probably inits game
    board = new Board(rowCount, columnCount);
    a = new Player("A");
    b = new Player("B");
    var rng = new Random();
    if (rng.nextInt(10) % 2 == 0) //big brain ?
    {
      q.add(a);
      q.add(b);
    } else {
      q.add(b);
      q.add(a);
    }
    q.first.startMove();
    board.saveState();
  }
  void _playAgain() {
    //probably inits game
    board = new Board(rowCount, columnCount);
    var rng = new Random();
    q.clear();
    if (rng.nextInt(10) % 2 == 0) //big brain ?
    {
      q.add(a);
      q.add(b);
    } else {
      q.add(b);
      q.add(a);
    }
    q.first.startMove();
    board.saveState();
  }

  void _endGame() {
    _endDialog();
  }

  void _ResignDialog() {  //this isnt working reeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Are You Sure?"),
          content: new Text("There's always a chance!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                setState(() {
                   _endGame();
                });
               Navigator.of(context).pop(); 
              },
            ),
          ],
        );
      },
    );
  }

  void _endDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Player " + winner.name + " wins!"),
          content: new Text("Scoreboard:\n" + a.name + ": " + a.score.toString() + "\n" + b.name + ": " + b.score.toString() + "\n\nPlay again?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                setState(() {
                   _playAgain();
                });
               Navigator.of(context).pop(); 
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                setState(() {
                   _initialiseGame();
                });
               Navigator.of(context).pop(); 
               Navigator.of(context).pop(); //pop dialog then pop page, return to menu
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext ctxt) {
    var _endAction; //end turn button calls this

    if (q.first.hasJumped() || q.first.hasPlaced()) {
      _endAction = () {
        setState(() {
          q.first.endMove();
          q.add(q.first);
          q.removeFirst();
          q.first.startMove();
          board.saveState();
          board.dropBall();
          if(board.endzone() == 0){
            winner = a; //first player instead of a
            a.win();
            _endGame();
          }
          if(board.endzone() == 1){
            winner = b; //second player instead of b
            b.win();
            _endGame();
          }
        });
      };
    }

    // var _loadState =

    return Scaffold(
      body: ListView(children: <Widget>[
        Container(
          //top bar oponent info or whatever
          padding: const EdgeInsets.all(10.0),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon:Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(ctxt).pop();
                },
              ),
              Container(width: 7),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Local Multiplayer", style: TextStyle(fontSize: 20), ),
                    Container(
                      height: 4,
                    ),
                    Text(q.first.name + "'s Turn", style: TextStyle(color: Colors.green), textAlign: TextAlign.left,),
                  ],
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            mainAxisSpacing: 0.0,
            crossAxisSpacing: 0.0,
            childAspectRatio: 1.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          itemBuilder: (context, position) {
            // Get row and column number of square

            int rowNumber = (position / columnCount).floor();
            int columnNumber = (position % columnCount);

            Image image;

            if (board.isDot(rowNumber, columnNumber)) {
              //draw the image into each square
              image = getImage(ImageType.player);
            } else if (board.isBall(rowNumber, columnNumber) &&
                board.inHand == true) {
              //ball selected
              image = getImage(ImageType.select);
            } else if (board.isBall(rowNumber, columnNumber)) {
              image = getImage(ImageType.ball);
            } else {
              image = getImage(null);
            }

            return InkWell(
              onTap: () // draw square
                  {
                if (q.first.canMakeMove()) {
                  if (board.isBall(rowNumber, columnNumber) &&
                      !board.hasBall()) {
                    //select ball
                    setState(() {
                      board.getBall(rowNumber, columnNumber);
                    });
                  } else if (board.hasBall()) {
                    //ball is selected, clicked a square
                    if (board.isBall(rowNumber, columnNumber) ||
                        board.isDot(rowNumber, columnNumber)) {
                      //selection totally invalid so deselect ball
                      setState(() {
                        board.dropBall();
                      });
                    } else {
                      board.initJump(rowNumber, columnNumber);
                      if (board.checkJump(rowNumber, columnNumber)) {
                        //continue with move
                        setState(() {
                          board.jump(rowNumber, columnNumber);
                          q.first.makeJump(); //not sure if needs to be in setState
                        });
                      } else {
                        //deselect ball
                        setState(() {
                          board.dropBall();
                        });
                      }
                    }
                  } else if (!q.first.hasJumped() &&
                      !(board.isDot(rowNumber, columnNumber))) {
                    setState(() {
                      board.setDot(rowNumber, columnNumber);
                      q.first.makePlacement(); //idk if needs to be in setState        i think they should be
                    });
                  }
                }
              },
              splashColor: Colors.lightBlueAccent,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage('images/grid.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: image, //ball png or whatever
              ),
            );
          },
          itemCount: rowCount * columnCount,
        ),
        Container(
          //bottom bar info game or whatever
          padding: const EdgeInsets.all(10.0),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new RaisedButton(
                child: const Text('End Turn'),
                color: Theme.of(context).accentColor,
                elevation: 4.0,
                splashColor: Colors.white,
                onPressed: _endAction, //refer to top
              ),
              new Container(width: 10),
              new RaisedButton(
                child: const Text('Reset'),
                color: Theme.of(context).accentColor,
                elevation: 4.0,
                splashColor: Colors.white,
                onPressed: () {
                  setState(() {
                    board.loadState();
                    q.first.reset();
                  });
                },
              ),
              new Container(width: 10),
              new RaisedButton(
                child: const Text('Resign'),
                color: Theme.of(context).accentColor,
                elevation: 4.0,
                splashColor: Colors.white,
                onPressed: () {
                  setState(() {
                    _ResignDialog();
                  });
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }

  //images list
  Image getImage(ImageType type) {
    switch (type) {
      case ImageType.ball:
        return Image.asset('images/ball.png');
      case ImageType.player:
        return Image.asset('images/player.png');
      case ImageType.select:
        return Image.asset('images/ballSelect.png');
      case ImageType.redend:
        return Image.asset('images/red.png');
      case ImageType.blueend:
        return Image.asset('images/blue.png');
      default:
        return null;
    }
  }
}
// i have no clue what im doing  https://github.com/deven98/FlutterMinesweeper
//uwu quakquakquak
