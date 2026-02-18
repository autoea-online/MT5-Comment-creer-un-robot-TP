## 😎 La flemme de coder ?

Si vous avez la flemme d'être développeur et que vous voulez un **Expert Advisor personnalisé** sans écrire une seule ligne de code, venez voir notre générateur en ligne :

### 👉 [**EA Creator — Créez votre EA en 2 minutes**](https://autoea.online/generate) 👈

- ✅ Aucune compétence en programmation requise
- ✅ Configurez visuellement vos modules (SL, TP, Break Even, Trailing Stop...)
- ✅ Fichier `.ex5` compilé et livré par email en 5 minutes
- ✅ Compatible toutes les Prop Firms
- ✅ Lié à votre compte MT5 pour plus de sécurité

> 🌐 **Site web :** [https://autoea.online](https://autoea.online)
>
> 📧 **Contact :** snowfallsys@proton.me

# 🎯 Tutoriel MT5 — Placer un Take Profit Automatiquement (Gestion du Risque)

[![MetaTrader 5](https://img.shields.io/badge/MetaTrader_5-Expert_Advisor-blue?style=for-the-badge&logo=metatrader5)](https://www.metatrader5.com)
[![MQL5](https://img.shields.io/badge/MQL5-Language-orange?style=for-the-badge)](https://www.mql5.com/fr/docs)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

> **Tutoriel complet et détaillé** pour créer un Expert Advisor MQL5 qui place automatiquement un Take Profit (en pips) sur toutes vos positions ouvertes dans MetaTrader 5. Chaque ligne de code est expliquée.

---

## 📖 Table des matières

1. [Introduction](#-introduction)
2. [Prérequis](#-prérequis)
3. [Architecture du projet](#-architecture-du-projet)
4. [Installation](#-installation)
5. [Explication complète du code](#-explication-complète-du-code)
   - [Fichier principal — TakeProfitBot.mq5](#1-fichier-principal--takeprofitbotmq5)
   - [Sélection des trades — TradeSelector.mqh](#2-sélection-des-trades--tradeselectormqh)
   - [Calcul du TP en pips — TPCalculator.mqh](#3-calcul-du-tp-en-pips--tpcalculatormqh)
   - [Modification des ordres — TradeManager.mqh](#4-modification-des-ordres--trademanagermqh)
6. [Comment fonctionne le calcul en pips ?](#-comment-fonctionne-le-calcul-en-pips-)
7. [Cycle de vie d'un Expert Advisor](#-cycle-de-vie-dun-expert-advisor)
8. [Configuration et paramètres](#-configuration-et-paramètres)
9. [Gestion des erreurs](#-gestion-des-erreurs)
10. [Tests et backtest](#-tests-et-backtest)
11. [FAQ](#-faq)
12. [Liens utiles](#-liens-utiles)

---

## 🌟 Introduction

### Qu'est-ce qu'un Expert Advisor ?

Un **Expert Advisor (EA)** est un programme automatisé qui s'exécute directement dans MetaTrader 5. Il peut :
- Surveiller les prix en temps réel
- Ouvrir et fermer des positions
- Placer et modifier des Stop Loss / Take Profit
- Exécuter des stratégies de trading complexes 24h/24

### Que fait cet EA ?

Ce tutoriel vous apprend à créer un EA qui **place automatiquement un Take Profit** sur chaque position ouverte qui n'en a pas encore. L'idée est simple :

1. Vous ouvrez un trade manuellement (ou via un autre EA)
2. Notre EA détecte que ce trade n'a **pas de TP défini**
3. Il calcule le bon prix de TP en fonction de la **distance en pips** que vous avez configurée
4. Il modifie la position pour ajouter le TP

C'est un outil de **gestion du risque** indispensable : il s'assure que chaque trade a une cible de profit claire.

### Pourquoi structurer le code en plusieurs fichiers ?

En MQL5, il est tentant de tout mettre dans un seul fichier `.mq5`. Mais pour un code lisible, maintenable et réutilisable, on sépare les responsabilités :

| Fichier | Rôle |
|---------|------|
| `TakeProfitBot.mq5` | Point d'entrée, logique principale |
| `TradeSelector.mqh` | Sélection et filtrage des positions |
| `TPCalculator.mqh` | Calcul du prix du TP en pips |
| `TradeManager.mqh` | Envoi des modifications au broker |

Cette structure permet de **réutiliser** chaque module dans d'autres EA sans copier-coller.

---

## 🔧 Prérequis

- **MetaTrader 5** installé ([télécharger ici](https://www.metatrader5.com/fr/download))
- **MetaEditor** (inclus dans MT5 — c'est l'IDE pour écrire du MQL5)
- Un **compte de trading** (démo ou réel) chez n'importe quel broker
- Connaissances de base en programmation (variables, boucles, fonctions)

### Versions testées

| Composant | Version |
|-----------|---------|
| MetaTrader 5 | Build 4580+ |
| MQL5 | Standard Library incluse |

---

## 📁 Architecture du projet

```
📂 Tuto-MT5-Take-Profit-Automatique/
│
├── 📂 Experts/
│   └── 📄 TakeProfitBot.mq5          ← Fichier principal de l'EA
│
├── 📂 Include/
│   ├── 📄 TradeSelector.mqh           ← Fonctions de sélection des positions
│   ├── 📄 TPCalculator.mqh            ← Calcul du Take Profit en pips
│   └── 📄 TradeManager.mqh            ← Modification des ordres via CTrade
│
├── 📄 README.md                       ← Ce fichier
└── 📄 LICENSE                         ← Licence MIT
```

### Pourquoi cette structure ?

Dans MetaTrader 5, les fichiers sont organisés dans le **dossier de données** (Data Folder) :

```
📂 MQL5/
├── 📂 Experts/      ← Les fichiers .mq5 (EA principaux)
├── 📂 Include/      ← Les fichiers .mqh (bibliothèques réutilisables)
├── 📂 Indicators/   ← Les indicateurs personnalisés
└── 📂 Scripts/      ← Les scripts (exécution unique)
```

Les fichiers `.mqh` dans `Include/` peuvent être importés par n'importe quel EA avec `#include`. C'est comme les bibliothèques dans d'autres langages.

---

## 📥 Installation

### Méthode 1 : Installation manuelle

1. **Ouvrez MetaTrader 5**

2. **Accédez au dossier de données :**
   - Menu `Fichier` → `Ouvrir le dossier des données`
   - Ou tapez `%APPDATA%\MetaQuotes\Terminal\` dans l'explorateur Windows

3. **Copiez les fichiers :**
   ```
   TakeProfitBot.mq5  →  MQL5/Experts/TakeProfitBot.mq5
   TradeSelector.mqh   →  MQL5/Include/TradeSelector.mqh
   TPCalculator.mqh    →  MQL5/Include/TPCalculator.mqh
   TradeManager.mqh    →  MQL5/Include/TradeManager.mqh
   ```
   
   > **⚠️ Alternative :** Vous pouvez aussi mettre les `.mqh` dans le même dossier que le `.mq5` et utiliser des chemins relatifs dans les `#include` (c'est ce que fait ce tutoriel par défaut).

4. **Compilez dans MetaEditor :**
   - Ouvrez `TakeProfitBot.mq5` dans MetaEditor (double-clic)
   - Appuyez sur `F7` ou cliquez sur `Compiler`
   - Vérifiez qu'il n'y a aucune erreur dans l'onglet `Erreurs`

5. **Lancez l'EA :**
   - Retournez dans MT5
   - Dans le `Navigateur` (panneau de gauche), trouvez `Experts Consultatifs`
   - Faites un clic droit → `Actualiser`
   - Double-cliquez sur `TakeProfitBot` pour le placer sur un graphique
   - Configurez la distance TP en pips dans la fenêtre de paramètres
   - Cliquez sur `OK`

### Méthode 2 : Clone Git

```bash
git clone https://github.com/VOTRE_USER/Tuto-MT5-Take-Profit-Automatique.git
```

Puis copiez les fichiers comme décrit ci-dessus.

---

## 📝 Explication complète du code

### 1. Fichier principal — `TakeProfitBot.mq5`

C'est le **point d'entrée** de l'EA. Il contient les 3 fonctions obligatoires de tout Expert Advisor MQL5 :

#### Les propriétés (`#property`)

```mql5
#property copyright   "EA Creator - autoea.online"
#property link        "https://autoea.online"
#property version     "1.00"
#property description "EA qui place automatiquement un Take Profit en pips"
```

Ces métadonnées sont affichées dans la fenêtre d'information de l'EA dans MT5. Elles n'affectent pas le fonctionnement du code.

#### Les inclusions (`#include`)

```mql5
#include "Include\TradeSelector.mqh"
#include "Include\TPCalculator.mqh"
#include "Include\TradeManager.mqh"
```

`#include` copie littéralement le contenu du fichier `.mqh` à l'endroit de la directive. C'est fait **à la compilation**, pas à l'exécution. Après compilation, tout est fusionné en un seul fichier `.ex5`.

**Guillemets (`""`)** = chemin relatif depuis le fichier actuel.
**Chevrons (`<>`)** = chemin relatif depuis le dossier `MQL5/Include/`.

#### Le paramètre d'entrée (`input`)

```mql5
input double TP_Pips = 50.0;  // Distance TP en pips
```

- `input` : ce mot-clé rend la variable modifiable par l'utilisateur dans l'interface MT5
- `double` : nombre décimal (pour supporter des valeurs comme 20.5 pips)
- `50.0` : valeur par défaut si l'utilisateur ne change rien
- Le commentaire `// Distance TP en pips` apparaît comme label dans l'interface

#### `OnInit()` — Initialisation

```mql5
int OnInit()
{
    if(TP_Pips <= 0)
    {
        Print("❌ ERREUR : La distance TP doit être supérieure à 0 !");
        return INIT_PARAMETERS_INCORRECT;
    }

    Print("🚀 Take Profit Bot démarré avec succès !");
    return INIT_SUCCEEDED;
}
```

`OnInit()` est appelée **une seule fois** au démarrage. Elle vérifie que les paramètres sont valides. Si `TP_Pips` est négatif ou nul, l'EA refuse de démarrer (`INIT_PARAMETERS_INCORRECT`).

#### `OnDeinit()` — Nettoyage

```mql5
void OnDeinit(const int reason)
{
    Print("🛑 Take Profit Bot arrêté. Raison : ", reason);
}
```

Appelée quand l'EA s'arrête. Le paramètre `reason` indique pourquoi (suppression, recompilation, fermeture du graphique, etc.).

#### `OnTick()` — Boucle principale

C'est le **cœur** de l'EA. Elle est appelée à **chaque mouvement de prix** (tick). Voici sa logique étape par étape :

```
┌─────────────────────────────────────────┐
│           Nouveau tick reçu              │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│  Compter les positions ouvertes          │
│  sur ce symbole                          │
└─────────────────┬───────────────────────┘
                  │
         nbPositions == 0 ?
          ┌───────┴───────┐
         OUI             NON
          │               │
          ▼               ▼
      (sortir)   ┌────────────────────┐
                 │  Pour chaque       │
                 │  position :        │
                 │                    │
                 │  1. Sélectionner   │
                 │  2. A déjà un TP ? │
                 │     → OUI : skip   │
                 │     → NON :        │
                 │  3. Calculer TP    │
                 │  4. Valider TP     │
                 │  5. Modifier pos.  │
                 └────────────────────┘
```

**Pourquoi vérifier si le TP existe déjà ?**

Sans cette vérification, l'EA essaierait de modifier le TP à chaque tick (plusieurs fois par seconde). Non seulement c'est inutile, mais le broker pourrait vous bloquer pour trop de requêtes.

```mql5
double tpActuel = ObtenirTPActuel();
if(tpActuel > 0)
    continue;  // TP déjà défini, on passe à la position suivante
```

---

### 2. Sélection des trades — `TradeSelector.mqh`

Ce fichier contient les fonctions pour **trouver et sélectionner** les positions ouvertes.

#### `CompterPositionsOuvertes()`

```mql5
int CompterPositionsOuvertes()
{
    int count = 0;
    int totalPositions = PositionsTotal();

    for(int i = 0; i < totalPositions; i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0)
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
                count++;
        }
    }
    return count;
}
```

**Pourquoi filtrer par symbole ?**

`PositionsTotal()` retourne **toutes** les positions ouvertes sur **tous** les symboles. Si vous tradez EURUSD et GBPUSD en même temps, cette fonction retournerait les deux. On filtre avec `_Symbol` pour ne garder que celles du graphique actif.

**Qu'est-ce qu'un ticket ?**

Le ticket est un identifiant unique attribué par le broker à chaque position. C'est un nombre entier (`ulong` = unsigned long = 0 à 18 446 744 073 709 551 615). Exemple : `ticket = 12345678`.

#### `SelectionnerPosition(indexLocal)`

Cette fonction traduit un index local (0, 1, 2...) en ticket global. C'est nécessaire car les fonctions de MT5 utilisent un index global (toutes les positions de tous les symboles), alors que nous voulons un index par symbole.

**Exemple concret :**

| Index global | Symbole | Index local (EURUSD) |
|:---:|:---:|:---:|
| 0 | GBPUSD | — |
| 1 | EURUSD | 0 |
| 2 | EURUSD | 1 |
| 3 | USDJPY | — |
| 4 | EURUSD | 2 |

Si on demande `SelectionnerPosition(1)` sur un graphique EURUSD, la fonction retourne le ticket de la position à l'index global 2.

#### Fonctions d'accès aux données

```mql5
ENUM_POSITION_TYPE ObtenirTypePosition()     // BUY ou SELL
double             ObtenirPrixOuverture()     // Prix d'entrée
double             ObtenirTPActuel()          // TP actuel (ou 0)
double             ObtenirSLActuel()          // SL actuel (ou 0)
```

Ces fonctions sont des **wrappers** (enveloppes) autour des fonctions natives MQL5. Elles simplifient la lecture du code principal.

> **Important :** Ces fonctions ne fonctionnent que si une position a été **sélectionnée** au préalable (via `PositionGetTicket()` ou `PositionSelect()`).

---

### 3. Calcul du TP en pips — `TPCalculator.mqh`

Ce fichier contient la logique mathématique pour convertir une distance en pips en un prix exact.

#### `ObtenirValeurPip()` — Comprendre les pips

Un **pip** (Point In Percentage) est l'unité de mesure standard des mouvements de prix en Forex.

```
EURUSD : 1.10000 → 1.10010 = +1 pip   (4ème décimale)
USDJPY : 150.000 → 150.010 = +1 pip   (2ème décimale)
```

Mais dans MT5, le prix est affiché avec une **décimale supplémentaire** (le "pipette") :

```
EURUSD : 5 décimales → _Point = 0.00001 → 1 pip = 10 points
USDJPY : 3 décimales → _Point = 0.001   → 1 pip = 10 points
```

La fonction détecte automatiquement le format :

```mql5
double ObtenirValeurPip()
{
    if(_Digits == 3 || _Digits == 5)
        return _Point * 10;   // Format moderne (pipettes)
    return _Point;            // Format classique
}
```

#### `CalculerPrixTP()` — La formule

Le calcul est simple une fois qu'on a la valeur d'un pip :

```
BUY  : TP = Prix d'ouverture + (Distance × Valeur pip)
SELL : TP = Prix d'ouverture - (Distance × Valeur pip)
```

**Exemple concret :**

```
Achat EURUSD à 1.10000, TP souhaité : 50 pips

Valeur pip = 0.0001 (5 décimales → _Point × 10)
Distance prix = 50 × 0.0001 = 0.0050
TP = 1.10000 + 0.0050 = 1.10500 ✅
```

```
Vente USDJPY à 150.000, TP souhaité : 30 pips

Valeur pip = 0.01 (3 décimales → _Point × 10)
Distance prix = 30 × 0.01 = 0.30
TP = 150.000 - 0.30 = 149.700 ✅
```

**Pourquoi `NormalizeDouble` ?**

Les calculs en virgule flottante peuvent produire des imprécisions :

```
1.10000 + 0.00500 = 1.10499999999998  ← problème !
NormalizeDouble(1.10499999999998, 5) = 1.10500  ← corrigé ✅
```

Sans cette normalisation, MT5 rejettera l'ordre.

#### `ValiderTP()` — Vérifications de sécurité

Avant d'envoyer la modification au broker, on vérifie :

1. **Le prix est positif** — un TP négatif n'a aucun sens
2. **Le TP est du bon côté** — au-dessus du prix pour un BUY, en-dessous pour un SELL
3. **La distance minimale** — chaque broker impose un écart minimum entre le prix actuel et les stops (`SYMBOL_TRADE_STOPS_LEVEL`)

```mql5
// Récupérer la distance minimale imposée par le broker
long stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
double distanceMin = stopsLevel * _Point;
```

Si le TP est trop proche du prix actuel, le broker le rejettera automatiquement. Notre validation le détecte **avant** l'envoi pour éviter des erreurs inutiles.

---

### 4. Modification des ordres — `TradeManager.mqh`

Ce fichier gère la communication avec le serveur du broker pour modifier les positions.

#### `ModifierTP()` — Utilisation de CTrade

MQL5 fournit une **Standard Library** avec la classe `CTrade` qui simplifie les opérations de trading :

```mql5
#include <Trade\Trade.mqh>   // Importation de la classe CTrade

bool ModifierTP(ulong ticket, double slActuel, double nouveauTP)
{
    CTrade trade;
    trade.SetDeviationInPoints(10);   // Tolérance de slippage
    
    bool resultat = trade.PositionModify(ticket, slActuel, nouveauTP);
    // ...
}
```

**Pourquoi utiliser CTrade plutôt que OrderSend() directement ?**

Sans CTrade, il faudrait remplir manuellement la structure `MqlTradeRequest` (+ de 15 champs) et gérer la structure `MqlTradeResult`. CTrade fait tout ça automatiquement.

**Comparaison :**

```mql5
// ❌ Sans CTrade (version longue)
MqlTradeRequest request = {};
MqlTradeResult result = {};
request.action = TRADE_ACTION_SLTP;
request.position = ticket;
request.symbol = _Symbol;
request.sl = slActuel;
request.tp = nouveauTP;
request.deviation = 10;
OrderSend(request, result);
if(result.retcode != TRADE_RETCODE_DONE) { /* gérer erreur */ }

// ✅ Avec CTrade (version simple)
CTrade trade;
trade.SetDeviationInPoints(10);
trade.PositionModify(ticket, slActuel, nouveauTP);
```

#### Codes de retour

Après l'envoi, le serveur répond avec un code :

| Code | Constante | Signification |
|:---:|:---:|:---|
| 10009 | `TRADE_RETCODE_DONE` | ✅ Succès |
| 10013 | `TRADE_RETCODE_INVALID` | ❌ Requête invalide |
| 10016 | `TRADE_RETCODE_INVALID_STOPS` | ❌ Stops invalides |
| 10006 | `TRADE_RETCODE_REJECT` | ❌ Rejeté par le broker |
| 10004 | `TRADE_RETCODE_REQUOTE` | ⚠️ Nouveau prix proposé |

#### `AfficherInfoPosition()` — Debug

Cette fonction affiche toutes les infos d'une position dans l'onglet `Expert` de MT5. C'est essentiel pendant le développement pour comprendre ce qui se passe.

---

## 📐 Comment fonctionne le calcul en pips ?

### Tableau récapitulatif

| Symbole | Décimales (`_Digits`) | `_Point` | Valeur 1 pip | 50 pips en prix |
|:---:|:---:|:---:|:---:|:---:|
| EURUSD | 5 | 0.00001 | 0.00010 | 0.00500 |
| GBPUSD | 5 | 0.00001 | 0.00010 | 0.00500 |
| USDJPY | 3 | 0.001 | 0.010 | 0.500 |
| EURJPY | 3 | 0.001 | 0.010 | 0.500 |
| XAUUSD | 2 | 0.01 | 0.01 | 0.50 |

### Formule générale

```
Prix TP (BUY)  = Prix ouverture + (Pips × Valeur pip)
Prix TP (SELL) = Prix ouverture - (Pips × Valeur pip)
```

### Exemples détaillés

**Exemple 1 : BUY EURUSD**
```
Entrée : 1.10250
TP : 50 pips
Calcul : 1.10250 + (50 × 0.00010) = 1.10250 + 0.00500 = 1.10750
```

**Exemple 2 : SELL USDJPY**
```
Entrée : 149.850
TP : 30 pips
Calcul : 149.850 - (30 × 0.010) = 149.850 - 0.300 = 149.550
```

**Exemple 3 : BUY XAUUSD (Or)**
```
Entrée : 1925.50
TP : 100 pips
Calcul : 1925.50 + (100 × 0.01) = 1925.50 + 1.00 = 1926.50
```

---

## 🔄 Cycle de vie d'un Expert Advisor

```
┌──────────────────────────────────────────────────────────┐
│                    CHARGEMENT DE L'EA                      │
│            (double-clic dans le Navigateur)                │
└─────────────────────────┬────────────────────────────────┘
                          │
                          ▼
                    ┌──────────┐
                    │ OnInit() │ ← Appelée 1 SEULE FOIS
                    └────┬─────┘
                         │
              INIT_SUCCEEDED ?
              ┌──────────┴──────────┐
             NON                   OUI
              │                     │
              ▼                     ▼
         (EA arrêté)         ┌──────────────┐
                             │   BOUCLE     │
                             │  PRINCIPALE  │
                             │              │
                             │  OnTick() ◄──┼── Chaque tick
                             │              │
                             └──────┬───────┘
                                    │
                            (EA retiré / MT5 fermé)
                                    │
                                    ▼
                             ┌────────────┐
                             │ OnDeinit() │ ← Nettoyage
                             └────────────┘
```

### Fréquence des ticks

| Marché | Ticks par seconde (environ) |
|:---:|:---:|
| EUR/USD (haute liquidité) | 5-50 ticks/s |
| Actions (moyenne liquidité) | 1-10 ticks/s |
| Crypto (variable) | 1-30 ticks/s |
| Weekend / hors marché | 0 tick |

> **⚠️ Important :** `OnTick()` n'est PAS appelée à intervalles réguliers. Elle est déclenchée par les mouvements de prix réels. Si le marché est calme, elle est rarement appelée.

---

## ⚙️ Configuration et paramètres

Quand vous placez l'EA sur un graphique, une fenêtre de paramètres apparaît :

| Paramètre | Type | Défaut | Description |
|:---:|:---:|:---:|:---|
| `TP_Pips` | double | 50.0 | Distance du Take Profit en pips |

### Conseils de configuration

| Stratégie | TP recommandé | Notes |
|:---:|:---:|:---|
| Scalping | 5-15 pips | Petits mouvements, sorties rapides |
| Day trading | 20-50 pips | Intraday, bons pour la plupart des paires |
| Swing trading | 50-200 pips | Positions tenues plusieurs jours |
| Position trading | 200-500+ pips | Long terme |

> **⚠️ Rappel :** Ces valeurs sont indicatives. Le TP idéal dépend de votre stratégie, du symbole, de la volatilité et de votre ratio risque/récompense.

---

## ❌ Gestion des erreurs

L'EA gère plusieurs types d'erreurs :

### Erreurs de paramètres

| Erreur | Cause | Solution |
|:---:|:---:|:---|
| TP ≤ 0 | Valeur négative ou nulle | Entrez une valeur positive |

### Erreurs de calcul

| Erreur | Cause | Solution |
|:---:|:---:|:---|
| TP trop proche | Distance < `SYMBOL_TRADE_STOPS_LEVEL` | Augmentez la distance TP |
| TP du mauvais côté | Bug logique | Vérifiez le type BUY/SELL |

### Erreurs broker

| Code | Signification | Solution |
|:---:|:---:|:---|
| 10013 | Requête invalide | Vérifiez les paramètres |
| 10016 | Stops invalides | Distance trop faible |
| 10006 | Rejeté par broker | Marché fermé ou restriction |
| 10015 | Prix invalide | Problème de normalisation |

### Où voir les logs ?

Dans MT5, allez dans l'onglet **"Expert"** en bas de l'écran. Tous les messages `Print()` de l'EA apparaissent ici avec un horodatage.

---

## 🧪 Tests et backtest

### Test en temps réel (compte démo)

1. Ouvrez un **compte démo** chez votre broker
2. Placez l'EA sur un graphique
3. Ouvrez un trade manuellement **sans définir de TP**
4. Observez dans les logs et dans la liste des positions : le TP doit apparaître automatiquement

### Backtest dans le Strategy Tester

> **Note :** Le backtest de cet EA est limité car il ne prend pas de positions lui-même. Il modifie uniquement les positions existantes. Pour un backtest significatif, combinez cet EA avec un EA qui ouvre des positions.

1. MT5 → Menu `Affichage` → `Testeur de stratégie`
2. Sélectionnez `TakeProfitBot`
3. Choisissez un symbole et une période
4. Lancez le test

---

## ❓ FAQ

### Puis-je utiliser cet EA en production ?

Ce code est un **tutoriel éducatif**. Il fonctionne mais manque de certaines protections avancées pour un usage professionnel (gestion multi-thread, retry automatique, etc.).

### L'EA ouvre-t-il des positions ?

**Non.** Cet EA ne fait que **modifier** des positions existantes pour ajouter un Take Profit. Vous devez ouvrir les trades vous-même ou via un autre EA.

### Que se passe-t-il si le TP est déjà défini ?

L'EA **ignore** les positions qui ont déjà un TP (`tpActuel > 0`). Il ne modifie jamais un TP existant.

### Est-ce compatible avec les Prop Firms ?

Oui, les EA de gestion du risque sont généralement **autorisés et recommandés** par les Prop Firms (FTMO, Funded Next, etc.) car ils aident à respecter les règles de drawdown.

### Comment modifier le code ?

1. Ouvrez le fichier `.mq5` dans **MetaEditor**
2. Faites vos modifications
3. Appuyez sur `F7` pour recompiler
4. L'EA se rechargera automatiquement dans MT5

---

## 🔗 Liens utiles

### Documentation officielle
- 📖 [Documentation MQL5 complète](https://www.mql5.com/fr/docs)
- 📖 [Classe CTrade](https://www.mql5.com/fr/docs/standardlibrary/tradeclasses/ctrade)
- 📖 [Fonctions de positions](https://www.mql5.com/fr/docs/trading/positiongetticket)
- 📖 [Standard Library](https://www.mql5.com/fr/docs/standardlibrary)

### Articles MQL5
- 📰 [Les bases des Expert Advisors](https://www.mql5.com/fr/articles)
- 📰 [Gestion du risque en MQL5](https://www.mql5.com/fr/articles)

### Téléchargements
- ⬇️ [MetaTrader 5](https://www.metatrader5.com/fr/download)
- ⬇️ [MetaEditor](https://www.metatrader5.com/fr/download) (inclus dans MT5)

---



---

## 📄 Licence

Ce projet est sous licence [MIT](LICENSE). Vous êtes libre de l'utiliser, le modifier et le distribuer.

---

<p align="center">
  Fait par <a href="https://autoea.online">EA Creator</a>
</p>

