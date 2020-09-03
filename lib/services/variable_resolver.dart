import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:fakedart/fakedart.dart';
import 'package:restler/helper.dart';
import 'package:restler/i18n.dart';

final _variableRegex = RegExp(r'{{(.+?)}}');
final _tagRegex = RegExp(r'{%(.+?)%}');
final _tagBlockRegex = RegExp(r'(\w+)\b(.*)?');
final _faker = Faker();

typedef VariableResolverCallback = String Function(String text);

class VariableResolver {
  final Map<String, String> globals;
  final Map<String, String> variables;

  VariableResolver({
    this.globals = const {},
    this.variables = const {},
  });

  String resolve(String text) => _resolve(text, <String>{});

  String _resolve(
    String text,
    Set<String> parentNames,
  ) {
    if (text == null || text.isEmpty) {
      return text;
    }

    while (true) {
      final m = _tagRegex.firstMatch(text);

      if (m == null) break;

      final start = m.start;
      final end = m.end;
      final block = m.group(1).trim();

      final args = parseTagBlock(block);

      if (args.isNotEmpty) {
        final tagName = args[0];
        final parameters = <Object>[];

        if (args.length > 1) {
          for (var i = 1; i < args.length; i++) {
            final arg = args[i];

            if (arg is String && arg.startsWith("'") && arg.endsWith("'")) {
              parameters.add(arg.substring(1, arg.length - 1));
            } else if (arg == 'true') {
              parameters.add(true);
            } else if (arg == 'false') {
              parameters.add(false);
            } else {
              final n = int.tryParse(arg) ??
                  double.tryParse(arg) ??
                  _resolve(_resolveVariableByName(arg), const <String>{});
              parameters.add(n);
            }
          }
        }

        final value = _resolveTag(tagName, parameters);

        text = text.replaceRange(start, end, value);
      }
    }

    while (true) {
      final m = _variableRegex.firstMatch(text);

      if (m == null) break;

      final start = m.start;
      final end = m.end;
      final name = m.group(1).trim();

      if (parentNames.contains(name)) {
        throw VariableIsRecursiveException(name);
      }

      final value = _resolveVariableByName(name);

      if (value == null) {
        throw VariableNotFoundException(name);
      }

      final recursive = _resolve(value, {...parentNames, name});
      text = text.replaceRange(start, end, recursive);
    }

    return text;
  }

  String _resolveVariableByName(String name) {
    return variables[name] ?? globals[name] ?? _computeDynamicVariable(name);
  }

  String _resolveTag(
    String name,
    List<Object> p,
  ) {
    try {
      switch (name) {
        case 'base64':
          return _resolveBase64(p[0], p[1], p[2]);
        case 'hash':
          return _resolveHash(p[0], p[1], p[2]);
          break;
        case 'now':
          return _resolveNow(p[0]);
          break;
        case 'uuid':
          return _resolveUuid(p[0]);
          break;
        default:
          throw TagCantBeResolvedException(name);
      }
    } on RangeError {
      throw TagHasWrongParameterException(name);
    } on TagHasWrongParameterException {
      rethrow;
    } catch (e) {
      throw TagCantBeResolvedException(name, e);
    }
  }

  String _resolveBase64(
    String action,
    String kind,
    String value,
  ) {
    if (action == 'encode') {
      return base64.encode(utf8.encode(value));
    } else {
      return utf8.decode(base64.decode(value));
    }
  }

  String _resolveHash(
    String algorithm,
    String digest,
    String value,
  ) {
    List<int> data;

    if (algorithm == 'md5') {
      data = md5.convert(utf8.encode(value)).bytes;
    } else if (algorithm == 'sha1') {
      data = sha1.convert(utf8.encode(value)).bytes;
    } else if (algorithm == 'sha256') {
      data = sha256.convert(utf8.encode(value)).bytes;
    } else if (algorithm == 'sha512') {
      data = sha512.convert(utf8.encode(value)).bytes;
    }

    if (data != null) {
      if (digest == 'hex') {
        return hex.encode(data);
      } else if (digest == 'base64') {
        return base64.encode(data);
      }
    }

    throw const TagHasWrongParameterException('hash');
  }

