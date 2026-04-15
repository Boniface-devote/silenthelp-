class PhrasesData {
  static const Map<String, List<String>> phrases = {
    'emergency': [
      'I need help immediately!|Ninahitaji msaada sasa hivi!|Neetaaga obuyamba mangu!',
      'I use Ugandan Sign Language|Mimi hutumia Luganda Sign Language|Ntumya Ugandan Sign Language',
      'Please call 911 or emergency services|Tafadhali piga simu 911|Yita 911 oba abakonze emmeeza',
      'Please call my emergency contact|Tafadhali piga simu mgasalwa yangu wa dharura|Yita muntu wange omukungu omwegumbavu',
      'I may not hear spoken words|Yangu kumakingi zaidi ya sauti|Sisobola kwikiriza sauti',
    ],
    'daily': [
      'Please write it down|Tafadhali andika|Wandiika, nkuwe',
      'I use sign language|Mimi hutumia lugha ya ishara|Ntumya lugha y\'obubonero',
      'Can you repeat that?|Unaweza kurudia?|Osobola okuddamu?',
      'Thank you very much|Asante sana|Webale nyo',
      'Good morning!|Habari za asubuhi!|Wasuze otya!',
      'Yes, please|Ndiyo, tafadhali|Yee, nkuwe',
      'No, thank you|Hapana, asante|Nedda, webale',
    ],
    'medical': [
      'I am in pain|Nina maumivu|Ndi mu bulumi',
      'I need my medication|Ninahitaji dawa zangu|Neetaaga eddagala lyange',
      'Where is the nearest hospital?|Hospitali ya karibu iko wapi?|Issubo ly\'okukira kiri wa?',
      'I am diabetic|Nina ugonjwa wa kisukari|Ndi ne sukari',
      'I have a heart condition|Nina ugonjwa wa moyo|Ndi ne bulwadde bw\'omutima',
      'I feel sick|Ninahisi vibaya|Ndi newala',
      'Please call a doctor|Tafadhali pigia simu daktari|Yita mudoctor, nkuwe',
    ],
    'shopping': [
      'How much does this cost?|Hii inagharimu kiasi gani?|Eno esasula mmeka?',
      'I would like to buy this|Nataka kununua hii|Njagala okugula eno',
      'Do you have another size?|Je, una saizi nyingine?|Olina ensawo endala?',
      'Where is the checkout?|Mahali pa kulipwa iko wapi?|Kifo eky\'okusasula kiri wa?',
      'Can you help me find...?|Unaweza kunisaidia kutafuta...?|Oyinza okunsobola okunnsoboza...?',
      'Thank you for your help|Asante kwa msaada wako|Webale ku buyambi bwo',
    ],
  };

  static String getPhrase(String category, String language, int index) {
    final key = category.toLowerCase();
    if (phrases.containsKey(key) && index < phrases[key]!.length) {
      final phrases_ = phrases[key]![index].split('|');
      final langIndex = language == 'en' ? 0 : language == 'sw' ? 1 : 2;
      return phrases_[langIndex];
    }
    return '';
  }
}
