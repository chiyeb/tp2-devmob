/// Échelle d'espacement (multiples de 4) et rayons partagés par toute l'UI.
abstract final class Dimens {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double radiusField = 14;
  static const double radiusCard = 20;

  /// Hauteur minimale des boutons et champs : cible tactile >= 48.
  static const double control = 52;

  /// Largeur max du contenu pour rester lisible sur tablette / web.
  static const double contentMaxWidth = 440;
}
