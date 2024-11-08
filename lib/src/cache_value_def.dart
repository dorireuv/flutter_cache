typedef Formatter<T> = String Function(T);
typedef Parser<T> = T? Function(String);
typedef Validator<T> = bool Function(T);

abstract class CacheValueDef<T extends Object> {
  String get key;
  Formatter<T> get formatter;
  Parser<T> get parser;
  Validator<T>? get validator;

  static CacheValueDef<T> value<T extends Object>({
    required String key,
    required Formatter<T> formatter,
    required Parser<T> parser,
    Validator<T>? validator,
  }) =>
      _CacheValueDef(
          key: key, formatter: formatter, parser: parser, validator: validator);

  static CacheValueDef<bool> bool_(String key) => _CacheValueDef(
      key: key, formatter: (v) => v.toString(), parser: bool.tryParse);

  static CacheValueDef<int> int_(String key) => _CacheValueDef(
      key: key, formatter: (v) => v.toString(), parser: int.tryParse);

  static CacheValueDef<String> string(String key,
      {List<String>? whitelisted, List<String>? blacklisted}) {
    assert(whitelisted == null || blacklisted == null);
    return _CacheValueDef(
      key: key,
      formatter: (v) => v,
      parser: (v) => v,
      validator: whitelisted?.contains ?? blacklisted?.doesNotContain,
    );
  }
}

class _CacheValueDef<T extends Object> implements CacheValueDef<T> {
  @override
  final String key;
  @override
  final Formatter<T> formatter;
  @override
  final Parser<T> parser;
  @override
  final Validator<T>? validator;

  const _CacheValueDef({
    required this.key,
    required this.formatter,
    required this.parser,
    this.validator,
  });
}

extension _DoesNotContain<T> on List<T> {
  bool doesNotContain(T element) => !contains(element);
}
