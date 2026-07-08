typedef WcEntry = ({String key, String emoji});

const List<WcEntry> wcList = [
  (key: 'sunny',          emoji: '☀️'),
  (key: 'partly_cloudy',  emoji: '⛅'),
  (key: 'overcast',       emoji: '☁️'),
  (key: 'light_rain',     emoji: '🌦'),
  (key: 'rain',           emoji: '🌧'),
  (key: 'heavy_rain',     emoji: '🌧'),
  (key: 'drizzle',        emoji: '🌂'),
  (key: 'thunderstorm',   emoji: '⛈'),
  (key: 'iso_thunder',    emoji: '🌩'),
  (key: 'hail',           emoji: '🌨'),
  (key: 'dust',           emoji: '🌫'),
  (key: 'foggy',          emoji: '🌁'),
  (key: 'windy',          emoji: '💨'),
  (key: 'cold',           emoji: '❄️'),
];

String? wcEmoji(String? key) =>
    key == null ? null : wcList.where((e) => e.key == key).map((e) => e.emoji).firstOrNull;
