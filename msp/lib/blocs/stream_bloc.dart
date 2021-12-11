import 'dart:async';
import 'dart:developer' as developer;

class StreamBloc<T> {
  StreamController<T> _fetcher = StreamController<T>();

  Stream<T> get stream => _fetcher.stream;
  StreamSubscription? subscription = null;

  bool isStarted = false;

  void start() {
    if (isStarted) return;

    isStarted = true;
    _fetcher = StreamController<T>();
    developer.log('${this.runtimeType} Started');
  }

  void stop() {
    isStarted = false;
    subscription?.cancel();
    subscription = null;
    _fetcher.close();
    developer.log('${this.runtimeType} Stopped');
  }

  void pub(T event) {
    if (!_fetcher.isClosed) {
      _fetcher.sink.add(event);
    }
  }
}
