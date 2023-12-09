import 'package:ai_musicplayer/utils/ai_util.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:velocity_x/velocity_x.dart';

import '../model/radio.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late  List<MyRadio> radios;
  late MyRadio _selectedRadio;
  late Color _selectedColor;
  bool _isPlaying = false;
  final sugg = [
    "Play",
    "Stop",
    "Play rock music",
    "Play 107 FM",
    "Play next",
    "Play 104 FM",
    "Pause",
    "Play previous",
    "Play pop music"
  ];

  //final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    radios = [];
    setupAlan();
    fetchRadios();
   // fetchLocalSong();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState event) {
      if (event == PlayerState.playing) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {
        _isPlaying = event == PlayerState.playing;
      });
    });
  }

  setupAlan(){
    AlanVoice.addButton(
        "588b182dff0527a9e8b9c40a3c349f502e956eca572e1d8b807a3e2338fdd0dc/stage");
    // Customize the visual state of the Alan button

    AlanVoice.callbacks.add((command) => handleCommand(command.data));
  }

  handleCommand(Map<String,dynamic> response){
    switch(response["command"]){
      case "play":
        _playMusic(_selectedRadio.url);
        break;

      case "play_channel":
        final id = response["id"];
        // _audioPlayer.pause();
        MyRadio newRadio = radios.firstWhere((element) => element.id == id);
        radios.remove(newRadio);
        radios.insert(0, newRadio);
        _playMusic(newRadio.url);
        break;

      // case "play_local":
      //   final songId = response["songId"];
      //   SongModel localSong = songs.firstWhere((element) => element.id == songId);
      //   _playMusic(localSong.data);
      //   break;


      case "stop":
        _audioPlayer.stop();
        break;

      case "next":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index + 1 > radios.length) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index + 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;

      case "previous":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index - 1 <= 0) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index - 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;

      default:
        print("Command was ${response["command"]}");
        break;
    }
  }

  _playMusic(String url)  {
      _audioPlayer.play(UrlSource(url));
       _selectedRadio = radios.firstWhere((element) => element.url == url);
       _selectedRadio = radios[0];
       // _selectedColor = Color(int.tryParse(_selectedRadio.color));
      // _selectedRadio = radios.isNotEmpty? radios[0] : MyRadio(
      //     id: 1,
      //     order: 1,
      //     name: "92.7",
      //     tagline: "Suno Sunao, Life Banao!",
      //     color: "0xffa11431",
      //     desc: "bdjvbdfibvidnv",
      //     url: "https://thegrowingdeveloper.org/files/audios/quiet-time.mp3?b4869097e4",
      //     category: "pop",
      //
      //     icon: "https://mytuner.global.ssl.fastly.net/media/tvos_radios/m8afyszryaqt.png",
      //     image: "https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/b5df4c18876369.562d0d4bd94cf.jpg",
      //     lang: "Hindi");
      print(_selectedRadio.name);
      setState(() {});

  }

  // fetchLocalSong() async{
  //   songs = await _audioQuery.querySongs();
  // }
  //
  // List<SongModel> songs = [];


  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    final myRadioList = MyRadioList.fromJson(radioJson);
    radios = myRadioList.radios ?? [];

    if (radios.isNotEmpty) {
      _selectedRadio = radios[0];
      _selectedColor = Color(int.tryParse(_selectedRadio.color ?? "0xFF000000") ?? 0xFF000000);
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: Container(
              color: _selectedColor ?? AiColors.primaryColor2 ?? Colors.blue,
              child: radios != null
              ? [
              100.heightBox,
              "All Channels".text.xl.white.semiBold.make().px16(),
              20.heightBox,
              ListView(
                padding: Vx.m0,
                shrinkWrap: true,
                children: radios
                    .map((e) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(e.icon),
                  ),
                  title: "${e.name} FM".text.white.make(),
                  subtitle: e.tagline.text.white.make(),
                ))
                    .toList(),
              ).expand()
              ].vStack(crossAlignment: CrossAxisAlignment.start)
              : const Offstage(),
    ),
    ),

      body: Stack(
        fit: StackFit.expand,
    clipBehavior: Clip.antiAlias,
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
            LinearGradient(
              colors: [
              AiColors.primaryColor2 ?? Colors.blue,
    _selectedColor ?? AiColors.primaryColor1 ?? Colors.grey,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          )
              .make(),

    [
      AppBar(
        title: "AI Assistant".text.xl4.bold.white.make().shimmer(
        primaryColor: Vx.white, secondaryColor: Colors.black38),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        ).h(100.0).p16(),
        "Start with - Hey Alan 👇".text.italic.semiBold.white.make(),
        10.heightBox,
          VxSwiper.builder(
            itemCount: sugg.length,
            height: 50.0,
            viewportFraction: 0.35,
            autoPlay: true,
            autoPlayAnimationDuration: 3.seconds,
            autoPlayCurve: Curves.linear,
            enableInfiniteScroll: true,
            itemBuilder: (context, index) {
              final s = sugg[index];
                 return Chip(
                    label: s.text.make(),
                    backgroundColor: Vx.randomColor,
                    );
                 },
    )
    ].vStack(alignment: MainAxisAlignment.start),
    30.heightBox,
              radios != null
              ? VxSwiper.builder(
            itemCount: radios.length,
            aspectRatio: 1.0,
            enlargeCenterPage: true,
            onPageChanged: (index) {
              _selectedRadio = radios[index];
              final colorHex = radios[index].color;
              _selectedColor = Color(int.parse(colorHex));
              setState(() {});
            },
            itemBuilder: (context, index) {
              final  rad = radios[index];

              return VxBox(
                  child: ZStack([
                    Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: VxBox(
                        child:
                        rad.category.text.uppercase.white.make().px16(),
                      )
                          .height(40)
                          .black
                          .alignCenter
                          .withRounded(value: 10.0)
                          .make(),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: VStack(
                        [
                          rad.name.text.xl3.white.semiBold.make(),
                          5.heightBox,
                          rad.tagline.text.sm.white.semiBold.make(),
                        ],
                        crossAlignment: CrossAxisAlignment.center,
                      ),
                    ),
    Positioned(
        bottom: 130,
        left: 30,
        right: 30,
        child: Container(
        width: context.screenWidth, // Ensure the container takes the full width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Icon(
          CupertinoIcons.play_circle,
          color: Colors.white,
    size: 30.0,
          ),
          10.heightBox,
          "Double tap to play".text.gray300.make(),
      ],
    ),
    ),
    ),

    ],))
                  .clip(Clip.antiAlias)
                  .bgImage(
                DecorationImage(
                    image: NetworkImage(rad.image),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.darken)),
                    )
                  .border(color: Colors.black, width: 5.0)
                  .withRounded(value: 60.0)
                  .make()
                  .onInkDoubleTap(() {
                _playMusic(rad.url);
              }).p16();
            },
          ).centered()
              : const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child:
              Icon(
                _isPlaying
                    ? CupertinoIcons.stop_circle
                    : CupertinoIcons.play_circle,
                color: Colors.white,
                size: 50.0,
              ).onInkTap(() {
                if (_isPlaying) {
                  _audioPlayer.stop();
                } else {
                  _playMusic(_selectedRadio.url);
                }
              })
          ).pOnly(bottom: context.percentHeight * 12)


    ],
      ),
    );
  }
}
