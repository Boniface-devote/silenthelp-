import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyState {
  final Position? currentPosition;
  final bool isSendingSos;
  final bool sosSent;

  EmergencyState({
    this.currentPosition,
    this.isSendingSos = false,
    this.sosSent = false,
  });

  EmergencyState copyWith({
    Position? currentPosition,
    bool? isSendingSos,
    bool? sosSent,
  }) {
    return EmergencyState(
      currentPosition: currentPosition ?? this.currentPosition,
      isSendingSos: isSendingSos ?? this.isSendingSos,
      sosSent: sosSent ?? this.sosSent,
    );
  }
}

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  EmergencyNotifier() : super(EmergencyState());

  void setPosition(Position? position) {
    state = state.copyWith(currentPosition: position);
  }

  void setSendingSos(bool sending) {
    state = state.copyWith(isSendingSos: sending);
  }

  void setSosSent(bool sent) {
    state = state.copyWith(sosSent: sent);
  }

  void reset() {
    state = EmergencyState();
  }
}

final emergencyProvider = StateNotifierProvider<EmergencyNotifier, EmergencyState>(
  (ref) => EmergencyNotifier(),
);
