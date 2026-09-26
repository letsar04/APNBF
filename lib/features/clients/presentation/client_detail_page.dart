import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/clients_repository.dart';

class ClientDetailPage extends StatefulWidget {
  const ClientDetailPage({super.key, required this.clientId});
  final String clientId;
  @override State<ClientDetailPage> createState()=>_ClientDetailPageState();
}
class _ClientDetailPageState extends State<ClientDetailPage>{
  final repo=ClientsRepository(); late Future<Map<String,dynamic>> clientFuture; late Future<List<Map<String,dynamic>>> creditsFuture;
  @override void initState(){super.initState();_load();}
  void _load(){clientFuture=repo.get(widget.clientId);creditsFuture=repo.credits(widget.clientId);setStateIfMounted();}
  void setStateIfMounted(){if(mounted)setState((){});}
  Future<void> _call(String value) async {final n=_phone(value);if(n.isNotEmpty)await launchUrl(Uri.parse('tel:$n'));}
  Future<void> _whatsapp(String value) async {final n=_phone(value);if(n.isEmpty)return;await launchUrl(Uri.parse('https://wa.me/$n'),mode:LaunchMode.externalApplication);}
  String _phone(String v){var n=v.replaceAll(RegExp(r'[^0-9+]'),'');if(n.startsWith('00'))n=n.substring(2);if(n.startsWith('0'))n='226${n.substring(1)}';else if(n.startsWith('+'))n=n.substring(1);return n;}
  Future<void> _credit() async {final r=await showDialog<bool>(context:context,builder:(_)=>const _CreditDialog(clientId:''));}
  @override Widget build(BuildContext context)=>FutureBuilder<Map<String,dynamic>>(future:clientFuture,builder:(context,snap){
    if(!snap.hasData)return const Scaffold(body:Center(child:CircularProgressIndicator())); final c=snap.data!;
    final phone=(c['phone']??'').toString(); final wa=(c['whatsapp']??phone).toString();
    return Scaffold(appBar:AppBar(title:Text(c['full_name']??'Client')),body:ListView(padding:const EdgeInsets.all(16),children:[
      Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(c['full_name']??'',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold)),
        if(phone.isNotEmpty)Text('Téléphone : $phone'),if((c['address']??'').toString().isNotEmpty)Text('Zone : ${c['address']}'),
        const SizedBox(height:12),Wrap(spacing:8,children:[
          if(phone.isNotEmpty)OutlinedButton.icon(onPressed:()=>_call(phone),icon:const Icon(Icons.call),label:const Text('Appeler')),
          if(wa.isNotEmpty)OutlinedButton.icon(onPressed:()=>_whatsapp(wa),icon:const Icon(Icons.chat),label:const Text('WhatsApp')),
        ])
      ]))),
      const SizedBox(height:12),Row(children:[Expanded(child:Text('Crédits',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:()=>showDialog(context:context,builder:(_)=>_CreditDialog(clientId:widget.clientId)).then((_){if(mounted)setState(()=>creditsFuture=repo.credits(widget.clientId));}),icon:const Icon(Icons.add),label:const Text('Crédit'))]),
      const SizedBox(height:8),FutureBuilder<List<Map<String,dynamic>>>(future:creditsFuture,builder:(context,s){
        if(s.connectionState==ConnectionState.waiting)return const LinearProgressIndicator(); final list=s.data??[];
        if(list.isEmpty)return const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Aucun crédit pour ce client.')));
        return Column(children:list.map((x)=>_CreditCard(credit:x,clientId:widget.clientId,onPaid:(){setState(()=>creditsFuture=repo.credits(widget.clientId));})).toList());
      })
    ]));
  });
}

class _CreditCard extends StatelessWidget{
  const _CreditCard({required this.credit,required this.clientId,required this.onPaid});
  final Map<String,dynamic> credit;final String clientId;final VoidCallback onPaid;
  @override Widget build(BuildContext context){final total=(credit['original_amount'] as num).toDouble();final paid=(credit['paid_amount'] as num).toDouble();final remain=total-paid;
    return Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Expanded(child:Text('${total.toStringAsFixed(0)} F',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:18))),Text(credit['status']??'active')]),
      Text('Payé : ${paid.toStringAsFixed(0)} F  •  Reste : ${remain.toStringAsFixed(0)} F'),
      if(credit['due_date']!=null)Text('Échéance : ${credit['due_date']}'),
      if(remain>0)Align(alignment:Alignment.centerRight,child:TextButton(onPressed:()=>showDialog(context:context,builder:(_)=>_PaymentDialog(credit:credit,clientId:clientId)).then((_){onPaid();}),child:const Text('Enregistrer un paiement')))
    ])));
  }
}
class _CreditDialog extends StatefulWidget{const _CreditDialog({required this.clientId});final String clientId;@override State<_CreditDialog> createState()=>_CreditDialogState();}
class _CreditDialogState extends State<_CreditDialog>{final amount=TextEditingController();final notes=TextEditingController();DateTime? due;bool loading=false;@override void dispose(){amount.dispose();notes.dispose();super.dispose();}
@override Widget build(BuildContext c)=>AlertDialog(title:const Text('Nouveau crédit'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Montant (F CFA)')),TextField(controller:notes,decoration:const InputDecoration(labelText:'Note')),TextButton.icon(onPressed:()async{final d=await showDatePicker(context:c,firstDate:DateTime.now(),lastDate:DateTime(2100),initialDate:DateTime.now().add(const Duration(days:30)));if(d!=null)setState(()=>due=d);},icon:const Icon(Icons.event),label:Text(due==null?'Ajouter une échéance':due!.toIso8601String().split('T').first))]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Annuler')),FilledButton(onPressed:loading?null:()async{final a=double.tryParse(amount.text.replaceAll(' ',''));if(a==null||a<=0)return;setState(()=>loading=true);try{await ClientsRepository().createCredit(clientId:widget.clientId,amount:a,dueDate:due,notes:notes.text);if(c.mounted)Navigator.pop(c,true);}catch(e){if(c.mounted)ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('$e')));}finally{if(mounted)setState(()=>loading=false);}},child:const Text('Créer'))]));}
class _PaymentDialog extends StatefulWidget{const _PaymentDialog({required this.credit,required this.clientId});final Map<String,dynamic> credit;final String clientId;@override State<_PaymentDialog> createState()=>_PaymentDialogState();}
class _PaymentDialogState extends State<_PaymentDialog>{final amount=TextEditingController();String method='cash';@override void dispose(){amount.dispose();super.dispose();}@override Widget build(BuildContext c){final remain=(widget.credit['original_amount'] as num).toDouble()-(widget.credit['paid_amount'] as num).toDouble();return AlertDialog(title:const Text('Enregistrer un paiement'),content:Column(mainAxisSize:MainAxisSize.min,children:[Text('Reste : ${remain.toStringAsFixed(0)} F'),TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Montant')),DropdownButtonFormField<String>(value:method,items:const[DropdownMenuItem(value:'cash',child:Text('Espèces')),DropdownMenuItem(value:'mobile_money',child:Text('Mobile Money')),DropdownMenuItem(value:'bank',child:Text('Banque'))],onChanged:(v){if(v!=null)setState(()=>method=v);})]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Annuler')),FilledButton(onPressed:()async{final a=double.tryParse(amount.text);if(a==null||a<=0||a>remain)return;try{await ClientsRepository().payCredit(creditId:widget.credit['id'],amount:a,clientId:widget.clientId,method:method);if(c.mounted)Navigator.pop(c,true);}catch(e){if(c.mounted)ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('$e')));}},child:const Text('Enregistrer'))]));}}
