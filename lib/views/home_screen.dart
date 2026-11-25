import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';
import '../utils/weather_utils.dart';
import 'search_screen.dart';
import 'widgets/daily_forecast_card.dart';
import 'widgets/weather_info_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherViewModel>(
        builder: (context, vm, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _getGradientColors(vm),
              ),
            ),
            child: SafeArea(
              child: _buildContent(context, vm),
            ),
          );
        },
      ),
    );
  }

  List<Color> _getGradientColors(WeatherViewModel vm) {
    if (vm.weatherData == null) {
      return [const Color(0xFF1565C0), const Color(0xFF0D47A1)];
    }
    final code = vm.weatherData!.current.weatherCode;
    if (code == 0 || code == 1) {
      return [const Color(0xFF1976D2), const Color(0xFF0D47A1)];
    } else if (code >= 61 && code <= 82) {
      return [const Color(0xFF37474F), const Color(0xFF263238)];
    } else if (code >= 95) {
      return [const Color(0xFF212121), const Color(0xFF37474F)];
    } else {
      return [const Color(0xFF455A64), const Color(0xFF263238)];
    }
  }

  Widget _buildContent(BuildContext context, WeatherViewModel vm) {
    return RefreshIndicator(
      onRefresh: vm.refreshWeather,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildAppBar(context, vm)),
          if (vm.state == WeatherLoadState.loading)
            const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Colors.white)))
          else if (vm.state == WeatherLoadState.error)
            SliverFillRemaining(child: _buildError(context, vm))
          else if (vm.state == WeatherLoadState.initial)
            const SliverFillRemaining(
              child: Center(
                child: Text('Memuat data cuaca...',
                    style: TextStyle(color: Colors.white70)),
              ),
            )
          else ...[
            SliverToBoxAdapter(child: _buildCurrentWeather(context, vm)),
            SliverToBoxAdapter(child: _buildWeatherDetails(context, vm)),
            SliverToBoxAdapter(child: _buildDailyForecast(context, vm)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WeatherViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openSearch(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      vm.selectedLocation?.name ?? 'Cari kota...',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              vm.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: vm.isFavorite ? Colors.pinkAccent : Colors.white70,
            ),
            onPressed: vm.selectedLocation != null ? vm.toggleFavorite : null,
            tooltip:
                vm.isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
          ),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context) {
    final weatherVM = Provider.of<WeatherViewModel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: weatherVM),
            ChangeNotifierProvider(create: (_) => SearchViewModel()),
          ],
          child: const SearchScreen(),
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(BuildContext context, WeatherViewModel vm) {
    final weather = vm.weatherData!.current;
    final location = vm.selectedLocation!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            location.name,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
          ),
          if (location.admin1 != null) ...[
            const SizedBox(height: 4),
            Text(
              '${location.admin1}, ${location.country}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            WeatherUtils.getWeatherIcon(weather.weatherCode),
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 8),
          Text(
            '${weather.temperature.round()}°C',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 76),
          ),
          Text(
            WeatherUtils.getWeatherDescription(weather.weatherCode),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terasa seperti ${weather.apparentTemperature.round()}°C',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails(BuildContext context, WeatherViewModel vm) {
    final weather = vm.weatherData!.current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Detail Cuaca',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: WeatherInfoCard(
                  icon: Icons.water_drop_outlined,
                  label: 'Kelembapan',
                  value: '${weather.relativeHumidity}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WeatherInfoCard(
                  icon: Icons.air,
                  label: 'Kecepatan Angin',
                  value: '${weather.windSpeed.round()} km/h',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: WeatherInfoCard(
                  icon: Icons.umbrella_outlined,
                  label: 'Curah Hujan',
                  value: '${weather.precipitation} mm',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WeatherInfoCard(
                  icon: Icons.thermostat_outlined,
                  label: 'Suhu Terasa',
                  value: '${weather.apparentTemperature.round()}°C',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast(BuildContext context, WeatherViewModel vm) {
    final dailyList = vm.weatherData!.daily;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Perkiraan 7 Hari',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailyList.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white12, height: 1),
              itemBuilder: (_, index) =>
                  DailyForecastCard(daily: dailyList[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WeatherViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              vm.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: vm.refreshWeather,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
