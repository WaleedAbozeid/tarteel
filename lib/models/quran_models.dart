class Surah {
  final int number;
  final String name;
  final String nameAr;
  final String nameEn;
  final String revelationType;
  final int numberOfAyahs;
  final String description;

  Surah({
    required this.number,
    required this.name,
    required this.nameAr,
    required this.nameEn,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.description,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      revelationType: json['revelationType'],
      numberOfAyahs: json['numberOfAyahs'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'revelationType': revelationType,
      'numberOfAyahs': numberOfAyahs,
      'description': description,
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
    return Ayah(
      number: json['number'],
      surahNumber: json['surahNumber'],
      text: json['text'],
      textAr: json['textAr'],
      translation: json['translation'],
      translationAr: json['translationAr'],
      juz: json['juz'],
      page: json['page'],
      ruku: json['ruku'],
      hizbQuarter: json['hizbQuarter'],
      sajda: json['sajda'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'surahNumber': surahNumber,
      'text': text,
      'textAr': textAr,
      'translation': translation,
      'translationAr': translationAr,
      'juz': juz,
      'page': page,
      'ruku': ruku,
      'hizbQuarter': hizbQuarter,
      'sajda': sajda,
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
  final String description;
  final String color;
  final String example;

  TajweedRule({
    required this.name,
    required this.description,
    required this.color,
    required this.example,
  });

  factory TajweedRule.fromJson(Map<String, dynamic> json) {
    return TajweedRule(
      name: json['name'],
      description: json['description'],
      color: json['color'],
      example: json['example'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
      'example': example,
    };
  }
} 