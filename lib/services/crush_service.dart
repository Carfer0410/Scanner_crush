import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crush_result.dart';
import 'daily_love_service.dart';
import 'secure_time_service.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';

class CrushService {
  static final CrushService _instance = CrushService._internal();
  static CrushService get instance => _instance;
  CrushService._internal();

  // Lista expandida de 500+ celebridades trending 2025 🌟
  final List<String> _celebrities = [
    // 🎬 HOLLYWOOD A-LIST
    "Ryan Gosling", "Emma Stone", "Timothée Chalamet", "Zendaya", "Tom Holland",
    "Anya Taylor-Joy", "Michael B. Jordan", "Margot Robbie", "Chris Evans", "Scarlett Johansson",
    "Ryan Reynolds", "Blake Lively", "Leonardo DiCaprio", "Jennifer Lawrence", "Brad Pitt",
    "Emma Watson", "Sebastian Stan", "Elizabeth Olsen", "Oscar Isaac", "Florence Pugh",
    "Adam Driver", "Saoirse Ronan", "Regé-Jean Page", "Pedro Pascal", "Jacob Elordi",
    "Sydney Sweeney", "Noah Centineo", "Charles Melton", "Maddie Ziegler", "Glen Powell",
    
    // 🔥 NUEVAS GENERACIONES 2025
    "Jenna Ortega", "Anya Chalotra", "Hunter Schafer", "Barbie Ferreira", "Alexa Demie",
    "Storm Reid", "Kaitlyn Dever", "Thomasin McKenzie", "Millicent Simmonds", "Julia Garner",
    "Rachel Zegler", "Halle Bailey", "Yara Shahidi", "Lana Condor", "Anna Cathcart",
    "Madison Beer", "Dixie D'Amelio", "Addison Rae", "Emma Chamberlain", "James Charles",
    "Noah Beck", "Bryce Hall", "Chase Hudson", "Anthony Reeves", "Payton Moormeier",
    
    // 🎵 MÚSICA GLOBAL
    "Harry Styles", "Taylor Swift", "Dua Lipa", "Olivia Rodrigo", "Billie Eilish",
    "The Weeknd", "Ariana Grande", "Post Malone", "Travis Scott", "Drake",
    "Shawn Mendes", "Justin Bieber", "Ed Sheeran", "Bruno Mars", "The Chainsmokers",
    "Camila Cabello", "Selena Gomez", "Doja Cat", "Megan Thee Stallion", "Cardi B",
    "SZA", "Halsey", "Lorde", "Charli XCX", "Troye Sivan", "Lana Del Rey",
    
    // 🇰🇷 K-POP SUPERSTARS
    "BTS", "RM", "Jin", "Suga", "J-Hope", "Jimin", "V", "Jungkook",
    "BLACKPINK", "Jennie", "Jisoo", "Rosé", "Lisa", "TWICE", "Nayeon", "Jeongyeon",
    "Momo", "Sana", "Jihyo", "Mina", "Dahyun", "Chaeyoung", "Tzuyu",
    "Stray Kids", "Bang Chan", "Lee Know", "Changbin", "Hyunjin", "Han", "Felix", "Seungmin", "I.N",
    "NewJeans", "Minji", "Hanni", "Danielle", "Haerin", "Hyein",
    "aespa", "Karina", "Giselle", "Winter", "Ningning", "IU", "Taeyeon", "IVE",
    "ITZY", "LE SSERAFIM", "(G)I-DLE", "Red Velvet", "MAMAMOO", "SEVENTEEN",
    "ENHYPEN", "TXT", "ATEEZ", "ITZY", "Yeji", "Lia", "Ryujin", "Chaeryeong", "Yuna",
    
    // 🇪🇸 LATINOAMÉRICA
    "Bad Bunny", "Karol G", "Rosalía", "Aitana", "Ana Mena", "Lola Índigo",
    "C. Tangana", "Rauw Alejandro", "Maluma", "J Balvin", "Ozuna", "Anuel AA",
    "Daddy Yankee", "Nicky Jam", "Don Omar", "Wisin", "Yandel", "Farruko",
    "Becky G", "Natti Natasha", "Tini", "María Becerra", "Emilia", "Cazzu",
    "Paulo Londra", "Duki", "Bizarrap", "Peso Pluma", "Feid", "Ryan Castro",
    
    // 🎭 NETFLIX & STREAMING STARS
    "Noah Centineo", "Lana Condor", "Ross Butler", "Anna Cathcart", "Jordan Fisher",
    "Chase Stokes", "Madelyn Cline", "Rudy Pankow", "Madison Bailey", "Jonathan Daviss",
    "Austin Butler", "Jacob Elordi", "Alexa Demie", "Sydney Sweeney", "Hunter Schafer",
    "Zendaya", "Tom Holland", "Millie Bobby Brown", "Finn Wolfhard", "Gaten Matarazzo",
    "Caleb McLaughlin", "Sadie Sink", "Maya Hawke", "Joe Keery", "Natalia Dyer",
    "Charlie Heaton", "Dacre Montgomery", "Penn Badgley", "Victoria Pedretti",
    "Dylan Minnette", "Katherine Langford", "Ross Lynch", "13 Reasons Why Cast",
    
    // 🦸‍♂️ MARVEL & DC
    "Tom Holland", "Zendaya", "Jacob Batalon", "Tony Revolori", "Marisa Tomei",
    "Chris Evans", "Scarlett Johansson", "Mark Ruffalo", "Chris Hemsworth", "Jeremy Renner",
    "Paul Rudd", "Evangeline Lilly", "Brie Larson", "Tessa Thompson", "Lupita Nyong'o",
    "Chadwick Boseman", "Michael B. Jordan", "Letitia Wright", "Danai Gurira",
    "Robert Downey Jr.", "Gwyneth Paltrow", "Don Cheadle", "Anthony Mackie", "Sebastian Stan",
    "Elizabeth Olsen", "Paul Bettany", "Kathryn Hahn", "Evan Peters", "Kat Dennings",
    
    // 🎪 TIKTOKERS & INFLUENCERS
    "Charli D'Amelio", "Dixie D'Amelio", "Addison Rae", "Bella Poarch", "Loren Gray",
    "Baby Ariel", "Zach King", "David Dobrik", "Emma Chamberlain", "James Charles",
    "Jeffree Star", "Nikocado Avocado", "MrBeast", "PewDiePie", "Markiplier",
    "Jacksepticeye", "DanTDM", "VanossGaming", "Ninja", "Pokimane", "Valkyrae",
    "Corpse Husband", "Dream", "GeorgeNotFound", "Sapnap", "TommyInnit", "Tubbo",
    
    // 🏃‍♂️ DEPORTISTAS
    "Cristiano Ronaldo", "Lionel Messi", "Neymar Jr", "Kylian Mbappé", "Erling Haaland",
    "Vinicius Jr", "Pedri", "Gavi", "Jude Bellingham", "Marcus Rashford",
    "LeBron James", "Stephen Curry", "Kevin Durant", "Giannis Antetokounmpo", "Luka Dončić",
    "Jayson Tatum", "Zion Williamson", "Ja Morant", "Trae Young", "Anthony Edwards",
    "Serena Williams", "Naomi Osaka", "Emma Raducanu", "Coco Gauff", "Iga Świątek",
    
    // 🎨 MODELOS & FASHION
    "Gigi Hadid", "Bella Hadid", "Kendall Jenner", "Hailey Bieber", "Emily Ratajkowski",
    "Cara Delevingne", "Kaia Gerber", "Paloma Elsesser", "Ashley Graham", "Winnie Harlow",
    "Joan Smalls", "Liu Wen", "Adut Akech", "Kiki Willems", "Vittoria Ceretti",
    "Barbara Palvin", "Taylor Hill", "Romee Strijd", "Jasmine Tookes", "Sara Sampaio",
    
    // 🔥 RISING STARS 2025
    "Anya Taylor-Joy", "Thomasin McKenzie", "Millicent Simmonds", "Darby Camp", "Julia Butters",
    "McKenna Grace", "Marsai Martin", "Storm Reid", "Yara Shahidi", "Rowan Blanchard",
    "Jenna Davis", "Annie LeBlanc", "Mackenzie Ziegler", "JoJo Siwa", "Millie Bobby Brown",
    "Sadie Sink", "Maya Hawke", "Priah Ferguson", "Gaten Matarazzo", "Caleb McLaughlin",
    
    // 🌟 HOLLYWOOD LEGENDS (STILL HOT)
    "Will Smith", "Johnny Depp", "Tom Cruise", "Keanu Reeves", "Hugh Jackman",
    "Robert Downey Jr.", "Chris Pratt", "Mark Wahlberg", "Dwayne Johnson", "Jason Momoa",
    "Henry Cavill", "Chris Pine", "Ryan Gosling", "Jake Gyllenhaal", "Michael Fassbender",
    "Angelina Jolie", "Jennifer Aniston", "Scarlett Johansson", "Charlize Theron", "Nicole Kidman",
    
    // 🎵 REGGAETON & URBANO
    "Bad Bunny", "J Balvin", "Maluma", "Ozuna", "Anuel AA", "Farruko", "Nicky Jam",
    "Daddy Yankee", "Don Omar", "Wisin", "Yandel", "Arcángel", "De La Ghetto",
    "Rauw Alejandro", "Myke Towers", "Jhay Cortez", "Sech", "Lunay", "Lyanno",
    "Cazzu", "Karol G", "Natti Natasha", "Becky G", "Rosalía", "Aitana",
    
    // 🇧🇷 BRAZIL STARS
    "Anitta", "Pabllo Vittar", "Luísa Sonza", "IZA", "Pocah", "Lexa", "MC Rebecca",
    "Bruna Marquezine", "Marina Ruy Barbosa", "Giovanna Ewbank", "Sabrina Sato",
    "Grazi Massafera", "Paolla Oliveira", "Isis Valverde", "Camila Queiroz",
    
    // 🇮🇳 BOLLYWOOD
    "Priyanka Chopra", "Deepika Padukone", "Alia Bhatt", "Katrina Kaif", "Anushka Sharma",
    "Kareena Kapoor", "Sonam Kapoor", "Jacqueline Fernandez", "Shraddha Kapoor",
    "Ranveer Singh", "Ranbir Kapoor", "Shahid Kapoor", "Varun Dhawan", "Sidharth Malhotra",
    
    // 🇬🇧 BRITISH STARS
    "Daniel Radcliffe", "Emma Watson", "Rupert Grint", "Tom Felton", "Bonnie Wright",
    "Benedict Cumberbatch", "Tom Hiddleston", "Eddie Redmayne", "Dev Patel", "John Boyega",
    "Daisy Ridley", "Felicity Jones", "Keira Knightley", "Kate Winslet", "Helena Bonham Carter",
    
    // 🇫🇷 FRENCH CINEMA
    "Léa Seydoux", "Marion Cotillard", "Adèle Exarchopoulos", "Virginie Efira", "Charlotte Gainsbourg",
    "Omar Sy", "Jean Dujardin", "Gaspard Ulliel", "Pierre Niney", "Romain Duris",
    
    // 🎮 GAMING & ESPORTS
    "Ninja", "Pokimane", "Valkyrae", "Corpse Husband", "Dream", "GeorgeNotFound",
    "Sapnap", "TommyInnit", "Tubbo", "Wilbur Soot", "Philza", "Technoblade",
    "PewDiePie", "Markiplier", "Jacksepticeye", "VanossGaming", "DanTDM", "CaptainSparklez",
    
    // 🌈 LGBTQ+ ICONS
    "Troye Sivan", "Lil Nas X", "Sam Smith", "Janelle Monáe", "Frank Ocean",
    "Tyler, The Creator", "Kevin Abstract", "Hayley Kiyoko", "King Princess", "Clairo",
    "Phoebe Bridgers", "Julien Baker", "Lucy Dacus", "boygenius", "MUNA",
    
    // 🔥 VIRAL SENSATIONS 2025
    "Ice Spice", "Central Cee", "Gayle", "Steve Lacy", "Daniel Caesar", "Summer Walker",
    "Giveon", "Brent Faiyaz", "Kali Uchis", "Rex Orange County", "Boy Pablo", "Cuco",
    "Omar Apollo", "Arlo Parks", "Beabadoobee", "Girl in Red", "Conan Gray", "Declan McKenna",

    // ▶ Additional diverse famous names (added +100)
    // Painters & Visual Artists
    "Frida Kahlo", "Pablo Picasso", "Vincent van Gogh", "Claude Monet", "Leonardo da Vinci", "Salvador Dalí",
    "Rembrandt", "Georgia O'Keeffe", "Jackson Pollock", "Edvard Munch", "Gustav Klimt", "Henri Matisse",
    "Jean-Michel Basquiat", "Caravaggio", "Sandro Botticelli", "Titian", "Paul Cézanne", "Paul Klee",
    "Ansel Adams", "Dorothea Lange",

    // Classical composers & legendary musicians
    "Wolfgang Amadeus Mozart", "Ludwig van Beethoven", "Johann Sebastian Bach", "Freddie Mercury", "David Bowie",
    "Prince", "Aretha Franklin", "Nina Simone", "Ella Fitzgerald", "Frank Sinatra", "Bob Dylan", "Joni Mitchell",
    "Paul McCartney", "John Lennon", "Mick Jagger", "Keith Richards", "Elvis Presley", "Stevie Wonder",
    "Celine Dion", "Whitney Houston", "Mariah Carey",

    // Writers & Poets
    "William Shakespeare", "Gabriel García Márquez", "Isabel Allende", "Jorge Luis Borges", "Pablo Neruda",
    "Federico García Lorca", "Octavio Paz", "Mario Vargas Llosa", "Ernest Hemingway", "F. Scott Fitzgerald",
    "Jane Austen", "Charles Dickens", "Virginia Woolf", "Toni Morrison", "Haruki Murakami", "Khaled Hosseini",
    "Mark Twain", "Leo Tolstoy", "Fyodor Dostoevsky", "Albert Camus",

    // Poets, modern & classic
    "Maya Angelou", "Rumi", "Sappho", "Emily Dickinson", "Sylvia Plath", "Langston Hughes", "Arthur Miller",
    "Agatha Christie", "Arthur Conan Doyle",

    // Scientists & Thinkers
    "Albert Einstein", "Marie Curie", "Isaac Newton", "Nikola Tesla", "Stephen Hawking", "Charles Darwin",
    "Galileo Galilei", "Ada Lovelace", "Rosalind Franklin", "Niels Bohr", "Jane Goodall", "Rachel Carson",

    // Film auteurs & directors
    "Alfred Hitchcock", "Stanley Kubrick", "Akira Kurosawa", "Ingmar Bergman", "Wes Anderson", "Quentin Tarantino",
    "Martin Scorsese", "Steven Spielberg", "Christopher Nolan", "Hayao Miyazaki", "Pedro Almodóvar", "Guillermo del Toro",
    "Alejandro González Iñárritu", "Sofia Coppola", "Peter Jackson",

    // Fashion & Design
    "Coco Chanel", "Yves Saint Laurent", "Gianni Versace", "Giorgio Armani", "Karl Lagerfeld", "Ralph Lauren",
    "Zaha Hadid", "Frank Lloyd Wright",

    // Statespeople & activists
    "Nelson Mandela", "Barack Obama", "Michelle Obama", "Angela Merkel", "Winston Churchill", "Malala Yousafzai",

    // Entrepreneurs & public figures
    "Elon Musk", "Bill Gates", "Steve Jobs", "Jeff Bezos", "Oprah Winfrey",

    // Rappers / Hip-Hop icons
    "Kendrick Lamar", "Eminem", "Jay-Z", "Nas", "Tupac Shakur", "The Notorious B.I.G.", "Dr. Dre",

    // Athletes (additional)
    "Roger Federer", "Rafael Nadal", "Novak Djokovic", "Serena Williams", "Usain Bolt", "Muhammad Ali", "Pelé",
    "Diego Maradona", "Zinedine Zidane",

    // Actors & classic stars
    "Meryl Streep", "Al Pacino", "Denzel Washington", "Jodie Foster", "Helen Mirren", "Judi Dench", "Dustin Hoffman",

    // Chefs
    "Gordon Ramsay", "Jamie Oliver", "Massimo Bottura", "Ferran Adrià", "Yotam Ottolenghi", "Alice Waters",
  ];

