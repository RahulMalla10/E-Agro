# Assets guide

## App logo

Place your logo at:

```
assets/logo/logo.png
```

The app uses this on the splash screen, onboarding, and home header via `AppLogo`.

## Splash loading animation (Lottie)

1. Go to [LottieFiles](https://lottiefiles.com/) and search for terms like **"loading"**, **"agriculture"**, **"plant"**, or **"farmer"**.
2. Pick a free animation (check license — many are free for app use).
3. Download the **Lottie JSON** file (not GIF/MP4).
4. Save it as:

```
assets/animations/splash_loading.json
```

5. Run `flutter pub get` and restart the app.

Recommended searches:

- [Loading agriculture](https://lottiefiles.com/search?q=loading%20agriculture&category=animations)
- [Plant growth](https://lottiefiles.com/search?q=plant%20growth&category=animations)

If the file is missing, the app shows a rotating leaf icon instead.

## OpenWeather (live forecast)

Add to `.env`:

```
OPENWEATHER_API_KEY=your_key_here
```

Get a free key at [OpenWeather](https://openweathermap.org/api).

lets push this project  to github without any comments only comment initial commit " new way of doing agriculture" like that 