import 'dart:async';

/// common bloc template that broadcasts [D] data and reacts on [A] actions
abstract class Bloc<A, D> {
  // Stream to handle the [D] data
  final StreamController<D> _dataController = StreamController<D>.broadcast();

  /// Get broadcast stream of [D] data, which can be subscribed more than once
  Stream<D> get data => _dataController.stream;

  // This is where all logic should be placed
  Future<bool> perform(A action);

  /// Unfortunately Dart doesn't allow protected methods, so it's public =/
  /// Lets use 'i' prefix for protected methods and properties and will not use them externally

  // This is a handle to inject values into output broadcast Stream
  StreamSink<D> get iSink => _dataController.sink;

  void dispose() {
    _dataController.close();
  }
}

extension StreamTools<T> on Stream<T> {
  startWith<T>(T first) async* {
    ArgumentError.checkNotNull(first, 'first');
    yield first;
    await for (var item in this) {
      yield item;
    }
  }

  concatWith<T>(Stream<T> nextStream) async* {
    ArgumentError.checkNotNull(nextStream, 'nextStream');
    await for (var item in this) {
      yield item;
    }
    await for (var item in nextStream) {
      yield item;
    }
  }
}

extension FutureTools<T> on Future<T> {
  concatWith<T>(Stream<T> nextStream) async* {
    ArgumentError.checkNotNull(nextStream, 'nextStream');
    yield await this;
    await for (var item in nextStream) {
      yield item;
    }
  }
}
