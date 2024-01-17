import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/models/person_data.dart';
import 'package:sos_app/models/pet_data.dart';
import 'package:sos_app/pages/homePage/pages/lost/lost_cards.dart';
import 'package:sos_app/pages/homePage/pages/missing/missing_cards.dart';

class MyPosts extends StatefulWidget {

  const MyPosts({super.key});

  @override
  State<MyPosts> createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  List<PersonData> personDataList = [];
  List<PetData> petDataList = [];
  List<dynamic> postsList = [];
  bool isLoading = true;
  late UserStore sessionUser;

  @override
  void initState() {
    super.initState();
    sessionUser = Provider.of<UserStore>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    // Limpa as listas
    personDataList.clear();
    petDataList.clear();

    postsList = await _getDataFromFirebase();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Postagens'),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await _loadData();
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          child: _buildFirebaseList(),
        ),
      ),
    );
  }

  Widget _buildFirebaseList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    } else {
      if (postsList.isEmpty) {
        return const Center(child: Text('Nenhuma publicação encontrada.'));
      } else {
        return ListView.builder(
          itemCount: postsList.length,
          itemBuilder: (context, index) {
            final data = postsList[index];

            if (data.isMissing) {
              return MissingCards(
                data: data
              );
            } else {
              return LostCards(
                data: data
              );
            }
          },
        );
      }
    }
  }

  Future<List<dynamic>> _getDataFromFirebase() async {
    await FirebaseFirestore.instance
        .collection('missingPeople')
        .where('userId', isEqualTo: sessionUser.currentUser!.id)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final dataMpeople = doc.data();
        final personData = PersonData.fromFirebase(dataMpeople, doc.id, true);
        personDataList.add(personData);
      }
    });

    // Consulta de desaparecidos de animais
    await FirebaseFirestore.instance
        .collection('missingPets')
        .where('userId', isEqualTo: sessionUser.currentUser!.id)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final dataMpets = doc.data();
        final petData = PetData.fromFirebase(dataMpets, doc.id, true);
        petDataList.add(petData);
      }
    });

    // Consulta de pessoas perdiads
    await FirebaseFirestore.instance
        .collection('lostPeople')
        .where('userId', isEqualTo: sessionUser.currentUser!.id)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final dataLpeople = doc.data();
        final personData = PersonData.fromFirebase(dataLpeople, doc.id, false);
        personDataList.add(personData);
      }
    });

    // Consulta de animais perdidos
    await FirebaseFirestore.instance
        .collection('lostPets')
        .where('userId', isEqualTo: sessionUser.currentUser!.id)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final dataLpets = doc.data();
        final petData = PetData.fromFirebase(dataLpets, doc.id, false);
        petDataList.add(petData);
      }
    });

    List<dynamic> combinedDataList = [...personDataList, ...petDataList];
    return combinedDataList;
  }
}