  final List<String> _additionalPersonalities = [
    // Políticos y líderes globales
    'Joe Biden', 'Donald Trump', 'Barack Obama', 'Kamala Harris', 'Hillary Clinton',
    'Vladimir Putin', 'Volodymyr Zelensky', 'Emmanuel Macron', 'Justin Trudeau',
    'Pedro Sánchez', 'Nayib Bukele', 'Gustavo Petro', 'Andrés Manuel López Obrador',
    'Javier Milei', 'Dilma Rousseff', 'Lula da Silva', 'Margaret Thatcher',
    'John F. Kennedy', 'Ronald Reagan', 'Xi Jinping', 'Narendra Modi', 'Pope Francis',

    // Cantantes y bandas extra
    'Shakira', 'Rihanna', 'Beyoncé', 'Adele', 'Kanye West', 'Coldplay',
    'Imagine Dragons', 'Linkin Park', 'Metallica', 'Nirvana', 'The Beatles',
    'Queen', 'Luis Miguel', 'Juan Gabriel', 'Carlos Vives', 'Romeo Santos',
    'Marc Anthony', 'Mon Laferte', 'Morat',

    // Actores/actrices extra
    'Robert De Niro', 'Morgan Freeman', 'Anne Hathaway', 'Natalie Portman',
    'Gal Gadot', 'Keira Knightley', 'Penélope Cruz', 'Javier Bardem',
    'Antonio Banderas', 'Ricardo Darín', 'Gael García Bernal',

    // Futbolistas y atletas extra
    'Lamine Yamal', 'Jamal Musiala', 'Florian Wirtz', 'Rodri', 'Kevin De Bruyne',
    'Luka Modrić', 'Sergio Ramos', 'Karim Benzema', 'Mohamed Salah', 'Sadio Mané',
    'Robert Lewandowski', 'Harry Kane', 'Son Heung-min', 'Alexia Putellas',
    'Aitana Bonmatí', 'Marta Vieira da Silva', 'James Rodríguez', 'Radamel Falcao',

    // Pintores/escultores extra
    'Michelangelo', 'Raphael', 'Diego Velázquez', 'Francisco Goya', 'Joan Miró',
    'René Magritte', 'Camille Pissarro', 'Egon Schiele', 'Amedeo Modigliani',
    'Andy Warhol', 'Banksy', 'Fernando Botero',
  ];

