// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LocationController on _LocationController, Store {
  late final _$staticMapImageUrlAtom =
      Atom(name: '_LocationController.staticMapImageUrl', context: context);

  @override
  String get staticMapImageUrl {
    _$staticMapImageUrlAtom.reportRead();
    return super.staticMapImageUrl;
  }

  @override
  set staticMapImageUrl(String value) {
    _$staticMapImageUrlAtom.reportWrite(value, super.staticMapImageUrl, () {
      super.staticMapImageUrl = value;
    });
  }

  late final _$cepAtom =
      Atom(name: '_LocationController.cep', context: context);

  @override
  String get cep {
    _$cepAtom.reportRead();
    return super.cep;
  }

  @override
  set cep(String value) {
    _$cepAtom.reportWrite(value, super.cep, () {
      super.cep = value;
    });
  }

  late final _$cityAtom =
      Atom(name: '_LocationController.city', context: context);

  @override
  String get city {
    _$cityAtom.reportRead();
    return super.city;
  }

  @override
  set city(String value) {
    _$cityAtom.reportWrite(value, super.city, () {
      super.city = value;
    });
  }

  late final _$ufAtom = Atom(name: '_LocationController.uf', context: context);

  @override
  String get uf {
    _$ufAtom.reportRead();
    return super.uf;
  }

  @override
  set uf(String value) {
    _$ufAtom.reportWrite(value, super.uf, () {
      super.uf = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_LocationController.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$getPositionAsyncAction =
      AsyncAction('_LocationController.getPosition', context: context);

  @override
  Future getPosition() {
    return _$getPositionAsyncAction.run(() => super.getPosition());
  }

  @override
  String toString() {
    return '''
staticMapImageUrl: ${staticMapImageUrl},
cep: ${cep},
city: ${city},
uf: ${uf},
isLoading: ${isLoading}
    ''';
  }
}