  String _resolveNow(String format) {
    if (format == 'iso-8601') {
      return currentUtc().toIso8601String();
    } else if (format == 'millis') {
      return currentMillis().toString();
    } else if (format == 'unix') {
      return (currentMillis() ~/ 1000).toString();
    } else {
      throw const TagHasWrongParameterException('now');
    }
  }

  String _resolveUuid(String version) {
    if (version == 'v1') {
      return generateUuidV1();
    } else if (version == 'v4') {
      return generateUuidV4();
    } else {
      throw const TagHasWrongParameterException('uuid');
    }
  }

  // tagName 'string', 1234, true, variableName
  static List<Object> parseTagBlock(String text) {
    final m = _tagBlockRegex.firstMatch(text);

    if (m == null) return const [];

    final tagName = m.group(1);
    final rawArgs = m.group(2);
    final args = <Object>[];

    args.add(tagName.trim());

    if (rawArgs != null && rawArgs.isNotEmpty) {
      String prevChar;
      var current = '';
      var insideString = false;

      for (var i = 0; i < rawArgs.length; i++) {
        final c = rawArgs[i];

        // Fim do texto ou de um argumento.
        if (i == rawArgs.length - 1 || c == ',' && !insideString) {
          if (c != ',') current += c;
          args.add(current.trim().replaceAll("\\'", "'"));
          current = '';
        } else {
          // Inicio e fim de uma string.
          if (c == "'" && prevChar != '\\') {
            insideString = !insideString;
          }

          current += c;
        }

        prevChar = c;
      }
    }

    return args;
  }