  final Map<String, String> _celebrityAliases = {
    'barak obama': 'barack obama',
    'barac obama': 'barack obama',
    'obama': 'barack obama',
    'donald trunp': 'donald trump',
    'donal trump': 'donald trump',
    'trump': 'donald trump',
    'vladmir putin': 'vladimir putin',
    'vladimir putim': 'vladimir putin',
    'putin': 'vladimir putin',
    'zelinky': 'volodymyr zelensky',
    'zelenski': 'volodymyr zelensky',
    'zelensky': 'volodymyr zelensky',
    'volodimir zelensky': 'volodymyr zelensky',
    'messi': 'lionel messi',
    'cr7': 'cristiano ronaldo',
    'ronaldo': 'cristiano ronaldo',
    'neymar': 'neymar jr',
    'mbappe': 'kylian mbappe',
    'kylian mbappe': 'kylian mbappe',
    'shakira isabel': 'shakira',
    'the weekend': 'the weeknd',
    'weekend': 'the weeknd',
    'badbunny': 'bad bunny',
    'karolg': 'karol g',
    'dua lipae': 'dua lipa',
    'timothe chalamet': 'timothee chalamet',
    'timothee chalamet': 'timothee chalamet',
    'pedro pascalle': 'pedro pascal',
    'michael jordan': 'michael b. jordan',
    'vincent van gogh': 'vincent van gogh',
    'pablo picazo': 'pablo picasso',
    'leonardo davinci': 'leonardo da vinci',
  };

  /// Returns deduplicated celebrity list preserving first occurrence order.
  List<String> get celebrities {
    final seen = <String>{};
    return [..._celebrities, ..._additionalPersonalities]
        .where((c) => seen.add(c))
        .toList();
  }

