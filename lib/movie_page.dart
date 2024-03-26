import 'package:flutter/material.dart';
import 'package:theolive/theolive.dart';
import 'fullscreen_page.dart';


class MoviePage extends StatefulWidget {
  const MoviePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> with THEOliveEventListener {

  late THEOlive _theoLive;

  void _callLoadChannel() {
    _theoLive.loadChannel("2vqqekesftg9zuvxu9tdme6kl");

  }

  bool playing = false;
  bool loaded = false;
  bool inFullscreen = false;


  @override
  void initState() {
    print("_MoviePageState with THEOliveView: initState ");
    super.initState();
    _theoLive = THEOlive(
        playerConfig: PlayerConfig(
          AndroidConfig(
            useHybridComposition: true,
            nativeRenderingTarget: AndroidNativeRenderingTarget.surfaceView,
          ),
        ),
        onCreate: () {
          // assign the controller to interact with the player
          _theoLive.addEventListener(this);
          //_theoController.preloadChannels(["2vqqekesftg9zuvxu9tdme6kl"]);

          // automatically load the channel once the view is ready
          _callLoadChannel();
    }
    );

  }

  @override
  void dispose() {
    print("_MoviePageState with THEOliveView: dispose ");

    // NOTE: this would be nicer, if we move it inside the THEOliveView that's a StatefulWidget
    // FIX for https://github.com/flutter/flutter/issues/97499
    //_theoController.manualDispose();
    _theoLive.removeEventListener(this);
    _theoLive.dispose();
    super.dispose();
  }

  void _playPause() {
    bool newState = false;
    if (playing) {
      _theoLive.pause();
      newState = false;
    } else {
      _theoLive.play();
      newState = true;
    }
    setState(() {
      playing = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          //check orientation variable to identify the current mode
          double w = 300;
          double h = 300;
          bool landscape = false;

          if(orientation == Orientation.landscape){
            print("The screen is on Landscape mode.");
            w = MediaQuery.of(context).size.width;
            h = MediaQuery.of(context).size.height * 0.5;
            landscape = true;
          }

          return Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              //
              // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
              // action in the IDE, or press "p" in the console), to see the
              // wireframe for each widget.
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'THEOlive',
                ),
                Stack(
                    alignment: Alignment.center,
                    children: [
                      !inFullscreen ? Container(width: w, height: h, color: Colors.black, child: ChromelessPlayer(player: _theoLive, key: ChromelessPlayer.playerUniqueKey,)) : Container(),
                      !loaded ? Container(width: w, height: h, color: Colors.black, child: const Center(child: SizedBox(width: 50, height: 50, child: RefreshProgressIndicator()))) : Container(),
                    ]
                ),
                !landscape ? FilledButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Text("Go back")) : Container(),
                !landscape ? FilledButton(onPressed: () {
                  setState(() {
                    inFullscreen = true;
                  });

                  //Navigator.push(context, MaterialPageRoute(builder: (context) =>  FullscreenPage(playerViewKey: playerUniqueKey,)));
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return FullscreenPage(theoLive: _theoLive,);
                    //return FullscreenPage(playerViewKey: playerUniqueKey);
                  }, settings: null)).then((value){
                    print("_MoviePageState with THEOliveView: return from fullscreen ");
                    setState(() {
                      inFullscreen = false;
                    });
                  });

                }, child: Text("Open Fullscreen")) : Container(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _playPause,
        tooltip: 'Load',
        child: playing ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  // THEOliveEventListener interface methods
  @override
  void onChannelLoaded(String channelID) {
    // TODO: implement onChannelLoaded
  }

  @override
  void onPlaying() {
    setState(() {
      loaded = true;
    });
  }

  @override
  void onChannelLoadStart(String channelID) {
    // TODO: implement onChannelLoadStart
  }

  @override
  void onChannelOffline(String channelID) {
    // TODO: implement onChannelOffline
  }

  @override
  void onError(String message) {
    // TODO: implement onError
  }

  @override
  void onIntentToFallback() {
    // TODO: implement onIntentToFallback
  }

  @override
  void onPause() {
    // TODO: implement onPause
  }

  @override
  void onPlay() {
    // TODO: implement onPlay
  }

  @override
  void onReset() {
    // TODO: implement onReset
  }

  @override
  void onWaiting() {
    // TODO: implement onWaiting
  }
}

class ChromelessPlayer extends StatelessWidget {
  static GlobalKey playerUniqueKey = GlobalKey(debugLabel: "playerUniqueKey");

  const ChromelessPlayer({
    super.key,
    required this.player,
  });

  final THEOlive player;

  @override
  Widget build(BuildContext context) {
    return player.getView();
  }
}

