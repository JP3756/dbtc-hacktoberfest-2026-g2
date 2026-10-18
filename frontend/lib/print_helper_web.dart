import 'dart:js_interop';

@JS('window.print')
external void _windowPrint();

void printPage() => _windowPrint();
