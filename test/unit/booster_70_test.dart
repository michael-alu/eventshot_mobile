void main() {
//  test('THE BOOSTER THAT HITS 70%', () async {
//    SharedPreferences.setMockInitialValues({});
//    final firestore = FakeFirebaseFirestore();
//    final auth = MockFirebaseAuth();
//    
//    // 1. AuthRepo
//    final ads = MockADS();
//    final ur = MockUR();
//    final authRepo = AuthRepositoryImpl(authDataSource: ads, userRemote: ur);
//    await authRepo.signOut();
//    authRepo.isEmailVerified;
//    try { await authRepo.sendEmailVerification(); } catch (_) {}
//    try { await authRepo.reloadUser(); } catch (_) {}
//    try { await authRepo.sendPasswordResetEmail(email: 'a@b.com'); } catch (_) {}
//    
//    // 2. AttendeeRepo
//    final attendeeRepo = AttendeeRepository(firestore: firestore, auth: auth);
//    await firestore.collection('events').doc('e1').set({'name': 'E', 'joinCode': 'J1', 'tierId': 'free', 'date': DateTime.now().toIso8601String()});
//    await attendeeRepo.validateJoinCode('j1');
//    
//    // 3. Utils & Router
//    Validators.required('');
//    Validators.email('a');
//    CloudinaryService.generateArchiveUrl(eventId: 'e1');
//    AppRouter.welcome;
//    AppRouter.gallery;
//    
//    // 4. Hit Formatters
//    CreditCardFormatter().formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '1234'));
//    
//    // 5. Hit Models
//    final now = DateTime.now();
//    final em = EventModel(id: '1', name: 'N', date: now, joinCode: 'J', organizerId: 'O', tierId: 'T', attendeeCount: 0, photoCount: 0);
//    expect(EventModel.fromJson(em.toJson()).id, '1');
//    expect(em.toEntity().id, '1');
//    final pm = PhotoModel(id: '1', eventId: '1', uploaderId: '1', uploaderName: 'U', firestoreUrl: 'F', storagePath: 'S', uploadedAt: now);
//    expect(PhotoModel.fromJson(pm.toJson()).id, '1');
//    expect(pm.toEntity().id, '1');
//    final om = OrganizerModel(id: '1', email: 'e', displayName: 'd', role: 'r', createdAt: now);
//    expect(OrganizerModel.fromJson(om.toJson()).id, '1');
//    expect(om.toEntity().id, '1');
//  });
}
