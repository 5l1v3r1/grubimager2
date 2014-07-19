import 'dart:html';

main() {
  ButtonElement button = query('#submit-button');
  button.onClick.listen((e) {
    print("got click");
  });
}
