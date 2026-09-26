# APNBF — Burkina Faso

Application mobile de gestion commerciale pour un artisan/commerçant : maçonnerie, carrelage, plomberie, peinture, vente de produits d'occasion et importation.

## V1 professionnelle

- Tableau de bord activité
- Clients, fiches et crédits
- Commandes et précommandes
- Produits et services avec photos
- Trésorerie : entrées, sorties et solde
- Relances par appel et WhatsApp
- Espace client public dans l'application
- Demandes clients depuis la vitrine
- QR de téléchargement de l'APK
- QR personnel pour ouvrir la vitrine client
- Identité visuelle APNBF
- Stockage média Supabase sécurisé par entreprise

## Stack

Flutter + Riverpod + GoRouter + Supabase/PostgreSQL.

Le modèle de données est multi-entreprise dès la V1 grâce à `business_id`, afin de permettre une évolution future vers un SaaS pour artisans et commerçants.

## Médias

Les photos des produits et services sont stockées dans le bucket Supabase `apnbf-media`. Les chemins commencent par l'identifiant de l'entreprise et les politiques Storage empêchent un utilisateur authentifié d'écrire dans le dossier d'une autre entreprise.

## Démarrage

Si les plateformes Flutter ne sont pas encore présentes, exécuter à la racine :

```bash
flutter create .
flutter pub get
```

Pour connecter Supabase :

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Ne jamais mettre une service-role key dans l'application mobile.

## QR et distribution

Le module **QR & partage** génère :

1. un QR de téléchargement de l'APK Android depuis les releases GitHub ;
2. un QR privé permettant d'ouvrir la vitrine client de l'entreprise dans APNBF.

Quand APNBF sera publié sur Google Play, le lien de téléchargement pourra être remplacé par la fiche officielle.

## Identité visuelle

- `assets/brand/apnbf_logo.svg` : logo principal
- `assets/brand/apnbf_icon.svg` : icône de marque
- `web/favicon.svg` : favicon
- `web/thumbnail.svg` : miniature sociale / future landing page

## Roadmap

1. ~~Fondations Flutter + Supabase~~
2. ~~Authentification et profil professionnel~~
3. ~~Clients~~
4. ~~Produits et services~~
5. ~~Commandes / précommandes~~
6. ~~Ventes / paiements / crédits / dépenses~~
7. ~~Dashboard et trésorerie~~
8. ~~WhatsApp / téléphone~~
9. Devis et chantiers
10. Multi-entreprises avancé, catalogue web public et automatisations
