import 'dart:math';

/// Port for random number generation.
abstract interface class RandomGenerator {
  int nextInt(int max);
}

/// Default system random number generator.
class SystemRandomGenerator implements RandomGenerator {
  final Random _random;

  SystemRandomGenerator([int? seed]) : _random = Random(seed);

  @override
  int nextInt(int max) => _random.nextInt(max);
}
