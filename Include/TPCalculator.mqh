//+------------------------------------------------------------------+
//|                                              TPCalculator.mqh    |
//|                   Tuto MT5 - Take Profit Automatique             |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

//+------------------------------------------------------------------+
//| Fonction : ObtenirValeurPip                                      |
//| Calcule la valeur d'1 pip pour le symbole courant.               |
//|                                                                  |
//| Explication du calcul :                                          |
//| - _Point est la plus petite unité de mouvement du prix.          |
//|   Pour EURUSD (5 décimales) : _Point = 0.00001                  |
//|   Pour USDJPY (3 décimales) : _Point = 0.001                    |
//|                                                                  |
//| - 1 pip = 10 points pour les paires à 5 décimales               |
//|   (car 1 pip = 0.0001, et _Point = 0.00001)                     |
//|                                                                  |
//| - Pour les paires JPY (3 décimales) : 1 pip = 10 points aussi   |
//|   (car 1 pip = 0.01, et _Point = 0.001)                         |
//|                                                                  |
//| - Pour les paires à 4 ou 2 décimales (ancien format) :          |
//|   1 pip = 1 point directement.                                   |
//+------------------------------------------------------------------+
//| Paramètres : aucun                                               |
//| Retour : double - valeur de 1 pip en unités de prix              |
//+------------------------------------------------------------------+
double ObtenirValeurPip()
{
    // _Digits contient le nombre de décimales du symbole courant.
    // Exemples :
    //   EURUSD = 5 décimales (0.00001)
    //   USDJPY = 3 décimales (0.001)
    //   XAUUSD = 2 décimales (0.01) — cas particulier

    // Si le symbole a 3 ou 5 décimales, c'est le "nouveau format"
    // où 1 pip = 10 points
    if(_Digits == 3 || _Digits == 5)
    {
        return _Point * 10;
    }

    // Sinon (2 ou 4 décimales), 1 pip = 1 point
    return _Point;
}

//+------------------------------------------------------------------+
//| Fonction : CalculerPrixTP                                        |
//| Calcule le prix exact du Take Profit en ajoutant ou retirant     |
//| un nombre de pips au prix d'ouverture de la position.            |
//+------------------------------------------------------------------+
//|                                                                  |
//| Logique du calcul :                                              |
//|                                                                  |
//|   Pour un BUY (achat) :                                          |
//|     Le prix monte = profit, donc on AJOUTE les pips.             |
//|     TP = prixOuverture + (distancePips × valeurPip)              |
//|     Exemple : Achat EURUSD à 1.10000, TP à 50 pips              |
//|     TP = 1.10000 + (50 × 0.0001) = 1.10500                      |
//|                                                                  |
//|   Pour un SELL (vente) :                                         |
//|     Le prix descend = profit, donc on RETIRE les pips.           |
//|     TP = prixOuverture - (distancePips × valeurPip)              |
//|     Exemple : Vente EURUSD à 1.10000, TP à 50 pips              |
//|     TP = 1.10000 - (50 × 0.0001) = 1.09500                      |
//|                                                                  |
//+------------------------------------------------------------------+
//| Paramètres :                                                     |
//|   prixOuverture  (double)             - prix d'entrée du trade   |
//|   distancePips   (double)             - distance TP en pips      |
//|   typePosition   (ENUM_POSITION_TYPE) - BUY ou SELL              |
//| Retour : double - prix du Take Profit (normalisé)                |
//+------------------------------------------------------------------+
double CalculerPrixTP(double prixOuverture, double distancePips, ENUM_POSITION_TYPE typePosition)
{
    // On récupère la valeur d'1 pip pour ce symbole
    double valeurPip = ObtenirValeurPip();

    // On calcule la distance en unités de prix
    // Exemple : 50 pips × 0.0001 = 0.0050 pour EURUSD
    double distancePrix = distancePips * valeurPip;

    // Variable qui contiendra le prix du TP final
    double prixTP = 0.0;

    // Si c'est un achat (BUY), on ajoute la distance au prix d'entrée
    if(typePosition == POSITION_TYPE_BUY)
    {
        prixTP = prixOuverture + distancePrix;
    }
    // Si c'est une vente (SELL), on soustrait la distance
    else if(typePosition == POSITION_TYPE_SELL)
    {
        prixTP = prixOuverture - distancePrix;
    }

    // NormalizeDouble arrondit le prix au bon nombre de décimales.
    // C'est OBLIGATOIRE sinon MT5 rejettera l'ordre avec une erreur.
    // Exemple : 1.105004999 → 1.10500 (arrondi à 5 décimales)
    return NormalizeDouble(prixTP, _Digits);
}