  final List<String> _emojis = [
    "💕",
    "💖",
    "💘",
    "💝",
    "💗",
    "💓",
    "💞",
    "💌",
    "🌹",
    "❤️",
    "🥰",
    "😍",
    "🌟",
    "✨",
    "💫",
    "🦋",
    "🌸",
    "🌺",
    "🍀",
    "🌙",
  ];

  // Heurística simple para inferir género por nombre (primer nombre)
  // Lista reducida y extensible de nombres frecuentes en la lista de celebridades
  final Set<String> _femaleFirstNames = {
    'emma', 'zendaya', 'anya', 'margot', 'scarlett', 'blake', 'jennifer', 'saoirse', 'florence', 'julia', 'rachel', 'halle', 'yara', 'lana', 'anna', 'madison', 'dixie', 'addison', 'alia', 'deepika', 'priyanka', 'rosalia', 'camila', 'selena', 'becky', 'natti', 'tini', 'emilia', 'anitta', 'luisa', 'gigi', 'bella', 'kendall', 'hailey', 'lina',
    // Added female first names from new celebrities
    'frida', 'georgia', 'dorothea', 'joni', 'celine', 'whitney', 'mariah', 'isabel', 'virginia', 'toni', 'maya', 'emily', 'sylvia', 'agatha', 'ada', 'rosalind', 'sofia', 'coco', 'zaha', 'michelle', 'oprah', 'serena', 'meryl', 'jodie', 'helen', 'judi', 'alice', 'annie', 'monica', 'joanna', 'dorothy', 'dorotea'
  };

  final Set<String> _maleFirstNames = {
    'ryan', 'timothée', 'timothee', 'tom', 'michael', 'chris', 'brad', 'leonardo', 'harry', 'drake', 'post', 'travis', 'justin', 'ed', 'bruno', 'noah', 'jacob', 'james', 'paulo', 'dwayne', 'cristiano', 'lionel', 'neymar', 'kylian', 'ronaldo', 'benedict', 'daniel', 'henry', 'marcus', 'jude', 'joshua', 'charles', 'keanu', 'robert', 'kevin',
    // Added male first names from new celebrities
    'pablo', 'vincent', 'claude', 'salvador', 'rembrandt', 'jackson', 'edvard', 'gustav', 'henri', 'jeanmichel', 'caravaggio', 'wolfgang', 'ludwig', 'johann', 'freddie', 'david', 'prince', 'bob', 'frank', 'john', 'mick', 'keith', 'elvis', 'stevie', 'roger', 'rafael', 'novak', 'usain', 'muhammad', 'edson', 'diego', 'zinedine', 'al', 'denzel', 'dustin', 'gordon', 'massimo', 'ferran', 'yotam', 'elon', 'bill', 'steve', 'jeff', 'kendrick', 'marshall', 'shawn', 'nasir', 'tupac', 'christopher', 'andre'
  };

  String _inferGenderFromName(String fullName) {
    if (fullName.trim().isEmpty) return 'unknown';
    final first = fullName.split(' ').first.toLowerCase();
    // Remove non-letter characters
    final normalized = first.replaceAll(RegExp(r"[^a-zñáéíóúü]"), '').toLowerCase();
    if (_femaleFirstNames.contains(normalized)) return 'female';
    if (_maleFirstNames.contains(normalized)) return 'male';
    return 'unknown';
  }

  String inferCelebrityGender(String fullName) => _inferGenderFromName(fullName);

