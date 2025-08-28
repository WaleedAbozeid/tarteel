import 'package:flutter/material.dart';

class Surah {
  final int number;
  final String name;
  final String nameAr;
  final String nameEn;
  final String revelationType;
  final int numberOfAyahs;
  final String description;
  final int wordsCount;
  final int lettersCount;

  Surah({
    required this.number,
    required this.name,
    required this.nameAr,
    required this.nameEn,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.description,
    this.wordsCount = 0,
    this.lettersCount = 0,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    print('Surah.fromJson: Starting to parse JSON');
    
    // Handle new JSON structure with nested objects
    final Map<String, dynamic> name = json['name'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> revelationPlace = json['revelation_place'] as Map<String, dynamic>? ?? {};
    
    print('Surah.fromJson: name object = $name');
    print('Surah.fromJson: revelation_place object = $revelationPlace');
    
    final surah = Surah(
      number: json['number'] ?? 0,
      name: name['en'] ?? name['transliteration'] ?? '',
      nameAr: name['ar'] ?? '',
      nameEn: name['en'] ?? name['transliteration'] ?? '',
      revelationType: revelationPlace['en'] ?? '',
      numberOfAyahs: json['verses_count'] ?? 0,
      description: name['en'] ?? '',
      wordsCount: json['words_count'] ?? 0,
      lettersCount: json['letters_count'] ?? 0,
    );
    
    print('Surah.fromJson: Created surah ${surah.number}: ${surah.nameAr} (${surah.nameEn})');
    return surah;
  }

  // Factory method for old API structure (backward compatibility)
  factory Surah.fromOldJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      revelationType: json['revelationType'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': {
        'ar': nameAr,
        'en': nameEn,
        'transliteration': name,
      },
      'revelation_place': {
        'ar': revelationType == 'Meccan' ? 'مكية' : 'مدنية',
        'en': revelationType,
      },
      'verses_count': numberOfAyahs,
      'words_count': wordsCount,
      'letters_count': lettersCount,
    };
  }
}

class Ayah {
  final int number;
  final int surahNumber;
  final String text;
  final String textAr;
  final String translation;
  final String translationAr;
  final int juz;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final String sajda;

  Ayah({
    required this.number,
    required this.surahNumber,
    required this.text,
    required this.textAr,
    required this.translation,
    required this.translationAr,
    required this.juz,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    // Handle new JSON structure with nested text object
    final Map<String, dynamic> textObj = json['text'] as Map<String, dynamic>? ?? {};
    
    return Ayah(
      number: json['number'] ?? 0,
      surahNumber: json['surahNumber'] ?? 0,
      text: textObj['en']?.toString() ?? textObj['ar']?.toString() ?? '',
      textAr: textObj['ar']?.toString() ?? '',
      translation: textObj['en']?.toString() ?? '',
      translationAr: '',
      juz: json['juz'] ?? 0,
      page: json['page'] ?? 0,
      ruku: json['ruku'] ?? 0,
      hizbQuarter: json['hizbQuarter'] ?? 0,
      sajda: (json['sajda'] ?? false).toString(),
    );
  }

  // Factory method for old API structure (backward compatibility)
  factory Ayah.fromOldJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] ?? 0,
      surahNumber: json['surahNumber'] ?? 0,
      text: json['text'] ?? '',
      textAr: json['textAr'] ?? '',
      translation: json['translation'] ?? '',
      translationAr: json['translationAr'] ?? '',
      juz: json['juz'] ?? 0,
      page: json['page'] ?? 0,
      ruku: json['ruku'] ?? 0,
      hizbQuarter: json['hizbQuarter'] ?? 0,
      sajda: json['sajda'] ?? 'false',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'surahNumber': surahNumber,
      'text': {
        'ar': textAr,
        'en': translation,
      },
      'juz': juz,
      'page': page,
      'ruku': ruku,
      'hizbQuarter': hizbQuarter,
      'sajda': sajda == 'true',
    };
  }
}

class Tafsir {
  final int ayahNumber;
  final int surahNumber;
  final String text;
  final String source;
  final String author;

