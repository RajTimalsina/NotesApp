import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _notesStream =
      Supabase.instance.client.from('notes').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final notes = snapshot.data!;
          return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(notes[index]['body']),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: ((context) {
                return SimpleDialog(
                    title: const Text('Add a note!'),
                    children: [
                      TextFormField(
                        onFieldSubmitted: (value) async {
                          final userId = Supabase.instance.client.auth.currentUser!.id;
                          await Supabase.instance.client
                              .from('notes')
                              .insert({'body': value, 'user_id': userId});
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                      )
                    ]);
              }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
