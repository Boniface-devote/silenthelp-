/// All phrases stored as "English|Swahili|Luganda" pipe-delimited strings.
class PhrasesData {
  static const Map<String, List<String>> phrases = {
    // ── Emergency ──────────────────────────────────────────────────────────
    'emergency': [
      'I need help immediately!|Ninahitaji msaada sasa hivi!|Neetaaga obuyamba mangu!',
      'I use Ugandan Sign Language (UgSL)|Mimi hutumia Lugha ya Ishara ya Uganda|Ntumya Ugandan Sign Language',
      'Please call emergency services|Tafadhali piga simu huduma za dharura|Yita abakonze emmeeza b\'obuyamba',
      'Please call my emergency contact|Tafadhali piga simu mgasailwa wangu wa dharura|Yita muntu wange omukungu omwegumbavu',
      'I cannot hear spoken words|Siwezi kusikia maneno yanayosemwa|Sisobola kwikiriza eddoboozi',
      'Please write down what you are saying|Tafadhali andika unachosema|Wandiika gye oyogera nkuwe',
      'I need an ambulance|Ninahitaji gari la wagonjwa|Neetaaga ambulansi',
    ],

    // ── Daily ──────────────────────────────────────────────────────────────
    'daily': [
      'Please write it down|Tafadhali andika|Wandiika nkuwe',
      'I use sign language|Mimi hutumia lugha ya ishara|Ntumya olulimi lw\'obubonero',
      'Can you repeat that?|Unaweza kurudia?|Osobola okuddamu?',
      'Thank you very much|Asante sana|Webale nyo',
      'Good morning!|Habari za asubuhi!|Wasuze otya!',
      'Yes, please|Ndiyo, tafadhali|Yee, nkuwe',
      'No, thank you|Hapana, asante|Nedda, webale',
      'Please speak slowly|Tafadhali ongea polepole|Nkuwe yogera mpola',
      'I do not understand|Sielewi|Sisobola okutegera',
      'Please face me when speaking|Tafadhali ngelie uso ukiongea|Nkoleera mu maaso go nga oyogera',
    ],

    // ── Medical ────────────────────────────────────────────────────────────
    'medical': [
      'I am in pain|Nina maumivu|Ndi mu bulumi',
      'I need my medication|Ninahitaji dawa zangu|Neetaaga eddagala lyange',
      'Where is the nearest hospital?|Hospitali ya karibu iko wapi?|Issubo ly\'okukira kiri wa?',
      'I am diabetic|Nina ugonjwa wa kisukari|Ndi ne sukali',
      'I have a heart condition|Nina ugonjwa wa moyo|Ndi ne bulwadde bw\'omutima',
      'I feel sick|Ninahisi vibaya|Ndi newala',
      'Please call a doctor|Tafadhali pigia simu daktari|Yita mudokita nkuwe',
      'I am allergic to this|Nina mzio wa hili|Omubiri gwange ogakkiriza kino',
      'I need a wheelchair|Ninahitaji kiti cha magurudumu|Neetaaga entebe y\'amagudumu',
    ],

    // ── Shopping ───────────────────────────────────────────────────────────
    'shopping': [
      'How much does this cost?|Hii inagharimu kiasi gani?|Eno esasula mmeka?',
      'I would like to buy this|Nataka kununua hii|Njagala okugula eno',
      'Do you have another size?|Je, una saizi nyingine?|Olina ensawo endala?',
      'Where is the checkout?|Mahali pa kulipwa iko wapi?|Kifo eky\'okusasula kiri wa?',
      'Can you help me find...?|Unaweza kunisaidia kutafuta...?|Oyinza okunsaasirira okunnwanira...?',
      'Thank you for your help|Asante kwa msaada wako|Webale ku buyambi bwo',
      'Can I pay by mobile money?|Ninaweza kulipa kwa pesa ya simu?|Nsobola okusasula ku sente z\'essimu?',
      'Do you have a receipt?|Je, una risiti?|Olina risiti?',
    ],

    // ── Office / Work ──────────────────────────────────────────────────────
    'office': [
      'May I speak with...?|Je, naweza kuzungumza na...?|Nsobola okuyanira na...?',
      'I have a meeting at...|Nina mkutano saa...|Ndi mu musomo ku saawa...',
      'Where is the meeting room?|Chumba cha mkutano kiko wapi?|Yaka y\'ommusomo kiri wa?',
      'Can you send me an email?|Unaweza kunipeleka barua pepe?|Oyinza okuntumira imeyile?',
      'I need technical support|Ninahitaji msaada wa teknolojia|Neetaaga obuyambi bwa tekinolojiya',
      'What time is the meeting?|Mkutano ni saa ngapi?|Ommusomo guli ku saawa meka?',
      'Where is the restroom?|Choo kiko wapi?|Enjaza kiri wa?',
      'Can I have the Wi-Fi password?|Ninaweza kupata nenosiri la Wi-Fi?|Nsobola okufuna password ya Wi-Fi?',
      'Can we reschedule?|Je, tunaweza kupanga upya?|Tusobola okukyusa amateeka?',
      'I communicate through writing|Ninawasiliana kwa maandishi|Nyanira bw\'okuwandiika',
    ],

    // ── Transport ──────────────────────────────────────────────────────────
    'transport': [
      'How much is the fare?|Bei ya nauli ni ngapi?|Okuyita kweba mmeka?',
      'Please drop me here|Tafadhali nishushe hapa|Nziika wano nkuwe',
      'I am Deaf, please write the price|Mimi ni bubu, andika bei tafadhali|Ndi mubu, wandiika emtengo nkuwe',
      'Is this going to Kampala?|Je, hii inaenda Kampala?|Eno eragira Kampala?',
      'Stop here please|Simama hapa tafadhali|Yimirira wano nkuwe',
      'How long until we arrive?|Tutafika lini?|Tujja kutuuka ddi?',
      'I need a receipt|Ninahitaji risiti|Neetaaga risiti',
      'Please be patient with me|Tafadhali nisubirie|Nkuwe nobeera na buziranfubbi nange',
    ],

    // ── Restaurant / Food ──────────────────────────────────────────────────
    'restaurant': [
      'I would like to order|Nataka kuagiza|Njagala okulonda',
      'Do you have a menu I can read?|Je, una menyu ninayoweza kusoma?|Olina menyu gye nsobola okusoma?',
      'What is in this dish?|Kuna nini katika chakula hiki?|Waliiko ki mu mmere eno?',
      'The bill, please|Bili tafadhali|Akaunti nkuwe',
      'No sugar please|Bila sukari tafadhali|Tosaako sukaali nkuwe',
      'This is delicious!|Hii ni ladha sana!|Eno ennungi nnyo!',
      'I am allergic to this|Nina mzio wa hili|Omubiri gwange ogakkiriza kino',
      'Can I have water please?|Ninaweza kupata maji tafadhali?|Nsobola okufuna amazzi nkuwe?',
    ],

    // ── Bank & Mobile Money ────────────────────────────────────────────────
    'bank': [
      'I need to withdraw money|Ninahitaji kutoa pesa|Neetaaga okuggya sente',
      'I want to send mobile money|Nataka kutuma pesa kwa simu|Njagala okutuma sente ku simu',
      'What is my balance?|Nini salio langu?|Ssente zange nzirina mmeka?',
      'Can you help me fill this form?|Unaweza kunisaidia kujaza fomu hii?|Oyinza okumpomagira okujjuza foomu eno?',
      'Is there a fee for this?|Kuna ada kwa hili?|Waliiko musolo ku kino?',
      'I need a receipt|Ninahitaji risiti|Neetaaga risiti',
      'I am Deaf, please write it down|Mimi ni bubu, tafadhali andika|Ndi mubu, wandiika nkuwe',
      'I need to open an account|Ninahitaji kufungua akaunti|Neetaaga okuzibula akaunti',
    ],

    // ── School ─────────────────────────────────────────────────────────────
    'school': [
      'I need to speak to a teacher|Ninahitaji kuzungumza na mwalimu|Neetaaga okutegeeza omutitisa',
      'My child is Deaf|Mtoto wangu ni bubu|Omwana wange mubu',
      'I need a sign language interpreter|Ninahitaji mtafsiri wa lugha ya ishara|Neetaaga omutafsiri w\'obulimi bw\'obubonero',
      'When is the parents meeting?|Mkutano wa wazazi ni lini?|Okukuŋŋaana kwa bazadde kuli ddi?',
      'Can I see the results?|Ninaweza kuona matokeo?|Nsobola okulaba byavvuunuka?',
      'Please face me when you speak|Tafadhali ningelie uso ukiongea|Nkoleera mu maaso go nga oyogera',
      'Please write that down|Tafadhali andika|Wandiika nkuwe',
      'I communicate through writing|Ninawasiliana kwa maandishi|Nyanira bw\'okuwandiika',
    ],

    // ── Police / Security ──────────────────────────────────────────────────
    'police': [
      'I am Deaf|Mimi ni bubu|Ndi mubu',
      'I need help|Ninahitaji msaada|Neetaaga obuyamba',
      'I want to report something|Nataka kuripoti kitu|Njagala okusumulula ekintu',
      'Please write down what you are saying|Tafadhali andika unachosema|Wandiika gye oyogera nkuwe',
      'I have not done anything wrong|Sijafanya kitu kibaya|Sikoze bubi na budde',
      'I need a lawyer|Ninahitaji wakili|Neetaaga omuvuzi',
      'Can I call someone?|Ninaweza kumpigia simu mtu?|Nsobola okuyitanga muntu?',
      'Please be patient with me|Tafadhali nisubirie|Nkuwe nobeera na buziranfubbi nange',
    ],
  };

  static String getPhrase(String category, String language, int index) {
    final key = category.toLowerCase();
    if (phrases.containsKey(key) && index < phrases[key]!.length) {
      final parts = phrases[key]![index].split('|');
      final langIndex = language == 'en' ? 0 : language == 'sw' ? 1 : 2;
      return langIndex < parts.length ? parts[langIndex] : parts[0];
    }
    return '';
  }

  /// Returns all three translations for a phrase.
  static ({String en, String sw, String lg}) getAllTranslations(
      String category, int index) {
    final key = category.toLowerCase();
    if (phrases.containsKey(key) && index < phrases[key]!.length) {
      final parts = phrases[key]![index].split('|');
      return (
        en: parts.isNotEmpty ? parts[0] : '',
        sw: parts.length > 1 ? parts[1] : '',
        lg: parts.length > 2 ? parts[2] : '',
      );
    }
    return (en: '', sw: '', lg: '');
  }
}
