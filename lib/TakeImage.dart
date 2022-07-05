import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'zhujiangtao'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final imagePicker = ImagePicker();
  File? _imgPath;

  Future getImage(bool takePhoto) async {
    try {
      var pickFile = await imagePicker.pickImage(
          source: takePhoto ? ImageSource.camera : ImageSource.gallery);
      if (pickFile != null) {
        setState(() {
          _imgPath = File(pickFile.path);
          if (_imgPath != null && takePhoto) {
            saveTakePhoto2Album(pickFile);
          }
        });
      } else {
        debugPrint('没有选择任何照片');
      }
    } catch (e) {
      debugPrint('该手机不支持相机');
    }
  }

  void saveTakePhoto2Album(XFile? xFile) async {
    var bytes = await xFile?.readAsBytes();
    if (bytes != null) {
      final result = await ImageGallerySaver.saveImage(bytes);
      debugPrint('save path = $result');
    } else {
      debugPrint('saveTakePhoto2Album error : bytes == null');
    }
  }

  /// 申请存储权限
  Future<bool> requestStoragePermission() async {
    PermissionStatus? status;
    if (Platform.isIOS) {
      status = await Permission.photosAddOnly.request();
    } else if (Platform.isAndroid) {
      status = await Permission.storage.request();
    }

    debugPrint("---- status = $status");

    if (status == PermissionStatus.granted) {
      return true;
    } else if (status == PermissionStatus.permanentlyDenied) {
      // 用户拒绝且不再提醒
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('您已永久拒绝权限！！'),
              content: const Text('去设置界面打开读写权限'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      openAppSettings();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('确定')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('取消')),
              ],
            );
          }).then((value) {
        /// 获取关闭对话框的结果，即 pop 中的参数，这里确定传入的是 true , 取消传入的是 false
        debugPrint('dialog result => $value');
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  getImage(true);
                },
                child: const Text('拍照')),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  getImage(false);
                },
                child: const Text('选择照片')),
            const SizedBox(
              height: 10,
            ),
            _imgPath != null
                ? Image.file(
                    _imgPath!,
                    fit: BoxFit.cover,
                  )
                : const Center(
                    child: Text(
                    "没有选择照片",
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  )),
            ElevatedButton(
                onPressed: () {
                  requestStoragePermission();
                },
                child: const Text('读写权限'))
          ],
        ),
      ),
    );
  }
}
