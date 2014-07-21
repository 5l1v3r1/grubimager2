import 'package:http_server/http_server.dart';
import 'package:mime/mime.dart';
import 'grubfs.dart';
import 'dart:async';

class UploadHandler {
  GrubFS grub;
  final HttpRequest request;

  UploadHandler(this.request) : grub = null {
  }

  Future createGrub() {
    return GrubFS.createTemp().then((g) {
      grub = g;
      return grub.makeDirectories();
    });
  }

  Future handleFields() {
    var completer = new Completer();

    String boundary = request.headers.contentType.parameters['boundary'];
    request.transform(new MimeMultipartTransformer(boundary))
      .map(HttpMultipartFormData.parse)
      .listen((HttpMultipartFormData formData) {
        print('field name is ${formData.contentDisposition.toString()}');
        print("got form data " + formData.toString());
        formData.listen((x) => print('hey ${x.length}'));
      });

    return completer.future;
  }

  Future deleteGrub() {
    if (grub == null) {
      return new Completer()..complete()..future;
    }
    return grub.delete();
  }

}

