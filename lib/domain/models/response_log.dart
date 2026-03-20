class ResponseLog {
  final int logNumber;
  final String log;
  final String? cellKey;
  final bool error;

  const ResponseLog({
    required this.logNumber,
    required this.log,
    this.cellKey,
    required this.error
});
}