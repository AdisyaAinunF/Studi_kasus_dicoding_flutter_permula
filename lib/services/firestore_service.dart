import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studi_kasus/models/appointment_model.dart';
import '../models/psychologist_model.dart';

class FirestoreService {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('psychologists');

  Stream<List<PsychologistModel>> streamPsychologists() {
    return _col.snapshots().map((snap) => snap.docs
        .map((d) =>
            PsychologistModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList());
  }

  // add using generated doc id so we can store with consistent id
  Future<void> addPsychologist(PsychologistModel p) async {
    final docRef = _col.doc();
    await docRef.set(p.toMap());
  }

  Future<void> seedIfEmpty() async {
    final s = await _col.limit(1).get();
    if (s.docs.isEmpty) {
      final list = [
        PsychologistModel(
            id: '',
            name: 'Dr. Rina Putri',
            hospital: 'RS Sehat Jiwa',
            schedule: 'Mon, Wed 10:00-12:00',
            imageUrl: 'https://picsum.photos/id/1005/200/200',
            rating: 4.8),
        PsychologistModel(
            id: '',
            name: 'Bapak Agus',
            hospital: 'Klinik Jiwa',
            schedule: 'Tue, Thu 14:00-16:00',
            imageUrl: 'https://picsum.photos/id/1011/200/200',
            rating: 4.6),
        PsychologistModel(
            id: '',
            name: 'Dra. Sari',
            hospital: 'RS Harapan',
            schedule: 'Fri 09:00',
            imageUrl: 'https://picsum.photos/id/1027/200/200',
            rating: 4.9),
      ];
      for (var p in list) {
        await addPsychologist(p);
      }
    }
  }

  Stream<List<AppointmentModel>> streamUserAppointments(String userId) {
    final col = FirebaseFirestore.instance.collection('appointments');
    return col
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final m = d.data() as Map<String, dynamic>;
              return AppointmentModel.fromMap(d.id, m);
            }).toList());
  }

  // Cancel: update status to 'cancelled'
  Future<void> cancelAppointment(String appointmentId) async {
    final doc =
        FirebaseFirestore.instance.collection('appointments').doc(appointmentId);
    await doc.update({'status': 'cancelled'});
  }

  Future<void> createAppointment(AppointmentModel appt) async {
    final col = FirebaseFirestore.instance.collection('appointments');
    final doc = col.doc(); // generate id
    final withId = appt.copyWith(id: doc.id);
    await doc.set(withId.toMap());
  }
}
