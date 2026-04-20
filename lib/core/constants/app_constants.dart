class AppConstants {
  static const String appName = 'Ruang Karya';
  static const String supabaseEmailDomain = '@ruangkarya.id';
  static const String defaultRole = 'anggota';

  static const String bucketAvatars = 'avatars';
  static const String bucketGallery = 'gallery';

  static const List<String> divisions = [
    'Musik',
    'Tari',
    'DKV',
    'Kreatif Event',
  ];

  static const Map<String, String> divisionColors = {
    'Musik': '#3B82F6',
    'Tari': '#EC4899',
    'DKV': '#10B981',
    'Kreatif Event': '#F97316',
  };
}
