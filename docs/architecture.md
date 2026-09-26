# APNBF — Architecture

## Principes

- Flutter UI séparée des accès Supabase.
- Organisation par fonctionnalité dans lib/features.
- Toutes les données métier sont rattachées à business_id.
- PostgreSQL + RLS constituent la frontière de sécurité.
- Le catalogue public sera ajouté avec des politiques dédiées.
- Aucun secret serveur dans l'application mobile.

## Évolution

V1 : usage mono-utilisateur, modèle multi-business.
V2 : chantiers, devis, fournisseurs, importations.
V3 : catalogue public, portail client, multi-entreprises, abonnements.
V4 : automatisations et assistant vocal/IA.
