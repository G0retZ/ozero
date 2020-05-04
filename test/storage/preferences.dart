import 'package:flutter_test/flutter_test.dart';
import 'package:ozero/storage/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Set up empty storage
  SharedPreferences.setMockInitialValues({});

  /// Check current turn storage
  group('Current Turn storage logic', () {
    test('Get current turn from storage whithout current turn inside',
        () async {
      // Given
      (await SharedPreferences.getInstance()).clear();
      CurrentTurnStorage _currentTurnStorage = CurrentTurnStorage();

      // When
      final _currentTurn = await _currentTurnStorage.loadData();

      // Then
      expect(_currentTurn, null);
    });

    test(
        'Save and get back current turn from storage whithout turn inside',
        () async {
      // Given
      (await SharedPreferences.getInstance()).clear();
      CurrentTurnStorage _currentTurnStorage = CurrentTurnStorage();

      // When
      final _success = await _currentTurnStorage.saveData(13);
      final _currentTurn = await _currentTurnStorage.loadData();

      // Then
      expect(_success, true);
      expect(_currentTurn, 13);
    });

    test('Get current turn from storage whith current turn inside', () async {
      // Given
      CurrentTurnStorage _currentTurnStorage = CurrentTurnStorage();

      // When
      final _currentTurn = await _currentTurnStorage.loadData();

      // Then
      expect(_currentTurn, 13);
    });

    test(
        'Save and get back current turn from storage whith turn inside',
        () async {
      // Given
      CurrentTurnStorage _currentTurnStorage = CurrentTurnStorage();

      // When
      final _success = await _currentTurnStorage.saveData(7);
      final _currentTurn = await _currentTurnStorage.loadData();

      // Then
      expect(_success, true);
      expect(_currentTurn, 7);
    });
  });

  /// Check players storage
  group('Current List storage logic', () {
    test('Get list from storage whithout list inside', () async {
      // Given
      (await SharedPreferences.getInstance()).clear();
      ListDataStorage<String> _playersStorage =
          ListDataStorage('key', (val) => val.toString());

      // When
      final _players = await _playersStorage.loadData();

      // Then
      expect(_players, null);
    });

    test('Save and get back list from storage whithout list inside', () async {
      // Given
      (await SharedPreferences.getInstance()).clear();
      ListDataStorage<String> _playersStorage =
          ListDataStorage('key', (val) => val.toString());

      // When
      final _success = await _playersStorage.saveData([]);
      final _players = await _playersStorage.loadData();

      // Then
      expect(_success, true);
      expect(_players, []);
    });

    test('Get list from storage whith list inside', () async {
      // Given
      ListDataStorage<String> _playersStorage =
          ListDataStorage('key', (val) => val.toString());

      // When
      final _players = await _playersStorage.loadData();

      // Then
      expect(_players, []);
    });

    test('Save and get back list from storage whith list inside', () async {
      // Given
      ListDataStorage<String> _playersStorage =
          ListDataStorage('key', (val) => val.toString());

      // When
      final _success = await _playersStorage.saveData(['a']);
      final _players = await _playersStorage.loadData();

      // Then
      expect(_success, true);
      expect(_players.length, 1);
      expect(_players[0], 'a');
    });
  });
}
