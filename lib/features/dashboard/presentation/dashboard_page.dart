import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/auth_repository.dart';
import '../../../core/session/app_session.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState()=>_DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage>{
  final session=AppSession(); late Future<_Stats> future;
  @override void initState(){super.initState();future=_load();}
  Future<_Stats> _load() async{
    final id=await session.businessId(); final db=Supabase.instance.client;
    final income=await db.from('transactions').select('amount').eq('business_id',id).eq('type','income');
    final expense=await db.from('transactions').select('amount').eq('business_id',id).eq('type','expense');
    final credits=await db.from('credits').select('original_amount,paid_amount').eq('business_id',id).neq('status','paid').neq('status','cancelled');
    final orders=await db.from('orders').select('id').eq('business_id',id).neq('status','cancelled');
    final clients=await db.from('clients').select('id').eq('business_id',id);
    double sum(List x,String k)=>x.fold(0.0,(s,e)=>s+(e[k] as num).toDouble());
    return _Stats(income:sum(income,'amount'),expense:sum(expense,'amount'),receivable:credits.fold(0.0,(s,e)=>s+(e['original_amount'] as num).toDouble()-(e['paid_amount'] as num).toDouble()),orders:orders.length,clients:clients.length);
  }
  Future<void> logout()async{await AuthRepository().signOut();if(mounted)context.go('/');}
  @override Widget build(BuildContext context){final user=Supabase.instance.client.auth.currentUser;final name=user?.userMetadata?['full_name'] as String? ?? 'Responsable';
    return Scaffold(appBar:AppBar(title:const Text('Mon activité'),actions:[IconButton(onPressed:logout,icon:const Icon(Icons.logout_outlined))]),
      body:RefreshIndicator(onRefresh:()async=>setState(()=>future=_load()),child:ListView(padding:const EdgeInsets.all(16),children:[
        Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Bonjour $name',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),const SizedBox(height:4),const Text('Pilote ton activité depuis un seul endroit.')]))) ,
        const SizedBox(height:12),
        FutureBuilder<_Stats>(future:future,builder:(c,s){if(!s.hasData)return const LinearProgressIndicator();final x=s.data!;return Column(children:[
          Row(children:[Expanded(child:_MetricCard(title:'Encaissements',value:_money(x.income))),const SizedBox(width:10),Expanded(child:_MetricCard(title:'À recevoir',value:_money(x.receivable)))]),
          const SizedBox(height:10),Row(children:[Expanded(child:_MetricCard(title:'Dépenses',value:_money(x.expense))),const SizedBox(width:10),Expanded(child:_MetricCard(title:'Commandes',value:'${x.orders}'))]),
          const SizedBox(height:10),Card(child:ListTile(leading:const Icon(Icons.people_outline),title:const Text('Clients'),subtitle:Text('${x.clients} client(s)'),trailing:const Icon(Icons.chevron_right),onTap:()=>context.push('/clients')))
        ];}),
        const SizedBox(height:16),_section('Vendre et travailler',[
          _Action('Clients',Icons.people_outline,()=>context.push('/clients')),
          _Action('Produits',Icons.inventory_2_outlined,()=>context.push('/products')),
          _Action('Services',Icons.handyman_outlined,()=>context.push('/services')),
          _Action('Commandes',Icons.receipt_long_outlined,()=>context.push('/orders')),
          _Action('Précommandes',Icons.bookmark_border,()=>context.push('/preorders')),
        ]),const SizedBox(height:10),_section('Argent',[
          _Action('Trésorerie',Icons.account_balance_wallet_outlined,()=>context.push('/finance')),
        ])
      ]));
  }
  String _money(double n)=>'${n.toStringAsFixed(0)} F';
  Widget _section(String title,List<Widget> children)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)),const SizedBox(height:8),Wrap(spacing:8,runSpacing:8,children:children)]);
}
class _Stats{final double income,expense,receivable;final int orders,clients;_Stats({required this.income,required this.expense,required this.receivable,required this.orders,required this.clients});}
class _MetricCard extends StatelessWidget{const _MetricCard({required this.title,required this.value});final String title,value;@override Widget build(BuildContext c)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title),const SizedBox(height:6),Text(value,style:Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800))])));}
class _Action extends StatelessWidget{const _Action(this.label,this.icon,this.onTap);final String label;final IconData icon;final VoidCallback onTap;@override Widget build(BuildContext c)=>SizedBox(width:150,child:Card(child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(12),child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[Icon(icon,size:30),const SizedBox(height:7),Text(label)])))));}
