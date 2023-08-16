import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvvm/utils/database/sqlhelper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'app_round_image.dart';

class UserImage extends StatefulWidget {
  final Function(String imageUrl) onFileChanged;
  const UserImage({super.key, required this.onFileChanged});

  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  final ImagePicker _picker = ImagePicker();
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageUrl == null)
          Icon(
            Icons.image,
            size: 60,
            color: Theme.of(context).primaryColor,
          ),
        if (imageUrl != null)
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => selectPhoto(),
            child: AppRoundImage.url(
              imageUrl!,
              height: 80,
              width: 80,
            ),
          ),
        InkWell(
          onTap: () => selectPhoto(),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              imageUrl == null ? "Select Photo" : "Change Photo",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }

  Future selectPhoto() async {
    return showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheet(
            onClosing: () {},
            builder: (context) => Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.camera),
                      title: Text('Camera'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.file_copy),
                      title: Text('Pick a File'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                )));
  }

  Future _pickImage(ImageSource source) async {
    try {
      var pickedFile =
          await _picker.pickImage(source: source, imageQuality: 50);

      if (pickedFile == null) {
        return;
      }

      var file = await ImageCropper.platform.cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
      if (file == null) {
        return;
      }
      file = await compressImage(file.path, 35);
    //  debugPrint(file.toString());
      debugPrint('');
      uploadImageToDatabase(file);
    } catch (e) {
      debugPrint('');
    }
  }

  Future compressImage(String path, int imageQuality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        "${DateTime.now()}.${p.extension(path)}");
    try {
      final result = FlutterImageCompress.compressAndGetFile(path, newPath,
          quality: imageQuality);
      debugPrint(result.toString());
      return result;
    } catch (e) {
      debugPrint('');
    }
  }

  Future<void> uploadImageToDatabase(CroppedFile? imageFile) async {
    // Convert the image to bytes
    List<int> imageBytes = await imageFile!.readAsBytes();

    // Encode the image bytes to base64
    String base64Image = base64Encode(imageBytes);

    SqlHelper.insertImage(base64Image);
    debugPrint('Image saved to local database');

    var result = SqlHelper.getImage(base64Image);
    debugPrint(result.toString());
  }
}
