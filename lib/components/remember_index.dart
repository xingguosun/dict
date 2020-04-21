import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:collins_vocabulary/components/word_detail.dart';
import 'package:collins_vocabulary/components/wordcard.dart';
import 'package:collins_vocabulary/model/word.dart';
import 'package:collins_vocabulary/components/book_options.dart';
import 'package:collins_vocabulary/model/db.dart';
import 'dart:async';

class RememberIndex extends StatefulWidget {
  final SharedPreferences prefs;
  final String title;
  RememberIndex({Key key,this.prefs,this.title}) : super(key:key);

  @override
  RememberIndexState createState()  =>  new RememberIndexState();
}

class RememberIndexState extends State<RememberIndex> {
  List list;
  DBClient client;

  @override
  initState(){
    super.initState();
    client = new DBClient();
  }

  @override
  dispose(){
    super.dispose();
  }

  Future<Map> getListNumber() async{
    List wholeList = await new Word().getList(widget.prefs.getInt('level'));
      
    List studiedList =  await client.queryAll();
    List studied = wholeList.where((item){
      return studiedList.contains(item['word']);
    }).toList();
    return {'studiedNumber':studied.length, 'wholeListNumber':wholeList.length};
  }

  Widget _getProgressBar(){
   
    return new Column(
        children: <Widget>[
          ClipRRect(
            // padding: const EdgeInsets.symmetric(vertical: 8.0),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              value: 0.1,
              
            ),
          )
        ],
      );
  }
  Widget _generateWidget(){
    // final word = widget.item;
    return new Container(
      height: 160.0,
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage('assets/img/mine.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      // padding: new EdgeInsets.all(8.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // alignment: WrapAlignment.center,
        // crossAxisAlignment: WrapCrossAlignment.center,
        // runSpacing: 9.0,
        children: <Widget>[
          Row(
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.only(left:20.0,top: 10.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Text('基本英语',
                      style: new TextStyle(
                        fontSize: 22.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    new Padding(padding: new EdgeInsets.only(left:200.0)),
                    new FlatButton(
                      padding: new EdgeInsets.only(left:10.0, right:10.0),
                      color: Colors.white,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      child: Text("切换计划", style: new TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold
                      ),),
                      shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                      onPressed: (){
                        Navigator.of(context).push(
                            new MaterialPageRoute(
                                builder: (context) => new SelectBook(prefs:widget.prefs)
                            )
                        );
                      }
                    ),
                  ],
                )
              )
            ]
          ),
          Wrap(
            children: <Widget>[
              Padding(
                padding: new EdgeInsets.only(left:10.0,top: 60.0,right:10.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        new Text('1%', 
                          style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.white
                        ),),
                        new Text('已学1个，共850个单词',
                          style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.white
                        ),)
                      ],
                    ),
                    _getProgressBar(),
                  ],
                )
              )
            ]
          )
          // Row(
          //   children: [
          //     new Padding(padding: const EdgeInsets.only(top:50.0)),
          //     _getProgressBar(),
          //   ],
          // )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Dictionary"),
        elevation: 0.0,
      ),
      body: new Container(
        child: new Column(
          children: [
            _generateWidget(),
           new Row(
            mainAxisAlignment: MainAxisAlignment.center,
             children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width-20,
                    height: 50,
                    child: new FlatButton(
                      // padding: new EdgeInsets.only(left:10.0, right:10.0),
                      
                      color: Colors.blue[800],
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      child: Text("开始学习", style: new TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),),
                      // shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      onPressed: (){
                        Navigator.of(context).push(
                            new MaterialPageRoute(
                                builder: (context) => new RememberVocab(prefs:widget.prefs)
                            )
                        );
                      }
                    ),
                  ),
                ),
             ],
           )
          ],
        ),
      ),
    );
  }
}