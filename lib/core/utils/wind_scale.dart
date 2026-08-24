import 'package:flutter/painting.dart';

/// Farebná stupnica rýchlosti vetra v uzloch.
///
/// Modrá pre hladinu, cez zelenú a žltú do červenej — rovnaké poradie, aké
/// pozná každý z máp vetra, takže sa nemusí učiť nová konvencia. Prahy sedia
/// na to, čo skipera zaujíma: 12 kn je príjemná plavba, 20 kn refovanie,
/// 30 kn už rozhodovanie, či vôbec vyplávať.
///
/// Žije mimo ktorejkoľvek služby zámerne: rovnakú stupnicu má používať značka
/// meranej stanice na mape aj karty v Počasí. Kým bola schovaná vo vrstve
/// modelu, jedno číslo vedelo mať dve farby podľa toho, kto ho kreslil.
Color windColor(double knots) {
  if (knots < 6) return const Color(0xFF3E7BD6);
  if (knots < 12) return const Color(0xFF35A79C);
  if (knots < 18) return const Color(0xFF7CB342);
  if (knots < 24) return const Color(0xFFFDD835);
  if (knots < 30) return const Color(0xFFFB8C00);
  if (knots < 40) return const Color(0xFFE53935);
  return const Color(0xFF8E24AA);
}
