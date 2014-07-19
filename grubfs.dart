import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as pathLib;

/**
 * This class configures the basic directory structure for a GRUB rescue image.
 */
class GrubFS {
  String path;

  GrubFS(this.path);

  Future makeMenu(String menuName, String isoName) {
    var result = new Completer();
    var grubPath = pathLib.join(path, 'boot/grub');
    
    new Directory(grubPath).create(recursive: true)
      .then((Directory d) {
        var menuPath = pathLib.join(grubPath, 'grub.cfg');
        var menuContent = 'menuentry "${menuName}" {\n' +
            '\tmultiboot /boot/learnos.bin\n}';
        return new File(menuPath).writeAsString(menuContent);
      }).then((File f) => result.complete());

    return result.future;
  }

  String get grubDir => pathLib.join(path, 'boot/grub');

}

