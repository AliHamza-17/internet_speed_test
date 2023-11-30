import 'package:flutter/material.dart';
import 'package:speed_test_dart/classes/server.dart';
import 'package:speed_test_dart/speed_test_dart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildSpeedWidget() {
    if (!loadingUpload) {
      return _buildSpeedContainer("Download Speed");
    } else {
      return _buildSpeedContainer("Upload Speed");
    }
  }

  Widget _buildSpeedContainer(String speedType) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${_speedValue.toStringAsFixed(2)} Mb/s",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            speedType,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  SpeedTestDart tester = SpeedTestDart();
  List<Server> bestServersList = [];

  double downloadRate = 0;
  double uploadRate = 0;
  double _speedValue = 0;

  bool readyToTest = false;
  bool loadingDownload = false;
  bool loadingUpload = false;
  bool testingInProgress = false;
  Future<void> setBestServers() async {
    final settings = await tester.getSettings();
    final servers = settings.servers;

    final _bestServersList = await tester.getBestServers(
      servers: servers,
    );

    setState(() {
      bestServersList = _bestServersList;
      readyToTest = true;
    });
  }

  // Future<void> _testDownloadSpeed() async {
  //   setState(() {
  //     loadingDownload = true;
  //   });
  //   final _downloadRate =
  //       await tester.testDownloadSpeed(servers: bestServersList);
  //   setState(() {
  //     downloadRate = _downloadRate;
  //     _speedValue = downloadRate;
  //     loadingDownload = false;
  //   });
  // }
  //
  // Future<void> _testUploadSpeed() async {
  //   setState(() {
  //     loadingUpload = true;
  //   });
  //
  //   final _uploadRate = await tester.testUploadSpeed(servers: bestServersList);
  //
  //   setState(() {
  //     uploadRate = _uploadRate;
  //     _speedValue = uploadRate;
  //     loadingUpload = false;
  //   });
  // }
  bool downloadButtonEnabled = true;
  bool uploadButtonEnabled = true;

  Future<void> _testDownloadSpeed() async {
    setState(() {
      loadingDownload = true;
      downloadButtonEnabled = false; // Disable download button during the test
      testingInProgress = true;
    });

    final _downloadRate =
        await tester.testDownloadSpeed(servers: bestServersList);

    setState(() {
      downloadRate = _downloadRate;
      _speedValue = downloadRate;
      loadingDownload = false;
      downloadButtonEnabled = true; // Enable download button after the test
      testingInProgress = false;
    });
  }

  Future<void> _testUploadSpeed() async {
    setState(() {
      loadingUpload = true;
      uploadButtonEnabled = false; // Disable upload button during the test
      testingInProgress = true;
    });

    final _uploadRate = await tester.testUploadSpeed(servers: bestServersList);

    setState(() {
      uploadRate = _uploadRate;
      _speedValue = uploadRate;
      loadingUpload = false;
      uploadButtonEnabled = true; // Enable upload button after the test
      testingInProgress = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setBestServers();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.redAccent),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          centerTitle: true,
          title: const Text('Internet Speed Tester'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                ),
                SfRadialGauge(
                    enableLoadingAnimation: true,
                    animationDuration: 4500,
                    axes: <RadialAxis>[
                      RadialAxis(minimum: 0, maximum: 60, ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0, endValue: 20, color: Colors.green),
                        GaugeRange(
                            startValue: 20, endValue: 40, color: Colors.orange),
                        GaugeRange(
                            startValue: 40, endValue: 60, color: Colors.red)
                      ], pointers: <GaugePointer>[
                        NeedlePointer(value: _speedValue)
                      ], annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: (loadingUpload || loadingDownload)
                                ? Text('')
                                : _buildSpeedWidget(),
                            angle: 90,
                            positionFactor: 0.6)
                      ])
                    ]),
                // const Text(
                //   'Test Upload speed:',
                //   style: TextStyle(
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
                // if (loadingUpload)
                //   const Column(
                //     children: [
                //       CircularProgressIndicator(),
                //       SizedBox(height: 10),
                //       Text('Testing upload speed...'),
                //     ],
                //   )
                // else
                //   Text('Upload rate ${uploadRate.toStringAsFixed(2)} Mb/s'),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    loadingUpload
                        ? CircularProgressIndicator(
                            color: Colors.redAccent,
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              primary: Colors.black,
                              onPrimary: Colors.redAccent,
                            ),
                            onPressed: testingInProgress ||
                                    !readyToTest ||
                                    bestServersList.isEmpty ||
                                    !uploadButtonEnabled
                                ? null
                                : () async {
                                    await _testUploadSpeed();
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Check Upload'),
                              ],
                            ),
                          ),
                    SizedBox(
                      width: 10,
                    ),
                    loadingDownload
                        ? CircularProgressIndicator(
                            color: Colors.redAccent,
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              primary: Colors.brown,
                              onPrimary: Colors.white,
                            ),
                            onPressed: testingInProgress ||
                                    !readyToTest ||
                                    bestServersList.isEmpty ||
                                    !downloadButtonEnabled
                                ? null
                                : () async {
                                    setState(() {});
                                    await _testDownloadSpeed();
                                  },
                            child: const Text('Check Download'),
                          ),
                  ],
                ),
                // const SizedBox(
                //   height: 50,
                // ),
                // const Text(
                //   'Test Download Speed:',
                //   style: TextStyle(
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 10),
                // if (loadingDownload)
                //   const Column(
                //     children: [
                //       CircularProgressIndicator(),
                //       SizedBox(
                //         height: 10,
                //       ),
                //       Text('Testing download speed...'),
                //     ],
                //   )
                // else
                //   Text(
                //       'Download rate  ${downloadRate.toStringAsFixed(2)} Mb/s'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
