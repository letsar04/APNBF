import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/session/app_session.dart';

class ShareQrPage extends StatefulWidget { const ShareQrPage({super.key}); @override State<ShareQrPage> createState()=>_ShareQrPageState(); }
class _ShareQrPageState extends State<ShareQrPage> {
  final session=AppSession(); late Future<String> businessFuture;
  // Replace this with the Play Store/App Store landing page when APNBF is published.
  static const downloadUrl='https://github.com/letsar04/APNBF/releases/latest';
  @override void initState(){super.initState();businessFuture=session.businessId();}
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('QR & partage')),body:FutureBuilder<String>(future:businessFuture,builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final id=s.data!;final clientLink='apnbf://client-space/$id';return ListView(padding:const EdgeInsets.all(20),children:[
    _QrCard(title:'Télécharger APNBF',subtitle:'Le client scanne ce QR pour accéder à la page de téléchargement.',data:downloadUrl),
    const SizedBox(height:16),
    _QrCard(title:'Espace client',subtitle:'QR utilisable depuis APNBF pour ouvrir directement votre vitrine client.',data:clientLink),
    const SizedBox(height:20),
    Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Conseil',style:TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:6),const Text('Imprime le QR de téléchargement sur tes cartes de visite, factures et affiches. Quand APNBF sera publié sur Google Play, remplace simplement le lien par celui de la fiche officielle.')])))
  ]);});
}
class _QrCard extends StatelessWidget{const _QrCard({required this.title,required this.subtitle,required this.data});final String title,subtitle,data;@override Widget build(BuildContext c)=>Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(children:[Text(title,style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:6),Text(subtitle,textAlign:TextAlign.center),const SizedBox(height:16),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:QrImageView(data:data,size:210,backgroundColor:Colors.white)),const SizedBox(height:12),SelectableText(data,textAlign:TextAlign.center,style:const TextStyle(fontSize:12)),const SizedBox(height:10),OutlinedButton.icon(onPressed:()=>launchUrl(Uri.parse(data),mode:LaunchMode.externalApplication),icon:const Icon(Icons.open_in_new),label:const Text('Ouvrir le lien'))])));}
