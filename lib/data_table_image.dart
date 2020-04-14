      import 'package:flutter/material.dart';
      import 'dart:async';
      import 'dart:convert';
      import 'package:flutter/cupertino.dart';
      import 'package:flutter/services.dart';
      import 'package:http/http.dart' as http;
      import 'package:cached_network_image/cached_network_image.dart';

      class DataImageTableDemo extends StatefulWidget {
        DataImageTableDemo() : super();
        final String title = "Carsome Flutter Demo";

        @override
        DataTableDemoState createState() => DataTableDemoState();
      }

      class DataTableDemoState extends State<DataImageTableDemo> {
        List<bool> _selections = [true, false];
        List data;
        final String url = "https://jsonplaceholder.typicode.com/photos?albumId=1";
        final String url2 = "https://jsonplaceholder.typicode.com/photos?albumId=2";

        bool selectedBtn1;
        @override
        void initState() {
          selectedBtn1 = false;
          this.getJsonData(selectedBtn1 == true ? url : url2);
          super.initState();
        }

        Future<String> getJsonData(String urlString) async {
          var response = await http
              .get(Uri.encodeFull(urlString), 
              headers: {"Accept": "application/json"});
          print(response.body);
          setState(() {
            var covertDataToJson = json.decode(response.body);
            data = covertDataToJson;
          });
        
          return "Success";
        }

          presentSelectedImage(String imageUrl, String imageName, Orientation orientation) {
            setState(() {
              Navigator.push(context, CupertinoPageRoute(
              builder: (BuildContext context) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(title: Text("$imageName")),
                  body: Center (
                  child:
                    CachedNetworkImage(
                      alignment: orientation == Orientation.portrait ? Alignment.topCenter : Alignment.center,
                      imageUrl: imageUrl,
                      placeholder: (context, url) => LinearProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                  ),
                );
              },
            ));
            });
          }
      

          onSelectedBtn(bool selectedBtn1) async {
            setState(() {
              if (selectedBtn1) {
                getJsonData(url);
              } else {
                getJsonData(url2);
              }
            });
          }

          CustomScrollView dataBody(Orientation orientation) {
          return CustomScrollView(
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: orientation == Orientation.portrait ? 2 : 5,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: orientation == Orientation.portrait ? 1.2 : 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  
                  return Stack
                  (    
                    children: <Widget>[
                      Positioned(
                        left: orientation == Orientation.portrait && index % 2 == 0 ? null : 10,
                        right: orientation == Orientation.portrait && index % 2 != 0 ? null : 10,
                        child: CachedNetworkImage(
                          imageUrl: data[index]['thumbnailUrl'],
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        left: orientation == Orientation.portrait && index % 2 == 0 ? 20 : 5, 
                        width: 200,
                        bottom: 0,
                        child: 
                          Text(
                            (data[index]['title']),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      InkWell (
                        splashColor: Colors.blue,
                          onTap: () {
                            presentSelectedImage(data[index]['url'], data[index]['title'], orientation);
                          },
                        ),
                      ]
                    );
                  },
                childCount: data == null ? 0 : data.length,
              ),
            ),
          ],
          );
        }
        
        @override
        Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: OrientationBuilder(
              builder: (context, orientation) {
                return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  buttonHeight: 30,
                  buttonMinWidth: 30,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(00.0),
                      child: ToggleButtons(
                        selectedColor: Colors.red,
                        selectedBorderColor: Colors.blue,
                        isSelected: [selectedBtn1, !selectedBtn1],
                        children: <Widget>[
                          RaisedButton(
                              child: 
                              Text('1',
                                style: TextStyle(fontSize: 20)
                              ),
                              onPressed: () {
                                onSelectedBtn(true);
                                selectedBtn1 = true;
                            }),
                            RaisedButton(
                              child: 
                              Text('2',
                                style: TextStyle(fontSize: 20)
                              ),
                            onPressed: () {
                              onSelectedBtn(false);
                              selectedBtn1 = false;
                          }),
                        ],
                        onPressed: (int index) {
                        setState(() {
                            _selections[index] = !_selections[index];
                        });
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                  child: dataBody(orientation),
                )),
              ],
            );
            })
          );
        }
      }
