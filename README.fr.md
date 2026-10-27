# Santé, bonheur et revenu en Europe

> 🇬🇧 [English version](README.md)

**Le lien entre santé et bonheur dépend-il de l'éducation et du revenu ?** Une analyse descriptive de l'European Social Survey en R, qui compare la France au reste de l'Europe.

*ENSAE Paris · Statistiques descriptives avec R (décembre 2025) · Samuel Placek & Eytan Zaghroun*

![Bonheur selon la santé subjective](figures/04_happiness_by_health.png)

## Données

[European Social Survey](https://doi.org/10.21338/ess9e03_2), vague 9 (2018), édition 3.2 : **49 519 répondants dans 29 pays**, dont 2 010 en France.

| Variable | Code ESS | Échelle |
|---|---|---|
| Bonheur subjectif (cible) | `happy` | 0 (extrêmement malheureux) à 10 (extrêmement heureux) |
| Santé subjective | `health` | recodée de 1 (très mauvaise) à 5 (très bonne) |
| Années d'éducation | `eduyrs` | années d'études à temps plein achevées |
| Revenu du ménage | `hinctnta` | décile du revenu net total du ménage, de 1 à 10 |

Les non-réponses (refus, « ne sait pas », valeurs manquantes) sont retirées pour chaque variable.

## Principaux résultats

**1. La France se situe légèrement sous la moyenne européenne.** Le bonheur moyen est de 7,2/10 en France contre 7,4 sur l'ensemble des répondants, entre la Bulgarie (5,6) et le Danemark (8,4). Les Français « très heureux » sont moins nombreux : 21 % répondent 9 ou 10 sur 10, contre 29 % en Europe.

**2. La santé est le facteur le plus lié au bonheur.** Le bonheur moyen passe de 4,8 chez les personnes en très mauvaise santé à 8,2 chez celles en très bonne santé (Europe ; de 5,8 à 8,0 en France).

**3. L'éducation aide, mais de moins en moins.** Bonheur et santé augmentent avec le nombre d'années d'études jusqu'à environ 20 ans, puis plafonnent. Au-delà de 30 ans, les groupes sont trop petits pour que les moyennes soient fiables.

**4. Le revenu va de pair avec le bonheur, même en haut de l'échelle.** Le bonheur moyen augmente régulièrement de 6,4 dans le premier décile de revenu à 8,2 dans le dernier (Europe), sans seuil de saturation net, ce qui rejoint Stevenson & Wolfers (2008) plutôt que le paradoxe d'Easterlin. La santé suit le même gradient (de 3,3 à 4,2).

![Bonheur et santé selon le décile de revenu](figures/07_income_happiness_health.png)

### Limites
- **Corrélation n'est pas causalité** : ce sont des associations descriptives, pas des effets causaux.
- Toutes les mesures sauf l'éducation sont **déclaratives**.
- Les moyennes sont **non pondérées**, sauf le tableau sur l'éducation, qui utilise les pondérations de post-stratification de l'ESS (`pspwght`).

## Reproduire l'analyse

1. Télécharger les données : sur le [portail de l'ESS](https://doi.org/10.21338/ess9e03_2), récupérer **ESS vague 9, édition 3.2** au format CSV (inscription gratuite). Les données ne peuvent pas être redistribuées, elles ne sont donc pas incluses dans ce dépôt.
2. Placer `ESS9e03_2.csv` dans le dossier `data/`.
3. Depuis la racine du dépôt, lancer :
   ```bash
   Rscript R/analysis.R
   ```
   Le script n'utilise que R de base (aucun package à installer). Les figures sont enregistrées dans `figures/` et les statistiques clés s'affichent dans la console.

## Structure du projet

```
R/analysis.R     Analyse complète : nettoyage, statistiques et figures
figures/         Toutes les figures générées
report/          Rapport original (en français, PDF)
data/            Emplacement de ESS9e03_2.csv (non versionné)
```

## Auteurs

**Samuel Placek** · **Eytan Zaghroun** : ENSAE Paris
