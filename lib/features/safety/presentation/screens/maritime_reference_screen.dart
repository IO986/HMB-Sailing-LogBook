import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';

class MaritimeReferenceScreen extends StatelessWidget {
  const MaritimeReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.maritimeReference),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l.phonetic),
              Tab(text: l.flagAlphabet),
              Tab(text: l.dayShapes),
              Tab(text: 'Morse'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PhoneticTab(),
            _FlagTab(),
            _DayShapesTab(),
            _MorseTab(),
          ],
        ),
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────

const _alphabet = [
  (letter: 'A', nato: 'Alpha',    morse: '·−',     flagColors: [Colors.white, Colors.blue],
    flagDescEn: 'Diver down – keep clear',               flagDescSk: 'Potápač pod hladinou – nepribližujte sa',
    flagDescDe: 'Taucher im Wasser – Abstand halten',    flagDescEs: 'Buceador en el agua – manténgase alejado',
    flagDescUk: 'Водолаз під водою – тримайтесь осторонь',
    flagDescCs: 'Potápěč pod hladinou – nepřibližujte se', flagDescPl: 'Nurek pod wodą – zachowaj odstęp', flagDescEl: 'Δύτης στο νερό – κρατηθείτε μακριά', flagDescHr: 'Ronilac u vodi – držite se podalje', flagDescSl: 'Potapljač v vodi – držite se stran'),
  (letter: 'B', nato: 'Bravo',    morse: '−···',   flagColors: [Colors.red],
    flagDescEn: 'Dangerous goods on board',              flagDescSk: 'Na palube nebezpečný náklad',
    flagDescDe: 'Gefährliche Güter an Bord',             flagDescEs: 'Mercancías peligrosas a bordo',
    flagDescUk: 'Небезпечний вантаж на борту',
    flagDescCs: 'Nebezpečný náklad na palubě', flagDescPl: 'Niebezpieczny ładunek na pokładzie', flagDescEl: 'Επικίνδυνο φορτίο στο σκάφος', flagDescHr: 'Opasan teret na brodu', flagDescSl: 'Nevaren tovor na krovu'),
  (letter: 'C', nato: 'Charlie',  morse: '−·−·',   flagColors: [Colors.blue, Colors.white, Colors.red, Colors.white, Colors.blue],
    flagDescEn: 'Yes / Affirmative',                     flagDescSk: 'Áno / Súhlasím',
    flagDescDe: 'Ja / Affirmativ',                       flagDescEs: 'Sí / Afirmativo',
    flagDescUk: 'Так / Стверджую',
    flagDescCs: 'Ano / Souhlasím', flagDescPl: 'Tak / Potwierdzam', flagDescEl: 'Ναι / Καταφατικό', flagDescHr: 'Da / Potvrdno', flagDescSl: 'Da / Pritrdilno'),
  (letter: 'D', nato: 'Delta',    morse: '−··',    flagColors: [Colors.blue, Colors.yellow, Colors.red],
    flagDescEn: 'Keep clear – maneuvering with difficulty', flagDescSk: 'Drž sa ďalej – problémy s manévrovaním',
    flagDescDe: 'Abstand halten – Manövrierfähigkeit eingeschränkt', flagDescEs: 'Manténgase alejado – dificultades de maniobra',
    flagDescUk: 'Тримайтесь осторонь – труднощі з маневруванням',
    flagDescCs: 'Držte se dál – obtížně manévruji', flagDescPl: 'Zachowaj odstęp – manewruję z trudnością', flagDescEl: 'Κρατηθείτε μακριά – ελίσσομαι με δυσκολία', flagDescHr: 'Držite se podalje – teško manevriram', flagDescSl: 'Držite se stran – težko manevriram'),
  (letter: 'E', nato: 'Echo',     morse: '·',      flagColors: [Colors.blue],
    flagDescEn: 'Altering course to starboard',          flagDescSk: 'Mením kurz doprava',
    flagDescDe: 'Kursänderung nach Steuerbord',          flagDescEs: 'Cambiando rumbo a estribor',
    flagDescUk: 'Змінюю курс на правий борт',
    flagDescCs: 'Měním kurz doprava', flagDescPl: 'Zmieniam kurs w prawo', flagDescEl: 'Αλλάζω πορεία δεξιά', flagDescHr: 'Mijenjam kurs udesno', flagDescSl: 'Spreminjam kurz v desno'),
  (letter: 'F', nato: 'Foxtrot',  morse: '··−·',   flagColors: [Colors.white, Colors.red, Colors.white],
    flagDescEn: 'I am disabled – communicate with me',   flagDescSk: 'Som imobilný – kontaktujte ma',
    flagDescDe: 'Manövrierunfähig – bitte Verbindung aufnehmen', flagDescEs: 'Estoy averiado – comuníquese conmigo',
    flagDescUk: 'Я нерухомий – зв\'яжіться зі мною',
    flagDescCs: 'Jsem neschopný manévru – kontaktujte mě', flagDescPl: 'Jestem niezdolny do manewru – skontaktuj się ze mną', flagDescEl: 'Είμαι ακυβέρνητος – επικοινωνήστε μαζί μου', flagDescHr: 'Onesposobljen sam – stupite u vezu sa mnom', flagDescSl: 'Nesposoben za manevriranje – vzpostavite stik z mano'),
  (letter: 'G', nato: 'Golf',     morse: '−−·',    flagColors: [Colors.yellow, Colors.blue],
    flagDescEn: 'I require a pilot',                     flagDescSk: 'Potrebujem lodného pilota',
    flagDescDe: 'Lotse erforderlich',                    flagDescEs: 'Necesito práctico',
    flagDescUk: 'Потрібен лоцман',
    flagDescCs: 'Potřebuji lodivoda', flagDescPl: 'Potrzebuję pilota', flagDescEl: 'Χρειάζομαι πλοηγό', flagDescHr: 'Trebam peljara', flagDescSl: 'Potrebujem pilota'),
  (letter: 'H', nato: 'Hotel',    morse: '····',   flagColors: [Colors.white, Colors.red],
    flagDescEn: 'Pilot on board',                        flagDescSk: 'Lodný pilot na palube',
    flagDescDe: 'Lotse an Bord',                         flagDescEs: 'Práctico a bordo',
    flagDescUk: 'Лоцман на борту',
    flagDescCs: 'Lodivod na palubě', flagDescPl: 'Pilot na pokładzie', flagDescEl: 'Πλοηγός στο σκάφος', flagDescHr: 'Peljar je na brodu', flagDescSl: 'Pilot je na krovu'),
  (letter: 'I', nato: 'India',    morse: '··',     flagColors: [Colors.yellow, Colors.black],
    flagDescEn: 'Altering course to port',               flagDescSk: 'Mením kurz doľava',
    flagDescDe: 'Kursänderung nach Backbord',            flagDescEs: 'Cambiando rumbo a babor',
    flagDescUk: 'Змінюю курс на лівий борт',
    flagDescCs: 'Měním kurz doleva', flagDescPl: 'Zmieniam kurs w lewo', flagDescEl: 'Αλλάζω πορεία αριστερά', flagDescHr: 'Mijenjam kurs ulijevo', flagDescSl: 'Spreminjam kurz v levo'),
  (letter: 'J', nato: 'Juliet',   morse: '·−−−',   flagColors: [Colors.blue, Colors.white],
    flagDescEn: 'Fire & dangerous cargo – keep clear',   flagDescSk: 'Požiar a nebezpečný náklad – drž sa ďalej',
    flagDescDe: 'Feuer und gefährliche Ladung – Abstand halten', flagDescEs: 'Fuego y carga peligrosa – manténgase alejado',
    flagDescUk: 'Пожежа та небезпечний вантаж – тримайтесь осторонь',
    flagDescCs: 'Požár a nebezpečný náklad – držte se dál', flagDescPl: 'Pożar i niebezpieczny ładunek – zachowaj odstęp', flagDescEl: 'Φωτιά και επικίνδυνο φορτίο – κρατηθείτε μακριά', flagDescHr: 'Požar i opasan teret – držite se podalje', flagDescSl: 'Požar in nevaren tovor – držite se stran'),
  (letter: 'K', nato: 'Kilo',     morse: '−·−',    flagColors: [Colors.blue, Colors.yellow],
    flagDescEn: 'I wish to communicate',                 flagDescSk: 'Chcem komunikovať',
    flagDescDe: 'Ich möchte kommunizieren',              flagDescEs: 'Deseo comunicarme',
    flagDescUk: 'Хочу зв\'язатися',
    flagDescCs: 'Chci komunikovat', flagDescPl: 'Chcę się porozumieć', flagDescEl: 'Θέλω να επικοινωνήσω', flagDescHr: 'Želim stupiti u vezu', flagDescSl: 'Želim vzpostaviti stik'),
  (letter: 'L', nato: 'Lima',     morse: '·−··',   flagColors: [Colors.yellow, Colors.black],
    flagDescEn: 'Stop your vessel instantly',             flagDescSk: 'Okamžite zastavte svoju loď',
    flagDescDe: 'Schiff sofort stoppen',                 flagDescEs: 'Detenga su barco inmediatamente',
    flagDescUk: 'Негайно зупиніть судно',
    flagDescCs: 'Okamžitě zastavte své plavidlo', flagDescPl: 'Natychmiast zatrzymaj swoją jednostkę', flagDescEl: 'Σταματήστε αμέσως το σκάφος σας', flagDescHr: 'Odmah zaustavite plovilo', flagDescSl: 'Takoj ustavite plovilo'),
  (letter: 'M', nato: 'Mike',     morse: '−−',     flagColors: [Colors.white, Colors.blue],
    flagDescEn: 'My vessel is stopped',                  flagDescSk: 'Moja loď stojí',
    flagDescDe: 'Mein Schiff liegt still',               flagDescEs: 'Mi barco está parado',
    flagDescUk: 'Моє судно стоїть',
    flagDescCs: 'Moje plavidlo stojí', flagDescPl: 'Moja jednostka stoi', flagDescEl: 'Το σκάφος μου είναι σταματημένο', flagDescHr: 'Moje plovilo je zaustavljeno', flagDescSl: 'Moje plovilo je ustavljeno'),
  (letter: 'N', nato: 'November', morse: '−·',     flagColors: [Colors.blue, Colors.white],
    flagDescEn: 'No / Negative',                         flagDescSk: 'Nie / Nesúhlasím',
    flagDescDe: 'Nein / Negativ',                        flagDescEs: 'No / Negativo',
    flagDescUk: 'Ні / Негативно',
    flagDescCs: 'Ne / Nesouhlasím', flagDescPl: 'Nie / Przeczę', flagDescEl: 'Όχι / Αρνητικό', flagDescHr: 'Ne / Niječno', flagDescSl: 'Ne / Nikalno'),
  (letter: 'O', nato: 'Oscar',    morse: '−−−',    flagColors: [Colors.red, Colors.yellow],
    flagDescEn: 'Man overboard',                         flagDescSk: 'Muž cez palubu',
    flagDescDe: 'Mann über Bord',                        flagDescEs: 'Hombre al agua',
    flagDescUk: 'Людина за бортом',
    flagDescCs: 'Muž přes palubu', flagDescPl: 'Człowiek za burtą', flagDescEl: 'Άνθρωπος στη θάλασσα', flagDescHr: 'Čovjek u moru', flagDescSl: 'Človek v morju'),
  (letter: 'P', nato: 'Papa',     morse: '·−−·',   flagColors: [Colors.blue, Colors.white],
    flagDescEn: 'All aboard – departing to sea',          flagDescSk: 'Všetci na palube – odplávam na more',
    flagDescDe: 'Alle an Bord – Abfahrt auf See',        flagDescEs: 'Todos a bordo – zarpo al mar',
    flagDescUk: 'Всі на борту – відпливаю в море',
    flagDescCs: 'Všichni na palubu – vyplouvám na moře', flagDescPl: 'Wszyscy na pokład – wypływam w morze', flagDescEl: 'Όλοι στο σκάφος – αποπλέω', flagDescHr: 'Svi na brod – isplovljavamo', flagDescSl: 'Vsi na krov – izplutje'),
  (letter: 'Q', nato: 'Quebec',   morse: '−−·−',   flagColors: [Colors.yellow],
    flagDescEn: 'Vessel healthy – free pratique requested', flagDescSk: 'Loď je zdravá – žiadam voľný prístup',
    flagDescDe: 'Schiff gesund – bitte freie Einfahrt',  flagDescEs: 'Barco sano – solicito libre plática',
    flagDescUk: 'Судно здорове – прошу вільного доступу',
    flagDescCs: 'Loď je zdravá – žádám volný přístup', flagDescPl: 'Statek zdrowy – proszę o wolną praktykę', flagDescEl: 'Το πλοίο είναι υγιές – ζητώ ελεύθερη πρατίκα', flagDescHr: 'Brod je zdrav – tražim slobodan promet', flagDescSl: 'Ladja je zdrava – prosim za prost promet'),
  (letter: 'R', nato: 'Romeo',    morse: '·−·',    flagColors: [Colors.red, Colors.yellow, Colors.red],
    flagDescEn: '(No standard ICS meaning)',              flagDescSk: '(Bez štandardného ICS významu)',
    flagDescDe: '(Keine ICS-Standardbedeutung)',          flagDescEs: '(Sin significado ICS estándar)',
    flagDescUk: '(Немає стандартного значення ICS)',
    flagDescCs: '(Bez standardního významu ICS)', flagDescPl: '(Bez standardowego znaczenia ICS)', flagDescEl: '(Χωρίς τυπική σημασία ICS)', flagDescHr: '(Nema standardnog ICS značenja)', flagDescSl: '(Ni standardnega pomena ICS)'),
  (letter: 'S', nato: 'Sierra',   morse: '···',    flagColors: [Colors.white, Colors.blue],
    flagDescEn: 'Engines full astern',                   flagDescSk: 'Motory plnou cúvaním',
    flagDescDe: 'Maschinen volle Kraft zurück',           flagDescEs: 'Máquinas a toda marcha atrás',
    flagDescUk: 'Машини на повний задній хід',
    flagDescCs: 'Motory plnou vzad', flagDescPl: 'Maszyny cała wstecz', flagDescEl: 'Μηχανές ολοταχώς ανάποδα', flagDescHr: 'Strojevi punom snagom krmom', flagDescSl: 'Stroji s polno močjo nazaj'),
  (letter: 'T', nato: 'Tango',    morse: '−',      flagColors: [Colors.red, Colors.white, Colors.red],
    flagDescEn: 'Engaged in pair trawling – keep clear', flagDescSk: 'Lovím sieťami – drž sa ďalej',
    flagDescDe: 'Schleppnetzfischerei – Abstand halten', flagDescEs: 'Pesca de arrastre – manténgase alejado',
    flagDescUk: 'Веду парне тралення – тримайтесь осторонь',
    flagDescCs: 'Lovím v páru vlečnou sítí – držte se dál', flagDescPl: 'Prowadzę połów tuką parą – zachowaj odstęp', flagDescEl: 'Ψαρεύω με ζευγαρωτή τράτα – κρατηθείτε μακριά', flagDescHr: 'Bavim se koćarenjem u paru – držite se podalje', flagDescSl: 'Opravljam parno vlečno ribolov – držite se stran'),
  (letter: 'U', nato: 'Uniform',  morse: '··−',    flagColors: [Colors.red, Colors.white],
    flagDescEn: 'You are running into danger',            flagDescSk: 'Smerujete do nebezpečenstva',
    flagDescDe: 'Sie steuern in Gefahr',                 flagDescEs: 'Va en dirección al peligro',
    flagDescUk: 'Ви прямуєте в небезпеку',
    flagDescCs: 'Míříte do nebezpečí', flagDescPl: 'Zmierzasz ku niebezpieczeństwu', flagDescEl: 'Οδεύετε προς κίνδυνο', flagDescHr: 'Plovite u opasnost', flagDescSl: 'Plujete v nevarnost'),
  (letter: 'V', nato: 'Victor',   morse: '···−',   flagColors: [Colors.white, Colors.red],
    flagDescEn: 'I require assistance',                  flagDescSk: 'Potrebujem pomoc',
    flagDescDe: 'Ich benötige Hilfe',                    flagDescEs: 'Necesito asistencia',
    flagDescUk: 'Потрібна допомога',
    flagDescCs: 'Potřebuji pomoc', flagDescPl: 'Potrzebuję pomocy', flagDescEl: 'Χρειάζομαι βοήθεια', flagDescHr: 'Trebam pomoć', flagDescSl: 'Potrebujem pomoč'),
  (letter: 'W', nato: 'Whiskey',  morse: '·−−',    flagColors: [Colors.red, Colors.white],
    flagDescEn: 'I require medical assistance',           flagDescSk: 'Potrebujem lekársku pomoc',
    flagDescDe: 'Ich benötige ärztliche Hilfe',          flagDescEs: 'Necesito asistencia médica',
    flagDescUk: 'Потрібна медична допомога',
    flagDescCs: 'Potřebuji lékařskou pomoc', flagDescPl: 'Potrzebuję pomocy medycznej', flagDescEl: 'Χρειάζομαι ιατρική βοήθεια', flagDescHr: 'Trebam liječničku pomoć', flagDescSl: 'Potrebujem zdravniško pomoč'),
  (letter: 'X', nato: 'X-ray',    morse: '−··−',   flagColors: [Colors.blue, Colors.white],
    flagDescEn: 'Stop – watch for my signals',           flagDescSk: 'Zastavte – čakajte na moje signály',
    flagDescDe: 'Stopp – auf meine Signale warten',      flagDescEs: 'Pare – espere mis señales',
    flagDescUk: 'Стоп – чекайте моїх сигналів',
    flagDescCs: 'Zastavte – sledujte mé signály', flagDescPl: 'Zatrzymaj się – obserwuj moje sygnały', flagDescEl: 'Σταματήστε – προσέξτε τα σήματά μου', flagDescHr: 'Stanite – pratite moje signale', flagDescSl: 'Ustavite – spremljajte moje signale'),
  (letter: 'Y', nato: 'Yankee',   morse: '−·−−',   flagColors: [Colors.yellow, Colors.red],
    flagDescEn: 'Dragging anchor',                       flagDescSk: 'Kotva sa vlečie',
    flagDescDe: 'Anker schleppt',                        flagDescEs: 'Garreo de ancla',
    flagDescUk: 'Якір тягнеться',
    flagDescCs: 'Vleču kotvu', flagDescPl: 'Kotwica pełznie', flagDescEl: 'Σέρνω άγκυρα', flagDescHr: 'Sidro ore', flagDescSl: 'Sidro orje'),
  (letter: 'Z', nato: 'Zulu',     morse: '−−··',   flagColors: [Colors.black, Colors.yellow],
    flagDescEn: 'I require a tug',                       flagDescSk: 'Potrebujem remorkér',
    flagDescDe: 'Schlepper erforderlich',                flagDescEs: 'Necesito remolcador',
    flagDescUk: 'Потрібен буксир',
    flagDescCs: 'Potřebuji remorkér', flagDescPl: 'Potrzebuję holownika', flagDescEl: 'Χρειάζομαι ρυμουλκό', flagDescHr: 'Trebam tegljač', flagDescSl: 'Potrebujem vlačilec'),
];

