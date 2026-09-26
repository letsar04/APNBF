# APNBF — Burkina Faso

Application mobile de gestion commerciale pour un artisan/commerçant : maçonnerie, carrelage, plomberie, peinture, vente de produits d'occasion et importation.

## Stack

Flutter + Riverpod + GoRouter + Supabase/PostgreSQL.

Le modèle de données est multi-entreprise dès la V1 grâce à business_id, afin de permettre une évolution future vers un SaaS pour artisans et commerçants.

## Démarrage

Si les plateformes Flutter ne sont pas encore présentes, exécuter à la racine :

flutter create .
flutter pub get

L'application démarre en mode démonstration local si les identifiants Supabase ne sont pas fournis.

Pour connecter Supabase :

flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY

Ne jamais mettre une service-role key dans l'application mobile.

## Roadmap

1. Fondations Flutter + Supabase
2. Authentification et profil professionnel
3. Clients
4. Produits et services
5. Commandes / précommandes
6. Ventes / paiements / crédits / dépenses
7. Dashboard et trésorerie
8. WhatsApp / téléphone
9. Devis et chantiers
10. Multi-entreprises, catalogue public et automatisations
