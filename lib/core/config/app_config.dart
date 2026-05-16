class AppConfig {
  // Set your Cloudinary credentials (create an unsigned upload preset)
  // Example:
  // static const cloudName = 'my-cloud-name';
  // static const uploadPreset = 'unsigned_preset_name';
  // When using unsigned preset, ensure the preset is set to unsigned in Cloudinary dashboard.

  static const cloudName = '';
  static const uploadPreset = '';

  // Set your ML model endpoint that accepts POST { report_id, cloudinary_url }
  // and returns JSON { prediction: {...} }
  // Example: https://example-ml-server.com/predict
  static const modelUrl = 'https://hk3355-hallakukhan.hf.space/analyze';

  // You can also extend this file to load from .env or secure storage in future.
}
