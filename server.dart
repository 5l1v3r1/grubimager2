import 'dart:io';
import 'upload-handler.dart';
import 'package:path/path.dart' as pathlib;

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart server.dart <port>');
    stderr.flush().then((_) => exit(1));
    return;
  }

  var port = int.parse(args[0]);
  var bindCb = (x) => x.listen(requestHandler);
  var errorCb = (_) {
    print('Failed to listen on port $port');
    exit(1);
  };

  HttpServer.bind(InternetAddress.ANY_IP_V4, port).then(bindCb)
    .catchError(errorCb);
}

void requestHandler(HttpRequest request) {
  if (request.method == 'POST' &&
      request.headers.contentType.mimeType == 'multipart/form-data') {
    handleFileUpload(request);
    return;
  }

  var uri = request.uri.toString();
  if (uri == '/script.js') {
    serveFile('build/script.js', 'text/javascript', request);
  } else if (uri == '/script.dart') {
    serveFile('script.dart', 'application/dart', request);
  } else if (uri == '/script.js.map') {
    serveFile('build/script.js.map', 'application/octet-stream', request);
  } else if (['/', ''].contains(uri)) {
    serveFile('index.html', 'text/html', request);
  } else {
    var response = request.response;
    response.statusCode = 404;
    response.headers.contentType = ContentType.parse('text/plain');
    response..write('404 not found: $uri')..close();
  }
}

void serveFile(String path, String type, HttpRequest request) {
  var response = request.response;
  
  var scriptDir = pathlib.dirname(Platform.script.path);
  var relPath = pathlib.relative(path, from: scriptDir);
  
  new File(relPath).readAsBytes().then((body) {
    response.headers.contentType = ContentType.parse(type);
    response..add(body)..close();
  }).catchError((error) {
    response.headers.contentType = ContentType.parse('text/plain');
    response.statusCode = 500;
    response..write('Error reading file: $error')..close();
  });
}

void handleFileUpload(HttpRequest request) {
  var handler = new UploadHandler(request);
  handler.createGrub().then((_) => handler.handleFields()).then((_) {
    print("created GRUB temp and handled fields");
  }).catchError((e) {
    handler.deleteGrub();
    var response = request.response;
    response.headers.contentType = ContentType.parse('text/plain');
    response.statusCode = 400;
    response..write('Error processing request: ' + e.toString())..close();
  });
}

