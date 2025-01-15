# Sefaria Text Detector

Sefaria Text Detector is a mobile application designed to scan Hebrew or English text and detect whether it exists in the [Sefaria](https://www.sefaria.org/) database. If a match is found, the app provides a clickable link to the relevant Sefaria pages.

---

## Features

- **Text Recognition**: Utilizes Tesseract OCR to scan and recognize text in Hebrew and English.
- **Sefaria Integration**: Matches detected text against Sefaria's extensive library of Jewish texts.
- **Direct Links**: Provides clickable links to Sefaria for easy access to the matched text.
- **Mobile-Friendly**: Built for seamless use on mobile devices.

---

## Technology Stack

- **Language**: Written in [Dart](https://dart.dev/) using the [Flutter](https://flutter.dev/) framework for cross-platform compatibility.
- **OCR**: Leverages [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) for high-accuracy text recognition in both Hebrew and English.

---

## How It Works

1. **Scan Text**: Use your device camera or upload an image containing Hebrew or English text.
2. **Detect Matches**: The app processes the text using Tesseract OCR and searches for matches in Sefaria's database.
3. **Access Results**: If matches are found, the app displays clickable links to the corresponding Sefaria pages.

---

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/anehemya/Sefaria_Text_Detector.git
   ```
2. **Navigate to the Project Directory**:
   ```bash
   cd Sefaria_Text_Detector
   ```
3. **Install Dependencies**:
   Ensure you have Flutter installed. Run:
   ```bash
   flutter pub get
   ```
4. **Run the App**:
   Start the app in an emulator or connected device:
   ```bash
   flutter run
   ```

---

## Notes
- For optimal performance on iPhone, use Developer tools (Developer mode for iPhone, Xcode Runner) to emulate the application on your mobile device. The same is true for Android, although the application was primarily designed for iPhone.

---

## Prerequisites

- Flutter SDK installed on your system ([installation guide](https://docs.flutter.dev/get-started/install)).
- Tesseract OCR libraries installed (ensure compatibility with your device platform).

---

## Usage

1. Open the app on your mobile device.
2. Point your camera at a piece of text or upload an image containing text.
3. Wait for the app to process and search for matches in Sefaria.
4. Click on the provided link to view the matched text in Sefaria.

---

## Contributions

Contributions are welcome! Feel free to fork this repository, make improvements, and submit a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **Sefaria**: For their comprehensive library of Jewish texts and resources.
- **Tesseract OCR**: For providing open-source text recognition capabilities.
- **Flutter**: For enabling seamless cross-platform development.

---

Feel free to reach out with questions or feedback via the repository's [Issues](https://github.com/anehemya/Sefaria_Text_Detector/issues) page.
