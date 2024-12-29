
class UserModel {
      final String uid;
      final String email;
      final String name;
      final String photoUrl;
      final String status;
      final List<String> userCart;

      // Update constructor to use named parameters
      const UserModel({
            required this.uid,
            required this.email,
            required this.name,
            required this.photoUrl,
            required this.status,
            required this.userCart,
      });

      factory UserModel.fromFirestore(Map<String, dynamic> data) {
            return UserModel(
                  uid: data['uid'] ?? '',
                  email: data['email'] ?? '',
                  name: data['name'] ?? '',
                  photoUrl: data['photoUrl'] ?? '',
                  status: data['status'] ?? 'pending',
                  userCart: List<String>.from(data['userCart'] ?? ['garbageValue']),
            );
      }

      Map<String, dynamic> toFirestore() {
            return {
                  'uid': uid,
                  'email': email,
                  'name': name,
                  'photoUrl': photoUrl,
                  'status': status,
                  'userCart': userCart,
            };
      }
}