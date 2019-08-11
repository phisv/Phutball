import 'package:phutball/board.dart';
import 'package:flutter/material.dart';

enum ImageType{
  player,
  ball,
  select,
  redend,
  blueend,
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List<List<BoardSquare>> board; //board xd
  //classic is 19 rows 15 cols
  static int rowCount = 19;
  static int columnCount = 15;
  Board board;
  bool turn;

  @override
  void initState() {
    super.initState();
    _initialiseGame();
  }

  void _initialiseGame() {  //probably inits game 
    board = new Board(rowCount,columnCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container( //top bar oponent info or whatever
            padding: const EdgeInsets.all(10.0),
          
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.face, color: Colors.orange,size: 40.0,),
                Container(width: 7),   
                Container(           
                  child: Column(
                    children: <Widget>[
                      Text("Level 5 Ai"),
                      Container(height: 2,),
                      Text("your turn", style: TextStyle(color: Colors.green)), //change according to whos turn it is
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
            
              if(board.isDot(rowNumber,columnNumber)){  //draw the image into each square
                image = getImage(ImageType.player);
              }
              else if(board.isBall(rowNumber,columnNumber) &&  board.inHand == true ){  //ball selected
                image = getImage(ImageType.select);
              }
              else if(board.isBall(rowNumber,columnNumber)){  
                image = getImage(ImageType.ball);
              }
              else{
                image = getImage(null);
              }

              return InkWell(
                // draw square
                onTap: () { 
                  if(board.isBall(rowNumber,columnNumber) && !board.hasBall()){ //select ball
                    setState(() {
                      board.getBall(rowNumber, columnNumber);
                    });
                  }

                  else if(board.hasBall())
                  { //ball is selected, clicked a square
                    if(board.isBall(rowNumber,columnNumber) || board.isDot(rowNumber, columnNumber)){ //selection totally invalid so deselect ball
                      setState(() {
                        board.dropBall();
                      });
                    }
                    else{
                      board.initJump(rowNumber,columnNumber);
                      if(board.checkJump()){ //continue with move
                        setState(() {
                          board.jump(rowNumber,columnNumber);
                        });
                      } 
                      else{ //deselect ball
                        setState(() {
                          board.dropBall();
                        });
                      }        
                    }  
                  } 
                  else{ 
                    setState(() {
                      board.setDot(rowNumber,columnNumber);
                    });
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
                  child: image,   //ball png or whatever
                ),
              );
            },
            itemCount: rowCount * columnCount,
         ),
          Container( //bottom bar info game or whatever
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
                  onPressed: () {
                    // end turn
                  },
                ),
                new Container(width: 10),
                new RaisedButton(
                  child: const Text('Reset'),
                  color: Theme.of(context).accentColor,
                  elevation: 4.0,
                  splashColor: Colors.white,
                  onPressed: () {
                    // reset turn
                  },
                ),      
              ],
            ),
          ),
        ]
      ),
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