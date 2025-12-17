# Stock Tracker (Flutter)

A modern, minimal Flutter app for tracking Pakistan Stock Exchange (PSX) and global (US) equities. It pulls live quotes and chart data from Polygon.io and headlines from NewsAPI, while keeping the UI focused on clean charts and glanceable stats.

## Features
- **Market view**: Watchlist tiles for PSX and US tickers with price, absolute and percentage change.
- **Graphs**: Intraday line chart with quick ticker input (works for PSX and US tickers).
- **News**: Latest market headlines (default query blends global and Pakistan market coverage).
- **Sector performance**: Simple sector heat cards using representative tickers from both PSX and US markets.

## Configuration
The project uses the provided API keys by default but you can override them at runtime with `--dart-define` flags.

- Polygon.io: `POLYGON_API_KEY` (default: `01kYNfBSwdvAiS_IOtvVli2bMD3aBU2J`)
- NewsAPI: `NEWS_API_KEY` (default: `432ce4b1fc3842fa8bccacdb3470f584`)

## Getting started
1. Install Flutter `3.27.1` (Dart `3.6.0`).
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app (override keys if desired):
   ```bash
   flutter run \
     --dart-define=POLYGON_API_KEY=your_polygon_key \
     --dart-define=NEWS_API_KEY=your_newsapi_key
   ```

## Notes
- The PSX ticker list uses common symbols (e.g., `OGDC`, `HBL`, `PSO`, `LUCK`). Polygon locality is set to `pk` for Pakistan data in the market watchlist.
- Sector performance cards use lead tickers (e.g., `AAPL`, `OGDC`, `JPM`, `LUCK`, `NVDA`) to surface quick percentage moves.
- The news tab currently shows a snackbar with the article URL; plug in a URL launcher if you want in-app browsing.
