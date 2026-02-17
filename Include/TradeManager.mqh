//+------------------------------------------------------------------+
//|                                              TradeManager.mqh    |
//|                   Tuto MT5 - Take Profit Automatique             |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

// On inclut la classe CTrade qui simplifie l'envoi d'ordres à MT5.
// Cette classe fait partie de la Standard Library incluse avec MT5.
// Elle gère automatiquement la construction des requêtes MqlTradeRequest.
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Fonction : ModifierTP                                            |
//| Modifie le Take Profit d'une position existante en utilisant     |
//| la classe CTrade de la Standard Library MQL5.                    |
//+------------------------------------------------------------------+
//|                                                                  |
//| Processus interne :                                              |
//| 1. On crée une instance de CTrade                                |
//| 2. On appelle PositionModify(ticket, SL, TP)                     |
//| 3. CTrade construit automatiquement la requête MqlTradeRequest   |
//| 4. MT5 envoie la demande au serveur du broker                    |
//| 5. Le broker accepte ou rejette la modification                  |
//|                                                                  |
//| Si le broker rejette, CTrade écrit l'erreur dans le journal.     |
//+------------------------------------------------------------------+
//| Paramètres :                                                     |
//|   ticket     (ulong)  - ticket unique de la position à modifier  |
//|   slActuel   (double) - Stop Loss actuel (on ne le change pas)   |
//|   nouveauTP  (double) - nouveau prix du Take Profit              |
//| Retour : bool - true si la modification a réussi                 |
//+------------------------------------------------------------------+
bool ModifierTP(ulong ticket, double slActuel, double nouveauTP)
{
    // Création d'un objet CTrade.
    // CTrade est une classe "wrapper" qui simplifie les opérations :
    // - Elle remplit automatiquement les champs de MqlTradeRequest
    // - Elle gère les codes de retour du serveur
    // - Elle fournit des messages d'erreur lisibles
    CTrade trade;

    // SetDeviationInPoints définit le slippage maximum autorisé.
    // Le slippage est la différence entre le prix demandé et le prix
    // réellement exécuté. Ici on autorise 10 points de déviation.
    // Pour EURUSD (5 décimales) : 10 points = 1 pip de déviation
    trade.SetDeviationInPoints(10);

    // PositionModify envoie une requête de modification au serveur.
    // Paramètres :
    //   ticket    : identifie QUELLE position modifier
    //   slActuel  : le Stop Loss (on garde l'ancien, on ne change que le TP)
    //   nouveauTP : le nouveau prix du Take Profit
    //
    // NOTE IMPORTANTE : On ne peut PAS modifier uniquement le TP.
    // Il faut TOUJOURS fournir le SL aussi (même si on ne le change pas).
    // C'est une contrainte de l'API MQL5.
    bool resultat = trade.PositionModify(ticket, slActuel, nouveauTP);

    if(resultat)
    {
        // ResultRetcode() retourne le code de retour du serveur.
        // TRADE_RETCODE_DONE (10009) = tout s'est bien passé.
        // D'autres codes indiquent des erreurs ou des états intermédiaires.
        uint codeRetour = trade.ResultRetcode();

        if(codeRetour == TRADE_RETCODE_DONE)
        {
            Print("✅ Take Profit modifié avec succès !");
            Print("   Ticket : ", ticket);
            Print("   Nouveau TP : ", nouveauTP);
            Print("   SL maintenu : ", slActuel);
            return true;
        }
        else
        {
            // Le serveur a répondu mais avec un code différent de DONE.
            // Cela peut arriver si le marché est fermé, si le broker
            // a des restrictions, etc.
            Print("⚠️ Requête envoyée mais code retour inattendu : ", codeRetour);
            Print("   Description : ", trade.ResultRetcodeDescription());
            return false;
        }
    }
    else
    {
        // La requête a échoué (erreur locale avant même l'envoi)
        // Causes possibles :
        // - Paramètres invalides
        // - Pas de connexion au serveur
        // - Ticket inexistant
        Print("❌ Échec de la modification du TP !");
        Print("   Code erreur : ", trade.ResultRetcode());
        Print("   Description : ", trade.ResultRetcodeDescription());
        return false;
    }
}

//+------------------------------------------------------------------+
//| Fonction : AfficherInfoPosition                                  |
//| Affiche dans le journal (onglet "Expert") toutes les infos       |
//| importantes de la position actuellement sélectionnée.            |
//| Utile pour le debug et le suivi.                                 |
//+------------------------------------------------------------------+
//| Paramètres :                                                     |
//|   ticket (ulong) - ticket de la position                         |
//| Retour : void                                                    |
//+------------------------------------------------------------------+
void AfficherInfoPosition(ulong ticket)
{
    Print("═══════════════════════════════════════");
    Print("📊 Informations de la position #", ticket);
    Print("═══════════════════════════════════════");
    Print("   Symbole       : ", PositionGetString(POSITION_SYMBOL));

    // Afficher le type en texte lisible
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    Print("   Type           : ", (type == POSITION_TYPE_BUY) ? "BUY (Achat)" : "SELL (Vente)");

    Print("   Prix ouverture : ", PositionGetDouble(POSITION_PRICE_OPEN));
    Print("   Volume (lots)  : ", PositionGetDouble(POSITION_VOLUME));

    // Afficher le SL (ou "Non défini" si = 0)
    double sl = PositionGetDouble(POSITION_SL);
    if(sl > 0)
        Print("   Stop Loss      : ", sl);
    else
        Print("   Stop Loss      : Non défini");

    // Afficher le TP (ou "Non défini" si = 0)
    double tp = PositionGetDouble(POSITION_TP);
    if(tp > 0)
        Print("   Take Profit    : ", tp);
    else
        Print("   Take Profit    : Non défini");

    // Profit/Perte en cours (non réalisé)
    Print("   Profit actuel  : ", PositionGetDouble(POSITION_PROFIT), " ", 
          AccountInfoString(ACCOUNT_CURRENCY));
    Print("═══════════════════════════════════════");
}
