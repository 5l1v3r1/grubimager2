import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as pathLib;

/**
 * This class configures the basic directory structure for a GRUB rescue image.
 */
class GrubFS {
  String path;

  GrubFS(this.path);

  Future makeDirectories() {
    return new Directory(grubPath).create(recursive: true);
  }

  Future makeMenu(String menuName) {
    var menuPath = pathLib.join(grubPath, 'grub.cfg');
    var menuContent = 'menuentry "${menuName}" {\n' +
        '\tmultiboot /boot/kernel.bin\n}';
    return new File(menuPath).writeAsString(menuContent);
  }

  Future delete() {
    return new Directory(this.path).delete(recursive: true);
  }

  String get grubPath => pathLib.join(path, 'boot/grub');

  String get kernelPath => pathLib.join(grubPath, 'kernel.bin');

  static Future<GrubFS> createTemp() {
    return Directory.systemTemp.createTemp().then((Directory d) {
      return new GrubFS(d.path);
    });
  }

}

