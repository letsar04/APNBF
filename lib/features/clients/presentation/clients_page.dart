import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/clients_repository.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});
  @override State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final repo = ClientsRepository();
  late Future<List<Map<String, dynamic>>> future;
  @override void initState() { super.initState(); future = repo.list(); }
  void refresh() => setState(() => future = repo.list());

  Future<void> edit([Map<String,dynamic>? client]) async {
    final result = await showDialog<bool>(context: context, builder: (_) => _ClientDialog(client: client));
    if (result == true) refresh();
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Clients'), actions: [
      IconButton(onPressed: () => edit(), icon: const Icon(Icons.person_add_alt_1)),
    ]),
    body: FutureBuilder<List<Map<String,dynamic>>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Erreur : ${snap.error}'));
        final clients = snap.data ?? [];
        if (clients.isEmpty) return _Empty(onAdd: () => edit());
        return RefreshIndicator(
          onRefresh: () async => refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: clients.length,
            itemBuilder: (_, i) {
              final c = clients[i];
              return Card(child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(c['full_name'] ?? ''),
                subtitle: Text(c['phone']?.toString().isNotEmpty == true ? c['phone'] : 'Aucun téléphone'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/clients/${c['id']}'),
              ));
            },
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => edit(), icon: const Icon(Icons.add), label: const Text('Client')),
  );
}

class _ClientDialog extends StatefulWidget {
  const _ClientDialog({this.client});
  final Map<String,dynamic>? client;
  @override State<_ClientDialog> createState() => _ClientDialogState();
}
class _ClientDialogState extends State<_ClientDialog> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, phone, whatsapp, email, address, notes;
  final repo = ClientsRepository();
  bool loading = false;
  @override void initState() {
    super.initState();
    final c = widget.client;
    name=TextEditingController(text:c?['full_name']); phone=TextEditingController(text:c?['phone']);
    whatsapp=TextEditingController(text:c?['whatsapp']); email=TextEditingController(text:c?['email']);
    address=TextEditingController(text:c?['address']); notes=TextEditingController(text:c?['notes']);
  }
  @override void dispose(){for(final c in [name,phone,whatsapp,email,address,notes]) c.dispose(); super.dispose();}
  @override Widget build(BuildContext context)=>AlertDialog(
    title: Text(widget.client == null ? 'Nouveau client':'Modifier le client'),
    content: SizedBox(width: 420, child: SingleChildScrollView(child: Form(key:form, child: Column(children:[
      TextFormField(controller:name, decoration:const InputDecoration(labelText:'Nom complet'), validator:(v)=>v==null||v.trim().isEmpty?'Nom obligatoire':null),
      TextFormField(controller:phone, keyboardType:TextInputType.phone, decoration:const InputDecoration(labelText:'Téléphone')),
      TextFormField(controller:whatsapp, keyboardType:TextInputType.phone, decoration:const InputDecoration(labelText:'WhatsApp')),
      TextFormField(controller:email, keyboardType:TextInputType.emailAddress, decoration:const InputDecoration(labelText:'E-mail')),
      TextFormField(controller:address, decoration:const InputDecoration(labelText:'Adresse / zone')),
      TextFormField(controller:notes, decoration:const InputDecoration(labelText:'Notes')),
    ]))),
    actions:[TextButton(onPressed:loading?null:()=>Navigator.pop(context),child:const Text('Annuler')),FilledButton(onPressed:loading ? null : () async {
      if(!form.currentState!.validate()) return; setState(()=>loading=true);
      try { await repo.save(id:widget.client?['id'],fullName:name.text,phone:phone.text,whatsapp:whatsapp.text,email:email.text,address:address.text,notes:notes.text); if(context.mounted) Navigator.pop(context,true); }
      catch(e){if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Erreur : $e')));}
      finally{if(mounted)setState(()=>loading=false);}
    },child:loading?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Text('Enregistrer'))]
  );
}
class _Empty extends StatelessWidget { const _Empty({required this.onAdd}); final VoidCallback onAdd; @override Widget build(BuildContext c)=>Center(child:Padding(padding:const EdgeInsets.all(32),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.people_outline,size:64),const SizedBox(height:12),const Text('Aucun client',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Ajoute tes premiers clients pour suivre leurs commandes et crédits.',textAlign:TextAlign.center),const SizedBox(height:18),FilledButton.icon(onPressed:onAdd,icon:const Icon(Icons.add),label:const Text('Ajouter un client'))]))); }
