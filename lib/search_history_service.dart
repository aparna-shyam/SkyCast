import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _historyKey = 'search_history';

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> saveSearchHistory(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    // Add new city to the beginning of the list and ensure no duplicates
    history.remove(cityName);
    history.insert(0, cityName);

    // Keep the list size manageable, e.g., max 10 items
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await prefs.setStringList(_historyKey, history);
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
