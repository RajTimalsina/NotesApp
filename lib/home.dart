import 'package:flutter/material.dart';
import 'package:note_taking_app/components/card_component.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _notesStream =
      Supabase.instance.client.from('notes').stream(primaryKey: ['id']);

  final _storyStream =
      Supabase.instance.client.from("globalNotes").stream(primaryKey: ['id']);

  @override

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  void initState() {
    super.initState();

    // Listen to story stream and print data
    Future<void> debugGlobalNotes() async {
      try {
        print('🔍 Debugging globalNotes table...');

        // First, try to get the table structure by getting one row
        final result = await Supabase.instance.client
            .from('globalNotes')
            .select()
            .limit(1);

        print('Query result: $result');
        print('Number of records: ${result.length}');

        if (result.isNotEmpty) {
          print('First record keys: ${result.first.keys.toList()}');
          print('First record data: ${result.first}');
        } else {
          print('⚠️ Table exists but no data found');

          // Let's check if we can insert test data
          try {
            final testData = {
              'title': 'Test Story',
              'body': 'This is a test',
              // Add other required fields based on your schema
            };

            final insertResult = await Supabase.instance.client
                .from('globalNotes')
                .insert(testData)
                .select();

            print('✅ Test insert successful: $insertResult');
          } catch (e) {
            print('❌ Cannot insert test data: $e');
            print('This might indicate RLS or schema issues');
          }
        }
      } catch (e) {
        print('❌ Error accessing globalNotes: $e');
      }
    }

    debugGlobalNotes();
  }

  Future<void> _checkTableData() async {
    try {
      print('\n🔍 DIRECT QUERY CHECK:');
      final result = await Supabase.instance.client
          .from('globalNotes')
          .select();

      print('Direct query result: $result');
      print('Number of records: ${result.length}');

      if (result.isNotEmpty) {
        print('First record keys: ${result.first.keys.toList()}');
      }
    } catch (e) {
      print('Direct query error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _notesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No notes yet!"),
                    ),
                  );
                }
                final notes = snapshot.data!;
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(notes[index]['body']),
                      );
                    });
              },
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _storyStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No stories to display."),
                    ),
                  );
                }
                final stories = snapshot.data!;
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      final story = stories[index];
                      return PostCard(
                        authorInitials: story['nameInitials'] ?? 'NN',  // Updated to match DB
                        authorName: story['profileName'] ?? 'No Name',
                        timeAgo: story['created_at'] != null
                            ? _formatTimeAgo(DateTime.parse(story['created_at']))
                            : 'recently',
                        title: story['title'] ?? 'No Title',
                        content: story['body'] ?? 'No content...',
                        // tags: (story['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
                      );
                    });
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: ((context) {
                return SimpleDialog(
                    title: const Text('Add a note!'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TextFormField(
                          onFieldSubmitted: (value) async {
                            final userId = Supabase.instance.client.auth.currentUser!.id;
                            await Supabase.instance.client
                                .from('notes')
                                .insert({'body': value, 'user_id': userId});
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      )
                    ]);
              }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