  /// Public access to celebrity names (for Tournament feature)
  /// If `gender` is provided ('male' or 'female') the list will be filtered by
  /// a lightweight inference heuristic; otherwise returns all celebrities.
  List<String> getCelebrityNames({String? gender}) {
    if (gender == null) return List<String>.from(celebrities);
    final g = gender.toLowerCase();
    return celebrities.where((c) => _inferGenderFromName(c) == g).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMOTIONAL RESONANCE ALGORITHM v2 — Multi-layer compatibility engine
  // ═══════════════════════════════════════════════════════════════════

  /// Deterministic hash for a given string seed.
  int _hash(String seed) {
    var h = 0;
    for (int i = 0; i < seed.length; i++) {
      h = ((h << 5) - h + seed.codeUnitAt(i)) & 0xffffffff;
    }
    return h.abs();
  }

  /// Shared letters ratio between two names (0.0 – 1.0).
  double _sharedLettersRatio(String a, String b) {
    final setA = a.toLowerCase().replaceAll(RegExp(r'[^a-záéíóúñü]'), '').split('').toSet();
    final setB = b.toLowerCase().replaceAll(RegExp(r'[^a-záéíóúñü]'), '').split('').toSet();
    if (setA.isEmpty || setB.isEmpty) return 0;
    final shared = setA.intersection(setB).length;
    final total = setA.union(setB).length;
    return shared / total;
  }

  /// Vowel harmony score (0.0 – 1.0). Similar vowel profiles = higher.
  double _vowelHarmony(String a, String b) {
    List<int> profile(String s) {
      final chars = s.toLowerCase().split('');
      final counts = List.filled(5, 0); // a e i o u
      final map = {'a': 0, 'á': 0, 'e': 1, 'é': 1, 'i': 2, 'í': 2, 'o': 3, 'ó': 3, 'u': 4, 'ú': 4};
      for (final c in chars) {
        if (map.containsKey(c)) counts[map[c]!]++;
      }
      final total = counts.fold<int>(0, (s, v) => s + v);
      if (total == 0) return counts;
      return counts;
    }
    final pa = profile(a);
    final pb = profile(b);
    // Cosine-like similarity
    var dot = 0, magA = 0, magB = 0;
    for (int i = 0; i < 5; i++) {
      dot += pa[i] * pb[i];
      magA += pa[i] * pa[i];
      magB += pb[i] * pb[i];
    }
    if (magA == 0 || magB == 0) return 0.3;
    return dot / (sqrt(magA.toDouble()) * sqrt(magB.toDouble()));
  }

  /// Name length compatibility (0.0 – 1.0). Similar lengths score higher.
  double _lengthHarmony(String a, String b) {
    final la = a.replaceAll(' ', '').length;
    final lb = b.replaceAll(' ', '').length;
    if (la == 0 || lb == 0) return 0.3;
    final ratio = la < lb ? la / lb : lb / la;
    return ratio;
  }

  /// Apply a skewed distribution: maps a uniform 0-1 value to a
  /// distribution that favors higher scores.
  /// ~60% chance of 75-95, ~25% chance of 55-74, ~15% chance of 35-54.
  int _skewedScore(double uniform01) {
    // Use a power curve: raising to a fractional power pulls values upward.
    final skewed = 1.0 - pow(1.0 - uniform01, 1.8);
    // Map to 35-98 range
    return (35 + (skewed * 63)).round().clamp(35, 98);
  }

  /// Generate 4 sub-dimension scores deterministically from the two names.
  Map<String, int> generateDimensions(String name1, String name2) {
    final sorted = [name1.toLowerCase(), name2.toLowerCase()]..sort();

    final emotionalSeed = _hash('emotional_${sorted.join("+")}');
    final passionSeed = _hash('passion_${sorted.join("+")}');
    final intellectualSeed = _hash('intellectual_${sorted.join("+")}');
    final destinySeed = _hash('destiny_${sorted.join("+")}');

    // Each dimension gets its own uniform [0,1] value, then skewed
    double toUniform(int seed) => (seed % 10000) / 10000.0;

    return {
      'emotional': _skewedScore(toUniform(emotionalSeed)),
      'passion': _skewedScore(toUniform(passionSeed)),
      'intellectual': _skewedScore(toUniform(intellectualSeed)),
      'destiny': _skewedScore(toUniform(destinySeed)),
    };
  }

  /// Public accessor for the compatibility score (used by TournamentService).
  int generateCompatibilityScore(String name1, String name2) =>
      _generateCompatibilityPercentage(name1, name2);

  int _generateCompatibilityPercentage(String name1, String name2) {
    // Sort names alphabetically so order doesn't matter (A+B == B+A)
    final sorted = [name1.toLowerCase(), name2.toLowerCase()]..sort();
    final combined = sorted.join();

    // ── Layer 1: Base hash (deterministic seed) ──
    final baseHash = _hash(combined);
    final baseUniform = (baseHash % 10000) / 10000.0;

    // ── Layer 2: Name resonance signals ──
    final sharedLetters = _sharedLettersRatio(name1, name2); // 0-1
    final vowelScore = _vowelHarmony(name1, name2);           // 0-1
    final lengthScore = _lengthHarmony(name1, name2);         // 0-1

    // Weighted resonance: how "harmonious" the names feel
    final resonance = (sharedLetters * 0.40) + (vowelScore * 0.35) + (lengthScore * 0.25);

    // ── Layer 3: Blend base + resonance ──
    // Base hash drives 55% of the score, resonance drives 45%
    final blended = (baseUniform * 0.55) + (resonance * 0.45);

    // ── Layer 4: Skewed distribution (favors higher results) ──
    final percentage = _skewedScore(blended);

    return percentage.clamp(35, 98);
  }

  String _getRandomMessage(
    int percentage,
    AppLocalizations localizations, {
    bool isCelebrity = false,
  }) {
    final random = Random();

    // Mensajes de celebridades coherentes con el porcentaje
    if (isCelebrity) {
      // Seleccionar rango de mensajes según porcentaje
      // 1-5: alta (>=70), 6-10: media (>=45), 11-15: baja (<45)
      final int base;
      if (percentage >= 70) {
        base = random.nextInt(5) + 1;  // Mensajes 1-5 (positivos)
      } else if (percentage >= 45) {
        base = random.nextInt(5) + 6;  // Mensajes 6-10 (neutros)
      } else {
        base = random.nextInt(5) + 11; // Mensajes 11-15 (divertidos)
      }
      return _getCelebrityMessage(base, localizations);
    }

    if (percentage >= 80) {
      return _getRomanticMessage(random.nextInt(20) + 1, localizations);
    } else if (percentage >= 60) {
      return _getMysteriousMessage(random.nextInt(20) + 1, localizations);
    } else if (percentage >= 45) {
      return _getFunMessage(random.nextInt(20) + 1, localizations);
    } else {
      return _getLowCompatibilityMessage(random.nextInt(10) + 1, localizations);
    }
  }

  String _getCelebrityMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1:
        return localizations.celebrityMessage1;
      case 2:
        return localizations.celebrityMessage2;
      case 3:
        return localizations.celebrityMessage3;
      case 4:
        return localizations.celebrityMessage4;
      case 5:
        return localizations.celebrityMessage5;
      case 6:
        return localizations.celebrityMessage6;
      case 7:
        return localizations.celebrityMessage7;
      case 8:
        return localizations.celebrityMessage8;
      case 9:
        return localizations.celebrityMessage9;
      case 10:
        return localizations.celebrityMessage10;
      case 11:
        return localizations.celebrityMessage11;
      case 12:
        return localizations.celebrityMessage12;
      case 13:
        return localizations.celebrityMessage13;
      case 14:
        return localizations.celebrityMessage14;
      case 15:
        return localizations.celebrityMessage15;
      default:
        return localizations.celebrityMessage1;
    }
  }

  String _getRomanticMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1:
        return localizations.romanticMessage1;
      case 2:
        return localizations.romanticMessage2;
      case 3:
        return localizations.romanticMessage3;
      case 4:
        return localizations.romanticMessage4;
      case 5:
        return localizations.romanticMessage5;
      case 6:
        return localizations.romanticMessage6;
      case 7:
        return localizations.romanticMessage7;
      case 8:
        return localizations.romanticMessage8;
      case 9:
        return localizations.romanticMessage9;
      case 10:
        return localizations.romanticMessage10;
      case 11:
        return localizations.romanticMessage11;
      case 12:
        return localizations.romanticMessage12;
      case 13:
        return localizations.romanticMessage13;
      case 14:
        return localizations.romanticMessage14;
      case 15:
        return localizations.romanticMessage15;
      case 16:
        return localizations.romanticMessage16;
      case 17:
        return localizations.romanticMessage17;
      case 18:
        return localizations.romanticMessage18;
      case 19:
        return localizations.romanticMessage19;
      case 20:
        return localizations.romanticMessage20;
      default:
        return localizations.romanticMessage1;
    }
  }

  String _getMysteriousMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1:
        return localizations.mysteriousMessage1;
      case 2:
        return localizations.mysteriousMessage2;
      case 3:
        return localizations.mysteriousMessage3;
      case 4:
        return localizations.mysteriousMessage4;
      case 5:
        return localizations.mysteriousMessage5;
      case 6:
        return localizations.mysteriousMessage6;
      case 7:
        return localizations.mysteriousMessage7;
      case 8:
        return localizations.mysteriousMessage8;
      case 9:
        return localizations.mysteriousMessage9;
      case 10:
        return localizations.mysteriousMessage10;
      case 11:
        return localizations.mysteriousMessage11;
      case 12:
        return localizations.mysteriousMessage12;
      case 13:
        return localizations.mysteriousMessage13;
      case 14:
        return localizations.mysteriousMessage14;
      case 15:
        return localizations.mysteriousMessage15;
      case 16:
        return localizations.mysteriousMessage16;
      case 17:
        return localizations.mysteriousMessage17;
      case 18:
        return localizations.mysteriousMessage18;
      case 19:
        return localizations.mysteriousMessage19;
      case 20:
        return localizations.mysteriousMessage20;
      default:
        return localizations.mysteriousMessage1;
    }
  }

  String _getFunMessage(int index, AppLocalizations localizations) {
    switch (index) {
      case 1:
        return localizations.funMessage1;
      case 2:
        return localizations.funMessage2;
      case 3:
        return localizations.funMessage3;
      case 4:
        return localizations.funMessage4;
      case 5:
        return localizations.funMessage5;
      case 6:
        return localizations.funMessage6;
      case 7:
        return localizations.funMessage7;
      case 8:
        return localizations.funMessage8;
      case 9:
        return localizations.funMessage9;
      case 10:
        return localizations.funMessage10;
      case 11:
        return localizations.funMessage11;
      case 12:
        return localizations.funMessage12;
      case 13:
        return localizations.funMessage13;
      case 14:
        return localizations.funMessage14;
      case 15:
        return localizations.funMessage15;
      case 16:
        return localizations.funMessage16;
      case 17:
        return localizations.funMessage17;
      case 18:
        return localizations.funMessage18;
      case 19:
        return localizations.funMessage19;
      case 20:
        return localizations.funMessage20;
      default:
        return localizations.funMessage1;
    }
  }

  String _getLowCompatibilityMessage(
    int index,
    AppLocalizations localizations,
  ) {
    switch (index) {
      case 1:
        return localizations.lowCompatibilityMessage1;
      case 2:
        return localizations.lowCompatibilityMessage2;
      case 3:
        return localizations.lowCompatibilityMessage3;
      case 4:
        return localizations.lowCompatibilityMessage4;
      case 5:
        return localizations.lowCompatibilityMessage5;
      case 6:
        return localizations.lowCompatibilityMessage6;
      case 7:
        return localizations.lowCompatibilityMessage7;
      case 8:
        return localizations.lowCompatibilityMessage8;
      case 9:
        return localizations.lowCompatibilityMessage9;
      case 10:
        return localizations.lowCompatibilityMessage10;
      default:
        return localizations.lowCompatibilityMessage1;
    }
  }

  // Función auxiliar para normalizar texto (remover acentos y convertir a minúsculas)
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  String _normalizeForCompare(String text) {
    return _normalizeText(text)
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final previous = List<int>.generate(b.length + 1, (i) => i);
    final current = List<int>.filled(b.length + 1, 0);

    for (int i = 1; i <= a.length; i++) {
      current[0] = i;
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        current[j] = [
          current[j - 1] + 1,
          previous[j] + 1,
          previous[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      for (int j = 0; j <= b.length; j++) {
        previous[j] = current[j];
      }
    }

    return previous[b.length];
  }

  double _similarityScore(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final maxLen = a.length > b.length ? a.length : b.length;
    final dist = _levenshteinDistance(a, b);
    return 1 - (dist / maxLen);
  }

  String _resolveAlias(String text) {
    final normalized = _normalizeForCompare(text);
    if (_celebrityAliases.containsKey(normalized)) {
      return _celebrityAliases[normalized]!;
    }
    return normalized;
  }

  String _canonicalizeFigureIntent(String value) {
    final normalized = _resolveAlias(value);

    const known = <String>[
      'barack obama',
      'donald trump',
      'joe biden',
      'vladimir putin',
      'volodymyr zelensky',
      'lionel messi',
      'cristiano ronaldo',
    ];

    String best = normalized;
    double bestScore = 0;
    for (final candidate in known) {
      final score = _similarityScore(normalized, candidate);
      if (score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }
    return bestScore >= 0.76 ? best : normalized;
  }

  /// Public wrapper for celebrity detection.
  ///
  /// - `flexible: true`  -> tournament/duel flows (more permissive)
  /// - `flexible: false` -> normal scanner classification (stricter)
  bool checkIsCelebrity(String name, {bool flexible = true}) =>
      _isCelebrity(name, flexible: flexible);

  bool _isCelebrity(String name, {required bool flexible}) {
    final inputName = _resolveAlias(name);
    if (inputName.isEmpty) return false;

    final inputTokens = inputName.split(' ').where((e) => e.isNotEmpty).toList();
    if (inputTokens.isEmpty) return false;

    final isSingleTokenInput = inputTokens.length == 1;
    final inputToken = isSingleTokenInput ? inputTokens.first : '';

    // En modo estricto, nombres de una sola palabra MUY comunes
    // no deben activar modo celebridad.
    if (!flexible && isSingleTokenInput && inputToken.length <= 5) {
      return false;
    }

    final exactScoreThreshold = flexible ? 0.86 : 0.93;
    final singleTokenMinLength = flexible ? 5 : 6;
    final singleTokenSimilarityThreshold = flexible ? 0.86 : 0.95;
    final multiTokenAvgThreshold = flexible ? 0.80 : 0.88;
    final multiTokenCoverageThreshold = flexible ? 0.75 : 0.90;

    for (final celebrity in celebrities) {
      final celebName = _resolveAlias(celebrity);

      if (celebName == inputName) return true;

      final exactScore = _similarityScore(inputName, celebName);
      if (exactScore >= exactScoreThreshold) return true;

      final celebTokens = celebName.split(' ').where((e) => e.isNotEmpty).toList();
      if (celebTokens.isEmpty) continue;

      int strongMatches = 0;
      double tokenScoreSum = 0;

      for (final inputToken in inputTokens) {
        double bestTokenScore = 0;
        for (final celebToken in celebTokens) {
          final score = _similarityScore(inputToken, celebToken);
          if (score > bestTokenScore) bestTokenScore = score;
        }
        tokenScoreSum += bestTokenScore;
        if (bestTokenScore >= 0.82) strongMatches++;
      }

      final tokenAvg = tokenScoreSum / inputTokens.length;
      final inputCoverage = strongMatches / inputTokens.length;

      if (inputTokens.length == 1) {
        final token = inputTokens.first;
        if (token.length >= singleTokenMinLength) {
          final hasClose = celebTokens.any(
            (ct) =>
                _similarityScore(token, ct) >=
                singleTokenSimilarityThreshold,
          );
          if (hasClose) return true;
        }
      } else {
        if (tokenAvg >= multiTokenAvgThreshold &&
            inputCoverage >= multiTokenCoverageThreshold) {
          return true;
        }
      }
    }

    return false;
  }

  String _getRandomEmoji() {
    final random = Random();
    return _emojis[random.nextInt(_emojis.length)];
  }

  bool _isLikelyGibberish(String value) {
    final normalized = _normalizeText(value)
        .replaceAll(RegExp(r'[^a-z]'), '')
        .trim();
    if (normalized.length < 3) return true;

    final hasVowel = RegExp(r'[aeiou]').hasMatch(normalized);
    if (!hasVowel) return true;

    if (RegExp(r'(.)\1{3,}').hasMatch(normalized)) return true;
    if (RegExp(r'[bcdfghjklmnpqrstvwxyz]{6,}').hasMatch(normalized)) return true;
    if (RegExp(r'(ja|je|ji|jo|ju|ha|he|hi|ho|hu){2,}', caseSensitive: false)
        .hasMatch(normalized)) {
      return true;
    }

    final vowelsCount = RegExp(r'[aeiou]').allMatches(normalized).length;
    final vowelRatio = vowelsCount / normalized.length;
    if (normalized.length >= 8 && vowelRatio < 0.2) return true;

    final weirdConsonantChunks = RegExp(r'[bcdfghjklmnpqrstvwxyz]{4,}')
        .allMatches(normalized)
        .length;
    if (normalized.length >= 8 && weirdConsonantChunks >= 2) return true;

    final uniqueChars = normalized.split('').toSet().length;
    if (normalized.length >= 6 && uniqueChars <= 2) return true;

    return false;
  }

  String _randomInvalidNamesMessage(AppLocalizations localizations) {
    final isEn = localizations.localeName.toLowerCase().startsWith('en');
    final random = Random();

    final esMessages = <String>[
      'El algoritmo del amor acaba de decir: “eso no parece nombre, parece contraseña del Wi‑Fi”. Probemos con nombres reales 😄💘',
      'Uy, esos nombres vienen con modo meme activado. Dame nombres auténticos y te doy química de verdad 💞',
      'Nuestro radar romántico detectó puro ruido bonito. Intentemos de nuevo con nombres reales ✨',
      'Esa combinación está muy troll para el Cupido digital. Pon nombres válidos y lo volvemos magia 💖',
      'Jajaja te caché en modo broma 😜. Ahora sí, pon nombres reales para un resultado épico 💫',
    ];

    final enMessages = <String>[
      'Love algorithm detected out-of-range names. Use real names for a reliable scan ✨',
      'Hmm... those look more like secret codes than real crush names. Try valid names 💘',
      'Our romantic radar detected noisy names. Please use authentic names 💞',
      'Those inputs are too chaotic for the scanner. Use real names and we\'ll analyze again 💖',
    ];

    final list = isEn ? enMessages : esMessages;
    return list[random.nextInt(list.length)];
  }

  String? _validateNamesForScanner(
    String userName,
    String crushName,
    AppLocalizations localizations,
  ) {
    final cleanUser = userName.trim();
    final cleanCrush = crushName.trim();

    final onlyLettersUser = _normalizeText(cleanUser)
        .replaceAll(RegExp(r'[^a-z ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final onlyLettersCrush = _normalizeText(cleanCrush)
        .replaceAll(RegExp(r'[^a-z ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final weirdTokensRegex = RegExp(r'\b(ja|je|ji|jo|ju|ha|he|hi|ho|hu){2,}\b', caseSensitive: false);

    final hasTooManySymbols =
        RegExp(r'[^A-Za-zÀ-ÿ\s]').hasMatch(cleanUser) ||
        RegExp(r'[^A-Za-zÀ-ÿ\s]').hasMatch(cleanCrush);

    if (onlyLettersUser.length < 2 || onlyLettersCrush.length < 2) {
      return _randomInvalidNamesMessage(localizations);
    }

    if (hasTooManySymbols) {
      return _randomInvalidNamesMessage(localizations);
    }

    if (weirdTokensRegex.hasMatch(cleanUser) || weirdTokensRegex.hasMatch(cleanCrush)) {
      return _randomInvalidNamesMessage(localizations);
    }

    if (_isLikelyGibberish(onlyLettersUser) || _isLikelyGibberish(onlyLettersCrush)) {
      return _randomInvalidNamesMessage(localizations);
    }

    return null;
  }

  String? _sameNamePlayfulMessage(
    String userName,
    String crushName,
    AppLocalizations localizations,
  ) {
    final isEn = localizations.localeName.toLowerCase().startsWith('en');
    final a = _normalizeText(userName).replaceAll(RegExp(r'[^a-z ]'), '').trim();
    final b = _normalizeText(crushName).replaceAll(RegExp(r'[^a-z ]'), '').trim();
    if (a.isEmpty || b.isEmpty || a != b) return null;

    return isEn
        ? 'Double-name mode unlocked: two people, one legendary name. This could be destiny with matching labels 💫😄'
        : 'Modo nombre gemelo activado: dos personas, un mismo nombre legendario. Aquí puede haber destino con etiqueta repetida 💫😄';
  }

  String? _getSpecialPairMessage(
    String userName,
    String crushName,
    AppLocalizations localizations,
  ) {
    final sameNameMessage = _sameNamePlayfulMessage(
      userName,
      crushName,
      localizations,
    );
    if (sameNameMessage != null) {
      return sameNameMessage;
    }

    final isEn = localizations.localeName.toLowerCase().startsWith('en');
    final a = _canonicalizeFigureIntent(userName);
    final b = _canonicalizeFigureIntent(crushName);
    final pair = {a, b};

    bool containsBoth(List<String> names) => names.every((name) => pair.contains(name));

    if (containsBoth(['vladimir putin', 'volodymyr zelensky']) ||
        containsBoth(['vladimir putin', 'zelensky']) ||
        containsBoth(['putin', 'zelensky'])) {
      return isEn
          ? 'Diplomatic chemistry alert: this duo has the world talking. Intense vibes in every dimension 🌍🔥'
          : 'Alerta diplomática: esta dupla tiene al mundo hablando. Energía intensa en todas las dimensiones 🌍🔥';
    }

    if (containsBoth(['donald trump', 'joe biden']) ||
        containsBoth(['trump', 'biden'])) {
      return isEn
          ? 'This political match is pure debate energy: sparks, tension and unexpected twists ⚡🗳️'
          : 'Este match político viene cargado de debate: chispas, tensión y giros inesperados ⚡🗳️';
    }

    if (containsBoth(['lionel messi', 'cristiano ronaldo']) ||
        containsBoth(['messi', 'ronaldo'])) {
      return isEn
          ? 'Legendary rivalry detected: this match plays in Champions League mode only 🏆💥'
          : 'Rivalidad legendaria detectada: este match se juega en modo Champions League 🏆💥';
    }

    return null;
  }

  Future<CrushResult> generateResult(
    String userName,
    String crushName,
    AppLocalizations localizations,
  ) async {
    // Check if we already have a result for this combination
    final existingResult = await getSavedResult(userName, crushName);
    if (existingResult != null) {
      return existingResult;
    }

    final validationMessage = _validateNamesForScanner(
      userName,
      crushName,
      localizations,
    );
    if (validationMessage != null) {
      throw FormatException(validationMessage);
    }

    // Check if crush is a celebrity
    final isCelebrity = _isCelebrity(crushName, flexible: false);

    // Generate new result
    final percentage = _generateCompatibilityPercentage(userName, crushName);
    final dimensions = generateDimensions(userName, crushName);
    final message = _getSpecialPairMessage(userName, crushName, localizations) ??
        _getRandomMessage(
          percentage,
          localizations,
          isCelebrity: isCelebrity,
        );
    final emoji = _getRandomEmoji();

    final result = CrushResult(
      userName: userName,
      crushName: crushName,
      percentage: percentage,
      message: message,
      emoji: emoji,
      timestamp: SecureTimeService.instance.getSecureTime(),
      isCelebrity: isCelebrity,
      emotionalScore: dimensions['emotional']!,
      passionScore: dimensions['passion']!,
      intellectualScore: dimensions['intellectual']!,
      destinyScore: dimensions['destiny']!,
    );

    // Update statistics
    await DailyLoveService.instance.incrementTotalScans();
    await DailyLoveService.instance.addCompatibilityScore(
      percentage.toDouble(),
    );

    // Save result
    await _saveResult(result);

    return result;
  }

  // Método alternativo para cuando AppLocalizations no está disponible
  Future<CrushResult> generateSimpleResult(
    String userName,
    String crushName,
  ) async {
    // Check if we already have a result for this combination
    final existingResult = await getSavedResult(userName, crushName);
    if (existingResult != null) {
      return existingResult;
    }

    final simpleLettersA = _normalizeText(userName).replaceAll(RegExp(r'[^a-z ]'), '').trim();
    final simpleLettersB = _normalizeText(crushName).replaceAll(RegExp(r'[^a-z ]'), '').trim();
    if (simpleLettersA.length < 2 ||
        simpleLettersB.length < 2 ||
        _isLikelyGibberish(simpleLettersA) ||
        _isLikelyGibberish(simpleLettersB)) {
      throw const FormatException('Invalid names detected. Please use real names.');
    }

    // Check if crush is a celebrity
    final isCelebrity = _isCelebrity(crushName, flexible: false);

    // Generate new result with default English messages
    final percentage = _generateCompatibilityPercentage(userName, crushName);
    final dimensions = generateDimensions(userName, crushName);
    final message = _getSimpleMessage(percentage, isCelebrity: isCelebrity);
    final emoji = _getRandomEmoji();

    final result = CrushResult(
      userName: userName,
      crushName: crushName,
      percentage: percentage,
      message: message,
      emoji: emoji,
      timestamp: SecureTimeService.instance.getSecureTime(),
      isCelebrity: isCelebrity,
      emotionalScore: dimensions['emotional']!,
      passionScore: dimensions['passion']!,
      intellectualScore: dimensions['intellectual']!,
      destinyScore: dimensions['destiny']!,
    );

    // Update statistics
    await DailyLoveService.instance.incrementTotalScans();
    await DailyLoveService.instance.addCompatibilityScore(
      percentage.toDouble(),
    );

    // Save result
    await _saveResult(result);

    return result;
  }

  // Método para obtener mensajes simples sin localización
  String _getSimpleMessage(int percentage, {bool isCelebrity = false}) {
    final random = Random();

    if (isCelebrity) {
      final messages = [
        "You have great taste in celebrities! ⭐",
        "This celebrity crush makes perfect sense! 💫",
        "Your celebrity match has potential! 🌟",
        "This is a classic celebrity crush! ✨",
        "You and this star could be perfect together! 🎬",
      ];
      return messages[random.nextInt(messages.length)];
    }

    if (percentage >= 80) {
      final messages = [
        "This could be your perfect match! 💕",
        "The stars are perfectly aligned! ✨",
        "You two are meant to be together! 💖",
        "This is true love material! 💘",
        "Your hearts beat as one! 💓",
      ];
      return messages[random.nextInt(messages.length)];
    } else if (percentage >= 60) {
      final messages = [
        "There's definitely something special here! 💫",
        "The chemistry is undeniable! ⚡",
        "This connection has real potential! 🌟",
        "Your energies complement each other! 💜",
        "Something beautiful could blossom here! 🌸",
      ];
      return messages[random.nextInt(messages.length)];
    } else if (percentage >= 45) {
      final messages = [
        "A fun adventure awaits! 🎉",
        "This could be an interesting journey! 🚀",
        "You bring out each other's playful side! 😄",
        "Great friendship with romantic potential! 💛",
        "Your connection is full of surprises! 🎈",
      ];
      return messages[random.nextInt(messages.length)];
    } else {
      final messages = [
        "Sometimes opposites attract! 🧲",
        "Friendship might be the perfect foundation! 👫",
        "Every connection teaches us something! 📚",
        "The universe has interesting plans! 🌌",
        "Compatibility comes in many forms! 💫",
      ];
      return messages[random.nextInt(messages.length)];
    }
  }

  Future<void> _saveResult(CrushResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        '${result.userName.toLowerCase()}_${result.crushName.toLowerCase()}';
    final jsonString = jsonEncode(result.toJson());
    await prefs.setString('result_$key', jsonString);
  }

  Future<CrushResult?> getSavedResult(String userName, String crushName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${userName.toLowerCase()}_${crushName.toLowerCase()}';
    final jsonString = prefs.getString('result_$key');

    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      return CrushResult.fromJson(json);
    }

    return null;
  }

  Future<List<CrushResult>> getAllSavedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((key) => key.startsWith('result_')).toList();
    final results = <CrushResult>[];

    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString);
          var result = CrushResult.fromJson(json);

          // Fix any invalid percentages (outside 35-98 range)
          if (result.percentage < 35 || result.percentage > 98) {
            // Recalculate with fixed algorithm
            final correctedPercentage = _generateCompatibilityPercentage(
              result.userName,
              result.crushName,
            );

            // Create corrected result
            result = CrushResult(
              userName: result.userName,
              crushName: result.crushName,
              percentage: correctedPercentage,
              message: result.message,
              emoji: result.emoji,
              timestamp: result.timestamp,
              isCelebrity: result.isCelebrity,
            );

            // Save corrected result
            await _saveResult(result);
          }

          results.add(result);
        } catch (e) {
          // Skip corrupted results
          continue;
        }
      }
    }

    // Sort by timestamp (newest first)
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  /// Clean up any invalid results with percentages outside valid range
  /// Limpiar resultados inválidos con porcentajes fuera del rango válido
  Future<void> fixInvalidResults() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((key) => key.startsWith('result_')).toList();

    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString);
          final result = CrushResult.fromJson(json);

          // Check if percentage is invalid
          if (result.percentage < 35 || result.percentage > 98) {
            // Recalculate with fixed algorithm
            final correctedPercentage = _generateCompatibilityPercentage(
              result.userName,
              result.crushName,
            );

            // Create corrected result
            final correctedResult = CrushResult(
              userName: result.userName,
              crushName: result.crushName,
              percentage: correctedPercentage,
              message: result.message,
              emoji: result.emoji,
              timestamp: result.timestamp,
              isCelebrity: result.isCelebrity,
            );

            // Save corrected result
            await _saveResult(correctedResult);
          }
        } catch (e) {
          // Remove corrupted results
          await prefs.remove(key);
        }
      }
    }
  }

  /// Clears all saved crush results from storage
  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('result_')).toList();
    
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

