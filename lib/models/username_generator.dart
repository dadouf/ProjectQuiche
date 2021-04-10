import 'dart:math';

final _adjectives = [
  "funky",
  "lucky",
  "sad",
];

final _nouns = [
  "acai",
  "apple",
  "apricot",
];

final _random = new Random();

String generateUsername() {
  final adjective = _adjectives[_random.nextInt(_adjectives.length)];
  final noun = _nouns[_random.nextInt(_nouns.length)];
  final number = _random.nextInt(99) + 1;

  return "$adjective-$noun-$number";
}