  Tafsir({
    required this.ayahNumber,
    required this.surahNumber,
    required this.text,
    required this.source,
    required this.author,
  });

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    return Tafsir(
      ayahNumber: json['ayahNumber'],
      surahNumber: json['surahNumber'],
      text: json['text'],
      source: json['source'],
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayahNumber': ayahNumber,
      'surahNumber': surahNumber,
      'text': text,
      'source': source,
      'author': author,
    };
  }
}

class Reciter {
  final String id;
  final String name;
  final String nameAr;
  final String style;
  final String server;
  final String rewaya;

  Reciter({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.style,
    required this.server,
    required this.rewaya,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      style: json['style'],
      server: json['server'],
      rewaya: json['rewaya'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'style': style,
      'server': server,
      'rewaya': rewaya,
    };
  }
}

class TajweedRule {
  final String name;
  final String arabicName;
  final String description;
  final List<String> examples;
  final String practiceText;
  final String practiceInstructions;

  TajweedRule({
    required this.name,
    required this.arabicName,
    required this.description,
    required this.examples,
    required this.practiceText,
    required this.practiceInstructions,
  });

  factory TajweedRule.fromJson(Map<String, dynamic> json) {
    return TajweedRule(
      name: json['name'],
      arabicName: json['arabicName'],
      description: json['description'],
      examples: List<String>.from(json['examples'] ?? []),
      practiceText: json['practiceText'] ?? '',
      practiceInstructions: json['practiceInstructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'arabicName': arabicName,
      'description': description,
      'examples': examples,
      'practiceText': practiceText,
      'practiceInstructions': practiceInstructions,
    };
  }
}

class TafsirSource {
  final String name;
  final String arabicName;
  final String description;
  final Color color;

  TafsirSource({
    required this.name,
    required this.arabicName,
    required this.description,
    required this.color,
  });

  factory TafsirSource.fromJson(Map<String, dynamic> json) {
    return TafsirSource(
      name: json['name'],
      arabicName: json['arabicName'],
      description: json['description'],
      color: Color(json['color']), // Assuming Color is a defined type
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'arabicName': arabicName,
      'description': description,
      'color': color.value, // Assuming Color has a value property
    };
  }
}

class TafsirText {
  final int ayahNumber;
  final String ayahText;
  final String tafsirMuyassar;
  final String tafsirIbnKathir;
  final String tafsirTabari;
  final String tafsirQurtubi;

  TafsirText({
    required this.ayahNumber,
    required this.ayahText,
    required this.tafsirMuyassar,
    required this.tafsirIbnKathir,
    required this.tafsirTabari,
    required this.tafsirQurtubi,
  });

  factory TafsirText.fromJson(Map<String, dynamic> json) {
    return TafsirText(
      ayahNumber: json['ayahNumber'],
      ayahText: json['ayahText'],
      tafsirMuyassar: json['tafsirMuyassar'],
      tafsirIbnKathir: json['tafsirIbnKathir'],
      tafsirTabari: json['tafsirTabari'],
      tafsirQurtubi: json['tafsirQurtubi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'tafsirMuyassar': tafsirMuyassar,
      'tafsirIbnKathir': tafsirIbnKathir,
      'tafsirTabari': tafsirTabari,
      'tafsirQurtubi': tafsirQurtubi,
    };
  }
}

class MemorizationSurah {
  final Surah surah;
  final double progress;
  final DateTime lastReviewed;
  final String difficulty;

  MemorizationSurah({
    required this.surah,
    required this.progress,
    required this.lastReviewed,
    required this.difficulty,
  });

  factory MemorizationSurah.fromJson(Map<String, dynamic> json) {
    return MemorizationSurah(
      surah: Surah.fromJson(json['surah']),
      progress: json['progress'] as double,
      lastReviewed: DateTime.parse(json['lastReviewed']),
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah': surah.toJson(),
      'progress': progress,
      'lastReviewed': lastReviewed.toIso8601String(),
      'difficulty': difficulty,
    };
  }
} 