import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/brand/apnbf_logo.dart';

class HomePage extends StatelessWidget { const HomePage({super.key});
  @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:520),child:Column(children:[
    SizedBox(height:28),ApnbfLogo(height:78),SizedBox(height:30),
    Text('Ton activité, simplement.',style:TextStyle(fontSize:30,fontWeight:FontWeight.w800),textAlign:TextAlign.center),SizedBox(height:10),
    Text('Services, produits, commandes, crédits et trésorerie dans une seule application pensée pour les professionnels au Burkina Faso.',textAlign:TextAlign.center,style:TextStyle(fontSize:16,height:1.5)),SizedBox(height:26),
    Card(child:Padding(padding:EdgeInsets.all(18),child:Column(children:[_Feature(icon:Icons.handyman_outlined,text:'Présente tes services et tes produits'),_Feature(icon:Icons.receipt_long_outlined,text:'Reçois et suis les commandes'),_Feature(icon:Icons.account_balance_wallet_outlined,text:'Suis ta trésorerie et tes crédits'),_Feature(icon:Icons.qr_code_2,text:'Partage facilement ton activité')]))),SizedBox(height:22),
    SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:()=>context.go('/auth'),icon:Icon(Icons.arrow_forward_rounded),label:Padding(padding:EdgeInsets.symmetric(vertical:12),child:Text('Commencer'))),),SizedBox(height:12),
    Text('APNBF • Burkina Faso',style:Theme.of(context).textTheme.bodySmall)
  ]))))));
}
class _Feature extends StatelessWidget{const _Feature({required this.icon,required this.text});final IconData icon;final String text;@override Widget build(BuildContext c)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[Icon(icon,color:Theme.of(c).colorScheme.primary),const SizedBox(width:12),Expanded(child:Text(text))]));}
