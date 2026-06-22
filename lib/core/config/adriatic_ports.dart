class AdriaticPorts {
  static const List<String> croatia = [
    'Biograd na Moru', 'Dubrovnik', 'Hvar', 'Korčula', 'Mali Lošinj',
    'Milna (Brač)', 'Murter', 'Primošten', 'Pula', 'Rab', 'Rijeka',
    'Rogač (Šolta)', 'Rovinj', 'Šibenik', 'Skradin', 'Split',
    'Stari Grad (Hvar)', 'Supetar (Brač)', 'Trogir', 'Vela Luka (Korčula)',
    'Veli Rat (Dugi Otok)', 'Vis', 'Vodice', 'Zadar', 'Zavalatica',
    // Ostrovy / zátoky
    'Palmižana', 'Rukavac (Vis)', 'Komiža', 'Stončica',
    'Luka Polače (Mljet)', 'Saplunara (Mljet)', 'Okuklje (Mljet)',
    'Lovišće (Šolta)', 'Maslinica (Šolta)', 'Uvala Stupin',
    'Uvala Tiha', 'Povlja (Brač)', 'Bol (Brač)', 'Sumartin (Brač)',
    // Čierna Hora / Slovinsko
    'Bar', 'Budva', 'Kotor', 'Tivat',
    'Portorož', 'Izola', 'Piran',
  ];

  static List<String> search(String query) {
    if (query.isEmpty) return croatia.take(10).toList();
    final q = query.toLowerCase();
    return croatia
        .where((p) => p.toLowerCase().contains(q))
        .take(8)
        .toList();
  }
}
