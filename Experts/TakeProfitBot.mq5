//+------------------------------------------------------------------+
//|                                           TakeProfitBot.mq5      |
//|                   Tuto MT5 - Take Profit Automatique             |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| DESCRIPTION GÉNÉRALE                                             |
//|                                                                  |
//| Cet Expert Advisor (EA) place automatiquement un Take Profit     |
//| sur chaque nouvelle position ouverte sur le symbole du graphique |
//| actif, en utilisant une distance en pips configurée par          |
//| l'utilisateur.                                                   |
//|                                                                  |
//| L'EA fonctionne de manière réactive :                            |
//| - À chaque tick (mouvement de prix), il vérifie si des positions |
//|   ouvertes n'ont pas encore de Take Profit défini.               |
//| - Si une position sans TP est trouvée, il calcule le bon prix    |
//|   de TP (en fonction de la direction BUY/SELL) et le place       |
//|   automatiquement.                                               |
//|                                                                  |
//| STRUCTURE DES FICHIERS :                                         |
//|                                                                  |
//| TakeProfitBot.mq5         ← Fichier principal (celui-ci)         |
//|  ├── Include/TradeSelector.mqh  ← Sélection des positions        |
//|  ├── Include/TPCalculator.mqh   ← Calcul du prix TP en pips     |
//|  └── Include/TradeManager.mqh   ← Exécution de la modification  |
//|                                                                  |
//| Pour installer ces fichiers dans MT5 :                           |
//| 1. TakeProfitBot.mq5 → MQL5/Experts/                            |
//| 2. Les .mqh → MQL5/Include/ (ou un sous-dossier)                |
//| 3. Compilez TakeProfitBot.mq5 dans MetaEditor                   |
//+------------------------------------------------------------------+

// ===================================================================
// PROPRIÉTÉS DE L'EA
// ===================================================================

// Ces propriétés sont affichées dans MT5 quand on regarde les infos de l'EA
#property copyright   "EA Creator - autoea.online"
#property link        "https://autoea.online"
#property version     "1.00"
#property description "EA qui place automatiquement un Take Profit en pips"
#property description "sur chaque position ouverte sans TP."
#property description ""
#property description "Tutoriel complet : github.com/votre-repo"
#property description "Générateur EA sans code : https://autoea.online"

// ===================================================================
// INCLUSIONS DES FICHIERS
// ===================================================================

// #include permet d'importer le code d'un autre fichier.
// En MQL5, les fichiers .mqh (MQL Header) contiennent des fonctions
// réutilisables. C'est l'équivalent des bibliothèques en programmation.
//
// On utilise des guillemets "" au lieu de <> pour indiquer que les
// fichiers sont dans un chemin relatif (pas dans le dossier standard).

#include "Include\TradeSelector.mqh"   // Fonctions de sélection des positions
#include "Include\TPCalculator.mqh"    // Fonctions de calcul du TP
#include "Include\TradeManager.mqh"    // Fonctions de modification des ordres

// ===================================================================
// PARAMÈTRES D'ENTRÉE (INPUT)
// ===================================================================

// Les variables "input" apparaissent dans la fenêtre de paramètres
// de l'EA quand l'utilisateur le place sur un graphique.
// L'utilisateur peut modifier ces valeurs sans toucher au code.

// Distance du Take Profit en pips.
// Exemples :
//   50 pips sur EURUSD (5 déc.) = 0.00500 en prix
//   50 pips sur USDJPY (3 déc.) = 0.500 en prix
//   50 pips sur XAUUSD (2 déc.) = 5.00 en prix
input double TP_Pips = 50.0;  // Distance TP en pips

// ===================================================================
// FONCTION OnInit()
// ===================================================================

// OnInit() est appelée UNE SEULE FOIS quand l'EA est chargé
// sur le graphique. C'est l'équivalent du constructeur.
//
// Elle sert à :
// - Vérifier que les paramètres sont valides
// - Initialiser les variables globales
// - Afficher un message de démarrage
//
// Valeurs de retour :
// - INIT_SUCCEEDED     : tout est OK, l'EA démarre
// - INIT_PARAMETERS_INCORRECT : erreur dans les paramètres, l'EA ne démarre pas
// - INIT_FAILED         : erreur générale, l'EA ne démarre pas

