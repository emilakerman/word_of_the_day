/// Represents a Word of the Day with its definition and related information.
class Word {
  /// The word itself
  final String word;

  /// The definition/meaning of the word
  final String definition;

  /// Phonetic pronunciation guide
  final String? pronunciation;

  /// An example sentence using the word
  final String? exampleSentence;

  /// The part of speech (noun, verb, adjective, etc.)
  final PartOfSpeech partOfSpeech;

  /// Optional etymology/origin of the word
  final String? etymology;

  /// The date this word is associated with (for daily selection)
  final DateTime? date;

  const Word({
    required this.word,
    required this.definition,
    required this.partOfSpeech,
    this.pronunciation,
    this.exampleSentence,
    this.etymology,
    this.date,
  });

  /// Creates a Word from a JSON map
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'] as String,
      definition: json['definition'] as String,
      partOfSpeech: PartOfSpeech.fromString(json['partOfSpeech'] as String),
      pronunciation: json['pronunciation'] as String?,
      exampleSentence: json['exampleSentence'] as String?,
      etymology: json['etymology'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    );
  }

  /// Converts the Word to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'definition': definition,
      'partOfSpeech': partOfSpeech.value,
      'pronunciation': pronunciation,
      'exampleSentence': exampleSentence,
      'etymology': etymology,
      'date': date?.toIso8601String(),
    };
  }

  /// Creates a copy of this Word with the given fields replaced
  Word copyWith({
    String? word,
    String? definition,
    PartOfSpeech? partOfSpeech,
    String? pronunciation,
    String? exampleSentence,
    String? etymology,
    DateTime? date,
  }) {
    return Word(
      word: word ?? this.word,
      definition: definition ?? this.definition,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      pronunciation: pronunciation ?? this.pronunciation,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      etymology: etymology ?? this.etymology,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Word &&
        other.word == word &&
        other.definition == definition &&
        other.partOfSpeech == partOfSpeech &&
        other.pronunciation == pronunciation &&
        other.exampleSentence == exampleSentence &&
        other.etymology == etymology &&
        other.date == date;
  }

  @override
  int get hashCode {
    return Object.hash(
      word,
      definition,
      partOfSpeech,
      pronunciation,
      exampleSentence,
      etymology,
      date,
    );
  }

  @override
  String toString() {
    return 'Word(word: $word, definition: $definition, partOfSpeech: ${partOfSpeech.value})';
  }
}

/// Enum representing the part of speech for a word
enum PartOfSpeech {
  noun('noun'),
  verb('verb'),
  adjective('adjective'),
  adverb('adverb'),
  pronoun('pronoun'),
  preposition('preposition'),
  conjunction('conjunction'),
  interjection('interjection'),
  article('article'),
  other('other');

  final String value;

  const PartOfSpeech(this.value);

  /// Creates a PartOfSpeech from a string value
  static PartOfSpeech fromString(String value) {
    return PartOfSpeech.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PartOfSpeech.other,
    );
  }
}
