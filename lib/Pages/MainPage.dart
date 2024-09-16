import 'dart:async';
import 'package:arabot/AppService/Permisions.dart';
import 'package:arabot/ServerService/Server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Camera/Camera.dart';
import 'package:file_picker/file_picker.dart';
import '../MicService/Mic.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _mainPage createState() => _mainPage();
}

class _mainPage extends State<MainPage> {

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _botController = TextEditingController();
  final TextEditingController _loadingController = TextEditingController();
  final TextEditingController _speechResultController = TextEditingController();
  final _initalPage = 1;
  late MicService speechRecognizer;
  late Permisions appPermission;
  bool isPermissionGranted = false;
  bool _isLoading = false;
  bool _isTab = false;
  bool _isChecked = false;
  bool _isConnected = false;
  bool _hasCheckedLandscape = false;
  bool _isRecording = false;
  CameraServices cs = CameraServices();
  String? _filePath;
  PlatformFile? pickedFile;
  Servers? myServer;
  var screenWidth;

  @override
  void initState() {
    super.initState();
    initializeRecognition();
    initializeSpeechRecognition();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkIfTap()
  {
    screenWidth = MediaQuery.of(context).size.width;
    if(screenWidth >= 800)
    {
      setState(() {
        _isTab = true;
      });
    }else{
      _isTab = false;
    }
    _isChecked = true;
  }

  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        _isConnected = true;
      });
    } else {
      setState(() {
        _isConnected = false;
      });
    }
  }
  Future<void> initializeRecognition() async {
    speechRecognizer = MicService(
      onTextRecognized: (text) {
        setState(() {
          _speechResultController.text = text;
        });
      },
      onDone: () {
        setState(() {
          _isRecording = false; // Update recording status when done
        });
      },
    );
  }

  Future<void> initializeSpeechRecognition() async {
    isPermissionGranted = await speechRecognizer.getMicrophonePermission();
    handlePermissionResponse(false);
  }

  void handlePermissionResponse(bool isPressed) {
    if (isPressed) {
      if (isPermissionGranted) {
        speechRecognizer.startSpeechRecognition(context);
        setState(() {
          _isRecording = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('مطلوب إذن المايكروفون')),
        );
      }
    } else {
      setState(() {
        _isRecording = false;
      });
      speechRecognizer.stopSpeechRecognition();
    }
  }

  Future<void> _openCamera(BuildContext context) async {
    appPermission = Permisions(name: "Camera", context: context);
    setState(() {
      _loadingController.text = "جاري التحميل ...";
      _isLoading = true; // Set loading state to true
    });
    if (await appPermission.checkPermissions()) {
      final image = await cs.pickImage(context);
      String text = cs.getText();
      setState(() {
        _botController.text = text;
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مطلوب إذن الكاميرا')),
      );
    }
  }

  void sendText(String text) {
    if(text.isEmpty || text == "اكتب رسالة")
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('لا يوجد نص حاول مرة اخرى')),
        );
      }else
        {
          setState(() {
            _loadingController.text = "جاري التحميل ...";
            _isLoading = true; // Set loading state to true
          });
          myServer = Servers();
          myServer!.sendToTextServer(text, context).then((response) {
            setState(() {
              _botController.text = response;
              _isLoading = false; // Set loading state to false
            });
          }).catchError((error) {
            setState(() {
              _isLoading = false; // Ensure loading state is false even if there's an error
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error')),
            );
          });
        }
  }

  @override
  Widget build(BuildContext context) {
    if(!_isChecked)
      {
        _checkIfTap();
      }
    checkInternetConnection();
  return  OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && !_hasCheckedLandscape) {
          _hasCheckedLandscape = true;
          _isChecked = false;
        } else if (orientation == Orientation.portrait && _hasCheckedLandscape) {
          _isChecked = false;
          _hasCheckedLandscape = false;
        }
          return LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 52, 49, 49),
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color.fromARGB(255, 53, 23, 23),
                        Color.fromARGB(255, 160, 71, 71)
                      ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
                ),
                elevation: 10,
                title: Center(
                  child: !_isConnected? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                       const SizedBox(width: 100),
                        Text(
                            " تَــشــكِــيــل ",
                            style: GoogleFonts.reemKufi(
                              color: Colors.white,
                              fontSize:_isTab? width * 0.05 : width * 0.07,
                            )),
                        SizedBox(width: 65),
                        Icon(Icons.wifi_off_rounded , color: const Color.fromARGB(255, 187, 130, 130), size: _isTab? width * 0.05 : width * 0.07,),
                      ]):

                  Text(
                    " تَــشــكِــيــل ",
                    style: GoogleFonts.reemKufi(
                      color: Colors.white,
                      fontSize: _isTab? width * 0.05 : width * 0.07,
                    ),
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                          TextFormField(
                            enabled: _isConnected,
                            style: GoogleFonts.mada(
                              color: Colors.black,
                              fontSize:_isTab? width * 0.05 : width * 0.05,
                            ),
                            controller: _isRecording
                                ? _speechResultController
                                : _messageController,
                            textDirection: TextDirection.rtl,
                            decoration: InputDecoration(
                              hintStyle: GoogleFonts.mada(
                                color: Colors.black,
                                fontSize: width * 0.05,
                              ),
                              hintText: !_isConnected?'غير متصل بالإنترنت' :
                              'اكتب رسالة',
                              border: InputBorder.none,
                              hintTextDirection: TextDirection.rtl,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\u0600-\u06FF\s]'),
                              ),
                            ],
                            textAlignVertical: TextAlignVertical.top,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            expands:
                            true, // This makes the TextFormField expand vertically
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                        color: Color.fromARGB(255, 160, 71, 71),
                        height: 2,
                        thickness: 5),
                    const SizedBox(height: 10),
                    Container(
                      width: width,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color.fromARGB(255, 53, 23, 23),
                            Color.fromARGB(255, 160, 71, 71)
                          ], begin: Alignment.topRight, end: Alignment.bottomLeft),
                          borderRadius: BorderRadius.circular(20)),
                      child: SizedBox(
                        height: 80,
                        child: PageView(
                          controller: PageController(viewportFraction: 0.3 , initialPage: _initalPage),
                          scrollDirection: Axis.horizontal,
                          children: [
                            (_isLoading | !_isConnected)? Icon(Icons.mic_off , color: Colors.white , size:_isTab? width * 0.04 : width * 0.08,):
                            IconButton(
                              icon: Icon(
                                _isRecording
                                    ? Icons.check_circle_rounded
                                    : Icons.mic,
                                color:
                                _isRecording ? Colors.lightGreen : Colors.white,
                                size: _isTab? width * 0.06 : width * 0.08,
                              ),
                              onPressed: () {
                                if (_isRecording == true) {
                                  setState(() {
                                    _messageController.text = "";
                                    _isRecording = false;
                                  });
                                  sendText(_speechResultController.text);
                                  _speechResultController.text = "";
                                } else {
                                  handlePermissionResponse(!_isRecording);
                                }
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFFF8C00),
                                      const Color(0xFFFFD700).withOpacity(0.8)
                                    ],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 4,
                                    blurRadius: 10,
                                    offset: const Offset(4, 4), // Bottom right shadow
                                  ),
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 10, 10, 10)
                                        .withOpacity(0.7),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: const Offset(4, 4), // Top left shadow
                                  ),
                                ],
                              ),
                              child:
                              !_isConnected | _isLoading? Center (child: Icon(
                                Icons.not_interested_rounded
                                ,size: _isTab? width * 0.06 : width * 0.1,
                              )): _isRecording ? Center (child: IconButton(icon:Icon(Icons.cancel,size: _isTab? width * 0.06 : width * 0.1, color: Colors.white),
                                onPressed: (){_messageController.text = ""; _isRecording = false;speechRecognizer.stopSpeechRecognition();
                                },
                              )):
                              TextButton(
                                onPressed: () {
                                  sendText(_messageController.text);
                                },
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Colors.orangeAccent, Colors.yellowAccent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    "شَكِِل",
                                    style: GoogleFonts.reemKufi(
                                      fontSize: _isTab? width * 0.04 : width * 0.065, // Make the font larger
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black, // Text color (before shader is applied)
                                      shadows: [
                                        Shadow(
                                          offset: Offset(3, 3),
                                          blurRadius: 10,
                                          color: Colors.black.withOpacity(0.5), // Shadow effect
                                        ),
                                        Shadow(
                                          offset: Offset(-3, -3),
                                          blurRadius: 10,
                                          color: Colors.orange.withOpacity(0.3), // Soft highlight
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            !_isConnected ? Icon(Icons.no_accounts_rounded,color: Colors.white, size: _isTab? width * 0.06 : width * 0.08):
                            _isRecording | _isLoading ? Icon(Icons.no_photography_rounded,color: Colors.white, size: _isTab? width * 0.06 : width * 0.08):
                            IconButton(
                              onPressed: () {
                                _openCamera(context);
                              },
                              icon: Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: _isTab? width * 0.06 : width * 0.08),
                              tooltip: 'Capture',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                        color: Color.fromARGB(255, 160, 71, 71),
                        height: 2,
                        thickness: 5),
                    const SizedBox(height: 10),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            const Color(0xFFFFD700).withOpacity(0.8),
                            const Color(0xFFFF8C00)
                          ], begin: Alignment.topRight, end: Alignment.bottomLeft),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child:GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: _botController.text)).then((_) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('تم لسق النص'),
                                          ),
                                        );
                                      });
                                    },
                                    child:TextFormField(
                                      enabled: false,
                                      style: GoogleFonts.mada(
                                        color: Colors.black,
                                        fontSize: _isTab? width * 0.06 : width * 0.05,
                                      ),
                                      controller:_isLoading? _loadingController : _botController,
                                      textDirection: TextDirection.rtl,
                                      decoration: InputDecoration(
                                        hintStyle: GoogleFonts.mada(
                                          color: Colors.black,
                                          fontSize: _isTab? width * 0.05 : width * 0.05,
                                        ),
                                        hintText: _isLoading
                                            ? 'جاري التحميل...'
                                            : 'التشكيل',
                                        border: InputBorder.none,
                                        hintTextDirection: TextDirection.rtl,
                                      ),
                                      textAlignVertical: TextAlignVertical.top,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null, // Allows for multiple lines
                                    ),),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
      },
    );
  }
}
