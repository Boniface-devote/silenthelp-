import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/sign_video_player.dart';
import '../../shared/providers/locale_provider.dart';

// ════════════════════════════════════════════════════════════════════════════
// Data models
// ════════════════════════════════════════════════════════════════════════════

class _LearnCategory {
  final String key;
  final String enLabel;
  final String swLabel;
  final String lgLabel;
  final IconData icon;
  final Color color;

  const _LearnCategory({
    required this.key,
    required this.enLabel,
    required this.swLabel,
    required this.lgLabel,
    required this.icon,
    required this.color,
  });

  String labelFor(String lang) {
    if (lang == 'sw') return swLabel;
    if (lang == 'lg') return lgLabel;
    return enLabel;
  }
}

class Sign {
  final String category;
  final String enTitle;
  final String swTitle;
  final String lgTitle;
  final String enDescription;
  final List<String> steps;
  final String? videoPath; // null → coming soon
  final String difficulty;  // 'beginner' | 'intermediate' | 'advanced'

  const Sign({
    required this.category,
    required this.enTitle,
    required this.swTitle,
    required this.lgTitle,
    required this.enDescription,
    required this.steps,
    this.videoPath,
    this.difficulty = 'beginner',
  });

  bool get hasVideo => videoPath != null;

  String titleFor(String lang) {
    if (lang == 'sw') return swTitle;
    if (lang == 'lg') return lgTitle;
    return enTitle;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Static data
// ════════════════════════════════════════════════════════════════════════════

const _categories = <_LearnCategory>[
  _LearnCategory(key: 'all',           enLabel: 'All',           swLabel: 'Zote',            lgLabel: 'Byonna',         icon: Icons.grid_view_rounded,             color: AppColors.purple),
  _LearnCategory(key: 'basics',        enLabel: 'Basics',        swLabel: 'Misingi',         lgLabel: 'Entandikwa',     icon: Icons.waving_hand_rounded,           color: AppColors.teal),
  _LearnCategory(key: 'emergency',     enLabel: 'Emergency',     swLabel: 'Dharura',         lgLabel: 'Obuyamba',       icon: Icons.emergency_rounded,             color: AppColors.red),
  _LearnCategory(key: 'introductions', enLabel: 'Introductions', swLabel: 'Utambulisho',     lgLabel: 'Okwebuuza',      icon: Icons.person_rounded,                color: AppColors.blue),
  _LearnCategory(key: 'numbers',       enLabel: 'Numbers',       swLabel: 'Nambari',         lgLabel: 'Ennamba',        icon: Icons.tag_rounded,                   color: Color(0xFFFF8C42)),
  _LearnCategory(key: 'feelings',      enLabel: 'Feelings',      swLabel: 'Hisia',           lgLabel: 'Empewo',         icon: Icons.sentiment_satisfied_rounded,   color: Color(0xFF9C6AFF)),
  _LearnCategory(key: 'daily',         enLabel: 'Daily Life',    swLabel: 'Maisha ya Kila Siku', lgLabel: 'Obulamu',    icon: Icons.wb_sunny_rounded,              color: Color(0xFF4CAF50)),
];

const _signs = <Sign>[

  // ── Basics ──────────────────────────────────────────────────────────────

  Sign(
    category: 'basics', enTitle: 'Hello', swTitle: 'Hujambo', lgTitle: 'Nkusanyukidde',
    enDescription: 'A friendly greeting wave used every day.',
    steps: ['Open your right hand with the palm facing outward.', 'Raise your hand to face level.', 'Wave your hand gently from side to side 2–3 times.'],
    videoPath: 'assets/videos/hello.mp4',
  ),
  Sign(
    category: 'basics', enTitle: 'Thank you', swTitle: 'Asante', lgTitle: 'Webale',
    enDescription: 'Express gratitude with an outward chin movement.',
    steps: ['Place your open right hand fingers on your chin.', 'Move your hand outward away from your chin.', 'Smile to reinforce the meaning.'],
    videoPath: 'assets/videos/thank_you.mp4',
  ),
  Sign(
    category: 'basics', enTitle: 'Goodbye', swTitle: 'Kwaheri', lgTitle: 'Weraba',
    enDescription: 'Farewell sign — similar to hello but with a downward motion.',
    steps: ['Open your right hand with the palm facing the other person.', 'Raise it briefly at face level.', 'Gently wave once and lower your arm.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'basics', enTitle: 'Please', swTitle: 'Tafadhali', lgTitle: 'Nkuwe',
    enDescription: 'A polite request sign made at the chest.',
    steps: ['Place your open right hand flat on your chest.', 'Move your hand in a small circular motion clockwise.', 'Use a gentle, soft expression.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'basics', enTitle: 'Sorry', swTitle: 'Samahani', lgTitle: 'Mbeera',
    enDescription: 'Apologise with a circular fist motion on the chest.',
    steps: ['Make a fist with your right hand.', 'Place it on your chest over your heart.', 'Move it in a slow clockwise circle 2 times.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'basics', enTitle: 'Yes', swTitle: 'Ndiyo', lgTitle: 'Yee',
    enDescription: 'Affirmation — a nodding fist.',
    steps: ['Make a fist with your right hand, thumb pointing up.', 'Move your fist up and down like a nodding head.', 'Nod your head at the same time.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'basics', enTitle: 'No', swTitle: 'Hapana', lgTitle: 'Nedda',
    enDescription: 'Negation — a side-to-side shake.',
    steps: ['Extend your index and middle fingers straight out.', 'Tap them together twice rapidly.', 'Shake your head left-to-right at the same time.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'basics', enTitle: 'Good morning', swTitle: 'Habari za asubuhi', lgTitle: 'Wasuze otya',
    enDescription: 'A bright two-handed morning greeting.',
    steps: ['Hold both hands at chest level, palms facing up.', 'Raise both hands upward and outward as if revealing the sun.', 'Smile broadly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'basics', enTitle: 'Good night', swTitle: 'Lala salama', lgTitle: 'Sula bulungi',
    enDescription: 'A calm farewell for the end of the day.',
    steps: ['Place both palms together beside your tilted head.', 'Close your eyes briefly to mimic sleeping.', 'Slowly lower your hands.'],
    difficulty: 'beginner',
  ),

  // ── Emergency ───────────────────────────────────────────────────────────

  Sign(
    category: 'emergency', enTitle: 'Help', swTitle: 'Msaada', lgTitle: 'Obuyamba',
    enDescription: 'Urgently call for assistance.',
    steps: ['Place your dominant hand flat with thumb up on top of your non-dominant hand.', 'Push both hands upward together as if lifting someone.', 'Repeat 2–3 times with urgency.'],
    videoPath: 'assets/videos/help.mp4',
  ),
  Sign(
    category: 'emergency', enTitle: 'I am Deaf', swTitle: 'Mimi ni bubu', lgTitle: 'Nsimu',
    enDescription: 'Identify yourself as a Deaf person.',
    steps: ['Point your index finger to your ear.', 'Shake your head slightly to indicate "cannot hear".', 'Then point to yourself with your thumb.'],
    videoPath: 'assets/videos/i_am_deaf.mp4',
  ),
  Sign(
    category: 'emergency', enTitle: 'Emergency', swTitle: 'Dharura', lgTitle: 'Obuyamba mangu',
    enDescription: 'Signal an urgent situation.',
    steps: ['Make both hands into fists.', 'Cross your wrists in front of your chest.', 'Shake both fists rapidly to show urgency.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'emergency', enTitle: 'Stop / Danger', swTitle: 'Simama / Hatari', lgTitle: 'Yimirira',
    enDescription: 'Signal someone to stop or warn of danger.',
    steps: ['Raise your right hand with the palm facing outward.', 'Hold it firm and still at shoulder height.', 'For danger, add a two-handed crossed arms motion.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'emergency', enTitle: 'Call police', swTitle: 'Piga simu polisi', lgTitle: 'Yita abapoliisi',
    enDescription: 'Ask someone to contact law enforcement.',
    steps: ['Mime holding a phone to your ear.', 'Spell out "P" with your dominant hand.', 'Point outward to indicate "go call them".'],
    difficulty: 'intermediate',
  ),
  Sign(
    category: 'emergency', enTitle: 'Call ambulance', swTitle: 'Piga simu gari la wagonjwa', lgTitle: 'Yita ambulansi',
    enDescription: 'Request medical emergency transport.',
    steps: ['Mime holding a phone to your ear.', 'Then make a cross shape with both index fingers (medical symbol).', 'Point urgently away to indicate "go now".'],
    difficulty: 'intermediate',
  ),
  Sign(
    category: 'emergency', enTitle: 'I need a doctor', swTitle: 'Ninahitaji daktari', lgTitle: 'Neetaaga omudokita',
    enDescription: 'Ask for medical assistance.',
    steps: ['Point to yourself with your index finger.', 'Cross both index fingers to form a medical cross on your chest.', 'Then point outward.'],
    difficulty: 'intermediate',
  ),

  // ── Introductions ───────────────────────────────────────────────────────

  Sign(
    category: 'introductions', enTitle: 'My name is...', swTitle: 'Jina langu ni...', lgTitle: 'Erinnya lyange...',
    enDescription: 'Introduce yourself to someone new.',
    steps: ['Point to yourself with both index fingers simultaneously.', 'Tap the index and middle fingers of both hands together twice (the "name" sign).', 'Then fingerspell or point to yourself again.'],
    videoPath: 'assets/videos/my_name_is.mp4',
  ),
  Sign(
    category: 'introductions', enTitle: 'I am from...', swTitle: 'Ninatoka...', lgTitle: 'Ova...',
    enDescription: 'Tell someone where you come from.',
    steps: ['Point to yourself first.', 'Then bring both hands together in front of your chest, palms facing each other.', 'Move them outward to indicate "coming from" a place.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'introductions', enTitle: 'Nice to meet you', swTitle: 'Nafurahi kukutana nawe', lgTitle: 'Nasanyuse okukumanya',
    enDescription: 'Express pleasure at a new meeting.',
    steps: ['Shake hands in the standard greeting handshake.', 'Then place your right hand on your chest and smile.', 'Indicate the other person by pointing gently.'],
    difficulty: 'intermediate',
  ),
  Sign(
    category: 'introductions', enTitle: 'How are you?', swTitle: 'Habari yako?', lgTitle: 'Oli otya?',
    enDescription: 'Ask about someone\'s wellbeing.',
    steps: ['Point to the other person with your index finger.', 'Then make a thumbs-up and raise your eyebrows questioningly.', 'Tilt your head slightly to show it is a question.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'introductions', enTitle: 'I am fine', swTitle: 'Mimi niko sawa', lgTitle: 'Ndi bulungi',
    enDescription: 'Respond positively to a greeting.',
    steps: ['Give a firm thumbs up with your dominant hand.', 'Nod your head and smile.', 'Point to yourself to confirm you are the subject.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'introductions', enTitle: 'I don\'t understand', swTitle: 'Sielewi', lgTitle: 'Sitegera',
    enDescription: 'Indicate confusion or the need for clarification.',
    steps: ['Shake your head slowly from side to side.', 'Bring your index finger to your temple and wave it slightly.', 'Raise your eyebrows and look confused.'],
    difficulty: 'intermediate',
  ),

  // ── Numbers ─────────────────────────────────────────────────────────────

  Sign(
    category: 'numbers', enTitle: 'One (1)', swTitle: 'Moja (1)', lgTitle: 'Emu (1)',
    enDescription: 'Show the number one.',
    steps: ['Hold up your index finger on your dominant hand.', 'Keep all other fingers folded down.', 'Hold briefly to display the number.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'numbers', enTitle: 'Two (2)', swTitle: 'Mbili (2)', lgTitle: 'Bbiri (2)',
    enDescription: 'Show the number two.',
    steps: ['Hold up your index finger and middle finger on your dominant hand.', 'Spread them slightly apart in a V-shape.', 'Hold briefly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'numbers', enTitle: 'Three (3)', swTitle: 'Tatu (3)', lgTitle: 'Ssatu (3)',
    enDescription: 'Show the number three.',
    steps: ['Hold up your index finger, middle finger, and ring finger.', 'Keep the thumb and little finger folded.', 'Hold briefly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'numbers', enTitle: 'Four (4)', swTitle: 'Nne (4)', lgTitle: 'Nnya (4)',
    enDescription: 'Show the number four.',
    steps: ['Hold up all four fingers (index to little finger) spread apart.', 'Keep your thumb tucked against your palm.', 'Hold briefly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'numbers', enTitle: 'Five (5)', swTitle: 'Tano (5)', lgTitle: 'Ttaano (5)',
    enDescription: 'Show the number five.',
    steps: ['Open your entire hand with all five fingers spread wide.', 'Hold your palm facing the other person.', 'Hold briefly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'numbers', enTitle: 'Six (6)', swTitle: 'Sita (6)', lgTitle: 'Mukaaga (6)',
    enDescription: 'Show the number six.',
    steps: ['Hold out your pinky finger and thumb, folding the middle three fingers (hang loose sign).', 'In UgSL context, you may also show 5 then 1.', 'Hold briefly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'numbers', enTitle: 'Seven (7)', swTitle: 'Saba (7)', lgTitle: 'Musanvu (7)',
    enDescription: 'Show the number seven.',
    steps: ['Hold up your thumb, index, and middle fingers extended.', 'Keep the ring and little fingers folded.', 'Hold briefly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'numbers', enTitle: 'Eight (8)', swTitle: 'Nane (8)', lgTitle: 'Munaana (8)',
    enDescription: 'Show the number eight.',
    steps: ['Hold up your thumb, index, middle, and ring fingers extended.', 'Keep only the little finger folded.', 'Hold briefly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'numbers', enTitle: 'Nine (9)', swTitle: 'Tisa (9)', lgTitle: 'Mwenda (9)',
    enDescription: 'Show the number nine.',
    steps: ['Hold up all fingers and the thumb of your dominant hand.', 'Bend only the index finger down to the thumb.', 'Hold briefly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'numbers', enTitle: 'Ten (10)', swTitle: 'Kumi (10)', lgTitle: 'Kkumi (10)',
    enDescription: 'Show the number ten.',
    steps: ['Hold up both fists side by side.', 'Extend both thumbs upward.', 'Alternatively, show the open hand (5) and then do a quick twist.'],
    difficulty: 'beginner',
  ),

  // ── Feelings ────────────────────────────────────────────────────────────

  Sign(
    category: 'feelings', enTitle: 'Happy', swTitle: 'Furaha', lgTitle: 'Essanyu',
    enDescription: 'Express joy or happiness.',
    steps: ['Place both open hands flat on your chest.', 'Move them upward and outward in a brushing motion twice.', 'Smile to reinforce the sign.'],
    difficulty: 'intermediate',
  ),
  Sign(
    category: 'feelings', enTitle: 'Sad', swTitle: 'Huzuni', lgTitle: 'Obuzibu',
    enDescription: 'Show sadness or sorrow.',
    steps: ['Hold both open hands in front of your face, fingers pointing upward.', 'Slowly drag both hands downward past your face.', 'Drop your expression to look sad.'],
    difficulty: 'intermediate',
  ),
  Sign(
    category: 'feelings', enTitle: 'Pain / Hurt', swTitle: 'Maumivu', lgTitle: 'Bulumi',
    enDescription: 'Indicate physical or emotional pain.',
    steps: ['Point both index fingers toward each other without touching.', 'Twist them toward each other in a small repeated motion.', 'Touch the area that hurts if possible.'],
    difficulty: 'intermediate',
  ),
  Sign(
    category: 'feelings', enTitle: 'Tired', swTitle: 'Uchovu', lgTitle: 'Obukoowu',
    enDescription: 'Show that you are fatigued.',
    steps: ['Hold both bent hands up at shoulder level, elbows close to body.', 'Let them drop forward and down heavily, like limbs going limp.', 'Slouch your shoulders slightly.'],
    difficulty: 'intermediate',
  ),
  Sign(
    category: 'feelings', enTitle: 'Hungry', swTitle: 'Njaa', lgTitle: 'Enjala',
    enDescription: 'Signal that you need food.',
    steps: ['Make a "C" shape with your dominant hand.', 'Place it at your throat and slide it downward to your stomach.', 'Repeat the downward movement twice.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'feelings', enTitle: 'Angry', swTitle: 'Hasira', lgTitle: 'Obunyigu',
    enDescription: 'Express anger or frustration.',
    steps: ['Hold both bent (claw-shaped) hands in front of your face.', 'Move them away from your face in a tense, pulling motion.', 'Tighten your jaw and furrow your brow.'],
    difficulty: 'intermediate',
  ),
  Sign(
    category: 'feelings', enTitle: 'Scared', swTitle: 'Woga', lgTitle: 'Entiisa',
    enDescription: 'Show fear or fright.',
    steps: ['Hold both open hands, one on each side of your chest.', 'Quickly cross them over your chest in a startled motion.', 'Open your eyes wide and draw back slightly.'],
    difficulty: 'intermediate',
  ),

  // ── Daily Life ───────────────────────────────────────────────────────────

  Sign(
    category: 'daily', enTitle: 'Eat / Food', swTitle: 'Kula / Chakula', lgTitle: 'Kulya / Emmere',
    enDescription: 'Indicate the action of eating or the concept of food.',
    steps: ['Bring the fingertips of your dominant hand together (as if pinching food).', 'Move them repeatedly toward your mouth.', 'Mime the chewing motion with your jaw.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'daily', enTitle: 'Drink / Water', swTitle: 'Kunywa / Maji', lgTitle: 'Kunywa / Amazzi',
    enDescription: 'Signal drinking or the need for water.',
    steps: ['Make a "C" shape with your dominant hand like holding a cup.', 'Tilt it toward your mouth as if drinking.', 'Tip your head back slightly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'daily', enTitle: 'Sleep', swTitle: 'Kulala', lgTitle: 'Okutuula',
    enDescription: 'Indicate rest or sleep.',
    steps: ['Place both palms together beside your cheek.', 'Tilt your head onto your "pillow" hands.', 'Close your eyes briefly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'daily', enTitle: 'Go / Walk', swTitle: 'Kwenda', lgTitle: 'Okugenda',
    enDescription: 'Indicate movement or walking.',
    steps: ['Hold both hands in front, index and middle fingers pointing down like legs.', 'Alternate moving each hand forward in a walking rhythm.', 'Point in the direction you mean.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'daily', enTitle: 'Come', swTitle: 'Kuja', lgTitle: 'Okujja',
    enDescription: 'Beckon someone toward you.',
    steps: ['Hold one or both hands out in front, palms facing up.', 'Curl your fingers toward yourself repeatedly.', 'Make eye contact with the person you are gesturing to.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'daily', enTitle: 'Stop', swTitle: 'Simama', lgTitle: 'Yimirira',
    enDescription: 'Signal someone or something to stop.',
    steps: ['Hold your non-dominant hand open with the palm facing up.', 'Bring your dominant hand down onto the non-dominant palm firmly.', 'Hold it there briefly.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'daily', enTitle: 'Home', swTitle: 'Nyumbani', lgTitle: 'Awaka',
    enDescription: 'Reference a house or home.',
    steps: ['Touch your fingertips and thumbs together to form a rooftop shape above your head.', 'Then lower both hands to form the walls of the house.', 'Optionally point in the direction of home.'],
    difficulty: 'beginner',
  ),
  Sign(
    category: 'daily', enTitle: 'Work / School', swTitle: 'Kazi / Shule', lgTitle: 'Omulimu / Essomero',
    enDescription: 'Reference a workplace or school.',
    steps: ['Make two fists.', 'Tap your dominant fist on your non-dominant fist twice.', 'For "school", clap your hands twice instead.'],
    difficulty: 'intermediate',
  ),
];

// ════════════════════════════════════════════════════════════════════════════
// Screen
// ════════════════════════════════════════════════════════════════════════════

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  String _selectedCategory = 'all';

  List<Sign> get _filteredSigns => _selectedCategory == 'all'
      ? _signs
      : _signs.where((s) => s.category == _selectedCategory).toList();

  _LearnCategory get _activeCategory =>
      _categories.firstWhere((c) => c.key == _selectedCategory);

  Color _difficultyColor(String d) {
    if (d == 'intermediate') return AppColors.yellow;
    if (d == 'advanced') return AppColors.red;
    return AppColors.teal;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeProvider).languageCode;
    final filtered = _filteredSigns;
    final active = _activeCategory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildCategoryBar(context, language),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSectionHeader(context, active, filtered.length, language);
                }
                return _buildSignCard(context, filtered[index - 1], language);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 20.w,
      title: Row(
        children: [
          Text(context.tr('learn_title'), style: AppTextStyles.heading2),
          SizedBox(width: 10.w),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              context.tr('learn_badge'),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category chip bar ─────────────────────────────────────────────────────

  Widget _buildCategoryBar(BuildContext context, String language) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: _categories.map((cat) {
            final isActive = cat.key == _selectedCategory;
            final count = cat.key == 'all'
                ? _signs.length
                : _signs.where((s) => s.category == cat.key).length;

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? cat.color
                      : cat.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isActive
                        ? cat.color
                        : cat.color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon,
                        size: 14.sp,
                        color: isActive
                            ? AppColors.background
                            : cat.color),
                    SizedBox(width: 5.w),
                    Text(
                      cat.labelFor(language),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isActive
                            ? AppColors.background
                            : cat.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 5.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.background
                                .withValues(alpha: 0.25)
                            : cat.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '$count',
                        style: AppTextStyles.caption.copyWith(
                          color: isActive
                              ? AppColors.background
                              : cat.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context, _LearnCategory cat,
      int count, String language) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(cat.icon, color: cat.color, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.labelFor(language).toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$count signs',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sign card ─────────────────────────────────────────────────────────────

  Widget _buildSignCard(BuildContext context, Sign sign, String language) {
    final cat =
        _categories.firstWhere((c) => c.key == sign.category,
            orElse: () => _categories.first);

    return GestureDetector(
      onTap: () => _showSignDetail(context, sign, language),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.sign_language_rounded,
                  color: cat.color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),

              // Title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sign.titleFor(language),
                      style: AppTextStyles.labelLarge,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        // Difficulty badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _difficultyColor(sign.difficulty)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            sign.difficulty[0].toUpperCase() +
                                sign.difficulty.substring(1),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: _difficultyColor(sign.difficulty),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        // Video status
                        if (sign.hasVideo)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam_rounded,
                                  color: AppColors.teal, size: 11.sp),
                              SizedBox(width: 3.w),
                              Text(
                                'Video',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_rounded,
                                  color: AppColors.textMuted,
                                  size: 11.sp),
                              SizedBox(width: 3.w),
                              Text(
                                'Coming soon',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Play / Info button
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  sign.hasVideo
                      ? Icons.play_arrow_rounded
                      : Icons.info_outline_rounded,
                  color: cat.color,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sign detail bottom sheet ───────────────────────────────────────────────

  void _showSignDetail(
      BuildContext context, Sign sign, String language) {
    final cat = _categories.firstWhere((c) => c.key == sign.category,
        orElse: () => _categories.first);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: EdgeInsets.fromLTRB(
                      20.w, 4.h, 20.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: cat.color
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(12.r),
                            ),
                            child: Icon(Icons.sign_language_rounded,
                                color: cat.color, size: 22.sp),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sign.titleFor(language),
                                  style: AppTextStyles.heading2,
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: cat.color
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        cat.labelFor(language),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: cat.color,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: _difficultyColor(
                                                sign.difficulty)
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        sign.difficulty[0]
                                                .toUpperCase() +
                                            sign.difficulty.substring(1),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: _difficultyColor(
                                              sign.difficulty),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Video area
                      sign.hasVideo
                          ? SignVideoPlayer(
                              videoAssetPath: sign.videoPath!)
                          : _buildComingSoon(cat.color),

                      SizedBox(height: 20.h),

                      // Description
                      Text(
                        'About this sign',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        sign.enDescription,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Step-by-step instructions
                      Text(
                        'How to perform',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ...List<Widget>.generate(sign.steps.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24.w,
                                height: 24.w,
                                margin:
                                    EdgeInsets.only(right: 10.w),
                                decoration: BoxDecoration(
                                  color: cat.color
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                      color: cat.color,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  sign.steps[i],
                                  style: AppTextStyles.bodySmall
                                      .copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      SizedBox(height: 20.h),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cat.color,
                            padding:
                                EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14.r),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.of(ctx).pop(),
                          child: Text(
                            'Close',
                            style:
                                AppTextStyles.buttonMedium.copyWith(
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Coming Soon placeholder ────────────────────────────────────────────────

  Widget _buildComingSoon(Color accentColor) {
    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_off_rounded,
              color: accentColor.withValues(alpha: 0.6),
              size: 30.sp,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Video Coming Soon',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "We're filming this sign demonstration",
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
