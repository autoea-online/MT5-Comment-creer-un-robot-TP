//+------------------------------------------------------------------+
//|                                              TradeSelector.mqh   |
//|                   Tuto MT5 - Take Profit Automatique             |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

//+------------------------------------------------------------------+
//| Fonction : CompterPositionsOuvertes                              |
//| Compte le nombre de positions actuellement ouvertes              |
//| sur le symbole du graphique actif.                               |
//+------------------------------------------------------------------+
//| Paramètres : aucun                                               |
//| Retour     : int - nombre de positions ouvertes sur ce symbole   |
//+------------------------------------------------------------------+
int CompterPositionsOuvertes()
{
    // Variable qui va accumuler le nombre de positions trouvées
    int count = 0;

    // PositionsTotal() retourne le nombre TOTAL de positions ouvertes
    // sur TOUS les symboles du compte. On doit donc filtrer.
    int totalPositions = PositionsTotal();

    // On boucle sur chaque position ouverte
    for(int i = 0; i < totalPositions; i++)
    {
        // PositionGetTicket(i) retourne le ticket (identifiant unique)
        // de la position à l'index i. Si le ticket est valide (> 0),
        // la position est automatiquement sélectionnée pour lecture.
        ulong ticket = PositionGetTicket(i);

        if(ticket > 0)
        {
            // PositionGetString(POSITION_SYMBOL) retourne le symbole
            // de la position actuellement sélectionnée (ex: "EURUSD").
            // On compare avec _Symbol qui est le symbole du graphique actif.
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
            {
                count++;
            }
        }
    }

    return count;
}

//+------------------------------------------------------------------+
//| Fonction : SelectionnerPosition                                  |
//| Sélectionne une position spécifique sur le symbole courant       |
//| en utilisant son index parmi les positions du même symbole.      |
//+------------------------------------------------------------------+
//| Paramètres :                                                     |
//|   indexLocal (int) - index de la position parmi celles du        |
//|                      symbole courant (0 = la plus ancienne)      |
//| Retour : ulong - ticket de la position, ou 0 si non trouvée     |
//+------------------------------------------------------------------+
ulong SelectionnerPosition(int indexLocal)
{
    // Compteur pour savoir combien de positions du symbole
    // courant on a croisées jusqu'ici
    int found = 0;

    int totalPositions = PositionsTotal();

    for(int i = 0; i < totalPositions; i++)
    {
        ulong ticket = PositionGetTicket(i);

        if(ticket > 0)
        {
            // On ne garde que les positions du symbole du graphique
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
            {
                // Si c'est l'index qu'on cherche, on retourne le ticket
                if(found == indexLocal)
                {
                    return ticket;
                }
                found++;
            }
        }
    }

    // Si on arrive ici, l'index demandé n'existe pas
    return 0;
}

//+------------------------------------------------------------------+
//| Fonction : ObtenirTypePosition                                   |
//| Retourne le type (BUY ou SELL) de la position actuellement       |
//| sélectionnée.                                                    |
//+------------------------------------------------------------------+
//| Paramètres : aucun (la position doit être sélectionnée avant)    |
//| Retour : ENUM_POSITION_TYPE - POSITION_TYPE_BUY ou SELL         |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE ObtenirTypePosition()
{
    // PositionGetInteger(POSITION_TYPE) retourne un entier (long)
    // qu'on convertit en ENUM_POSITION_TYPE pour avoir un type lisible
    return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
}

//+------------------------------------------------------------------+
//| Fonction : ObtenirPrixOuverture                                  |
//| Retourne le prix d'ouverture de la position sélectionnée.        |
//+------------------------------------------------------------------+
//| Paramètres : aucun                                               |
//| Retour : double - prix d'entrée de la position                   |
//+------------------------------------------------------------------+
double ObtenirPrixOuverture()
{
    // POSITION_PRICE_OPEN donne le prix exact auquel la position
    // a été ouverte (prix d'exécution réel, pas le prix demandé)
    return PositionGetDouble(POSITION_PRICE_OPEN);
}

//+------------------------------------------------------------------+
//| Fonction : ObtenirTPActuel                                       |
//| Retourne le Take Profit actuel de la position sélectionnée.      |
//+------------------------------------------------------------------+
//| Paramètres : aucun                                               |
//| Retour : double - prix du TP, ou 0.0 si aucun TP n'est défini   |
//+------------------------------------------------------------------+
double ObtenirTPActuel()
{
    // POSITION_TP retourne le prix du Take Profit.
    // Si aucun TP n'est défini, la valeur retournée est 0.0
    return PositionGetDouble(POSITION_TP);
}

//+------------------------------------------------------------------+
//| Fonction : ObtenirSLActuel                                       |
//| Retourne le Stop Loss actuel de la position sélectionnée.        |
//+------------------------------------------------------------------+
//| Paramètres : aucun                                               |
//| Retour : double - prix du SL, ou 0.0 si aucun SL n'est défini   |
//+------------------------------------------------------------------+
double ObtenirSLActuel()
{
    // POSITION_SL retourne le prix du Stop Loss.
    return PositionGetDouble(POSITION_SL);
}
