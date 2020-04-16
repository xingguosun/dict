import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'package:collins_vocabulary/model/word.dart';
import 'package:collins_vocabulary/common/phmp3.dart';
import 'package:collins_vocabulary/components/detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collins_vocabulary/model/db.dart';
import 'dart:async';

class RememberVocab extends StatefulWidget {
  SharedPreferences prefs;

  RememberVocab({Key key, this.prefs}) : super(key:key);
  @override
  RememberVocabState createState(){
    return new RememberVocabState();
  }
}

class RememberVocabState extends State<RememberVocab> with SingleTickerProviderStateMixin {
  DBClient client;
  int currentIndex;
  bool next;
  Word currentItem;
  List list = [];
  List stuiedWords = [];
  AnimationController controller;
  Animation<Offset> animation;
  TextDirection direction;
  Future _future;

  @override
  initState() {
    super.initState();
    _future = getlist();
    controller = new AnimationController(
        duration: new Duration(milliseconds: 300),
        vsync: this
    );
    animation = new Tween(
      begin: new Offset(0.0, 0.0),
      end: new Offset(1.0, 0.0),
    ).animate(new CurvedAnimation(parent: controller, curve: Curves.easeInOut))
    ..addStatusListener(statusListener);
    setState((){
      currentIndex = 0;
      next = false;
      direction = TextDirection.rtl;
    });
  }

  @override
  void dispose(){
    animation.removeStatusListener(statusListener);
    controller.dispose();
    super.dispose();
  }

  statusListener(status){
    print(status);
    if(status==AnimationStatus.completed && mounted){
      setState((){
        if(next==true && mounted){
          currentIndex = currentIndex+1 == widget.prefs.getInt('count') ? currentIndex : currentIndex+1;
          setState(() {
            next = false;
          });
        }
      });
      controller.reverse();
    }
  }

  Future<int> getLevel() async {
    client = new DBClient();
    final int level = widget.prefs.getInt('level');
    return level;
  }
  Widget _getimg(){
    return new Column(
        children: <Widget>[
          new Image.network(
            currentItem.img,
            scale: 2.0,
          )
        ],
      );
  }
  Widget _getPhMp3(){
    if(widget.prefs.getBool('en_ph')){
      return new Column(
        children: <Widget>[
          new PhMp3(
              text: currentItem.ph_en,
              src: currentItem.ph_en_mp3,
              color: Colors.blueGrey,
              autoplay: widget.prefs.getBool('autoplay')
          ),
          new Text('英音',style: new TextStyle(color: Colors.blueGrey,fontSize: 12.0))
        ],
      );
    }else {
      return new Column(
        children: <Widget>[
          new PhMp3(
              text: currentItem.ph_am,
              src: currentItem.ph_am_mp3,
              color: Colors.blueGrey,
              autoplay: widget.prefs.getBool('autoplay')
          ),
          new Text('美音',style: new TextStyle(color: Colors.blueGrey,fontSize: 12.0),)
        ],
      );
    }
  }

  Future<List> getlist() async{
    await Future.delayed(Duration(milliseconds:300));
    final int level = await getLevel();
    List stuiedWords = await client.queryAll();
    final wholeList = await new Word().getList(level);
    List lastWords;
    if(stuiedWords != null) {
      lastWords = wholeList.where((item){
        return !stuiedWords.contains(item['word']);
      }).toList();
    }else {
      lastWords = wholeList;
    }
    int count = widget.prefs.getInt('count');
    int len = count > lastWords.length ? lastWords.length : count;
    return lastWords.sublist(0,len);
  }

  _checkIsFinish(BuildContext context,int index,bool know) async{
    if(index==widget.prefs.getInt('count')){
      final snackBar = new SnackBar(
        content: new Text('已完成今日学习计划',style: new TextStyle(color: Colors.white),textAlign: TextAlign.center,),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }else if(mounted){
      if(know){
        setState(() {
          direction = TextDirection.ltr;
          next = true;
        });
        await client.insert(currentItem);
      }else{
        setState(() {
          direction = TextDirection.rtl;
          next = true;
        });
      }
      controller.forward();
    }
  }

  Widget _builder(context, snapshot){
    if(snapshot.hasData){
      list = snapshot.data;
      currentItem = new Word().getDetail(list[currentIndex]);
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.only(top: 24.0,bottom:8.0),
            child: new Text(currentItem.text,style: new TextStyle(fontSize: 28.0,color: Colors.blue),),
          ),
          new Expanded(
              child: new Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Container(
                    child: _getPhMp3(),
                  ),
                  new Container(
                    child: _getimg(),
                  ),
                  new Padding(padding: const EdgeInsets.only(top:10.0)),
                  new Means(currentItem: currentItem,prefs: widget.prefs),
                ],
                
              )
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                  child: new Container(
                    decoration: new BoxDecoration(
                      border: new Border(
                        right: const BorderSide(width: 1.0,color: Colors.grey),
                        top: const BorderSide(width: 1.0,color: Colors.grey),
                      ),
                    ),
                    child: new Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0,vertical: 10.0),
                      child: new Center(
                        child:  new GestureDetector(
                            onTap: (){
                              _checkIsFinish(context,currentIndex+1,false);
                            },
                            child: new Text('不认识',style: new TextStyle(color: Colors.red,fontSize: 18.0),)
                        ),
                      ),
                    ),
                  )
              ),
              new Expanded(
                  child: new Container(
                    decoration: new BoxDecoration(
                      border: new Border(
                        right: const BorderSide(width: 1.0,color: Colors.grey),
                        top: const BorderSide(width: 1.0,color: Colors.grey),
                      ),
                    ),
                    child: new Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0,vertical: 10.0),
                      child: new Center(
                        child: new GestureDetector(
                            onTap: (){
                              _checkIsFinish(context,currentIndex+1,false);
                            },
                            child: new Text('模糊',style: new TextStyle(color: Colors.blue,fontSize: 18.0),)
                        ),
                      ),
                    ),
                  )
              ),
              new Expanded(
                  child: new Container(
                    decoration: new BoxDecoration(
                      border: new Border(
                        top: const BorderSide(width: 1.0,color: Colors.grey),
                      ),
                    ),
                    child: new Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0,vertical: 10.0),
                      child: new Center(
                        child: new GestureDetector(
                            onTap: (){
                              _checkIsFinish(context,currentIndex+1,true);
                            },
                            child: new Text('认识',style: new TextStyle(color: Colors.green,fontSize: 18.0),)
                        ),
                      ),
                    ),
                  )
              ),
            ],
          ),
        ],
      );
    }
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: new Text('柯林斯高频词汇'),
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new SlideTransition(
                position: animation,
                textDirection: direction,
                child:  new GestureDetector(
                  child: new Container(
                    margin: const EdgeInsets.all(16.0),
                    width: 380.0,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.circular(8.0),
                      boxShadow: [new BoxShadow(color: Colors.black45,offset: Offset.zero,blurRadius: 5.0,spreadRadius: 0.1)],
                    ),
                    child: new FutureBuilder(
                        future: _future,
                        builder: _builder,
                        initialData: null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

