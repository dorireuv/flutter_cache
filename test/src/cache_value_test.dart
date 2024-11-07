import 'package:flutter_cache/src/cache_value.dart';
import 'package:flutter_cache/src/cache_value_def.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'prefs_spy.dart';

void main() async {
  const key = 'key';

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  late MockSharedPreferences prefsSpy;

  late CacheValue<String> cacheValue;

  CacheValue<T> create<T extends Object>(CacheValueDef<T> def) =>
      CacheValue(prefs: prefsSpy, def: def);

  setUp(() async {
    await prefs.clear();
    prefsSpy = newPrefsSpy(prefs);
    cacheValue = create(CacheValueDef.string(key));
  });

  group('get', () {
    test('not set --> null', () async {
      expect(cacheValue.get(), isNull);
    });

    test('set --> value', () async {
      await cacheValue.set('value');
      expect(cacheValue.get(), 'value');
    });

    test('set with invalid value --> null', () async {
      final cacheValue = create(CacheValueDef(
          key: key, formatter: (v) => v.toString(), parser: int.parse));
      prefs.setString(key, 'not int');
      expect(cacheValue.get(), isNull);
    });
  });

  group('getOrDefault', () {
    test('not set --> default', () async {
      expect(cacheValue.getOrDefault('default'), 'default');
    });

    test('set --> value', () async {
      await cacheValue.set('value');
      expect(cacheValue.getOrDefault('default'), 'value');
    });
  });

  group('set', () {
    test('get --> value', () async {
      await cacheValue.set('value');
      expect(cacheValue.get(), 'value');
    });

    test('formats', () async {
      final cacheValue = create(CacheValueDef(
          key: key, formatter: (v) => 'formatted $v', parser: (v) => v));
      cacheValue.set('value');
      expect(prefs.getString(key), 'formatted value');
    });
  });

  group('setIfChanged', () {
    test('changed --> set ', () async {
      await cacheValue.set('value1');
      await cacheValue.setIfChanged('value2');
      verify(prefsSpy.setString(any, any)).called(2);
    });

    test('not changed --> not set', () async {
      await cacheValue.set('value');
      await cacheValue.setIfChanged('value');
      verify(prefsSpy.setString(any, any)).called(1);
    });
  });

  group('clear', () {
    test('set --> clears', () async {
      await cacheValue.set('value');
      await cacheValue.clear();
      expect(cacheValue.get(), isNull);
    });

    test('not set --> returns normally', () async {
      await cacheValue.clear();
      expect(cacheValue.get(), isNull);
    });
  });

  group('clearIfSet', () {
    test('set --> clears', () async {
      await cacheValue.set('value');
      await cacheValue.clearIfSet();
      expect(cacheValue.get(), isNull);
    });

    test('not set --> does nothing', () async {
      await cacheValue.clearIfSet();
      verifyNever(prefsSpy.remove(any));
    });
  });

  group('setIfChangedOrClearIfSet', () {
    test('null --> clears', () async {
      await cacheValue.set('value');
      await cacheValue.setIfChangedOrClearIfSet(null);
      expect(cacheValue.get(), isNull);
    });

    test('not null --> sets', () async {
      await cacheValue.setIfChangedOrClearIfSet('value');
      expect(cacheValue.get(), 'value');
    });
  });
}