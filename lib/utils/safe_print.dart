import 'package:flutter/foundation.dart';

void safePrint(Object? object) {
  if (kReleaseMode) return;
  print(object);
}
