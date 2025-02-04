import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_api/spotify_api.dart';

void main() {
  test('Nevermind', () async {
    SpotifyAlbum album = await searchAlbum('Nevermind');
    expect(album.found, true);
    if(album.id == '2uEf3r9i2bnxwJQsxQ0xQ7') {
      expect(album.tracks.length, 40);
      expect(album.artists, 'Nirvana');
      expect(album.title, 'Nevermind (Deluxe Edition)');
    }
  });
  test('GLMPS Test Found False', () async {
    expect((await searchAlbum('GLMPS Test Found False')).found, false);
  });
}