//+------------------------------------------------------------------+
//| Fonction : ValiderTP                                             |
//| Vérifie que le prix TP calculé est valide et logique.            |
//|                                                                  |
//| Un TP mal placé sera rejeté par le broker :                      |
//| - Pour un BUY : le TP doit être AU-DESSUS du prix actuel        |
//| - Pour un SELL : le TP doit être EN-DESSOUS du prix actuel      |
//|                                                                  |
//| De plus, le TP ne doit pas être trop proche du prix actuel       |
//| (la distance minimale dépend du broker, via SYMBOL_TRADE_STOPS_LEVEL) |
//+------------------------------------------------------------------+
//| Paramètres :                                                     |
//|   prixTP       (double)             - prix du TP calculé         |
//|   typePosition (ENUM_POSITION_TYPE) - BUY ou SELL                |
//| Retour : bool - true si le TP est valide, false sinon            |
//+------------------------------------------------------------------+
bool ValiderTP(double prixTP, ENUM_POSITION_TYPE typePosition)
{
    // Vérification de base : le prix ne doit pas être 0 ou négatif
    if(prixTP <= 0)
    {
        Print("❌ Erreur : Le prix du TP est invalide (", prixTP, ")");
        return false;
    }

    // Récupérer le prix actuel du marché
    // Pour un BUY, le prix de sortie est le Bid (prix de vente)
    // Pour un SELL, le prix de sortie est le Ask (prix d'achat)
    double prixActuel = 0;

    if(typePosition == POSITION_TYPE_BUY)
    {
        // SymbolInfoDouble récupère des informations en temps réel
        // SYMBOL_BID = meilleur prix de vente disponible
        prixActuel = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    }
    else
    {
        // SYMBOL_ASK = meilleur prix d'achat disponible
        prixActuel = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    }

    // Récupérer la distance minimale de stops imposée par le broker
    // Cette valeur est en POINTS (pas en pips !)
    // Exemple : si stops_level = 100 et _Point = 0.00001,
    //           distance min = 100 × 0.00001 = 0.00100 = 10 pips
    long stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    double distanceMin = stopsLevel * _Point;

    // Vérifier que le TP est du bon côté du prix actuel
    if(typePosition == POSITION_TYPE_BUY)
    {
        // Pour un BUY, le TP doit être au-dessus du prix Bid
        if(prixTP <= prixActuel)
        {
            Print("❌ Erreur : Pour un BUY, le TP (", prixTP,
                  ") doit être au-dessus du prix actuel (", prixActuel, ")");
            return false;
        }

        // Vérifier la distance minimale
        if((prixTP - prixActuel) < distanceMin)
        {
            Print("⚠️ Attention : Le TP est trop proche du prix actuel. ",
                  "Distance minimale requise : ", distanceMin / ObtenirValeurPip(), " pips");
            return false;
        }
    }
    else // SELL
    {
        // Pour un SELL, le TP doit être en-dessous du prix Ask
        if(prixTP >= prixActuel)
        {
            Print("❌ Erreur : Pour un SELL, le TP (", prixTP,
                  ") doit être en-dessous du prix actuel (", prixActuel, ")");
            return false;
        }

        // Vérifier la distance minimale
        if((prixActuel - prixTP) < distanceMin)
        {
            Print("⚠️ Attention : Le TP est trop proche du prix actuel. ",
                  "Distance minimale requise : ", distanceMin / ObtenirValeurPip(), " pips");
            return false;
        }
    }

    Print("✅ TP validé : ", prixTP, " (distance OK)");
    return true;
}
