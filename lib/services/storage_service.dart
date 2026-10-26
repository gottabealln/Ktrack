import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';
import '../models/trigger.dart';
import '../models/medicine.dart';

class StorageService {
  static const _entriesKey = 'ktrack_entries';
  static const _triggersKey = 'ktrack_triggers';
  static const _medicinesKey = 'ktrack_medicines';

  Future<List<Entry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_entriesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Entry.fromJson(e)).toList();
  }

  Future<void> saveEntry(Entry entry) async {
    final entries = await getEntries();
    entries.add(entry);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _entriesKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _entriesKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<List<Trigger>> getTriggers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_triggersKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Trigger.fromJson(e)).toList();
  }

  Future<void> saveTrigger(Trigger trigger) async {
    final triggers = await getTriggers();
    triggers.add(trigger);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _triggersKey, jsonEncode(triggers.map((e) => e.toJson()).toList()));
  }

  Future<List<Medicine>> getMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_medicinesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Medicine.fromJson(e)).toList();
  }

  Future<void> saveMedicine(Medicine medicine) async {
    final medicines = await getMedicines();
    medicines.add(medicine);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _medicinesKey, jsonEncode(medicines.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteMedicine(String id) async {
    final medicines = await getMedicines();
    medicines.removeWhere((e) => e.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _medicinesKey, jsonEncode(medicines.map((e) => e.toJson()).toList()));
  }
}