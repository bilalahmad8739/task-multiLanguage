class VoiceModel {
  final String name;
  final String locale;
  final Map<String, dynamic> rawData;

  VoiceModel({required this.name, required this.locale, required this.rawData});

  factory VoiceModel.fromMap(Map<String, dynamic> map) {
    return VoiceModel(
      name: map['name'] ?? '',
      locale: map['locale'] ?? '',
      rawData: map,
    );
  }
}
