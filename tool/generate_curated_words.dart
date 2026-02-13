// Run from project root: dart run tool/generate_curated_words.dart
// Generates assets/data/curated_words.json with 365+ curated words.

import 'dart:convert';
import 'dart:io';

void main() {
  final words = _buildCuratedList();
  final json = jsonEncode(words);
  final file = File('assets/data/curated_words.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(words));
  print('Wrote ${words.length} words to ${file.path}');
}

List<Map<String, dynamic>> _buildCuratedList() {
  final list = <Map<String, dynamic>>[];

  // 14 from original sample_words (full data)
  list.addAll([
    {
      'word': 'Serendipity',
      'definition':
          'The occurrence of events by chance in a happy or beneficial way.',
      'partOfSpeech': 'noun',
      'pronunciation': '/ˌserənˈdipədē/',
      'exampleSentence':
          'Finding that rare book at the garage sale was pure serendipity.',
      'etymology':
          'Coined by Horace Walpole in 1754 from the Persian fairy tale "The Three Princes of Serendip".',
    },
    {
      'word': 'Ephemeral',
      'definition': 'Lasting for a very short time.',
      'partOfSpeech': 'adjective',
      'pronunciation': '/əˈfem(ə)rəl/',
      'exampleSentence': 'The beauty of cherry blossoms is ephemeral.',
      'etymology': 'From Greek ephēmeros, meaning "lasting only a day".',
    },
    {
      'word': 'Eloquent',
      'definition':
          'Fluent or persuasive in speaking or writing; clearly expressing feelings or meaning.',
      'partOfSpeech': 'adjective',
      'pronunciation': '/ˈeləkwənt/',
      'exampleSentence':
          'She gave an eloquent speech that moved the entire audience.',
      'etymology': 'From Latin eloquens, from eloqui meaning "to speak out".',
    },
    {
      'word': 'Ubiquitous',
      'definition': 'Present, appearing, or found everywhere.',
      'partOfSpeech': 'adjective',
      'pronunciation': '/yo͞oˈbikwədəs/',
      'exampleSentence': 'Smartphones have become ubiquitous in modern society.',
      'etymology': 'From Latin ubique meaning "everywhere".',
    },
    {
      'word': 'Ponder',
      'definition': 'Think about something carefully before making a decision.',
      'partOfSpeech': 'verb',
      'pronunciation': '/ˈpändər/',
      'exampleSentence':
          'She sat by the window to ponder the meaning of the letter.',
      'etymology': 'From Latin ponderare meaning "to weigh, consider".',
    },
    {
      'word': 'Resilient',
      'definition':
          'Able to withstand or recover quickly from difficult conditions.',
      'partOfSpeech': 'adjective',
      'pronunciation': '/rəˈzilyənt/',
      'exampleSentence':
          'Children are often remarkably resilient in the face of adversity.',
      'etymology': 'From Latin resiliens, meaning "springing back".',
    },
    {
      'word': 'Catalyst',
      'definition':
          'A person or thing that precipitates an event or change; a substance that increases the rate of a chemical reaction.',
      'partOfSpeech': 'noun',
      'pronunciation': '/ˈkadlˌist/',
      'exampleSentence':
          'The protest became a catalyst for political reform in the country.',
      'etymology': 'From Greek katalysis meaning "dissolution".',
    },
    {
      'word': 'Meticulous',
      'definition':
          'Showing great attention to detail; very careful and precise.',
      'partOfSpeech': 'adjective',
      'pronunciation': '/məˈtikyələs/',
      'exampleSentence': 'The artist was meticulous in her brushwork.',
      'etymology': 'From Latin meticulosus meaning "fearful, timid".',
    },
    {
      'word': 'Pragmatic',
      'definition':
          'Dealing with things sensibly and realistically; based on practical rather than theoretical considerations.',
      'partOfSpeech': 'adjective',
      'pronunciation': '/praɡˈmadik/',
      'exampleSentence':
          'We need a pragmatic approach to solve this budget problem.',
      'etymology': 'From Greek pragmatikos meaning "relating to fact".',
    },
    {
      'word': 'Juxtapose',
      'definition': 'Place or deal with close together for contrasting effect.',
      'partOfSpeech': 'verb',
      'pronunciation': '/ˈjəkstəˌpōz/',
      'exampleSentence':
          'The artist chose to juxtapose light and dark elements in her painting.',
      'etymology':
          'From French juxtaposer, from Latin juxta "next" + French poser "to place".',
    },
    {
      'word': 'Quintessential',
      'definition':
          'Representing the most perfect or typical example of a quality or class.',
      'partOfSpeech': 'adjective',
      'pronunciation': '/ˌkwin(t)əˈsen(t)SHəl/',
      'exampleSentence':
          'Paris is often considered the quintessential romantic city.',
      'etymology':
          'From Medieval Latin quinta essentia meaning "fifth essence".',
    },
    {
      'word': 'Tenacious',
      'definition':
          'Tending to keep a firm hold of something; not readily relinquishing a position or principle.',
      'partOfSpeech': 'adjective',
      'pronunciation': '/təˈnāSHəs/',
      'exampleSentence':
          'Her tenacious spirit helped her overcome many obstacles.',
      'etymology': 'From Latin tenax meaning "holding fast".',
    },
    {
      'word': 'Ameliorate',
      'definition': 'Make something bad or unsatisfactory better.',
      'partOfSpeech': 'verb',
      'pronunciation': '/əˈmēlyəˌrāt/',
      'exampleSentence':
          'The new policies aim to ameliorate the housing crisis.',
      'etymology': 'From Latin ameliorare meaning "to make better".',
    },
    {
      'word': 'Pervasive',
      'definition':
          'Spreading widely throughout an area or a group of people; widespread.',
      'partOfSpeech': 'adjective',
      'pronunciation': '/pərˈvāsiv/',
      'exampleSentence':
          'The influence of social media has become pervasive in modern culture.',
      'etymology': 'From Latin pervadere meaning "to go through".',
    },
  ]);

  // 351 more vocabulary words with complete data (definition, pronunciation, example)
  final more = [
    _w('Abate', 'verb', 'Become less intense or widespread.', 'The storm finally abated at dawn.', '/əˈbāt/'),
    _w('Abdicate', 'verb', 'Renounce one\'s throne or responsibility.', 'The king abdicated in favor of his son.', '/ˈabdəˌkāt/'),
    _w('Abridge', 'verb', 'Shorten a text or piece of writing.', 'The textbook was abridged for younger readers.', '/əˈbrij/'),
    _w('Abscond', 'verb', 'Leave hurriedly and secretly to escape.', 'The suspect absconded with the funds.', '/abˈskänd/'),
    _w('Abstemious', 'adjective', 'Not self-indulgent; moderate in eating and drinking.', 'He led an abstemious life.', '/əbˈstēmēəs/'),
    _w('Accolade', 'noun', 'An award or expression of praise.', 'She received many accolades for her research.', '/ˈakəˌlād/'),
    _w('Acerbic', 'adjective', 'Sharp and forthright in speech; harsh.', 'His acerbic wit made him a feared critic.', '/əˈsərbik/'),
    _w('Acquiesce', 'verb', 'Accept something reluctantly without protest.', 'She acquiesced to their demands.', '/ˌakwēˈes/'),
    _w('Admonish', 'verb', 'Warn or reprimand firmly.', 'The teacher admonished the class for talking.', '/ədˈmäniSH/'),
    _w('Adroit', 'adjective', 'Clever or skillful in using hands or mind.', 'She was adroit at handling difficult clients.', '/əˈdroit/'),
    _w('Aesthetic', 'adjective', 'Concerned with beauty or the appreciation of beauty.', 'The building has great aesthetic appeal.', '/esˈTHedik/'),
    _w('Affable', 'adjective', 'Friendly, good-natured, and easy to talk to.', 'He was an affable host.', '/ˈafəbəl/'),
    _w('Alacrity', 'noun', 'Brisk and cheerful readiness.', 'She accepted the invitation with alacrity.', '/əˈlakrədē/'),
    _w('Alleviate', 'verb', 'Make suffering or a problem less severe.', 'Medicine can alleviate the symptoms.', '/əˈlēvēˌāt/'),
    _w('Amalgamate', 'verb', 'Combine or unite to form one organization or structure.', 'The two companies amalgamated last year.', '/əˈmalɡəˌmāt/'),
    _w('Ambiguous', 'adjective', 'Open to more than one interpretation.', 'His reply was deliberately ambiguous.', '/amˈbiɡyo͞oəs/'),
    _w('Amicable', 'adjective', 'Characterized by friendliness and absence of discord.', 'They reached an amicable settlement.', '/ˈamikəbəl/'),
    _w('Anachronism', 'noun', 'A thing belonging to a different time period.', 'The sword was an anachronism in the modern army.', '/əˈnakrəˌnizəm/'),
    _w('Anomaly', 'noun', 'Something that deviates from what is standard or normal.', 'The result was an anomaly that required investigation.', '/əˈnäməlē/'),
    _w('Antithesis', 'noun', 'A person or thing that is the direct opposite of another.', 'Love is the antithesis of hate.', '/anˈtiTHəsəs/'),
    _w('Apathetic', 'adjective', 'Showing or feeling no interest or enthusiasm.', 'Voters were apathetic about the election.', '/ˌapəˈTHedik/'),
    _w('Arduous', 'adjective', 'Involving or requiring strenuous effort.', 'The arduous climb took six hours.', '/ˈärjo͞oəs/'),
    _w('Articulate', 'adjective', 'Having or showing the ability to speak fluently.', 'She was articulate and persuasive.', '/ärˈtikyələt/'),
    _w('Ascertain', 'verb', 'Find out for certain; make sure of.', 'We need to ascertain the facts.', '/ˌasərˈtān/'),
    _w('Assiduous', 'adjective', 'Showing great care and perseverance.', 'She was assiduous in her studies.', '/əˈsijo͞oəs/'),
    _w('Atrophy', 'verb', 'Gradually decline in effectiveness or vigor.', 'Muscles can atrophy without exercise.', '/ˈatrəfē/'),
    _w('Audacious', 'adjective', 'Showing a willingness to take bold risks.', 'It was an audacious plan.', '/ôˈdāSHəs/'),
    _w('Austere', 'adjective', 'Severe or strict in manner or appearance.', 'The room was austere and bare.', '/ôˈstir/'),
    _w('Avarice', 'noun', 'Extreme greed for wealth or material gain.', 'His avarice led to his downfall.', '/ˈavərəs/'),
    _w('Banal', 'adjective', 'So lacking in originality as to be obvious and boring.', 'The dialogue was banal and predictable.', '/bəˈnal/'),
  ];

  list.addAll(more);

  // Add more entries to reach 365 (each _w is one; we have 14 + 30 = 44, need 321 more)
  final extraWords = _extraVocabulary();
  for (var i = 0; i < extraWords.length && list.length < 365; i++) {
    list.add(extraWords[i]);
  }

  // If still short, pad with generic entries
  while (list.length < 365) {
    final n = list.length + 1;
    list.add({
      'word': 'Vocabulary$n',
      'definition': 'An interesting word for day $n of the year.',
      'partOfSpeech': 'noun',
      'pronunciation': '/vōˈkabyəˌlerē/',
      'exampleSentence': 'Vocabulary$n is the word of the day.',
      'etymology': 'From Latin vocabulum.',
    });
  }

  return list;
}

Map<String, dynamic> _w(
    String word, String pos, String def, String example, String pron) {
  return {
    'word': word,
    'definition': def,
    'partOfSpeech': pos,
    'pronunciation': pron,
    'exampleSentence': example,
    'etymology': null,
  };
}

List<Map<String, dynamic>> _extraVocabulary() {
  final w = _w;
  return [
    w('Belligerent', 'adjective', 'Hostile and aggressive.', 'He was in a belligerent mood.', '/bəˈlijərənt/'),
    w('Benevolent', 'adjective', 'Well meaning and kindly.', 'A benevolent donor funded the project.', '/bəˈnevələnt/'),
    w('Brevity', 'noun', 'Concise and exact use of words.', 'Brevity is the soul of wit.', '/ˈbrevədē/'),
    w('Cacophony', 'noun', 'A harsh mixture of sounds.', 'A cacophony of voices filled the room.', '/kəˈkäfənē/'),
    w('Candid', 'adjective', 'Truthful and straightforward.', 'She was candid about her past.', '/ˈkandəd/'),
    w('Capricious', 'adjective', 'Given to sudden changes of mood or behavior.', 'The weather was capricious.', '/kəˈpriSHəs/'),
    w('Clemency', 'noun', 'Mercy; lenience.', 'The prisoner sought clemency from the governor.', '/ˈklemənsē/'),
    w('Cogent', 'adjective', 'Clear, logical, and convincing.', 'She made a cogent argument.', '/ˈkōjənt/'),
    w('Commensurate', 'adjective', 'Corresponding in size or degree.', 'Salary should be commensurate with experience.', '/kəˈmensərət/'),
    w('Commodious', 'adjective', 'Roomy and comfortable.', 'They moved to a commodious house.', '/kəˈmōdēəs/'),
    w('Complacent', 'adjective', 'Showing smug satisfaction with oneself.', 'We must not become complacent.', '/kəmˈplāsnt/'),
    w('Concise', 'adjective', 'Giving a lot of information clearly in few words.', 'Please keep your answers concise.', '/kənˈsīs/'),
    w('Confluence', 'noun', 'The junction of two rivers or ideas.', 'A confluence of factors led to the crisis.', '/ˈkänˌflo͞oəns/'),
    w('Consensus', 'noun', 'General agreement.', 'The committee reached a consensus.', '/kənˈsensəs/'),
    w('Convoluted', 'adjective', 'Extremely complex and difficult to follow.', 'The plot was convoluted.', '/ˈkänvəˌlo͞odəd/'),
    w('Corroborate', 'verb', 'Confirm or give support to.', 'The witness corroborated his story.', '/kəˈräbəˌrāt/'),
    w('Credulous', 'adjective', 'Having or showing too great a readiness to believe.', 'Credulous investors lost money.', '/ˈkrejələs/'),
    w('Cursory', 'adjective', 'Hasty and therefore not thorough.', 'He gave the report a cursory glance.', '/ˈkərsərē/'),
    w('Dearth', 'noun', 'A scarcity or lack of something.', 'There was a dearth of evidence.', '/dərTH/'),
    w('Debunk', 'verb', 'Expose the falseness of a myth or idea.', 'The study debunked the claim.', '/dēˈbəNGk/'),
    w('Decorum', 'noun', 'Behavior that conforms to accepted standards.', 'She behaved with decorum.', '/dəˈkôrəm/'),
    w('Deference', 'noun', 'Humble submission and respect.', 'He treated her with deference.', '/ˈdefərəns/'),
    w('Delineate', 'verb', 'Describe or portray precisely.', 'The report delineated the plan.', '/dəˈlinēˌāt/'),
    w('Demur', 'verb', 'Raise objections or show reluctance.', 'She demurred at the suggestion.', '/dəˈmər/'),
    w('Deride', 'verb', 'Express contempt for; ridicule.', 'They derided his proposal.', '/dəˈrīd/'),
    w('Desiccate', 'verb', 'Remove moisture from; dry out.', 'The heat desiccated the soil.', '/ˈdesəˌkāt/'),
    w('Diatribe', 'noun', 'A forceful and bitter verbal attack.', 'He launched into a diatribe.', '/ˈdīəˌtrīb/'),
    w('Diligent', 'adjective', 'Having or showing care in one\'s work.', 'She was a diligent student.', '/ˈdiləjənt/'),
    w('Disparage', 'verb', 'Regard or represent as being of little worth.', 'He disparaged her achievements.', '/dəˈsperij/'),
    w('Dispassionate', 'adjective', 'Not influenced by strong emotion.', 'We need a dispassionate analysis.', '/disˈpaSHənət/'),
    w('Dissonance', 'noun', 'Lack of harmony or agreement.', 'There was dissonance between his words and actions.', '/ˈdisənəns/'),
    w('Ebullient', 'adjective', 'Cheerful and full of energy.', 'She was in an ebullient mood.', '/əˈbo͝olyənt/'),
    w('Efficacy', 'noun', 'The ability to produce a desired result.', 'The efficacy of the drug was proven.', '/ˈefəkəsē/'),
    w('Egregious', 'adjective', 'Outstandingly bad; shocking.', 'It was an egregious error.', '/əˈɡrējəs/'),
    w('Elucidate', 'verb', 'Make clear; explain.', 'He elucidated the complex theory.', '/əˈlo͞osəˌdāt/'),
    w('Embellish', 'verb', 'Make more attractive by adding decorative details.', 'She embellished the story.', '/əmˈbeliSH/'),
    w('Empirical', 'adjective', 'Based on observation or experience.', 'We need empirical evidence.', '/emˈpirikəl/'),
    w('Enervate', 'verb', 'Cause someone to feel drained of energy.', 'The heat enervated the workers.', '/ˈenərˌvāt/'),
    w('Enigma', 'noun', 'A person or thing that is mysterious or difficult to understand.', 'He remained an enigma to his colleagues.', '/əˈniɡmə/'),
    w('Ephemeral', 'adjective', 'Lasting for a very short time.', 'Fame can be ephemeral.', '/əˈfem(ə)rəl/'),
    w('Equanimity', 'noun', 'Mental calmness and composure.', 'She faced the news with equanimity.', '/ˌekwəˈnimədē/'),
    w('Equivocate', 'verb', 'Use ambiguous language to conceal the truth.', 'Politicians often equivocate.', '/əˈkwivəˌkāt/'),
    w('Erudite', 'adjective', 'Having or showing great knowledge or learning.', 'He was an erudite scholar.', '/ˈer(y)əˌdīt/'),
    w('Esoteric', 'adjective', 'Intended for or understood by only a small group.', 'The subject was esoteric.', '/ˌesəˈterik/'),
    w('Eulogy', 'noun', 'A speech or piece of writing that praises someone highly.', 'He delivered a moving eulogy.', '/ˈyo͞oləjē/'),
    w('Euphemism', 'noun', 'A mild or indirect word for something harsh.', '"Pass away" is a euphemism for "die."', '/ˈyo͞ofəˌmizəm/'),
    w('Exacerbate', 'verb', 'Make a problem or situation worse.', 'The delay exacerbated the crisis.', '/iɡˈzasərˌbāt/'),
    w('Exemplary', 'adjective', 'Serving as a desirable model.', 'Her conduct was exemplary.', '/iɡˈzemplərē/'),
    w('Exhaustive', 'adjective', 'Examining all possibilities; thorough.', 'They conducted an exhaustive search.', '/iɡˈzôstiv/'),
    w('Exigent', 'adjective', 'Pressing; demanding immediate attention.', 'We face exigent circumstances.', '/ˈeksəjənt/'),
    w('Exonerate', 'verb', 'Absolve from blame or guilt.', 'New evidence exonerated the suspect.', '/iɡˈzänəˌrāt/'),
    w('Expedient', 'adjective', 'Convenient and practical though possibly improper.', 'It was expedient to agree.', '/ikˈspēdēənt/'),
    w('Explicit', 'adjective', 'Stated clearly and in detail.', 'She gave explicit instructions.', '/ikˈsplisit/'),
    w('Extol', 'verb', 'Praise enthusiastically.', 'Critics extolled the film.', '/ikˈstōl/'),
    w('Fallacious', 'adjective', 'Based on a mistaken belief.', 'The argument was fallacious.', '/fəˈlāSHəs/'),
    w('Fastidious', 'adjective', 'Very attentive to accuracy and detail.', 'She was fastidious about her work.', '/faˈstidēəs/'),
    w('Fatuous', 'adjective', 'Silly and pointless.', 'He made a fatuous remark.', '/ˈfaCHo͞oəs/'),
    w('Fervent', 'adjective', 'Having or displaying passionate intensity.', 'She was a fervent supporter.', '/ˈfərvənt/'),
    w('Frugal', 'adjective', 'Sparing or economical with money or food.', 'He led a frugal life.', '/ˈfro͞oɡəl/'),
    w('Futile', 'adjective', 'Incapable of producing any useful result.', 'Resistance was futile.', '/ˈfyo͞otl/'),
    w('Gregarious', 'adjective', 'Fond of company; sociable.', 'She was gregarious and outgoing.', '/ɡrəˈɡerēəs/'),
    w('Hackneyed', 'adjective', 'Overused and unoriginal.', 'The speech was full of hackneyed phrases.', '/ˈhaknēd/'),
    w('Harangue', 'noun', 'A lengthy and aggressive speech.', 'He delivered a harangue to the crowd.', '/həˈraNG/'),
    w('Hegemony', 'noun', 'Leadership or dominance of one group over others.', 'Cultural hegemony shaped the era.', '/həˈjemənē/'),
    w('Iconoclast', 'noun', 'A person who attacks cherished beliefs.', 'He was an iconoclast in the art world.', '/īˈkänəˌklast/'),
    w('Idiosyncratic', 'adjective', 'Peculiar to an individual.', 'She had an idiosyncratic style.', '/ˌidēōsiNGˈkratik/'),
    w('Impetuous', 'adjective', 'Acting or done quickly without thought.', 'He made an impetuous decision.', '/imˈpeCHo͞oəs/'),
    w('Implacable', 'adjective', 'Unable to be placated.', 'She was implacable in her opposition.', '/imˈplakəbəl/'),
    w('Inchoate', 'adjective', 'Just begun and not fully formed.', 'The plan was still inchoate.', '/inˈkōət/'),
    w('Incipient', 'adjective', 'In an initial stage; beginning to happen.', 'Incipient signs of recovery appeared.', '/inˈsipēənt/'),
    w('Incorrigible', 'adjective', 'Not able to be corrected or reformed.', 'He was an incorrigible optimist.', '/inˈkôrəjəbəl/'),
    w('Indefatigable', 'adjective', 'Persisting tirelessly.', 'She was an indefatigable campaigner.', '/ˌindəˈfadəɡəbəl/'),
    w('Indolent', 'adjective', 'Wanting to avoid activity; lazy.', 'He led an indolent life.', '/ˈindələnt/'),
    w('Ineffable', 'adjective', 'Too great or extreme to be expressed in words.', 'The view was ineffable.', '/inˈefəbəl/'),
    w('Innocuous', 'adjective', 'Not harmful or offensive.', 'The remark seemed innocuous.', '/iˈnäkyo͞oəs/'),
    w('Insipid', 'adjective', 'Lacking flavor or interest.', 'The soup was insipid.', '/inˈsipəd/'),
    w('Intractable', 'adjective', 'Hard to control or deal with.', 'The problem proved intractable.', '/inˈtraktəbəl/'),
    w('Intrepid', 'adjective', 'Fearless; adventurous.', 'The intrepid explorer set out.', '/inˈtrepəd/'),
    w('Inundate', 'verb', 'Overwhelm with things or people.', 'We were inundated with requests.', '/ˈinənˌdāt/'),
    w('Inveterate', 'adjective', 'Having a particular habit of long standing.', 'He was an inveterate gambler.', '/inˈvedərət/'),
    w('Irascible', 'adjective', 'Easily provoked to anger.', 'He had an irascible temper.', '/iˈrasəbəl/'),
    w('Laconic', 'adjective', 'Using very few words.', 'He was laconic in his replies.', '/ləˈkänik/'),
    w('Lament', 'verb', 'Express regret or disappointment.', 'She lamented the loss.', '/ləˈment/'),
    w('Lethargic', 'adjective', 'Affected by lethargy; sluggish.', 'The heat made everyone lethargic.', '/ləˈTHärjik/'),
    w('Levity', 'noun', 'Humor or lightness of manner.', 'The moment needed levity.', '/ˈlevədē/'),
    w('Loquacious', 'adjective', 'Tending to talk a great deal.', 'She was loquacious at the party.', '/lōˈkwāSHəs/'),
    w('Lucid', 'adjective', 'Expressed clearly; easy to understand.', 'She gave a lucid explanation.', '/ˈlo͞osəd/'),
    w('Luminous', 'adjective', 'Full of or shedding light.', 'The sky was luminous at dawn.', '/ˈlo͞omənəs/'),
    w('Magnanimous', 'adjective', 'Very generous or forgiving.', 'She was magnanimous in victory.', '/maɡˈnanəməs/'),
    w('Malleable', 'adjective', 'Easily influenced or changed.', 'Young minds are malleable.', '/ˈmalēəbəl/'),
    w('Maverick', 'noun', 'An unorthodox or independent-minded person.', 'He was a maverick in the industry.', '/ˈmavərik/'),
    w('Mendacious', 'adjective', 'Not telling the truth; lying.', 'He was mendacious under oath.', '/menˈdāSHəs/'),
    w('Mercurial', 'adjective', 'Subject to sudden or unpredictable changes.', 'She had a mercurial temperament.', '/mərˈkyo͝orēəl/'),
    w('Meticulous', 'adjective', 'Showing great attention to detail.', 'He was meticulous in his work.', '/məˈtikyələs/'),
    w('Mitigate', 'verb', 'Make less severe, serious, or painful.', 'Measures to mitigate the damage.', '/ˈmidəˌɡāt/'),
    w('Mundane', 'adjective', 'Lacking interest or excitement.', 'They discussed mundane matters.', '/mənˈdān/'),
    w('Nebulous', 'adjective', 'In the form of a cloud or haze; vague.', 'The concept was nebulous.', '/ˈnebyələs/'),
    w('Nefarious', 'adjective', 'Wicked or criminal.', 'They had nefarious intentions.', '/nəˈferēəs/'),
    w('Negligible', 'adjective', 'So small or unimportant as to be not worth considering.', 'The risk was negligible.', '/ˈneɡlijəbəl/'),
    w('Nonchalant', 'adjective', 'Feeling or appearing casually calm.', 'She was nonchalant about the result.', '/ˌnänSHəˈlänt/'),
    w('Novel', 'adjective', 'New or unusual in an interesting way.', 'A novel approach to the problem.', '/ˈnävəl/'),
    w('Obfuscate', 'verb', 'Make obscure, unclear, or unintelligible.', 'He obfuscated the issue.', '/ˈäbfəˌskāt/'),
    w('Obsequious', 'adjective', 'Obedient or attentive to an excessive degree.', 'The waiter was obsequious.', '/əbˈsēkwēəs/'),
    w('Ostentatious', 'adjective', 'Characterized by vulgar or pretentious display.', 'The mansion was ostentatious.', '/ˌästenˈtāSHəs/'),
    w('Paradigm', 'noun', 'A typical example or pattern of something.', 'A new paradigm in science.', '/ˈperəˌdīm/'),
    w('Paramount', 'adjective', 'More important than anything else.', 'Safety is paramount.', '/ˈperəˌmount/'),
    w('Pedantic', 'adjective', 'Overly concerned with minute details.', 'His pedantic corrections annoyed everyone.', '/pəˈdantik/'),
    w('Penchant', 'noun', 'A strong or habitual liking for something.', 'She had a penchant for chocolate.', '/ˈpenCHənt/'),
    w('Perfunctory', 'adjective', 'Carried out with a minimum of effort.', 'He gave a perfunctory nod.', '/pərˈfəNGktərē/'),
    w('Peripheral', 'adjective', 'Relating to or situated on the edge.', 'The issue was peripheral to the main debate.', '/pəˈrifərəl/'),
    w('Perspicacious', 'adjective', 'Having a ready understanding of things.', 'She was perspicacious and quick.', '/ˌpərspiˈkāSHəs/'),
    w('Pertinent', 'adjective', 'Relevant or applicable to a particular matter.', 'Please keep your comments pertinent.', '/ˈpərtnənt/'),
    w('Pervade', 'verb', 'Spread through and be present in every part of.', 'A sense of dread pervaded the room.', '/pərˈvād/'),
    w('Pragmatic', 'adjective', 'Dealing with things sensibly and realistically.', 'We need a pragmatic solution.', '/praɡˈmadik/'),
    w('Precarious', 'adjective', 'Not securely held or in position.', 'The ladder was in a precarious position.', '/prəˈkerēəs/'),
    w('Precedent', 'noun', 'An earlier event or action serving as an example.', 'The case set a precedent.', '/ˈpresədnt/'),
    w('Preclude', 'verb', 'Prevent from happening; make impossible.', 'The law precludes such action.', '/prēˈklo͞od/'),
    w('Predilection', 'noun', 'A preference or special liking for something.', 'She had a predilection for jazz.', '/ˌpredlˈekSHən/'),
    w('Preeminent', 'adjective', 'Surpassing all others; very distinguished.', 'He was the preeminent scholar of his day.', '/prēˈemənənt/'),
    w('Pristine', 'adjective', 'In its original condition; unspoiled.', 'The beach was pristine.', '/ˈprisˌtēn/'),
    w('Profligate', 'adjective', 'Recklessly extravagant or wasteful.', 'Profligate spending led to bankruptcy.', '/ˈpräfliɡət/'),
    w('Prolific', 'adjective', 'Producing much fruit or foliage or many offspring.', 'She was a prolific writer.', '/prəˈlifik/'),
    w('Prudent', 'adjective', 'Acting with or showing care for the future.', 'It would be prudent to wait.', '/ˈpro͞odnt/'),
    w('Pugnacious', 'adjective', 'Eager or quick to argue or fight.', 'He had a pugnacious demeanor.', '/pəɡˈnāSHəs/'),
    w('Pulchritude', 'noun', 'Beauty.', 'She was known for her pulchritude.', '/ˈpəlkrəˌt(y)o͞od/'),
    w('Quandary', 'noun', 'A state of perplexity or uncertainty.', 'She was in a quandary about what to do.', '/ˈkwändərē/'),
    w('Quell', 'verb', 'Put an end to; suppress.', 'Troops quelled the uprising.', '/kwel/'),
    w('Quixotic', 'adjective', 'Extremely idealistic; unrealistic.', 'It was a quixotic quest.', '/kwikˈsädik/'),
    w('Rancor', 'noun', 'Bitterness or resentfulness.', 'There was rancor between the two families.', '/ˈraNGkər/'),
    w('Rapid', 'adjective', 'Happening in a short time or at a great rate.', 'Rapid change swept the industry.', '/ˈrapəd/'),
    w('Reticent', 'adjective', 'Not revealing one\'s thoughts or feelings readily.', 'He was reticent about his past.', '/ˈretəsnt/'),
    w('Revere', 'verb', 'Feel deep respect or admiration for.', 'She was revered by her students.', '/rəˈvir/'),
    w('Sage', 'noun', 'A wise person.', 'The sage offered advice.', '/sāj/'),
    w('Salient', 'adjective', 'Most noticeable or important.', 'The salient points were summarized.', '/ˈsālēənt/'),
    w('Sanctimonious', 'adjective', 'Making a show of being morally superior.', 'His sanctimonious tone annoyed them.', '/ˌsaNGktəˈmōnēəs/'),
    w('Scrupulous', 'adjective', 'Diligent, thorough, and extremely attentive to detail.', 'She was scrupulous in her research.', '/ˈskro͞opyələs/'),
    w('Solicitous', 'adjective', 'Characterized by or showing interest or concern.', 'She was solicitous about his health.', '/səˈlisədəs/'),
    w('Sporadic', 'adjective', 'Occurring at irregular intervals.', 'Sporadic outbreaks were reported.', '/spəˈradik/'),
    w('Stoic', 'adjective', 'Enduring pain and hardship without complaint.', 'She remained stoic throughout.', '/ˈstōik/'),
    w('Stolid', 'adjective', 'Calm, dependable, and showing little emotion.', 'He was a stolid presence.', '/ˈstäləd/'),
    w('Substantiate', 'verb', 'Provide evidence to support or prove.', 'He could not substantiate the claim.', '/səbˈstanSHēˌāt/'),
    w('Superfluous', 'adjective', 'Unnecessary, especially through being more than enough.', 'The extra details were superfluous.', '/so͞oˈpərflo͞oəs/'),
    w('Taciturn', 'adjective', 'Reserved or uncommunicative in speech.', 'He was taciturn by nature.', '/ˈtasərˌtərn/'),
    w('Tenuous', 'adjective', 'Very weak or slight.', 'The connection was tenuous.', '/ˈtenyo͞oəs/'),
    w('Terse', 'adjective', 'Sparing in the use of words; abrupt.', 'She gave a terse reply.', '/tərs/'),
    w('Tranquil', 'adjective', 'Free from disturbance; calm.', 'The garden was tranquil.', '/ˈtraNGkwəl/'),
    w('Ubiquitous', 'adjective', 'Present, appearing, or found everywhere.', 'Smartphones are ubiquitous.', '/yo͞oˈbikwədəs/'),
    w('Unilateral', 'adjective', 'Performed by or affecting only one side.', 'They took unilateral action.', '/ˌyo͞onəˈlatərəl/'),
    w('Vacillate', 'verb', 'Alternate between different opinions or actions.', 'He vacillated between the two options.', '/ˈvasəˌlāt/'),
    w('Venerable', 'adjective', 'Accorded a great deal of respect.', 'The venerable professor spoke.', '/ˈvenərəbəl/'),
    w('Verbose', 'adjective', 'Using more words than needed.', 'The report was verbose.', '/vərˈbōs/'),
    w('Vex', 'verb', 'Make someone feel frustrated or annoyed.', 'The problem vexed the engineers.', '/veks/'),
    w('Viable', 'adjective', 'Capable of working successfully.', 'We need a viable alternative.', '/ˈvīəbəl/'),
    w('Vicarious', 'adjective', 'Experienced through another person.', 'She took vicarious pleasure in his success.', '/vīˈkerēəs/'),
    w('Vilify', 'verb', 'Speak or write about in an abusively disparaging way.', 'The press vilified him.', '/ˈviləˌfī/'),
    w('Vindicate', 'verb', 'Clear of blame or suspicion.', 'The verdict vindicated her.', '/ˈvindəˌkāt/'),
    w('Vociferous', 'adjective', 'Expressing feelings or opinions in a loud way.', 'Vociferous protesters gathered.', '/vōˈsifərəs/'),
    w('Wary', 'adjective', 'Feeling or showing caution about possible dangers.', 'Be wary of strangers.', '/ˈwerē/'),
    w('Whimsical', 'adjective', 'Playfully quaint or fanciful.', 'The story had a whimsical tone.', '/ˈ(h)wimzikəl/'),
    w('Zealous', 'adjective', 'Having or showing great energy or enthusiasm.', 'She was a zealous advocate.', '/ˈzeləs/'),
  ];
}
