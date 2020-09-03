class DialogResult<T> {
  final bool cancelled;
  final T data;

  const DialogResult({
    this.cancelled,
    this.data,
  });

  const DialogResult.cancelled(this.data) : cancelled = true;

  const DialogResult.ok(this.data) : cancelled = false;
}
