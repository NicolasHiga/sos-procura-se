import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/models/person_data.dart';
import 'package:sos_app/models/pet_data.dart';
import 'package:sos_app/pages/homePage/pages/lost/lost_cards.dart';
import 'package:sos_app/pages/homePage/components/city_selection_dialog.dart';
import 'package:sos_app/pages/homePage/components/custom_toggle_switch.dart';

class LostPage extends StatefulWidget {
  final bool isPeople;
  const LostPage({super.key, required this.isPeople});

  @override
  State<LostPage> createState() => _LostPageState();
}

class _LostPageState extends State<LostPage> {
  late String collectionName;
  late bool currentList;
  String? selectedUf;
  String? selectedCity;
  String searchedName = '';
  List<QueryDocumentSnapshot> filteredDocs = [];
  TextEditingController searchedEC = TextEditingController();
  late UserStore sessionUser;

  void _setNewLocation(String newState, String newCity) {
    setState(() {
      selectedUf = newState;
      selectedCity = newCity;
    });
  }

  @override
  void initState() {
    super.initState();
    currentList = widget.isPeople;
    collectionName = widget.isPeople ? 'lostPeople' : 'lostPets';
    sessionUser = Provider.of<UserStore>(context, listen: false);
    selectedUf = sessionUser.currentUser!.uf;
    selectedCity = sessionUser.currentUser!.city;
  }

  @override
  void dispose() {
    super.dispose();
    searchedEC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.instance.background,
      appBar: AppBar(
        title: const Text('Encontrados Perdidos'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    height: 35,
                    margin: const EdgeInsets.only(right: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(10.0), // Bordas arredondadas
                      border: Border.all(
                        color: ColorsApp.instance.accent, // Cor da borda branca
                        width: 1.0, // Largura da borda
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CitySelectionDialog(
                              currentState: selectedUf!,
                              currentCity: selectedCity!,
                              onSubmit: _setNewLocation,
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          Text(
                            selectedCity!.length > 10
                                ? '${selectedCity!.substring(0, 9)}...' // Abrevia se o tamanho for maior que 10
                                : selectedCity!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: TextField(
                      controller: searchedEC,
                      onSubmitted: (_) {
                        setState(() {
                          searchedName = searchedEC.text.toUpperCase();
                        });
                        searchedEC.clear();
                      },
                      decoration: const InputDecoration(
                          hintText: 'Pesquisar nome',
                          hintStyle: TextStyle(fontSize: 14),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10),
                          suffixIcon: Icon(Icons.search)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomToggleSwitch(
              isPeople: widget.isPeople,
              onChanged: (_) {
                setState(() {
                  currentList = !currentList;
                  currentList
                      ? collectionName = 'lostPeople'
                      : collectionName = 'lostPets';
                });
              },
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildFirebaseList(collectionName))
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseList(String collection) {
    return RefreshIndicator(
      onRefresh: () async {
        await _refreshData();
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collection)
            .where('uf', isEqualTo: selectedUf)
            .where('city', isEqualTo: selectedCity)
            .where('status', isEqualTo: 'W')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nada por aqui\n Ainda bem :)'));
          }

          final lostDocs = snapshot.data!.docs;

          if (searchedName.isNotEmpty) {
            filteredDocs = lostDocs.where((doc) {
              final name = doc['name'] as String;
              return name.contains(searchedName);
            }).toList();

            if (filteredDocs.isEmpty) {
              return const Center(child: Text('Nada por aqui\n Ainda bem :)'));
            }
          } else {
            filteredDocs = List.from(lostDocs);
          }

          return _buildListFromDocs(collection, filteredDocs);
        },
      ),
    );
  }

  Widget _buildListFromDocs(
      String collection, List<QueryDocumentSnapshot> missingDocs) {
    return ListView.builder(
      itemCount: missingDocs.length,
      itemBuilder: (context, index) {
        final missingDoc = missingDocs[index];
        final data = missingDoc.data() as Map<String, dynamic>;
        final dynamic objData;
        final String docId = missingDoc.id;

        if (collection == 'lostPeople') {
          objData = PersonData.fromFirebase(data, docId, true);
        } else {
          objData = PetData.fromFirebase(data, docId, true);
        }

        return LostCards(
          data: objData,
        );
      },
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      searchedName = '';
    });

    final querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('uf', isEqualTo: selectedUf)
        .where('city', isEqualTo: selectedCity)
        .get();

    setState(() {
      _buildListFromDocs(collectionName, querySnapshot.docs);
    });
  }
}
