import 'package:multidart/multidart.dart';
import 'grubfs.dart';
import 'dart:async';
import 'dart:io';

class UploadHandler {
  final HttpRequest request;
  final Map<String, String> fields;
  GrubFS grub;

  UploadHandler(this.request) : fields = {} {
    grub = null;
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
    var transformer = new PartTransformer(boundary);
    var sub;
    sub = request.transform(transformer).listen((Part part) {
      String name = part.contentDisposition.parameters['name'];
      if (!(name is String)) {
        sub.cancel();
        part.cancel();
        completer.completeError('missing name argument');
      } else if (name == 'file-name' || name == 'menu-name') {
        StringBuffer buffer = new StringBuffer();
        part.stream.listen((List<int> x) {
          buffer.write(new String.fromCharCodes(x));
        }, onDone: () {
          fields[name] = buffer.toString();
        });
      } else if (name == 'image') {
        // TODO: prevent HUGE uploads here!
        IOSink writable = new File(grub.kernelPath).openWrite();
        part.stream.pipe(writable).catchError((e) {
          completer.completeError(e);
          sub.cancel();
          part.cancel();
        });
      } else {
        sub.cancel();
        part.cancel();
        completer.completeError('invalid field name: ' + name);
      }
    }, onError: (e) {
      completer.completeError(e);
    }, onDone: () {
      if (completer.isCompleted) return;
      completer.complete();
    });
    return completer.future;
  }

  Future deleteGrub() {
    if (grub == null) {
      return new Future(() => null);
    } else {
      return grub.delete();
    }
  }

}
