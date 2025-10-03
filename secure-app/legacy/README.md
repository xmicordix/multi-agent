# 📦 Legacy Files - Prototypes Historiques

Ce dossier contient les anciens fichiers prototypes du développement initial du projet **Secure Universal Analysis 2025**.

## 🗂️ Fichiers Archivés

### `simple-server.ts`
- **Version**: Prototype v1.0
- **Date**: Première itération rapide
- **Description**: Serveur Deno simple avec hardcodage
- **Remplacé par**: `src/server/app.server.ts` (architecture professionnelle)

### `deno-server.ts`
- **Version**: Prototype v0.9
- **Date**: Version avec dépendances Oak
- **Description**: Tentative avec framework externe (échec dépendances)
- **Remplacé par**: `src/server/app.server.ts` (native Deno)

### `start-secure-server.bat`
- **Version**: Lanceur basique v1.0
- **Description**: Script de démarrage simple
- **Remplacé par**: `bin/start-server.bat` (lanceur professionnel)

### `install-deno.ps1`
- **Version**: Installeur automatique v1.0
- **Description**: Script d'installation PowerShell
- **Remplacé par**: Instructions manuelles dans README principal

## 🔄 Évolution vers Architecture Professionnelle

Ces fichiers représentent l'évolution naturelle du projet :

1. **Phase Prototype** (legacy/) : Développement rapide, hardcodage
2. **Phase Professionnelle** (src/) : Architecture enterprise, configuration centralisée

## ⚠️ Important

Ces fichiers sont **obsolètes** et ne doivent **pas être utilisés**. Ils sont conservés uniquement pour :
- Référence historique du développement
- Compréhension de l'évolution du projet
- Analyse des patterns abandonnés

## 🚀 Utilisation Actuelle

**Utilisez toujours** : `bin/start-server.bat` pour lancer le serveur professionnel.

---

*Fichiers archivés le 2025-10-03 lors de la migration vers l'architecture professionnelle.*