int OnInit()
{
    // Vérification de sécurité : le TP doit être positif
    // Un TP de 0 ou négatif n'a aucun sens et créerait des erreurs
    if(TP_Pips <= 0)
    {
        // Print() écrit dans l'onglet "Expert" de MT5 (en bas)
        // C'est le principal outil de debug en MQL5
        Print("❌ ERREUR : La distance TP doit être supérieure à 0 !");
        Print("   Valeur actuelle : ", TP_Pips, " pips");

        // On retourne INIT_PARAMETERS_INCORRECT pour empêcher
        // l'EA de démarrer avec des paramètres invalides
        return INIT_PARAMETERS_INCORRECT;
    }

    // Affichage d'un message de démarrage avec la config
    Print("══════════════════════════════════════════");
    Print("🚀 Take Profit Bot démarré avec succès !");
    Print("   Symbole   : ", _Symbol);
    Print("   TP        : ", TP_Pips, " pips");
    Print("   Valeur pip: ", ObtenirValeurPip());
    Print("══════════════════════════════════════════");

    // Tout est OK, l'EA peut démarrer
    return INIT_SUCCEEDED;
}

// ===================================================================
// FONCTION OnDeinit()
// ===================================================================

// OnDeinit() est appelée quand l'EA est retiré du graphique,
// quand on change de timeframe, ou quand MT5 se ferme.
//
// Le paramètre "reason" indique POURQUOI l'EA s'arrête :
// - REASON_REMOVE     : l'utilisateur a retiré l'EA
// - REASON_RECOMPILE  : le code a été recompilé dans MetaEditor
// - REASON_CHARTCLOSE  : le graphique a été fermé
// - REASON_PARAMETERS  : les paramètres ont été modifiés
// - etc.

void OnDeinit(const int reason)
{
    Print("🛑 Take Profit Bot arrêté. Raison : ", reason);
}

// ===================================================================
// FONCTION OnTick() — CŒUR DE L'EA
// ===================================================================

// OnTick() est appelée À CHAQUE NOUVEAU TICK (mouvement de prix).
// C'est la boucle principale de l'EA. C'est ici que toute la
// logique s'exécute.
//
// Fréquence d'appel :
// - Sur les paires Forex majeures : plusieurs fois par seconde
// - Sur les actions/crypto : variable selon la liquidité
// - Le weekend / hors marché : jamais (pas de ticks)
//
// ATTENTION : cette fonction doit être RAPIDE car elle est
// appelée très souvent. Évitez les calculs lourds ou les boucles
// infinies qui bloqueraient MT5.

void OnTick()
{
    // Étape 1 : Compter les positions ouvertes sur ce symbole
    int nbPositions = CompterPositionsOuvertes();

    // S'il n'y a aucune position, on n'a rien à faire
    // On sort immédiatement pour ne pas gaspiller de ressources
    if(nbPositions == 0)
        return;

    // Étape 2 : Parcourir chaque position du symbole courant
    for(int i = 0; i < nbPositions; i++)
    {
        // Sélectionner la position par son index local
        // (0 = la plus ancienne, 1 = la suivante, etc.)
        ulong ticket = SelectionnerPosition(i);

        // Si le ticket est 0, la position n'existe pas (erreur)
        if(ticket == 0)
            continue;   // "continue" saute à l'itération suivante

        // Étape 3 : Vérifier si un TP est déjà défini
        double tpActuel = ObtenirTPActuel();

        // Si le TP est déjà défini (> 0), on ne touche pas
        // Cette vérification évite de modifier le TP à chaque tick
        if(tpActuel > 0)
            continue;

        // ─────────────────────────────────────────────────
        // À ce stade : la position N'A PAS de Take Profit
        // On va en calculer un et le placer automatiquement
        // ─────────────────────────────────────────────────

        // Étape 4 : Récupérer les infos nécessaires au calcul
        ENUM_POSITION_TYPE typePos = ObtenirTypePosition();
        double prixOuverture      = ObtenirPrixOuverture();
        double slActuel           = ObtenirSLActuel();

        // Afficher les infos de la position (pour le debug)
        AfficherInfoPosition(ticket);

        // Étape 5 : Calculer le prix du Take Profit
        double nouveauTP = CalculerPrixTP(prixOuverture, TP_Pips, typePos);

        Print("📐 Calcul du TP :");
        Print("   Prix ouverture : ", prixOuverture);
        Print("   Distance       : ", TP_Pips, " pips");
        Print("   Direction      : ", (typePos == POSITION_TYPE_BUY) ? "BUY" : "SELL");
        Print("   TP calculé     : ", nouveauTP);

        // Étape 6 : Valider le TP avant de l'envoyer au broker
        if(!ValiderTP(nouveauTP, typePos))
        {
            Print("⚠️ TP invalide pour le ticket #", ticket, " — Abandon");
            continue;
        }

        // Étape 7 : Modifier la position pour ajouter le TP
        bool succes = ModifierTP(ticket, slActuel, nouveauTP);

        if(succes)
        {
            Print("🎯 TP placé avec succès sur la position #", ticket);
        }
        else
        {
            Print("❌ Échec du placement du TP sur #", ticket);
        }
    }
}
