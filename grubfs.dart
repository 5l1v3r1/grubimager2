import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as pathlib;

/**
 * This class configures the basic directory structure for a GRUB rescue image.
 */
class GrubFS {
  String path;
  String get grubPath => pathlib.join(path, 'boot/grub');
  String get menuPath => pathlib.join(grubPath, 'grub.cfg');
  String get kernelPath => pathlib.join(grubPath, 'kernel.bin');
  
  GrubFS(this.path);

  Future makeDirectories() {
    return new Directory(grubPath).create(recursive: true);
  }

  Future makeMenu(String menuName) {
    var menuContent = 'menuentry "${menuName}" {\n' +
        '\tmultiboot /boot/kernel.bin\n}';
    return new File(menuPath).writeAsString(menuContent);
  }

  Future delete() {
    return new Directory(path).delete(recursive: true);
  }

  static Future<GrubFS> createTemp() {
    return Directory.systemTemp.createTemp().then((Directory d) {
      return new GrubFS(d.path);
    });
  }

}
