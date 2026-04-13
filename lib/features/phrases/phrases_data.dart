class PhrasesData {
  static const Map<String, List<String>> phrases = {
    'emergency': [
      'I need help immediately!|Ninahitaji msaada sasa hivi!|Neetaaga obuyamba mangu!',
      'Call an ambulance please.|Piga simu ambulansi tafadhali.|Yita ambulensi, nkuwe.',
      'I am having a medical emergency.|Nina dharura ya kiafya.|Ndi mu nsonga y\'obulamu.',
      'Please call the police.|Tafadhali piga simu polisi.|Yita abapoliisi, nkuwe.',
      'I am deaf — please help me.|Mimi ni bubu — tafadhali nisaidie.|Nsimu — nkuyambe nkuwe.',
    ],
    'daily': [
      'Good morning!|Habari za asubuhi!|Wasuze otya!',
      'Thank you very much.|Asante sana.|Webale nyo.',
      'I am deaf.|Mimi ni bubu.|Nsimu.',
      'Please write it down.|Tafadhali andika.|Wandiika, nkuwe.',
      'Can you repeat that?|Unaweza kurudia?|Osobola okuddamu?',
      'Yes, please.|Ndiyo, tafadhali.|Yee, nkuwe.',
      'No, thank you.|Hapana, asante.|Nedda, webale.',
    ],
    'medical': [
      'I am in pain.|Nina maumivu.|Ndi mu bulumi.',
      'I need my medication.|Ninahitaji dawa zangu.|Neetaaga eddagala lyange.',
      'I am diabetic.|Nina ugonjwa wa kisukari.|Ndi ne sukari.',
      'I feel dizzy.|Ninahisi kizunguzungu.|Ndi ne kizunguzungu.',
      'I have a heart condition.|Nina ugonjwa wa moyo.|Ndi ne bulwadde bw\'omutima.',
    ],
    'shopping': [
      'How much does this cost?|Hii inagharimu kiasi gani?|Eno esasula mmeka?',
      'I would like to buy this.|Nataka kununua hii.|Njagala okugula eno.',
      'Do you have another size?|Je, una saizi nyingine?|Olina ensawo endala?',
      'Where is the cashier?|Kasha la malipo liko wapi?|Ekifo eky\'okusasula kiri wa?',
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
