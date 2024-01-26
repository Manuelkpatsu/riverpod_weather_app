import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

enum City { stockholm, paris, tokyo, accra }

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather({required City city}) {
  return Future.delayed(
    const Duration(seconds: 1),
    () =>
        {
          City.stockholm: '❄️',
          City.paris: '🌧️',
          City.tokyo: '💨',
          City.accra: '🌞',
        }[city] ??
        '🔥',
  );
}

const unknownWeatherEmoji = '🤷🏽‍';

// UI writes to and reads from this
final currentCityProvider = StateProvider<City?>((ref) => null);

// UI reads this
final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city: city);
  } else {
    return unknownWeatherEmoji;
  }
});

// Capitalize the first letter of a string
extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Column(
        children: [
          currentWeather.when(
            data: (data) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(data, style: const TextStyle(fontSize: 40)),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Error 🥲'),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: (context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currentCityProvider);
                return ListTile(
                  title: Text(city.name.toCapitalized()),
                  onTap: () => ref.read(currentCityProvider.notifier).state = city,
                  trailing: isSelected ? const Icon(Icons.check) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
