import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_format.dart';
import 'package:mgt_life_spark/core/models/deck_style.dart';
import 'package:mgt_life_spark/core/models/player_deck.dart';
import 'package:mgt_life_spark/features/profile/profile_carousel_sections.dart';
import 'package:mgt_life_spark/ui/tokens/layout_tokens.dart';

void main() {
  group('profile carousel card layout math', () {
    final heavyDeck = PlayerDeck(
      id: '1',
      displayName: 'Cas',
      commanderName: 'Sonic the Hedgehog',
      partnerCommanderName: 'Partner',
      commanderManaCost: '{1}{U}{R}',
      partnerManaCost: '{W}',
      format: GameFormat.commander.name,
      deckStyleId: DeckStyle.sliver.id,
    );

    test('footer reserve leaves room for minimum art at canonical size', () {
      const w = LayoutTokens.profileCarouselCardWidth;
      const h = LayoutTokens.profileCarouselCardCanonicalHeight;
      final innerH = h - 2 * kProfileCarouselCardPaddingPx;
      final footer = profileDeckCardFooterReserveHeight(heavyDeck);
      final art = profileDeckCardArtHeight(
        w,
        h,
        deck: heavyDeck,
        hasPartner: true,
      );
      expect(footer + art, lessThanOrEqualTo(innerH + 1));
      expect(art, greaterThanOrEqualTo(72));
    });

    test('min card height covers scaled heavy footer', () {
      const ts = 1.25;
      final minH = profileDeckCardMinHeight(textScale: ts);
      final innerH = minH - 2 * kProfileCarouselCardPaddingPx;
      final footer =
          profileDeckCardFooterReserveHeight(heavyDeck, textScale: ts);
      expect(innerH, greaterThanOrEqualTo(footer + 72));
    });

    test('footer reserve is a fixed worst-case estimate', () {
      final light = PlayerDeck(
        id: '2',
        displayName: 'Std',
        commanderName: 'Bolt',
        format: GameFormat.standard.name,
        deckStyleId: DeckStyle.spellslinger.id,
      );
      // Reserve height does not vary by deck fields — it budgets the densest
      // footer layout so art can shrink safely for every deck.
      expect(
        profileDeckCardFooterReserveHeight(light),
        profileDeckCardFooterReserveHeight(heavyDeck),
      );
    });

    test('public size helper matches layout tokens', () {
      final size = profileCarouselCardSize();
      expect(size.width, LayoutTokens.profileCarouselCardWidth);
      expect(size.height, LayoutTokens.profileCarouselCardCanonicalHeight);
    });

    test('canonical height is 2:3 with card width on the 4dp grid', () {
      const w = LayoutTokens.profileCarouselCardWidth;
      const h = LayoutTokens.profileCarouselCardCanonicalHeight;
      expect(h, LayoutTokens.profileCarouselCardHeightForWidth(w));
      expect(w / h, closeTo(2 / 3, 0.001));
    });

    test('fixed canonical height holds heaviest deck at max text scale', () {
      const canonical = LayoutTokens.profileCarouselCardCanonicalHeight;
      const minArt = 72.0;
      for (final ts in <double>[1.0, 1.15, 1.35]) {
        final footer =
            profileDeckCardFooterReserveHeight(heavyDeck, textScale: ts);
        final innerH = canonical - 2 * kProfileCarouselCardPaddingPx;
        // Footer + a usable art band must fit the fixed card at every scale.
        expect(
          footer + minArt,
          lessThanOrEqualTo(innerH),
          reason: 'overflow at text scale $ts (footer $footer)',
        );
        // The min-height safety floor never exceeds the fixed canonical height,
        // so the card stays a single consistent size on all pages.
        expect(
          profileDeckCardMinHeight(textScale: ts),
          lessThanOrEqualTo(canonical),
        );
      }
    });
  });
}
