import 'package:flutter_test/flutter_test.dart';
import 'package:restler/services/variable_resolver.dart';

void main() {
  group('Variable', () {
    test('By Environment', () {
      const variables = {
        'a': '0',
        'b': '1',
        'c': '2',
      };

      final vr = VariableResolver(variables: variables);

      final text = vr.resolve('httpbin.org/basic-auth/{{a}}/{{b}}');

      expect(text, 'httpbin.org/basic-auth/0/1');
    });

    test('By Global', () {
      const globals = {
        'a': '0',
        'b': '1',
        'c': '2',
      };

      final vr = VariableResolver(globals: globals);

      final text = vr.resolve('httpbin.org/basic-auth/{{a}}/{{b}}');

      expect(text, 'httpbin.org/basic-auth/0/1');
    });

    test('Fallback to Global', () {
      const variables = {
        'a': '0',
        'b': '1',
      };

      const globals = {
        'c': '2',
      };

      final vr = VariableResolver(globals: globals, variables: variables);

      final text = vr.resolve('httpbin.org/basic-auth/{{a}}/{{c}}');
      expect(text, 'httpbin.org/basic-auth/0/2');
    });

    test('Recursive', () {
      const variables = {
        'a': '0{{b}}',
        'b': '1{{c}}',
        'c': '2',
        'd': '{{d}}',
        'e': '{{f}}',
        'f': '{{g}}',
        'g': '{{a}}{{e}}',
      };

      final vr = VariableResolver(variables: variables);

      final text = vr.resolve('httpbin.org/basic-auth/{{a}}/{{b}}/{{c}}');
      expect(text, 'httpbin.org/basic-auth/012/12/2');

      expect(() => vr.resolve('httpbin.org/basic-auth/{{a}}/{{d}}'),
          throwsA(isInstanceOf<VariableIsRecursiveException>()));

      expect(() => vr.resolve('httpbin.org/basic-auth/{{e}}'),
          throwsA(isInstanceOf<VariableIsRecursiveException>()));
    });
  });

  test('Parse Tag Block', () {
    var args = VariableResolver.parseTagBlock(
        " functionName 'string', '\\'', 1, 0.45, true, variableName ");
    expect(args.length, 7);
    expect(args[0], 'functionName');
    expect(args[1], "'string'");
    expect(args[2], "'''");
    expect(args[3], '1');
    expect(args[4], '0.45');
    expect(args[5], 'true');
    expect(args[6], 'variableName');

    args = VariableResolver.parseTagBlock(
        "base64 'encode', 'normal', 'Hi, Insomnia\\'s'");
    expect(args.length, 4);
    expect(args[0], 'base64');
    expect(args[1], "'encode'");
    expect(args[2], "'normal'");
    expect(args[3], "'Hi, Insomnia's'");
  });

  group('Tag', () {
    const globals = {
      'b': '0{{a}}',
      'a': '1{{s}}',
      's': '2{{e}}',
      'e': '3',
    };

    final vr = VariableResolver(globals: globals);
    String res;

    group('Base64', () {
      test('Encode Normal', () {
        res = vr.resolve("{% base64 'encode', 'normal', 'Hi, Insomnia\\'s' %}");
        expect(res, 'SGksIEluc29tbmlhJ3M=');

        res = vr.resolve("{% base64 'encode', 'normal', b %}");
        expect(res, 'MDEyMw==');
      });

      test('Decode Normal', () {
        res = vr.resolve("{% base64 'decode', 'normal', 'SW5zb21uaWE=' %}");
        expect(res, 'Insomnia');
      });
    });

    group('Hash', () {
      test('MD5 Hex', () {
        res = vr.resolve("{% hash 'md5', 'hex', 'Insomnia' %}");
        expect(res, '866d815adb055e7d4ed23ac402b221f1');
      });

      test('MD5 Base64', () {
        res = vr.resolve("{% hash 'md5', 'base64', 'Insomnia' %}");
        expect(res, 'hm2BWtsFXn1O0jrEArIh8Q==');
      });

      test('SHA1 Hex', () {
        res = vr.resolve("{% hash 'sha1', 'hex', 'Insomnia' %}");
        expect(res, '362ba15336e55fe7e94cc722768f6e6955929aea');
      });

      test('SHA1 Base64', () {
        res = vr.resolve("{% hash 'sha1', 'base64', 'Insomnia' %}");
        expect(res, 'NiuhUzblX+fpTMcido9uaVWSmuo=');
      });

      test('SHA256 Hex', () {
        res = vr.resolve("{% hash 'sha256', 'hex', 'Insomnia' %}");
        expect(res,
            '9dcefd14ed11ae5d50e04abac353e8615bb05f00200536c86a107e8bbf62f64e');
      });

      test('SHA256 Base64', () {
        res = vr.resolve("{% hash 'sha256', 'base64', 'Insomnia' %}");
        expect(res, 'nc79FO0Rrl1Q4Eq6w1PoYVuwXwAgBTbIahB+i79i9k4=');
      });

      test('SHA512 Hex', () {
        res = vr.resolve("{% hash 'sha512', 'hex', 'Insomnia' %}");
        expect(res,
            'b5b61cef9577bbe8321cc6414d06e9ee7b67ff4289c2c617b7aa4071d4096327e24b57919bf1e2274495ae14a68e4fc0af859c47a76bb0b367baac7298f14cf0');
      });

      test('SHA512 Base64', () {
        res = vr.resolve("{% hash 'sha512', 'base64', 'Insomnia' %}");
        expect(res,
            'tbYc75V3u+gyHMZBTQbp7ntn/0KJwsYXt6pAcdQJYyfiS1eRm/HiJ0SVrhSmjk/Ar4WcR6drsLNnuqxymPFM8A==');
      });
    });

    group('Timestamp', () {
      test('ISO 8601', () {
        res = vr.resolve("{% now 'iso-8601', '' %}");

        expect(
          DateTime.parse(res).millisecondsSinceEpoch,
          lessThanOrEqualTo(DateTime.now().millisecondsSinceEpoch),
        );
      });

      test('Milliseconds', () {
        res = vr.resolve("{% now 'millis', '' %}");

        expect(
          int.parse(res),
          lessThanOrEqualTo(DateTime.now().millisecondsSinceEpoch),
        );
      });

      test('Unix', () {
        res = vr.resolve("{% now 'unix', '' %}");

        expect(
          int.parse(res) * 1000,
          lessThanOrEqualTo(DateTime.now().millisecondsSinceEpoch),
        );
      });
    });

    group('UUID', () {
      test('V1', () {
        res = vr.resolve("{% uuid 'v1', '' %}");
        expect(res.length, 36);
      });

      test('V4', () {
        res = vr.resolve("{% uuid 'v4', '' %}");
        expect(res.length, 36);
      });
    });

    group('Exception', () {
      test('TagHasWrongParameterException', () {
        expect(() => vr.resolve("{% base64 'decode', 'hex' %}"),
            throwsA(isInstanceOf<TagHasWrongParameterException>()));

        expect(() => vr.resolve("{% hash 'sha2', 'hex', 'abc' %}"),
            throwsA(isInstanceOf<TagHasWrongParameterException>()));

        expect(() => vr.resolve("{% hash 'md5', 'binary', 'abc' %}"),
            throwsA(isInstanceOf<TagHasWrongParameterException>()));

        expect(() => vr.resolve("{% now 'iso8601', '' %}"),
            throwsA(isInstanceOf<TagHasWrongParameterException>()));

        expect(() => vr.resolve("{% uuid 'v8', '' %}"),
            throwsA(isInstanceOf<TagHasWrongParameterException>()));
      });

      test('TagCantBeResolvedException', () {
        expect(() => vr.resolve("{% foo '' %}"),
            throwsA(isInstanceOf<TagCantBeResolvedException>()));

        expect(() => vr.resolve("{% base64 'decode', 'normal', 'error' %}"),
            throwsA(isInstanceOf<TagCantBeResolvedException>()));
      });
    });
  });
}