// ── Phonetic Alphabet Tab ─────────────────────────────────────────

class _PhoneticTab extends StatelessWidget {
  const _PhoneticTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _alphabet.length,
      itemBuilder: (ctx, i) {
        final entry = _alphabet[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(entry.letter,
                      style: const TextStyle(color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(entry.nato, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(entry.morse, style: const TextStyle(fontSize: 13, color: Colors.grey, letterSpacing: 2)),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}

// ── Flag Alphabet Tab ─────────────────────────────────────────────

class _FlagTab extends StatelessWidget {
  const _FlagTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _alphabet.length,
      itemBuilder: (ctx, i) {
        final entry = _alphabet[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              // Flag representation
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 52, height: 36,
                  child: _buildFlag(entry.flagColors),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.letter} – ${entry.nato}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    switch (Localizations.localeOf(context).languageCode) {
                      'sk' => entry.flagDescSk,
                      'de' => entry.flagDescDe,
                      'es' => entry.flagDescEs,
                      'uk' => entry.flagDescUk,
                      'cs' => entry.flagDescCs,
                      'pl' => entry.flagDescPl,
                      'el' => entry.flagDescEl,
                      'hr' => entry.flagDescHr,
                      'sl' => entry.flagDescSl,
                      _    => entry.flagDescEn,
                    },
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              )),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildFlag(List<Color> colors) {
    if (colors.length == 1) {
      return Container(color: colors[0]);
    }
    return Row(
      children: colors.map((c) => Expanded(child: Container(color: c))).toList(),
    );
  }
}

// ── Day Shapes Tab ─────────────────────────────────────────────────

const _dayShapes = [
  (
    shape: 'ball',
    rule: 'Rule 30',
    titleEn: 'Black ball (sphere)', titleSk: 'Čierna guľa', titleDe: 'Schwarzer Ball (Kugel)',
    titleEs: 'Bola negra (esfera)', titleUk: 'Чорна куля', titleCs: 'Černá koule',
    titlePl: 'Czarna kula', titleEl: 'Μαύρη μπάλα (σφαίρα)', titleHr: 'Crna kugla', titleSl: 'Črna krogla',
    descEn: 'Vessel at anchor.\nBall displayed at the bow.',
    descSk: 'Loď na kotve.\nGuľa vyvesená na prove.',
    descDe: 'Schiff vor Anker.\nBall am Bug gezeigt.',
    descEs: 'Buque fondeado.\nBola exhibida en la proa.',
    descUk: 'Судно на якорі.\nКуля виставлена на носі.',
    descCs: 'Loď na kotvě.\nKoule vyvěšená na přídi.',
    descPl: 'Jednostka na kotwicy.\nKula wywieszona na dziobie.',
    descEl: 'Σκάφος αγκυροβολημένο.\nΜπάλα στην πλώρη.',
    descHr: 'Plovilo na sidru.\nKugla istaknuta na pramcu.',
    descSl: 'Plovilo na sidru.\nKrogla izobešena na premcu.',
  ),
  (
    shape: 'ball-ball',
    rule: 'Rule 27(a)',
    titleEn: 'Two balls vertical', titleSk: 'Dve gule zvisle', titleDe: 'Zwei Bälle senkrecht',
    titleEs: 'Dos bolas verticales', titleUk: 'Дві кулі вертикально', titleCs: 'Dvě koule svisle',
    titlePl: 'Dwie kule pionowo', titleEl: 'Δύο μπάλες κατακόρυφα', titleHr: 'Dvije kugle okomito', titleSl: 'Dve krogli navpično',
    descEn: 'Not Under Command (NUC).\nUnable to maneuver due to exceptional circumstances.',
    descSk: 'Neschopná manévru (NUC).\nNemôže manévrovať pre výnimočné okolnosti.',
    descDe: 'Manövrierunfähig (NUC).\nKann wegen außergewöhnlicher Umstände nicht manövrieren.',
    descEs: 'Sin gobierno (NUC).\nIncapaz de maniobrar por circunstancias excepcionales.',
    descUk: 'Некерована (NUC).\nНе може маневрувати через виняткові обставини.',
    descCs: 'Neschopná manévru (NUC).\nNemůže manévrovat pro výjimečné okolnosti.',
    descPl: 'Nie odpowiada za sterem (NUC).\nNie może manewrować z powodu wyjątkowych okoliczności.',
    descEl: 'Ακυβέρνητο (NUC).\nΑδυναμία ελιγμών λόγω εξαιρετικών περιστάσεων.',
    descHr: 'Nesposobno za manevar (NUC).\nNe može manevrirati zbog izvanrednih okolnosti.',
    descSl: 'Nesposobno za manevriranje (NUC).\nNe more manevrirati zaradi izrednih okoliščin.',
  ),
  (
    shape: 'ball-diamond-ball',
    rule: 'Rule 28',
    titleEn: 'Ball – Diamond – Ball', titleSk: 'Guľa – kosoštvorec – guľa', titleDe: 'Ball – Rhombus – Ball',
    titleEs: 'Bola – rombo – bola', titleUk: 'Куля – ромб – куля', titleCs: 'Koule – kosočtverec – koule',
    titlePl: 'Kula – romb – kula', titleEl: 'Μπάλα – ρόμβος – μπάλα', titleHr: 'Kugla – romb – kugla', titleSl: 'Krogla – romb – krogla',
    descEn: 'Vessel constrained by her draught.',
    descSk: 'Loď obmedzená svojím ponorom.',
    descDe: 'Durch Tiefgang behindertes Schiff.',
    descEs: 'Buque restringido por su calado.',
    descUk: 'Судно, обмежене своєю осадкою.',
    descCs: 'Loď omezená svým ponorem.',
    descPl: 'Jednostka ograniczona swoim zanurzeniem.',
    descEl: 'Σκάφος περιορισμένο από το βύθισμά του.',
    descHr: 'Plovilo ograničeno svojim gazom.',
    descSl: 'Plovilo, omejeno s svojim ugrezom.',
  ),
  (
    shape: 'diamond',
    rule: 'Rule 24',
    titleEn: 'Diamond', titleSk: 'Kosoštvorec', titleDe: 'Rhombus',
    titleEs: 'Rombo', titleUk: 'Ромб', titleCs: 'Kosočtverec',
    titlePl: 'Romb', titleEl: 'Ρόμβος', titleHr: 'Romb', titleSl: 'Romb',
    descEn: 'Tow longer than 200 m.\nDisplayed by both towing vessel and towed vessel.',
    descSk: 'Vlek dlhší ako 200 m.\nVyvesuje vlečúca aj vlečená loď.',
    descDe: 'Schleppzug länger als 200 m.\nVon schleppendem und geschlepptem Schiff gezeigt.',
    descEs: 'Remolque de más de 200 m.\nExhibido por el remolcador y el remolcado.',
    descUk: 'Буксир довший за 200 м.\nВиставляють буксирувальне та буксироване судно.',
    descCs: 'Vlek delší než 200 m.\nVyvěšuje vlekoucí i vlečená loď.',
    descPl: 'Hol dłuższy niż 200 m.\nWywieszają jednostka holująca i holowana.',
    descEl: 'Ρυμούλκηση μεγαλύτερη από 200 m.\nΕπιδεικνύεται από ρυμουλκό και ρυμουλκούμενο.',
    descHr: 'Tegalj dulji od 200 m.\nIstiču ga i tegljač i tegljeno plovilo.',
    descSl: 'Vleka, daljša od 200 m.\nIzobesita jo vlačilec in vlečeno plovilo.',
  ),
  (
    shape: 'cone-up',
    rule: 'Rule 25',
    titleEn: 'Cone apex downward', titleSk: 'Kužeľ hrotom nadol', titleDe: 'Kegel mit Spitze nach unten',
    titleEs: 'Cono con vértice hacia abajo', titleUk: 'Конус вершиною вниз', titleCs: 'Kužel hrotem dolů',
    titlePl: 'Stożek wierzchołkiem w dół', titleEl: 'Κώνος με κορυφή προς τα κάτω', titleHr: 'Stožac vrhom prema dolje', titleSl: 'Stožec z vrhom navzdol',
    descEn: 'Sailing vessel also using engine.\nMust display cone with apex pointing down.',
    descSk: 'Plachetnica používajúca aj motor.\nMusí vyvesiť kužeľ hrotom nadol.',
    descDe: 'Segelschiff, das auch den Motor benutzt.\nMuss Kegel mit Spitze nach unten zeigen.',
    descEs: 'Velero que también usa el motor.\nDebe exhibir un cono con el vértice hacia abajo.',
    descUk: 'Вітрильник, що також використовує двигун.\nМає виставити конус вершиною вниз.',
    descCs: 'Plachetnice používající i motor.\nMusí vyvěsit kužel hrotem dolů.',
    descPl: 'Żaglówka używająca także silnika.\nMusi wywiesić stożek wierzchołkiem w dół.',
    descEl: 'Ιστιοφόρο που χρησιμοποιεί και μηχανή.\nΠρέπει να δείχνει κώνο με κορυφή προς τα κάτω.',
    descHr: 'Jedrilica koja se koristi i motorom.\nMora istaknuti stožac s vrhom prema dolje.',
    descSl: 'Jadrnica, ki uporablja tudi motor.\nMora izobesiti stožec z vrhom navzdol.',
  ),
  (
    shape: 'cones-apexes',
    rule: 'Rule 26',
    titleEn: 'Two cones apex together', titleSk: 'Dva kužele hrotmi k sebe', titleDe: 'Zwei Kegel mit Spitzen zueinander',
    titleEs: 'Dos conos con vértices juntos', titleUk: 'Два конуси вершинами разом', titleCs: 'Dva kužely hroty k sobě',
    titlePl: 'Dwa stożki wierzchołkami do siebie', titleEl: 'Δύο κώνοι με κορυφές μαζί', titleHr: 'Dva stošca spojena vrhovima', titleSl: 'Dva stožca, spojena z vrhovoma',
    descEn: 'Fishing vessel with nets, lines or trawls extending more than 150 m.',
    descSk: 'Rybárska loď so sieťami, šnúrami alebo vlečnými sieťami presahujúcimi 150 m.',
    descDe: 'Fischereifahrzeug mit Netzen, Leinen oder Schleppnetzen, die mehr als 150 m ausgebracht sind.',
    descEs: 'Buque de pesca con redes, líneas o artes que se extienden más de 150 m.',
    descUk: 'Рибальське судно із сітками, ярусами чи тралами, що виступають понад 150 м.',
    descCs: 'Rybářská loď se sítěmi, šňůrami nebo vlečnými sítěmi přesahujícími 150 m.',
    descPl: 'Jednostka rybacka z sieciami, linami lub włokami wystającymi ponad 150 m.',
    descEl: 'Αλιευτικό με δίχτυα, παραγάδια ή τράτες που εκτείνονται πάνω από 150 m.',
    descHr: 'Ribarsko plovilo s mrežama, parangalima ili koćama duljim od 150 m.',
    descSl: 'Ribiško plovilo z mrežami, parangali ali vlečnimi mrežami, daljšimi od 150 m.',
  ),
  (
    shape: 'cylinder',
    rule: 'Rule 29',
    titleEn: 'Cylinder', titleSk: 'Valec', titleDe: 'Zylinder',
    titleEs: 'Cilindro', titleUk: 'Циліндр', titleCs: 'Válec',
    titlePl: 'Walec', titleEl: 'Κύλινδρος', titleHr: 'Valjak', titleSl: 'Valj',
    descEn: 'Pilot vessel engaged on pilotage duty.',
    descSk: 'Lodivodská loď vykonávajúca lodivodskú službu.',
    descDe: 'Lotsenfahrzeug im Lotsendienst.',
    descEs: 'Embarcación de práctico en servicio de practicaje.',
    descUk: 'Лоцманське судно, що виконує лоцманську службу.',
    descCs: 'Lodivodská loď vykonávající lodivodskou službu.',
    descPl: 'Jednostka pilotowa pełniąca służbę pilotową.',
    descEl: 'Πλοηγικό σκάφος σε υπηρεσία πλοήγησης.',
    descHr: 'Peljarsko plovilo u obavljanju peljarske službe.',
    descSl: 'Pilotsko plovilo pri opravljanju pilotske službe.',
  ),
  (
    shape: 'ball-ball-ball',
    rule: 'Rule 30(d)',
    titleEn: 'Three balls vertical', titleSk: 'Tri gule zvisle', titleDe: 'Drei Bälle senkrecht',
    titleEs: 'Tres bolas verticales', titleUk: 'Три кулі вертикально', titleCs: 'Tři koule svisle',
    titlePl: 'Trzy kule pionowo', titleEl: 'Τρεις μπάλες κατακόρυφα', titleHr: 'Tri kugle okomito', titleSl: 'Tri krogle navpično',
    descEn: 'Vessel aground. Three balls displayed in a vertical line.',
    descSk: 'Loď na plytčine (na dne). Tri gule vyvesené zvisle.',
    descDe: 'Schiff auf Grund. Drei Bälle senkrecht gezeigt.',
    descEs: 'Buque varado. Tres bolas exhibidas en línea vertical.',
    descUk: 'Судно на мілині. Три кулі виставлені вертикально.',
    descCs: 'Loď na mělčině. Tři koule vyvěšené svisle.',
    descPl: 'Jednostka osiadła na mieliźnie. Trzy kule wywieszone pionowo.',
    descEl: 'Σκάφος προσαραγμένο. Τρεις μπάλες κατακόρυφα.',
    descHr: 'Plovilo nasukano. Tri kugle istaknute okomito.',
    descSl: 'Nasedlo plovilo. Tri krogle izobešene navpično.',
  ),
];

String _dayShapeTitle(dynamic s, String lc) => switch (lc) {
      'sk' => s.titleSk, 'de' => s.titleDe, 'es' => s.titleEs, 'uk' => s.titleUk,
      'cs' => s.titleCs, 'pl' => s.titlePl, 'el' => s.titleEl,
      'hr' => s.titleHr, 'sl' => s.titleSl, _ => s.titleEn,
    } as String;

String _dayShapeDesc(dynamic s, String lc) => switch (lc) {
      'sk' => s.descSk, 'de' => s.descDe, 'es' => s.descEs, 'uk' => s.descUk,
      'cs' => s.descCs, 'pl' => s.descPl, 'el' => s.descEl,
      'hr' => s.descHr, 'sl' => s.descSl, _ => s.descEn,
    } as String;

class _DayShapesTab extends StatelessWidget {
  const _DayShapesTab();

  @override
  Widget build(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _dayShapes.length,
      itemBuilder: (ctx, i) {
        final s = _dayShapes[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 52, height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E4F0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: _DayShapePainter(shapeCode: s.shape),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_dayShapeTitle(s, lc), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(s.rule, style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(_dayShapeDesc(s, lc), style: const TextStyle(fontSize: 12, height: 1.3)),
                ],
              )),
            ]),
          ),
        );
      },
    );
  }
}