  static String _computeDynamicVariable(String name) {
    if (name.startsWith('\$')) {
      name = name.substring(1);
    } else {
      return null;
    }

    switch (name) {
      case 'randomInt':
        return _faker.random.nextInt(1 << 32).toString();
      case 'randomNameTitle':
      case 'randomJobTitle':
        return _faker.name.jobTitle();
      case 'randomZipCode':
        return _faker.address.zipCode();
      case 'randomCity':
        return _faker.address.city();
      case 'randomCityPrefix':
        return _faker.address.cityPrefix();
      case 'randomCitySuffix':
        return _faker.address.citySuffix();
      case 'randomStreetName':
        return _faker.address.streetName();
      case 'randomStreetAddress':
        return _faker.address.streetAddress();
      case 'randomStreetSuffix':
        return _faker.address.streetSuffix();
      case 'randomCountry':
        return _faker.address.country();
      case 'randomCountryCode':
        return _faker.address.countryCode();
      case 'randomLatitude':
        return _faker.address.latitude();
      case 'randomLongitude':
        return _faker.address.longitude();
      case 'randomCompanyName':
        return _faker.company.companyName();
      case 'randomCompanySuffix':
        return _faker.company.companySuffix();
      case 'randomState':
        return _faker.address.state();
      case 'randomStateAbbr':
        return _faker.address.state(abbr: true);
      case 'randomSecondaryAddress':
        return _faker.address.secondaryAddress();
      case 'randomStreetPrefix':
        return _faker.address.streetPrefix();
      case 'randomColor':
        return _faker.commerce.color();
      case 'randomDepartment':
        return _faker.commerce.department();
      case 'randomProductName':
        return _faker.commerce.productName();
      case 'randomPrice':
        return _faker.commerce.price();
      case 'randomProductAdjective':
        return _faker.commerce.productAdjective();
      case 'randomProductMaterial':
        return _faker.commerce.productMaterial();
      case 'randomProduct':
        return _faker.commerce.product();
      case 'randomCatchPhrase':
        return _faker.company.catchPhrase();
      case 'randomBs':
        return _faker.company.bs();
      case 'randomCatchPhraseAdjective':
        return _faker.company.catchPhraseAdjective();
      case 'randomCatchPhraseDescriptor':
        return _faker.company.catchPhraseDescriptor();
      case 'randomCatchPhraseNoun':
        return _faker.company.catchPhraseNoun();
      case 'randomBsAdjective':
        return _faker.company.bsAdjective();
      case 'randomBsBuzz':
        return _faker.company.bsBuzz();
      case 'randomBsNoun':
        return _faker.company.bsNoun();
      case 'randomJobDescriptor':
        return _faker.name.jobDescriptor();
      case 'randomJobArea':
        return _faker.name.jobArea();
      case 'randomJobType':
        return _faker.name.jobType();
      case 'randomNamePrefix':
        return _faker.name.prefix();
      case 'randomNameSuffix':
        return _faker.name.suffix();
      case 'randomFirstName':
        return _faker.name.firstName();
      case 'randomLastName':
        return _faker.name.lastName();
      case 'randomFullName':
        return _faker.name.fullName();
      case 'randomIP':
        return _faker.internet.ip();
      case 'randomIPV6':
        return _faker.internet.ipv6();
      case 'randomMACAddress':
        return _faker.internet.mac();
      case 'randomBoolean':
        return _faker.random.nextBool().toString();
      case 'randomUserName':
        return _faker.internet.userName();
      case 'randomUrl':
        return _faker.internet.url();
      case 'randomEmail':
        return _faker.internet.email();
      case 'randomMonth':
        return _faker.date.month();
      case 'randomDatabaseColumn':
        return _faker.database.column();
      case 'randomDatabaseType':
        return _faker.database.type();
      case 'randomDatabaseCollation':
        return _faker.database.collation();
      case 'randomDatabaseEngine':
        return _faker.database.engine();
      case 'randomDatePast':
        return _faker.date.past().toIso8601String();
      case 'randomDateFuture':
        return _faker.date.future().toIso8601String();
      case 'randomDateRecent':
        return _faker.date.recent().toIso8601String();
      case 'randomWeekday':
        return _faker.date.weekday();
      case 'randomDomainName':
        return _faker.internet.domainName();
      case 'randomDomainWord':
        return _faker.internet.domainWord();
      case 'randomAbbreviation':
        return _faker.hacker.abbreviation();
      case 'randomAdjective':
        return _faker.hacker.adjective();
      case 'randomNoun':
        return _faker.hacker.noun();
      case 'randomVerb':
        return _faker.hacker.verb();
      case 'randomIngverb':
        return _faker.hacker.ingVerb();
      case 'randomPhrase':
        return _faker.hacker.phrase();
      case 'randomAvatarImage':
        return _faker.internet.avatar();
      case 'randomExampleEmail':
        return _faker.internet.exampleEmail();
      case 'randomProtocol':
        return _faker.internet.protocol();
      case 'randomDomainSuffix':
        return _faker.internet.domainSuffix();
      case 'randomHexColor':
        return _faker.internet.color();
      case 'randomCurrencyCode':
        return _faker.finance.currencyCode();
      case 'randomCurrencyName':
        return _faker.finance.currencyName();
      case 'randomBankAccount':
        return _faker.finance.account();
      case 'randomBankAccountName':
        return _faker.finance.accountName();
      case 'randomCurrencyAmount':
        return _faker.finance.amount();
      case 'randomTransactionType':
        return _faker.finance.transactionType();
      case 'randomCurrencySymbol':
        return _faker.finance.currencySymbol();
      case 'randomBitcoin':
        return _faker.finance.bitcoinAddress();
      case 'randomBankAccountIban':
        return _faker.finance.iban();
      case 'randomBankAccountBic':
        return _faker.finance.bic();
      case 'randomPhoneNumber':
        return _faker.phoneNumber.phoneNumber();
      case 'randomPhoneNumberFormat':
      case 'randomPhoneFormats':
        return _faker.phoneNumber.phoneNumberFormat();
      case 'randomAbstractImage':
        return _faker.image.abstract_();
      case 'randomAnimalsImage':
        return _faker.image.animals();
      case 'randomBusinessImage':
        return _faker.image.business();
      case 'randomCatsImage':
        return _faker.image.cats();
      case 'randomCityImage':
        return _faker.image.city();
      case 'randomFoodImage':
        return _faker.image.food();
      case 'randomNightlifeImage':
        return _faker.image.nightlife();
      case 'randomFashionImage':
        return _faker.image.fashion();
      case 'randomPeopleImage':
        return _faker.image.people();
      case 'randomNatureImage':
        return _faker.image.nature();
      case 'randomSportsImage':
        return _faker.image.sports();
      case 'randomTechnicsImage':
        return _faker.image.technics();
      case 'randomTransportImage':
        return _faker.image.transport();
      case 'randomImageDataUri':
        return _faker.image.imageUrl();
      case 'randomFileName':
        return _faker.system.fileName();
      case 'randomCommonFileName':
        return _faker.system.commonFileName();
      case 'randomMimeType':
        return _faker.system.mimeType();
      case 'randomCommonFileType':
        return _faker.system.commonFileType();
      case 'randomCommonFileExt':
        return _faker.system.commonFileExt();
      case 'randomFileType':
        return _faker.system.fileType();
      case 'randomFileExt':
        return _faker.system.fileExt();
      case 'randomDirectoryPath':
        return _faker.system.directoryPath();
      case 'randomFilePath':
        return _faker.system.filePath();
      case 'randomSemver':
        return _faker.system.semver();
      case 'randomPassword':
        return _faker.internet.password();
      case 'randomLoremWord':
        return _faker.lorem.word();
      case 'randomLoremWords':
        return _faker.lorem.words();
      case 'randomLoremSentence':
        return _faker.lorem.sentence();
      case 'randomLoremSentences':
        return _faker.lorem.sentences();
      case 'randomLoremSlug':
        return _faker.lorem.slug();
      case 'randomLoremParagraph':
        return _faker.lorem.paragraph();
      case 'randomLoremParagraphs':
        return _faker.lorem.paragraphs();
      case 'randomLoremText':
        return _faker.lorem.text();
      case 'randomLoremLines':
        return _faker.lorem.lines();
      case 'randomWord':
        return _faker.random.word();
      case 'randomWords':
        return _faker.random.words();
      case 'guid':
      case 'randomUUID':
        return generateUuid();
      case 'timestamp':
        return '${currentMillis() ~/ 1000}';
      case 'randomImageUrl':
        return _faker.image.imageUrl();
      case 'randomAlphaNumeric':
        return _faker.random.alphaNumeric(1);
      // TODO: Implementar usando fakedart.
      case 'randomLocale':
      case 'randomUserAgent':
      case 'randomCreditCardMask':
      default:
        throw PostmanDynamicVariableNotImplementedYetException(name);
    }
  }
}

