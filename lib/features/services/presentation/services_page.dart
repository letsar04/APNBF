import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/media/media_service.dart';
import '../../../core/session/app_session.dart';

class ServicesPage extends StatefulWidget { const ServicesPage({super.key}); @override State<ServicesPage> createState()=>_ServicesPageState(); }
class _ServicesPageState extends State<ServicesPage> {
  late Future<List<Map<String,dynamic>>> future; final db=Supabase.instance.client;
  @override void initState(){super.initState();future=_list();}
  Future<List<Map<String,dynamic>>> _list() async { final id=await AppSession().businessId(); final x=await db.from('services').select().eq('business_id',id).eq('is_active',true).order('name'); return List<Map<String,dynamic>>.from(x); }
  void refresh()=>setState(()=>future=_list());
  Future<void> add() async {final ok=await showDialog<bool>(context:context,builder:(_)=>const _ServiceDialog());if(ok==true)refresh();}
  @override Widget build(BuildContext c)=>Scaffold(
    appBar:AppBar(title:const Text('Services'),actions:[IconButton(onPressed:add,icon:const Icon(Icons.add))]),
    body:FutureBuilder<List<Map<String,dynamic>>>(future:future,builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final list=s.data!;if(list.isEmpty)return const Center(child:Text('Aucun service.'));return ListView.separated(padding:const EdgeInsets.all(16),itemCount:list.length,separatorBuilder:(_,__)=>const SizedBox(height:8),itemBuilder:(_,i){final x=list[i];final url=x['image_url']?.toString();final price=x['price_type']=='quote'?'Sur devis': '${x['base_price']} F';return Card(child:ListTile(contentPadding:const EdgeInsets.all(10),leading:ClipRRect(borderRadius:BorderRadius.circular(10),child:url==null||url.isEmpty?Container(width:58,height:58,color:Theme.of(c).colorScheme.primaryContainer,child:const Icon(Icons.handyman_outlined)):Image.network(url,width:58,height:58,fit:BoxFit.cover)),title:Text(x['name']??'',style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(price)));});}),
    floatingActionButton:FloatingActionButton.extended(onPressed:add,icon:const Icon(Icons.add),label:const Text('Service')),
  );
}
class _ServiceDialog extends StatefulWidget{const _ServiceDialog();@override State<_ServiceDialog> createState()=>_ServiceDialogState();}
class _ServiceDialogState extends State<_ServiceDialog>{
  final name=TextEditingController(),price=TextEditingController(),desc=TextEditingController();final media=MediaService();String type='quote';XFile? image;bool loading=false;
  @override void dispose(){name.dispose();price.dispose();desc.dispose();super.dispose();}
  @override Widget build(BuildContext c)=>AlertDialog(title:const Text('Nouveau service'),content:SingleChildScrollView(child:SizedBox(width:420,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    InkWell(onTap:()async{final x=await media.pickImage();if(x!=null)setState(()=>image=x);},child:Container(width:double.infinity,height:150,decoration:BoxDecoration(color:Theme.of(c).colorScheme.surfaceContainerHighest,borderRadius:BorderRadius.circular(16)),child:image==null?const Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.add_a_photo_outlined,size:36),SizedBox(height:8),Text('Ajouter une photo du service')]):FutureBuilder(future:image!.readAsBytes(),builder:(_,s)=>s.hasData?Image.memory(s.data!,fit:BoxFit.cover):const Center(child:CircularProgressIndicator())))),
    const SizedBox(height:14),TextField(controller:name,decoration:const InputDecoration(labelText:'Nom du service')),const SizedBox(height:10),TextField(controller:desc,maxLines:3,decoration:const InputDecoration(labelText:'Description')),const SizedBox(height:10),DropdownButtonFormField(value:type,items:const[DropdownMenuItem(value:'quote',child:Text('Sur devis')),DropdownMenuItem(value:'fixed',child:Text('Prix fixe')),DropdownMenuItem(value:'starting_from',child:Text('À partir de'))],onChanged:(v){if(v!=null)setState(()=>type=v);}),const SizedBox(height:10),TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Prix'))])),actions:[TextButton(onPressed:loading?null:()=>Navigator.pop(c),child:const Text('Annuler')),FilledButton(onPressed:loading?null:_save,child:loading?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Text('Créer'))]);
  Future<void> _save()async{if(name.text.trim().isEmpty)return;setState(()=>loading=true);try{final id=await AppSession().businessId();final service=await Supabase.instance.client.from('services').insert({'business_id':id,'name':name.text.trim(),'description':desc.text.trim(),'price_type':type,'base_price':double.tryParse(price.text.replaceAll(' ',''))}).select('id').single();if(image!=null)await media.uploadServiceImage(serviceId:service['id'],file:image!);if(mounted)Navigator.pop(context,true);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Impossible d’enregistrer : $e')));}finally{if(mounted)setState(()=>loading=false);}}
}
