import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class APIService {
  // GCPのAPIキー情報を_api_keyに入力する
  static const _api_key = "";

  static const String _base_url =
      "https://language.googleapis.com/v1/documents:analyzeSentiment";
  static Map<String, String> _header = {
    "content-type": "application/json",
  };

  Future<SentAna> post({@required Map<String, Map> query}) async {
    final response = await http.post(
      _base_url + "?key=" + _api_key,
      headers: _header,
      body: json.encode(query),
    );

    if (response.statusCode == 200) {
      return SentAna.fromJson(json.decode(response.body));
    } else {
      throw Exception('jsonデータの読み込みに失敗しました');
    }
  }
}

class SentAna {
  final String emotions;

  SentAna({this.emotions});

  factory SentAna.fromJson(Map<String, dynamic> json) {
    return SentAna(emotions: json['documentSentiment']['score'].toString());
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  final myController = TextEditingController();

  APIService apiService = APIService();
  Future<SentAna> analysis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.004, 1],
            colors: [
              Colors.blue,
              Colors.grey[200],
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height / 4.5,
              ),
              Text(
                '感情分析チェッカー',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              SizedBox(height: 30),
              Container(
                height: 150,
                child: Image.asset(
                  'assets/original.png',
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: _loading
                            ? Container(
                                width: 300,
                                child: Column(
                                  children: <Widget>[
                                    TextField(
                                      controller: myController,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                        labelText: "検索ワードを入力してください： ",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _loading = false;
                                analysis = apiService.post(
                                  query: {
                                    "document": {
                                      "type": "PLAIN_TEXT",
                                      "content": myController.text,
                                    }
                                  },
                                );
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width - 180,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 17,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF56ab2f),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '感情分析開始',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FutureBuilder<SentAna>(
                            future: analysis,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  '入力された文章の感情は' + '${snapshot.data.emotions}です',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 19,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Text('${snapshot.error}');
                              }
                              return CircularProgressIndicator();
                            },
                          )
                        ],
                      ),
                    )
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