class VariableException implements Exception {}

class VariableNotFoundException implements VariableException {
  final String name;

  const VariableNotFoundException(this.name);
}

class VariableIsRecursiveException implements VariableException {
  final String name;
  const VariableIsRecursiveException(this.name);
}

class TagHasWrongParameterException implements VariableException {
  final String name;

  const TagHasWrongParameterException(this.name);
}

class TagCantBeResolvedException implements VariableException {
  final String name;
  final dynamic exception;

  const TagCantBeResolvedException(this.name, [this.exception]);
}

class PostmanDynamicVariableNotImplementedYetException
    implements VariableException {
  final String name;

  const PostmanDynamicVariableNotImplementedYetException(this.name);
}

// TODO: Mover para a classe de tratamento de exceções.
String obtainVariableExceptionMessage(
  I18n i18n,
  VariableException e,
) {
  if (e is VariableNotFoundException) {
    return i18n.variableCantBeFound(e.name);
  } else if (e is VariableIsRecursiveException) {
    return i18n.variableIsRecursive(e.name);
  } else if (e is TagHasWrongParameterException) {
    return i18n.tagHasWrongParameter(e.name);
  } else if (e is TagCantBeResolvedException) {
    return i18n.tagCantBeResolved(e.name);
  } else if (e is PostmanDynamicVariableNotImplementedYetException) {
    return i18n.postmanDynamicVariableNotImplementedYet(e.name);
  } else {
    return null;
  }
}
