# Rice Yield Predictor

An agricultural rice yield prediction mobile application that leverages video upload and analysis features to help farmers predict rice crop yields accurately. Built with Flutter for cross-platform compatibility.

## 📋 Features

- **Video Upload & Analysis**: Upload rice field videos for yield prediction analysis
- **User Authentication**: Secure Firebase authentication with OTP verification
- **Yield Reports**: Generate detailed yield prediction reports with charts
- **Offline Support**: Local data storage using SharedPreferences
- **Modern UI**: Clean and intuitive user interface with Material Design
- **Real-time Updates**: Live video playback and analysis feedback

## 🛠 Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language
- **Provider**: State management solution

### Backend & Services
- **Firebase Core**: Backend services
- **Firebase Auth**: User authentication
- **HTTP**: API communication

### UI & UX
- **Google Fonts**: Custom typography
- **Cupertino Icons**: iOS-style icons
- **FL Chart**: Data visualization
- **Pinput**: OTP input fields
- **Loading Animation Widget**: Loading indicators

### Media & Storage
- **Video Player**: Video playback functionality
- **Image Picker**: Media selection
- **File Picker**: File handling
- **Shared Preferences**: Local data persistence

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Firebase project setup (for authentication)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd rice_yield_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place the files in the respective platform directories

4. **Run the app**
   ```bash
   flutter run
   ```

### Build Commands

- **Debug build**: `flutter run`
- **Release build**: `flutter build apk` (Android) or `flutter build ios` (iOS)
- **Run tests**: `flutter test`

## 📱 Usage

1. **Authentication**: Register/Login using phone number with OTP verification
2. **Upload Video**: Capture or select rice field videos for analysis
3. **View Reports**: Access detailed yield prediction reports with visual charts
4. **Profile Management**: Update user profile and preferences

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── providers/                # State management (Provider)
├── routes/                   # App routing configuration
├── screens/                  # UI screens
│   ├── home/                # Home screen
│   ├── reports/             # Report screens
│   └── video/               # Video upload screens
├── services/                 # API and external services
├── utils/                    # Utility functions and constants
└── widgets/                  # Reusable UI components
```

## 🔧 Configuration

### Firebase Setup
1. Enable Authentication in Firebase Console
2. Configure phone authentication
3. Set up Firestore (if needed for data storage)

### Environment Variables
Create a `.env` file in the root directory for sensitive configurations:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

Alternatively, set Cloudinary and model endpoint values directly in `lib/config/app_config.dart` (used by the app):

```dart
// lib/config/app_config.dart
static const cloudName = 'your_cloudinary_cloud_name';
static const uploadPreset = 'your_unsigned_upload_preset';
static const modelUrl = 'https://your-ml-server.example.com/predict';
```

The model endpoint should accept a POST JSON payload: `{ "report_id": "...", "cloudinary_url": "..." }` and return JSON `{ "prediction": { ... } }` on success.

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

For integration tests:
```bash
flutter test integration_test/
```

## Remove mock data

If you have mock reports in your Supabase DB (created during testing) you can remove them using the included script `tools/cleanup_mock_reports.dart`.

Run it with environment variables set:

```bash
SUPABASE_URL=https://your-project.supabase.co \
SUPABASE_KEY=your_service_role_key \
TARGET_USER_ID=the_user_id_to_clean \
dart run tools/cleanup_mock_reports.dart
```

The script looks for simple mock signatures (text 'mock', the example yield '5.2', or 'tons' keywords) and deletes matching reports.

## 📦 Dependencies

Key dependencies are listed in `pubspec.yaml`. Run `flutter pub get` to install all dependencies.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Flutter's official style guide
- Use `flutter format` for code formatting
- Run `flutter analyze` to check for issues

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Hallaku Khan** - *Initial work* - [Furqan3355](https://github.com/Furqan3355)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Open source community for various packages used

## 📞 Support

For support, email support@riceyieldapp.com or join our Discord community.

---

**Note**: This app is currently in development. Features may change without notice.
