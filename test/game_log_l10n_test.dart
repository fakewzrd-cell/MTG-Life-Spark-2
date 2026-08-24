import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/l10n/app_localizations_en.dart';
import 'package:mgt_life_spark/l10n/app_localizations_es.dart';
import 'package:mgt_life_spark/shared/utils/game_log_l10n.dart';

void main() {
  final en = AppLocalizationsEn();
  final es = AppLocalizationsEs();

  test('localizes life and commander damage lines', () {
    expect(
      localizeGameLogMessage(en, 'Alice: Life -3'),
      'Alice: Life -3',
    );
    expect(
      localizeGameLogMessage(es, 'Alice: Life -3'),
      'Alice: Vida -3',
    );
    expect(
      localizeGameLogMessage(es, 'Bob dealt you +2 commander damage'),
      'Bob te hizo +2 de daño de comandante',
    );
  });

  test('localizes table-tool and stack lines', () {
    expect(
      localizeGameLogMessage(es, 'Carol rolled a 6'),
      'Carol sacó un 6',
    );
    expect(
      localizeGameLogMessage(es, 'Dan flipped Heads'),
      'Dan sacó Cara',
    );
    expect(
      localizeGameLogMessage(es, 'Cleared stack'),
      'Pila vaciada',
    );
  });

  test('passes through unknown messages', () {
    expect(
      localizeGameLogMessage(es, 'Custom event xyz'),
      'Custom event xyz',
    );
  });
}
