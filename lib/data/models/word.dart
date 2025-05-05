class Word {
  final String word;
  final String? phonetic;
  final List<Phonetic> phonetics;
  final List<Meaning> meanings;

  Word({
    required this.word,
    this.phonetic,
    required this.phonetics,
    required this.meanings,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'],
      phonetic: json['phonetic'],
      phonetics: (json['phonetics'] as List)
          .map((p) => Phonetic.fromJson(p))
          .toList(),
      meanings: (json['meanings'] as List)
          .map((m) => Meaning.fromJson(m))
          .toList(),
    );
  }
}

class Phonetic {
  final String? text;
  final String? audio;

  Phonetic({this.text, this.audio});

  factory Phonetic.fromJson(Map<String, dynamic> json) {
    return Phonetic(
      text: json['text'],
      audio: json['audio'],
    );
  }
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;

  Meaning({required this.partOfSpeech, required this.definitions});

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'],
      definitions: (json['definitions'] as List)
          .map((d) => Definition.fromJson(d))
          .toList(),
    );
  }
}

class Definition {
  final String definition;
  final List<String> synonyms;
  final String? example;

  Definition({
    required this.definition,
    required this.synonyms,
    this.example,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'],
      synonyms: (json['synonyms'] as List<dynamic>?)?.cast<String>() ?? [],
      example: json['example'],
    );
  }
}