import 'dart:isolate';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolates Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Isolates Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String result = "Result will appear here";
  TextEditingController _controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:8.0, vertical:32.0),
                    child: Container(
                        height:50,
                        child: LinearProgressIndicator()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: txtField(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: submitButton(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(result,style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700),),
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width,100),
              painter: DrawCurves(),
            )

          ],
        ),
      ),
    );
  }
  Widget submitButton() {
    return RaisedButton(
        padding: EdgeInsets.symmetric(vertical:16.0,horizontal: 72),
        child: Text('SUBMIT',style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
        color: Colors.white,
        elevation: 4.0,
        shape: StadiumBorder(),
        textColor: Colors.red,
        onPressed: (){
//          _getPrimeWithoutIsolate(int.parse(_controller.text.toString()));
           _getPrimeWithIsolate(int.parse(_controller.text.toString()));
        }
        );
  }
  Widget txtField() {
    return TextField(
      controller: _controller,
      style: TextStyle(
        color: Colors.black,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        fillColor: Colors.red[50].withOpacity(0.5),
        contentPadding: EdgeInsets.only(left: 16,bottom: 12,top: 8),
        labelText: "Enter number",
        filled: true,
        enabled: true,
        enabledBorder: InputBorder.none,
        labelStyle: TextStyle(color: Colors.black, fontSize: 15.0),
      ),

    );

  }


  /// These functions are performed on main isolate.
  Future<int> getnthPrimeWithoutIsolate(int n) async{
    int currentPrimeCount = 0;
    int candidate = 1;
    while(currentPrimeCount < n) {
      ++candidate;
      if (isPrimeWithoutIsolate(candidate)) {
        ++currentPrimeCount;
      }
    }
    return candidate;
  }
  bool isPrimeWithoutIsolate(int n) {
    int count = 0;
    for(int i = 1 ; i <= n; ++i) {
      if (n % i == 0) {
        ++count;
      }
    }
    return count == 2;
  }
  void _getPrimeWithoutIsolate(int num) async {
    int ans = await getnthPrimeWithoutIsolate(num);
    setState((){
      result=ans.toString();
    });
  }


  /// These functions are performed on a separate isolate.
   static  bool isPrimeWithIsolate(int n) {
      int count = 0;
      for(int i = 1 ; i <= n; ++i) {
        if (n % i == 0) {
          ++count;
        }
      }
      return count == 2;
    }
  static getnthPrimeWithIsolate(SendPort mainSendPort)async{

    // This receive port is setup to receive messages from the main isolate
    ReceivePort isolateReceivePort = ReceivePort();

    // Send the mainReceivePort isolateSendPort
    mainSendPort.send(isolateReceivePort.sendPort);

    var msg = await isolateReceivePort.first;

    int n = msg;
    
    int currentPrimeCount = 0;
    int candidate = 1;
    while (currentPrimeCount < n) {
      ++candidate;
      if (isPrimeWithIsolate(candidate)) {
        ++currentPrimeCount;
      }
    }
    mainSendPort.send(candidate);
  }

  void _getPrimeWithIsolate(int num) async{

    // This receive port is setup to receive messages from the isolate
    ReceivePort mainReceivePort = ReceivePort();

    SendPort isolateSendPort;

    mainReceivePort.listen((message) {
      if(message is SendPort){
        isolateSendPort = message;
        isolateSendPort.send(num);
      }
      if(message is int){
        setState(() {
          result = message.toString();
        });
      }
    });

    await Isolate.spawn(getnthPrimeWithIsolate, mainReceivePort.sendPort);
  }

}


class DrawCurves extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    var colors = [Colors.red, Colors.white,Colors.white];
//2
    final stops = [0.0,0.8,1.0];
//3
    var gradient = LinearGradient(colors: colors, stops: stops,begin: Alignment.topCenter,end: Alignment.bottomCenter);
    var  wavePainter = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height),textDirection: TextDirection.rtl)
      ..style = PaintingStyle.fill;
    double high = size.height;
    double offset = size.width;
    Path path = Path()
      ..moveTo(0,size.height-100 )
      ..quadraticBezierTo(offset*0.2,-high*0.8 ,size.width*0.5, high-100)
      ..quadraticBezierTo(offset*0.97, high, size.width, high-100)
      ..lineTo(size.width, size.height)
      ..lineTo(0,size.height)
    ;

    canvas.drawPath(path, wavePainter);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}