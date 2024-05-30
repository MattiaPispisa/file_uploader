class _FileUploaderConfiguration {
  _FileUploaderConfiguration({
    this.defaultChunkSize = 5000,
  });

  int defaultChunkSize;
}

final _config = _FileUploaderConfiguration();

void setDefaultChunkSize(int chunkSize) => _config.defaultChunkSize = chunkSize;
int get defaultChunkSize => _config.defaultChunkSize;
