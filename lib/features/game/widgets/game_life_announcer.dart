import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_session_events.dart';

/// Coalesces rapid local life changes into a single screen-reader update.
class GameLifeAnnouncer extends ConsumerStatefulWidget {
  const GameLifeAnnouncer({super.key, required this.enabled});

  final bool enabled;

  @override
  ConsumerState<GameLifeAnnouncer> createState() => _GameLifeAnnouncerState();
}

class _GameLifeAnnouncerState extends ConsumerState<GameLifeAnnouncer> {
  static const _localDebounce = Duration(milliseconds: 600);
  static const _clearDelay = Duration(seconds: 3);

  Timer? _debounceTimer;
  Timer? _clearTimer;
  String? _label;
  int _generation = 0;

  @override
  void didUpdateWidget(GameLifeAnnouncer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _debounceTimer?.cancel();
      _clearTimer?.cancel();
      _generation++;
      _label = null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _clearTimer?.cancel();
    super.dispose();
  }

  void _handle(LifeChangeAnnouncement? event) {
    if (event == null || !widget.enabled) return;
    if (event.source == LifeChangeSource.local) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        _localDebounce,
        () => _show('${event.total} life'),
      );
      return;
    }

    _debounceTimer?.cancel();
    final direction = event.delta >= 0 ? 'plus' : 'minus';
    final actor = event.actorUsername;
    final prefix = actor == null || actor.isEmpty
        ? 'Your life changed'
        : '$actor changed your life';
    _show('$prefix $direction ${event.delta.abs()}, ${event.total} life');
  }

  void _show(String message) {
    if (!mounted || !widget.enabled) return;
    _clearTimer?.cancel();
    final generation = ++_generation;

    void publish() {
      if (!mounted || !widget.enabled || generation != _generation) return;
      setState(() => _label = message);
      _clearTimer = Timer(_clearDelay, () {
        if (mounted && generation == _generation) {
          setState(() => _label = null);
        }
      });
    }

    if (_label == null || _label != message) {
      publish();
      return;
    }

    setState(() => _label = null);
    WidgetsBinding.instance.addPostFrameCallback((_) => publish());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LifeChangeAnnouncement?>(localLifeChangeProvider, (_, next) {
      _handle(next);
    });

    return Semantics(
      container: true,
      liveRegion: _label != null,
      label: _label,
      child: const SizedBox(width: 1, height: 1),
    );
  }
}