class _DayShapePainter extends StatelessWidget {
  final String shapeCode;
  const _DayShapePainter({required this.shapeCode});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShapePainter(shapeCode),
      size: const Size(52, 68),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final String code;
  const _ShapePainter(this.code);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    switch (code) {
      case 'ball':
        canvas.drawCircle(Offset(cx, h / 2), 11, paint);
      case 'ball-ball':
        canvas.drawCircle(Offset(cx, h * 0.28), 10, paint);
        canvas.drawCircle(Offset(cx, h * 0.72), 10, paint);
      case 'ball-diamond-ball':
        canvas.drawCircle(Offset(cx, h * 0.12), 8, paint);
        _drawDiamond(canvas, cx, h * 0.5, 10, paint);
        canvas.drawCircle(Offset(cx, h * 0.88), 8, paint);
      case 'diamond':
        _drawDiamond(canvas, cx, h / 2, 12, paint);
      case 'cone-up':
        _drawConeDown(canvas, cx, h / 2, 13, paint);
      case 'cones-apexes':
        _drawConeDown(canvas, cx, h * 0.3, 10, paint);
        _drawConeUp(canvas, cx, h * 0.7, 10, paint);
      case 'cylinder':
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, h / 2), width: 22, height: 28), paint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, h / 2 - 14), width: 22, height: 8), paint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, h / 2 + 14), width: 22, height: 8), paint);
      case 'ball-ball-ball':
        canvas.drawCircle(Offset(cx, h * 0.18), 9, paint);
        canvas.drawCircle(Offset(cx, h * 0.5), 9, paint);
        canvas.drawCircle(Offset(cx, h * 0.82), 9, paint);
    }
  }

  void _drawDiamond(Canvas canvas, double cx, double cy, double r, Paint p) {
    final path = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r * 0.7, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r * 0.7, cy)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawConeDown(Canvas canvas, double cx, double cy, double r, Paint p) {
    final path = Path()
      ..moveTo(cx - r, cy - r * 0.8)
      ..lineTo(cx + r, cy - r * 0.8)
      ..lineTo(cx, cy + r * 0.8)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawConeUp(Canvas canvas, double cx, double cy, double r, Paint p) {
    final path = Path()
      ..moveTo(cx, cy - r * 0.8)
      ..lineTo(cx + r, cy + r * 0.8)
      ..lineTo(cx - r, cy + r * 0.8)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_ShapePainter old) => old.code != code;
}

