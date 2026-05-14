/// progress callback
///
/// [count] are the bytes sent
///
/// [total] represents the total bytes
typedef ProgressCallback = void Function(int count, int total);

/// transformation progress callback
///
/// [count] transformation progress (0 - 1)
typedef TransformationProgressCallback = void Function(double count);
