class Ticker {
  Stream<int> tick({int ticks}) {
    return Stream.periodic(
      Duration(seconds: 1),

      // The first call/tick passes [numOfEvents] back with the
      // value of 0, rather than 1.
      // Therefore, the [-1] offsets the final value back to what
      // it should be
      (numOfEvents) => ticks - numOfEvents - 1,
      //[take()] sets a maximum of events. When the provided number
      //of events are emitted, the stream will finish.
    ).take(ticks);
  }
}
