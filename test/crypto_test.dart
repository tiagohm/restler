import 'package:flutter_test/flutter_test.dart';
import 'package:restler/crypto.dart';

void main() {
  test('Pad', () {
    expect(pad('12345678').length, 32);
    expect(pad('12345678123456781234567812345678').length, 32);
    expect(pad('tgry5ytyytu6j44f').length, 32);
  });

  test('Decrypt', () {
    expect(
      decrypt(
        'gAAAAABd0VJcHAAfGgkIGgsHCQAVGQYCEQuZAAtLZ5i1HH1ylPuoWGYfLA55DRCohD/YV82o9zQD7CloqkWozuoRM02r2pJSmg==',
        '1234567812345678',
      ),
      'tiago',
    );
    expect(
      decrypt(
        'gAAAAABd0VJcHAAfGgkIGgsHCQAVGQYCEQuZAAtLZ5i1HH1ylPuoWGYfLA55DRCohD/YV82o9zQD7CloqkWozuoRM02r2pJSmg==',
        '1234567812345679',
      ),
      null,
    );
  });

  test('Encrypt & Decrypt', () {
    final encoded = encrypt('tiago', '1234567812345678');

    print(encoded);

    final text = decrypt(encoded, '1234567812345678');

    expect(text, 'tiago');
  });
}
