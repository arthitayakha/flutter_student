import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_product_page.dart';
import 'edit_product_page.dart';

void main() => runApp(const MyApp());

//////////////////////////////////////////////////////////////
// ✅ CONFIG (แก้ตรงนี้ถ้าเปลี่ยนเครื่อง)
//////////////////////////////////////////////////////////////

const String baseUrl =
    "http://localhost/flutter_studentregistrationapp/php_api/";

//////////////////////////////////////////////////////////////
// ✅ APP ROOT
//////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UsersList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ users LIST PAGE
//////////////////////////////////////////////////////////////

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  List users = [];
  List filteredusers = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchusers();
  }

  ////////////////////////////////////////////////////////////
  // ✅ FETCH DATA
  ////////////////////////////////////////////////////////////

  Future<void> fetchusers() async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}show_data.php"),
      );

      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
          filteredusers = users;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ SEARCH
  ////////////////////////////////////////////////////////////

  void filterusers(String query) {
    setState(() {
      filteredusers = users.where((users) {
        final name = users['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }




 ////////////////////////////////////////////////////////////
  // ✅ DELETE
  ////////////////////////////////////////////////////////////

  Future<void> deleteusers(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}delete_product.php?id=$id"),
      );

      final data = json.decode(response.body);

      if (data["success"] == true) {
        fetchusers();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ลบสินค้าเรียบร้อย")),
        );
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ CONFIRM DELETE
  ////////////////////////////////////////////////////////////

  void confirmDelete(dynamic users) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: Text("ต้องการลบ ${users['name']} ?"),
        actions: [
          TextButton(
            child: const Text("ยกเลิก"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("ลบ"),
            onPressed: () {
              Navigator.pop(context);
              deleteusers(int.parse(users['id'].toString()));
            },
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  // ✅ OPEN EDIT PAGE
  ////////////////////////////////////////////////////////////

  void openEdit(dynamic users) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductPage(product: users),
      ),
    ).then((value) => fetchusers());
  }



  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users List')),

      body: Column(
        children: [

          //////////////////////////////////////////////////////
          // 🔍 SEARCH BOX
          //////////////////////////////////////////////////////

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by users name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterusers,
            ),
          ),

          //////////////////////////////////////////////////////
          // 📦 users LIST
          //////////////////////////////////////////////////////

          Expanded(
            child: filteredusers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // ✅ สำคัญมาก
                    itemCount: filteredusers.length,
                    itemBuilder: (context, index) {
                      final users = filteredusers[index];

                      //////////////////////////////////////////////////////
                      // ✅ IMAGE URL (สำคัญมาก)
                      //////////////////////////////////////////////////////

                     String imageUrl =
                         "${baseUrl}images/${users['image']}";
    
                      return Card(
                        child: ListTile(

                          //////////////////////////////////////////////////
                          // 🖼 IMAGE FROM SERVER
                          //////////////////////////////////////////////////

                          leading: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),

                          //////////////////////////////////////////////////
                          // 🏷 NAME
                          //////////////////////////////////////////////////

                          title: Text(users['name'] ?? 'No Name'),

                          //////////////////////////////////////////////////
                          // 📝 email
                          //////////////////////////////////////////////////
                                                                  
                         
                          //////////////////////////////////////////////////
                          ///Faculty
                          //////////////////////////////////////////////////
                          subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text("${users['phone'] ?? ''}"),
                         Text(users['email'] ?? ''),
                         Text("${users['faculty'] ?? ''}"),
                         ],
                          ),


                          //////////////////////////////////////////////////
                          // 💰 phone
                          //////////////////////////////////////////////////

                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                openEdit(users);
                              } else if (value == 'delete') {
                                confirmDelete(users);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('แก้ไข'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('ลบ'),
                              ),
                            ],
                          ),


                          
                          //////////////////////////////////////////////////
                          // 👉 DETAIL PAGE
                          //////////////////////////////////////////////////

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    usersDetail(users: users),
                                    
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      ////////////////////////////////////////////////////////
      // ✅ ADD BUTTON
      ////////////////////////////////////////////////////////

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductPage(),
            ),
          ).then((value) {
            fetchusers(); // ✅ รีโหลดหลังเพิ่มสินค้า
          });
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ users DETAIL PAGE
//////////////////////////////////////////////////////////////

class usersDetail extends StatelessWidget {
  final dynamic users;

  const usersDetail({super.key, required this.users});

  @override
  Widget build(BuildContext context) {

    ////////////////////////////////////////////////////////////
    // ✅ IMAGE URL
    ////////////////////////////////////////////////////////////

    String imageUrl =
        "${baseUrl}images/${users['image']}";

    return Scaffold(
      appBar: AppBar(
        title: Text(users['name'] ?? 'Detail'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //////////////////////////////////////////////////////
            // 🖼 IMAGE
            //////////////////////////////////////////////////////

            Center(
              child: Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            // 🏷 NAME
            //////////////////////////////////////////////////////

            Text(
              users['name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 📝 email
            //////////////////////////////////////////////////////

            Text(users['email'] ?? ''),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 💰 phone
            //////////////////////////////////////////////////////

            Text(
              'ราคา: ฿${users['phone']}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
