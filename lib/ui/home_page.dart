import 'dart:convert';
import 'dart:async';
import 'package:buscador_gif/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offSet = 0;

  Future<Map> _getGif() async {
    http.Response response;
    if (_search == null)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=WeEAOl7Bzy0S90jafKRenL33DptpFdTM&limit=20&rating=G");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=WeEAOl7Bzy0S90jafKRenL33DptpFdTM&q=$_search&limit=19&offset=$_offSet&rating=G&lang=en");

    return json.decode(response.body);
  }

  int _getCount(List data) {
    if (_search == null)
      return data.length;
    else {
      return data.length + 1;
    }
    ;
  }

  @override
  void initState() {
    super.initState();
    _getGif().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Seu Gif!", border: OutlineInputBorder()),
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offSet = 0;
                });
              },
              style: TextStyle(fontSize: 18.0, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGif(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 150,
                      height: 150,
                      alignment: Alignment.topCenter,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3.5,
                      ),
                    );
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data["data"].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              placeholder: kTransparentImage,
              height: 250.0,
              fit: BoxFit.cover,
            ),
            // child: Image.network(
            //   snapshot.data["data"][index]["images"]["fixed_height"]["url"],
            //   height: 300.0,
            //   fit: BoxFit.cover,
            // ),
            onLongPress: (){
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data["data"][index])));
            },
          );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 65.0,
                  ),
                  Text(
                    "Carregar Mais...",
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offSet += 19;
                });
              },
            ),
          );
      },
    );
  }
}
