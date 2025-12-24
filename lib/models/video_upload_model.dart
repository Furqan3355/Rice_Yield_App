class VideoUpload {
  final String id;
  final String filePath;
  final String? cloudinaryId;
  final double progress;
  final DateTime uploadedAt;

  VideoUpload({
    required this.id,
    required this.filePath,
    this.cloudinaryId,
    this.progress = 0.0,
    required this.uploadedAt,
  });
}