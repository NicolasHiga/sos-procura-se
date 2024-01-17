import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sos_app/core/services/post/post_service.dart';
import 'package:sos_app/models/post_form_data.dart';

class PostFirebaseService implements PostService {
  @override
  Future<void> post(PostFormData formData) async {
    final imagesURLs = await _uploadImages(formData.images, formData.postType,
        formData.type, formData.userId, formData.datePost!);

    if (imagesURLs.isEmpty) return;

    if (formData.postType == 1) {
      if (formData.type == 1) {
        await _saveMissingPerson(formData, imagesURLs);
      } else if (formData.type == 2) {
        await _saveMissingPet(formData, imagesURLs);
      }
    } else if (formData.postType == 2) {
      if (formData.type == 1) {
        await _saveLostPerson(formData, imagesURLs);
      } else if (formData.type == 2) {
        await _saveLostPet(formData, imagesURLs);
      }
    }
  }

  Future<List<String>> _uploadImages(List<File> images, int postType, int type,
      String userId, DateTime date) async {
    final storage = FirebaseStorage.instance;
    List<String> imageUrls = [];
    String bucketName = '';

    try {
      if (postType == 1) {
        // SE FOR POST DESAPARECIDO
        if (type == 1) {
          bucketName = 'missingPeople';
        } else {
          bucketName = 'missingPets';
        }
      } else if (postType == 2) {
        // SE FOR POST PERDIDO
        if (type == 1) {
          bucketName = 'lostPeople';
        } else {
          bucketName = 'lostPets';
        }
      }

      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final imageName = '$userId-$date-$i.jpg'; // Nome do arquivo único

        final imageRef = storage.ref().child(bucketName).child(imageName);

        await imageRef.putFile(image);

        final imageUrl = await imageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }
    } catch (e) {
      throw Exception("Erro ao salvar imagens no Firebase Storage: $e");
    }
    return imageUrls;
  }

  Future<void> _saveMissingPerson(
      PostFormData formData, List<String> imagesURLs) async {
    try {
      final store = FirebaseFirestore.instance;
      final docRef = store.collection('missingPeople').doc();

      return docRef.set({
        'userId': formData.userId,
        'name': formData.name,
        'age': formData.age,
        'height': formData.height,
        'gender': formData.gender,
        'color': formData.colorOrspecie,
        'hairColor': formData.hairColor,
        'eyeColor': formData.eyeColor,
        'hairStyle': formData.hairStyle,
        'latitude': formData.latitude,
        'longitude': formData.longitude,
        'city': formData.city,
        'uf': formData.uf,
        'address': formData.address,
        'date': formData.date,
        'description': formData.description,
        'datePost': formData.datePost,
        'images': imagesURLs,
        'status': 'W',
      });
    } catch (e) {
      throw Exception("Erro ao salvar dados no banco: $e");
    }
  }

  Future<void> _saveMissingPet(
      PostFormData formData, List<String> imagesURLs) async {
    try {
      final store = FirebaseFirestore.instance;
      final docRef = store.collection('missingPets').doc();

      return docRef.set({
        'userId': formData.userId,
        'name': formData.name,
        'age': formData.age,
        'gender': formData.gender,
        'specie': formData.colorOrspecie,
        'size': formData.size,
        'breed': formData.breed,
        'latitude': formData.latitude,
        'longitude': formData.longitude,
        'city': formData.city,
        'uf': formData.uf,
        'address': formData.address,
        'reward': formData.reward,
        'date': formData.date,
        'description': formData.description,
        'datePost': formData.datePost,
        'images': imagesURLs,
        'status': 'W',
      });
    } catch (e) {
      throw Exception("Erro ao salvar dados no banco: $e");
    }
  }

  Future<void> _saveLostPerson(
      PostFormData formData, List<String> imagesURLs) async {
    try {
      final store = FirebaseFirestore.instance;
      final docRef = store.collection('lostPeople').doc();

      return docRef.set({
        'userId': formData.userId,
        'name': formData.name,
        'age': formData.age,
        'height': formData.height,
        'gender': formData.gender,
        'color': formData.colorOrspecie,
        'latitude': formData.latitude,
        'longitude': formData.longitude,
        'city': formData.city,
        'uf': formData.uf,
        'address': formData.address,
        'description': formData.description,
        'datePost': formData.datePost,
        'images': imagesURLs,
        'status': 'W',
      });
    } catch (e) {
      throw Exception("Erro ao salvar dados no banco: $e");
    }
  }

  Future<void> _saveLostPet(
      PostFormData formData, List<String> imagesURLs) async {
    try {
      final store = FirebaseFirestore.instance;
      final docRef = store.collection('lostPets').doc();

      return docRef.set({
        'userId': formData.userId,
        'name': formData.name,
        'age': formData.age,
        'gender': formData.gender,
        'specie': formData.colorOrspecie,
        'size': formData.size,
        'breed': formData.breed,
        'latitude': formData.latitude,
        'longitude': formData.longitude,
        'city': formData.city,
        'uf': formData.uf,
        'address': formData.address,
        'description': formData.description,
        'datePost': formData.datePost,
        'images': imagesURLs,
        'status': 'W',
      });
    } catch (e) {
      throw Exception("Erro ao salvar dados no banco: $e");
    }
  }

  @override
  Future<void> deleteFromFirebase(
      String collection, String doc, List<String> imagesURLs) async {
    try {
      // Referência para a coleção
      final CollectionReference collectionRef =
          FirebaseFirestore.instance.collection(collection);

      // Exclua o documento com o ID especificado
      await collectionRef.doc(doc).delete();

      //Exclui as images do Storage
      await deleteFilesFromStorage(imagesURLs, collection);

      // Documento excluído com sucesso
      log('Documento $doc excluído com sucesso da coleção $collection');
    } catch (e) {
      throw Exception('Erro ao excluir documento: $e');
    }
  }

  @override
  Future<void> deleteFilesFromStorage(
      List<String> fileUrls, String bucketName) async {
    for (String fileUrl in fileUrls) {
      try {
        // Extrai o nome do arquivo
        String fileName = await extractFileName(fileUrl);
        // Acessa o bucket e o arquivo passado
        final Reference storageRef =
            FirebaseStorage.instance.ref(bucketName).child(fileName);
        // Deleta o arquivo
        await storageRef.delete();
        log('Arquivo excluído com sucesso do Storage: $fileName');
      } catch (e) {
        throw Exception('Erro ao excluir arquivo de Storage $fileUrl: $e');
      }
    }
  }

  Future<String> extractFileName(String fileUrl) async {
    Uri uri = Uri.parse(fileUrl);
    String path = uri.path;
    List<String> pathSegments = path.split('/');
    String fileName = pathSegments.last;

    int indexOfPercent2F = fileName.indexOf("%2F");
    if (indexOfPercent2F != -1) {
      fileName = fileName.substring(indexOfPercent2F + 3); // +3 para remover '%2F'
    }
    return Uri.decodeComponent(fileName.split('?').first);
  }

  @override
  Future<void> setStatus(String collection, String docId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final DocumentReference documentReference =
          firestore.collection(collection).doc(docId);

      // Use o método update para atualizar o valor de 'status'
      await documentReference.update({'status': 'F'});
    } catch (error) {
      throw Exception('Erro ao atualizar o status: $error');
    }
  }

  @override
  Future<void> sendReport(String userId, String postId, String collectionPost,
      String reportType, String comment, DateTime dateReport) async {
    try {
      final store = FirebaseFirestore.instance;
      final docRef = store.collection('reports').doc();

      return docRef.set({
        'userId': userId,
        'postId': postId,
        'collectionPost': collectionPost,
        'reportType': reportType,
        'comment': comment,
        'dateReport': dateReport,
      });
    } catch (e) {
      throw Exception("Erro ao salvar denúncia no banco: $e");
    }
  }

  @override
  Future<void> update(PostFormData formData, String docId, bool isMissingPost,
      List<String> currentImages) async {
    try {
      if (isMissingPost) {
        if (formData.type == 1) {
          _updateMissingPeople(
              docId,
              formData.address,
              formData.age,
              formData.city,
              formData.colorOrspecie,
              formData.date,
              formData.description,
              formData.eyeColor,
              formData.gender,
              formData.hairColor,
              formData.hairStyle,
              formData.height,
              formData.latitude,
              formData.longitude,
              formData.name,
              formData.uf);
        } else if (formData.type == 2) {
          _updateMissingPets(
              docId,
              formData.address,
              formData.age,
              formData.breed,
              formData.city,
              formData.date,
              formData.description,
              formData.gender,
              formData.latitude,
              formData.longitude,
              formData.name,
              formData.reward,
              formData.size,
              formData.colorOrspecie,
              formData.uf);
        }
      } else {
        if (formData.type == 1) {
          _updateLostPeople(
              docId,
              formData.address,
              formData.age,
              formData.city,
              formData.colorOrspecie,
              formData.description,
              formData.gender,
              formData.height,
              formData.latitude,
              formData.longitude,
              formData.name,
              formData.uf);
        } else if (formData.type == 2) {
          _updateLostPets(
              docId,
              formData.address,
              formData.age,
              formData.breed,
              formData.city,
              formData.description,
              formData.gender,
              formData.latitude,
              formData.longitude,
              formData.name,
              formData.size,
              formData.colorOrspecie,
              formData.uf);
        }
      }

      if (formData.images.isNotEmpty) {
        await _replaceImages(formData, currentImages, docId);
      }
    } catch (e) {
      throw Exception("Erro no update(): $e");
    }
  }

  Future<void> _updateMissingPeople(
      String docId,
      String address,
      String age,
      String city,
      String color,
      String date,
      String description,
      String eyeColor,
      String gender,
      String hairColor,
      String hairStyle,
      String height,
      double latitude,
      double longitude,
      String name,
      String uf) async {
    try {
      final Map<String, dynamic> updatedData = {};

      updatedData['address'] = address;
      updatedData['age'] = age;
      updatedData['city'] = city;
      updatedData['color'] = color;
      updatedData['date'] = date;
      updatedData['description'] = description;
      updatedData['eyeColor'] = eyeColor;
      updatedData['gender'] = gender;
      updatedData['hairColor'] = hairColor;
      updatedData['hairStyle'] = hairStyle;
      updatedData['height'] = height;
      updatedData['latitude'] = latitude;
      updatedData['longitude'] = longitude;
      updatedData['name'] = name;
      updatedData['uf'] = uf;

      final store = FirebaseFirestore.instance;
      final docRef = store.collection('missingPeople').doc(docId);

      return docRef.update(updatedData);
    } catch (e) {
      throw Exception("Erro no _updateMissingPeople(): $e");
    }
  }

  Future<void> _updateMissingPets(
      String docId,
      String address,
      String age,
      String breed,
      String city,
      String date,
      String description,
      String gender,
      double latitude,
      double longitude,
      String name,
      String reward,
      String size,
      String specie,
      String uf) async {
    try {
      final Map<String, dynamic> updatedData = {};

      updatedData['address'] = address;
      updatedData['age'] = age;
      updatedData['breed'] = breed;
      updatedData['city'] = city;
      updatedData['date'] = date;
      updatedData['description'] = description;
      updatedData['gender'] = gender;
      updatedData['latitude'] = latitude;
      updatedData['longitude'] = longitude;
      updatedData['name'] = name;
      updatedData['reward'] = reward;
      updatedData['size'] = size;
      updatedData['specie'] = specie;
      updatedData['uf'] = uf;

      final store = FirebaseFirestore.instance;
      final docRef = store.collection('missingPets').doc(docId);

      return docRef.update(updatedData);
    } catch (e) {
      throw Exception("Erro no _updateMissingPets(): $e");
    }
  }

  Future<void> _updateLostPeople(
      String docId,
      String address,
      String age,
      String city,
      String color,
      String description,
      String gender,
      String height,
      double latitude,
      double longitude,
      String name,
      String uf) async {
    try {
      final Map<String, dynamic> updatedData = {};

      updatedData['address'] = address;
      updatedData['age'] = age;
      updatedData['city'] = city;
      updatedData['color'] = color;
      updatedData['description'] = description;
      updatedData['gender'] = gender;
      updatedData['height'] = height;
      updatedData['latitude'] = latitude;
      updatedData['longitude'] = longitude;
      updatedData['name'] = name;
      updatedData['uf'] = uf;

      final store = FirebaseFirestore.instance;
      final docRef = store.collection('lostPeople').doc(docId);

      return docRef.update(updatedData);
    } catch (e) {
      throw Exception("Erro no _updateLostPeople(): $e");
    }
  }

  Future<void> _updateLostPets(
      String docId,
      String address,
      String age,
      String breed,
      String city,
      String description,
      String gender,
      double latitude,
      double longitude,
      String name,
      String size,
      String specie,
      String uf) async {
    try {
      final Map<String, dynamic> updatedData = {};

      updatedData['address'] = address;
      updatedData['age'] = age;
      updatedData['breed'] = breed;
      updatedData['city'] = city;
      updatedData['description'] = description;
      updatedData['gender'] = gender;
      updatedData['latitude'] = latitude;
      updatedData['longitude'] = longitude;
      updatedData['name'] = name;
      updatedData['size'] = size;
      updatedData['specie'] = specie;
      updatedData['uf'] = uf;

      final store = FirebaseFirestore.instance;
      final docRef = store.collection('lostPets').doc(docId);

      return docRef.update(updatedData);
    } catch (e) {
      throw Exception("Erro no _updateLostPets(): $e");
    }
  }

  Future<void> _replaceImages(
      PostFormData formData, List<String> currentImages, String docId) async {
    try {
      String bucketName = '';
      final imagesURLs = await _uploadImages(formData.images, formData.postType,
          formData.type, formData.userId, formData.datePost!);

      if (imagesURLs.isEmpty) return;

      if (formData.postType == 1) {
        bucketName = formData.type == 1 ? 'missingPeople' : 'missingPets';
      } else {
        bucketName = formData.type == 1 ? 'lostPeople' : 'lostPets';
      }

      await deleteFilesFromStorage(currentImages, bucketName);

      final Map<String, dynamic> updatedData = {};
      updatedData['images'] = imagesURLs;

      final store = FirebaseFirestore.instance;
      final docRef = store.collection(bucketName).doc(docId);

      return docRef.update(updatedData);
    } catch (e) {
      throw Exception('Erro ao substituir imagens: $e');
    }
  }
}