// ── Morse Code Tab ────────────────────────────────────────────────

const _morseNumbers = [
  (char: '0', morse: '−−−−−'),
  (char: '1', morse: '·−−−−'),
  (char: '2', morse: '··−−−'),
  (char: '3', morse: '···−−'),
  (char: '4', morse: '····−'),
  (char: '5', morse: '·····'),
  (char: '6', morse: '−····'),
  (char: '7', morse: '−−···'),
  (char: '8', morse: '−−−··'),
  (char: '9', morse: '−−−−·'),
];

class _MorseTab extends StatefulWidget {
  const _MorseTab();
  @override
  State<_MorseTab> createState() => _MorseTabState();
}

class _MorseTabState extends State<_MorseTab> {
  final _ctrl = TextEditingController();
  String _morse = '';

  static final _morseMap = {
    for (final e in _alphabet) e.letter: e.morse,
    for (final e in _morseNumbers) e.char: e.morse,
  };

  void _convert(String text) {
    final result = text.toUpperCase().split('').map((c) {
      if (c == ' ') return '/';
      return _morseMap[c] ?? '?';
    }).join('  ');
    setState(() => _morse = result);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Prevodník ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.morseConverter,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 10),
                TextField(
                  controller: _ctrl,
                  onChanged: _convert,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).morseInputHint,
                    prefixIcon: const Icon(Icons.keyboard),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    _morse.isEmpty ? '· · ·' : _morse,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      letterSpacing: 2,
                      color: _morse.isEmpty ? Colors.white24 : Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // SOS highlight
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              Text(AppLocalizations.of(context).morseSosTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: '... --- ...'));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context).morseSosCopied)));
                },
                child: const Text('· · ·   − − −   · · ·',
                    style: TextStyle(color: Colors.yellow, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4)),
              ),
              const SizedBox(height: 4),
              const Text('500 kHz  ·  2182 kHz  ·  VHF Ch 16',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
          ),

          // Letters
          _MorseSection(title: 'Letters', items: _alphabet.map((e) => (char: e.letter, morse: e.morse)).toList()),
          const SizedBox(height: 12),
          // Numbers
          _MorseSection(title: 'Numbers', items: _morseNumbers.map((e) => (char: e.char, morse: e.morse)).toList()),
        ],
      ),
    );
  }
}

class _MorseSection extends StatelessWidget {
  final String title;
  final List<({String char, String morse})> items;
  const _MorseSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(title, style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13,
              color: Theme.of(context).colorScheme.primary)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.8,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final e = items[i];
            return Card(
              elevation: 0.5,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(e.char, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(e.morse, style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.5)),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }
}
