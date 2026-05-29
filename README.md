# Smart Krishi 🌾

Smart Agriculture Advisor for Nepali farmers — featuring offline-first crop advice, disease detection, market placement, and localized weather alerts.

## Features
- **Offline-First Crop Advice**: Read and follow stage-by-stage instructions without internet connectivity.
- **Disease Detection**: Take or upload pictures of infected crops to identify diseases (stub/fallback setup ready for TFLite).
- **Phonetic Nepali Input**: Type in romanized transliteration (e.g., `golbheda`) and watch it turn into Devanagari in real time.
- **Market & Sales**: Sell farm produce directly and view seller analytics.
- **Weather Alerts**: Real-time notifications and advisory warnings depending on temperature, humidity, and wind.

---

## Getting Started

### Prerequisites
- **Flutter SDK**: Ensure you have Flutter installed (compatible with Dart `^3.8.0`).
- **Supabase Account**: A Supabase project set up with tables configured.
- **OpenWeather API Key**: For fetching live weather alerts.

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/RahulMalla10/E-Agro.git
   cd E-Agro
   ```

2. **Configure Environment Variables**:
   Copy `.env.example` to `.env` and fill in your keys:
   ```bash
   cp .env.example .env
   ```
   Edit `.env`:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   OPENWEATHER_API_KEY=your-openweather-key
   ```

3. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the Application**:
   ```bash
   flutter run
   ```

---

## Project Structure
- `lib/core/`: Contains shared configuration, local database (SQLite), routing, security wrappers, and utility components.
- `lib/features/`: Contains feature modules (auth, crop advisor, disease detection, seller analytics, trading, weather).
