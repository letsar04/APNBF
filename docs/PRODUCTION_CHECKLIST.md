# APNBF — checklist de mise en production

## 1. Initialiser les plateformes Flutter

Le dépôt conserve volontairement le code Flutter et les migrations. Si les dossiers natifs ne sont pas encore présents localement :

```powershell
flutter create --platforms=android,web --project-name apnbf .
flutter pub get
```

## 2. Lancer sur Android

```powershell
flutter run --dart-define=SUPABASE_URL="https://yvgfdwuwymhgauicfutr.supabase.co" --dart-define=SUPABASE_PUBLISHABLE_KEY="TA_CLE_PUBLISHABLE"
```

## 3. Images

Les images des produits et services sont stockées dans le bucket Supabase `apnbf-media`.
Le bucket est public en lecture afin que les clients puissent voir les visuels de la vitrine.
Les écritures restent limitées aux membres de l'entreprise.

## 4. Espace client

Route interne Flutter :

`/client-space/<businessId>`

Le client peut :
- consulter les produits disponibles ;
- consulter les services ;
- appeler ;
- contacter via WhatsApp ;
- commander un produit ;
- demander un devis pour un service.

Les demandes arrivent dans `customer_requests` et apparaissent dans `Demandes clients` côté professionnel.

## 5. QR code

Le module `QR & partage` génère :
- un QR de téléchargement APNBF ;
- un QR de l'espace client.

Le QR de téléchargement pointe actuellement vers les releases GitHub. Une fois APNBF publié sur Google Play, remplacer `downloadUrl` dans `share_qr_page.dart` par l'URL Play Store officielle.

## 6. Release Android

Ajouter dans les secrets GitHub :

`SUPABASE_PUBLISHABLE_KEY`

Puis créer un tag :

```powershell
git tag v0.2.0
git push origin v0.2.0
```

Le workflow `.github/workflows/android-release.yml` génère l'APK et l'attache à la release GitHub.

Pour Google Play, générer ensuite un AAB signé (`flutter build appbundle`) avec une clé de signature conservée hors du dépôt.
