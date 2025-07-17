import 'package:flutter/material.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foodapp/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/providers/user_profile_provider.dart';
import 'package:go_router/go_router.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key}); // Add const constructor

  @override
  _PersonalProfileScreenState createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isEditing = false;

  Future<void> _saveProfile() async {
    // Save the changes
    final userProfile = Provider.of<UserProfileProvider>(context, listen: false);
    await userProfile.updateProfile({
      'fullName': _fullNameController.text,
      'phoneNumber': _phoneNumberController.text,
      'bio': _bioController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated!')),
    );
    // After saving, toggle the state.
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to listen for changes and rebuild the UI.
    return Consumer<UserProfileProvider>(
      builder: (context, userProfile, child) {
        // If not editing, update controllers with the latest data from the provider.
        // This keeps the displayed info fresh but doesn't override user input during an edit.
        if (!_isEditing) {
          _fullNameController.text = userProfile.fullName;
          _emailController.text = userProfile.email;
          _phoneNumberController.text = userProfile.phoneNumber;
          _bioController.text = userProfile.bio;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors1.circleAvatarBackGrey,
                child: IconButton( // Use context.pop() for go_router
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black, size: 20)),
              ),
            ),
            title: Text(
              "Personal Info",
              style: GoogleFonts.sen(fontWeight: FontWeight.bold), // Use GoogleFonts
            ),
            actions: [
              _isEditing
                  ? Container()
                  : TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: Text("EDIT",
                          style: GoogleFonts.sen(color: Colors1.primaryOrange, fontWeight: FontWeight.bold)),
                    ),
            ],
            backgroundColor: Colors.white, // Consistent app bar style
            foregroundColor: Colors.black, // Consistent app bar style
            elevation: 1, // Consistent app bar style
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfilePicture(),
                  const SizedBox(height: 16),
                  _buildProfileField(
                    label: "Full Name",
                    controller: _fullNameController,
                    isEditing: _isEditing, // Pass the editing state
                  ),
                  _buildProfileField(
                    label: "Email",
                    controller: _emailController,
                    // Email is a sensitive field and should not be edited directly.
                    // It requires re-authentication.
                    isEditing: false,
                  ),
                  _buildProfileField(
                    label: "Phone Number",
                    controller: _phoneNumberController,
                    isEditing: _isEditing, // Pass the editing state
                  ),
                  _buildProfileField(
                    label: "Bio",
                    controller: _bioController,
                    isEditing: _isEditing, // Pass the editing state
                    maxLines: 3,
                    // Add a hint for the bio field if needed
                  ),
                  const SizedBox(height: 16),
                  _buildProfileOption(context, icon: Icons.rate_review_outlined, title: "My Reviews", onTap: () => context.push(AppRoutes.myReviews)),
                  const SizedBox(height: 24),
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors1.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _saveProfile,
                        child: Text("SAVE CHANGES", style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: const AssetImage('assets/images/profile.jpg'), // Replace with your image
          ),
          if (_isEditing)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                onPressed: () { // TODO: Implement image selection and upload logic here
                  // For example, using image_picker package:
                  // final ImagePicker picker = ImagePicker();
                  // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  // if (image != null) {
                  //   // Update profile picture
                  // }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.sen(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            readOnly: !isEditing,
            style: GoogleFonts.sen(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              filled: !isEditing,
              fillColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.sen(fontSize: 16))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  @override
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}