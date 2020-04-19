import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:random_color/random_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:spotify_api/spotify_api.dart';

class Links extends StatefulWidget {


  final SpotifyAlbum album;

  Links({Key key, @required this.album}) : super(key: key);

  @override
  _LinksState createState() => _LinksState();
}

RandomColor _randomColor = RandomColor();
Color _color = _randomColor.randomColor();



class _LinksState extends State<Links> {

  Duration _duration = Duration();
  Duration _position = Duration();
  AudioPlayer advancedPlayer;
  AudioCache audioCache;

  @override
  void initState() {
    super.initState();
    _color = _randomColor.randomColor(colorBrightness: ColorBrightness.light);

    initPlayer();
  }


  void initPlayer(){
    advancedPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.durationHandler = (d) => setState((){
      _duration = d;
    });

    advancedPlayer.positionHandler = (p) => setState((){
      _position = p;
    });
  }

  String localFilePath;

  Widget _tab (List<Widget>children){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(1),
          child: Column(
              children: children
                  .map((w) => Container(child: w,padding: EdgeInsets.all(1))).toList()
          ),
        ),
      ],
    );
  }

  Widget _btn (String txt, VoidCallback onPressed){
    return ButtonTheme(
      minWidth: 50.0,
      child: Container(
        width: 100,
        height: 10,
        child: FlatButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            child: Text(txt),
            color: Colors.pink[900],
            textColor: Colors.white,
            onPressed: onPressed),
      ),
    );
  }

  Widget slider(){
    return Slider(
      activeColor: Colors.white,
      inactiveColor: Colors.black,
      value: _position.inSeconds.toDouble(),
      min: 0.0,
      max: _duration.inSeconds.toDouble(),
      onChanged: (double value){
        setState(() {
          seekToSecond(value.toInt());
          value = value;
        });
      },
    );
  }

  int _widgetIndex = 0;
  String _playerSongName = '--';
  String _url;

  Widget localAudio(){
    return _tab([
      Center(
        child: Column(
          children: <Widget>[
            IndexedStack(
              index: _widgetIndex,
              children: <Widget>[
                FlatButton(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: (){
                    advancedPlayer.play(_url);
                    setState(
                            () => _widgetIndex = 1);
                  },
                ),
                FlatButton(
                  child: Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: (){
                    advancedPlayer.pause();
                    setState(
                            () => _widgetIndex = 0);
                  },
                ),
              ],
            ),
            slider(),
            SizedBox(height: 10,),
            Text(_playerSongName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),),
          ],
        ),
      ),

    ]);
  }

  void seekToSecond(int second){
    Duration newDuration = Duration(seconds: second);
    advancedPlayer.seek(newDuration);
  }

  final player = AudioCache();

  void _launchUrl(String Url) async {
    if (await canLaunch(Url)) {
      await launch(Url);
    }
    else {
      throw 'could not open';
    }
  }

  Future<bool> _onBackPressed(){
    advancedPlayer.stop();
    setState(
            () => _widgetIndex = 0);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: DefaultTabController(
        length: 1,
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          body: TabBarView(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        color: _color,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.network(widget.album.imageUrl),
                            ),
                            Text(widget.album.title,
                              style: TextStyle(
                                fontSize: 30,
                                letterSpacing: 1.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),),

                            SizedBox(height: 5,),
                            Text(widget.album.artists,
                              style: TextStyle(
                                fontSize: 15,
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),),
                            SizedBox(height: 20,),
                          ],
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        _launchUrl('https://open.spotify.com/album/${widget.album.id}');
                      },
                      color: Colors.green,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20,0,20,0),
                        child: Text('Open In Spotify',
                          style: TextStyle(color: Colors.white),),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18),
                        side: BorderSide(color: Colors.green[600]),
                      ),
                    ),
                    localAudio(),
                    SizedBox(height: 30,),
                    Container(

                      width: 400,
                      height: 350,

                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[850],
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),

                      child: ListView.builder(
                        itemCount: widget.album.tracks.length,
                        itemBuilder: (context, index){
                          SpotifyTrack track = widget.album.tracks[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: .0),
                            child: Card(
                              color: Colors.grey[850],
                              child: ListTile(
                                onTap: () {
                                  advancedPlayer.stop();
                                  setState(() => _playerSongName = track.title); //set this to title.index
                                  if(track.previewUrl != null)
                                    advancedPlayer.play(track.previewUrl); // <-- URL HERE
                                  setState(() => _widgetIndex = 1);
                                },
                                title: Text(track.title,
                                style: TextStyle(color: Colors.white,
                                ),),
                                leading: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.network(widget.album.imageUrl), //<-- Please give each track an index number so I can place it here
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 30,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}