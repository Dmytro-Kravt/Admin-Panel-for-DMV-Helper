class ResponseLog {
  final int logNumber;
  final String log;
  final String? cellKey;

  const ResponseLog({
    required this.logNumber,
    required this.log,
    this.cellKey,
});
}