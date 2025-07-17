import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/core/colors/colors.dart'; // Assuming Colors1 is defined here
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:provider/provider.dart'; // Import provider
import 'package:collection/collection.dart'; // For firstWhereOrNull
import 'package:foodapp/providers/user_profile_provider.dart'; // Import UserProfileProvider

// Address Model
class Address {
  final String id;
  final String userId; // New: Link to the user
  final String label;
  final String address;
  bool isDefault;

  Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    this.isDefault = false,
  });

  // Convert Address object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      'address': address,
      'isDefault': isDefault,
    };
  }

  // Create Address object from a Map (from Firestore)
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(id: map['id'] as String, userId: map['userId'] as String, label: map['label'] as String, address: map['address'] as String, isDefault: map['isDefault'] as bool);
  }
}

// Address List Screen
class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  // No longer managing _addresses locally, it comes from UserProfileProvider
  // _selectedAddressId will also be managed by the provider or derived from it

  // This will be updated by the provider
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    // Set initial selected address from provider if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = context.read<UserProfileProvider>();
      if (userProfile.addresses.isNotEmpty) {
        _selectedAddressId = userProfile.addresses.firstWhere((addr) => addr.isDefault, orElse: () => userProfile.addresses.first).id;
        setState(() {}); // Trigger rebuild to show selection
      }
    });
  }

  void _deleteAddress(String addressId) async {
    final userProfile = context.read<UserProfileProvider>();
    await userProfile.deleteAddress(addressId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address deleted!')),
    );
  }

  void _selectDefaultAddress(String addressIdToSetDefault) async {
    final userProfile = context.read<UserProfileProvider>();

    // Find the address object to set as default
    final addressToSetDefault = userProfile.addresses.firstWhere(
      (addr) => addr.id == addressIdToSetDefault,
      orElse: () => throw Exception('Address with ID $addressIdToSetDefault not found'), // This should ideally not happen if IDs are from existing list
    );

    // First, unset current default
    final currentDefaultAddress = userProfile.addresses.firstWhereOrNull((addr) => addr.isDefault);

    if (currentDefaultAddress != null && currentDefaultAddress.id != addressIdToSetDefault) {
      currentDefaultAddress.isDefault = false;
      await userProfile.updateAddress(currentDefaultAddress);
    }
    // Set new default
    addressToSetDefault.isDefault = true;
    await userProfile.updateAddress(addressToSetDefault);
    setState(() => _selectedAddressId = addressIdToSetDefault); // Update local state for immediate UI feedback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Address'),
        backgroundColor: Colors.white, // Consistent app bar style
        foregroundColor: Colors.black, // Consistent app bar style
        elevation: 1, // Consistent app bar style
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, userProfile, child) {
          return userProfile.addresses.isEmpty
              ? _EmptyAddressState(onAddAddress: _navigateToAddAddress)
              : _AddressListView(
                  addresses: userProfile.addresses,
                  selectedAddressId: _selectedAddressId,
                  onSelect: _selectDefaultAddress,
                  onDelete: _deleteAddress, onAddAddress: _navigateToAddAddress,);
        },
      ),
    );
  }

  Future<void> _navigateToAddAddress() async {
    final newAddress = await context.push<Address>(AppRoutes.addAddress);
    if (newAddress != null && mounted) {
      _addAddress(newAddress);
      // After adding, set it as selected if it's the only one or marked default
      setState(() {
        _selectedAddressId = newAddress.id;
      });
    }
  }

  // Helper to add address to provider (called after push returns)
  void _addAddress(Address newAddress) {
    final userProfile = context.read<UserProfileProvider>();
    userProfile.addAddress(newAddress);
  }
}

// Widget for the list view when addresses exist
class _AddressListView extends StatelessWidget {
  final List<Address> addresses;
  final String? selectedAddressId;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;
  final VoidCallback onAddAddress;

  const _AddressListView({
    required this.addresses,
    required this.selectedAddressId,
    required this.onSelect,
    required this.onDelete,
    required this.onAddAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return AddressCard(
                address: address, // Pass the full address object
                isSelected: address.id == selectedAddressId,
                onSelect: () => onSelect(address.id),
                onDelete: () => onDelete(address.id),
                onEdit: () {
                  // TODO: Implement edit functionality
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: onAddAddress,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors1.primaryOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('ADD NEW ADDRESS'),
          ),
        ),
      ],
    );
  }
}

// Widget for the empty state
class _EmptyAddressState extends StatelessWidget {
  final VoidCallback onAddAddress;

  const _EmptyAddressState({required this.onAddAddress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Addresses Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new address to see it here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAddAddress,
              icon: const Icon(Icons.add),
              label: const Text('ADD YOUR FIRST ADDRESS'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors1.primaryOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ); // Corrected closing brackets here
  }
}

// Address Card Widget
class AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getIconForLabel(String label) {
    switch (label.toUpperCase()) {
      case 'HOME':
        return Icons.home_outlined;
      case 'WORK':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 2.0 : 1.0, // Reduced elevation difference
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: isSelected
            ? BorderSide(color: theme.primaryColor, width: 1.5)
            : BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        onTap: onSelect,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Increased vertical padding
        leading: Radio<bool>(
          value: isSelected,
          groupValue: true, // This makes the selected one active
          onChanged: (bool? value) => onSelect(), // Use the passed onSelect
        ),
        title: Text(address.label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(address.address, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
            const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

// Add Address Screen
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullAddress = '';
  // Default label is 'Home'
  String _label = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction, // Validate as user types
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FULL ADDRESS', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '3235 Royal Ln.Meso,New Jersy 34567',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) => _fullAddress = value!,
              ),
              const SizedBox(height: 24),
              Text('LABEL AS', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              // Choice chips for address labels
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Home'),
                      selected: _label == 'Home',
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                      onSelected: (selected) {
                        setState(() {
                          _label = 'Home';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Work'),
                      selected: _label == 'Work',
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                      onSelected: (selected) {
                        setState(() {
                          _label = 'Work';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Other'),
                      selected: _label == 'Other',
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                      onSelected: (selected) {
                        setState(() {
                          _label = 'Other';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final user = FirebaseAuth.instance.currentUser; // Get current user from Firebase Auth
                    // Generate a unique ID for the new address
                    final newAddress = Address(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: user?.uid ?? 'guest', // Assign current user's UID
                      label: _label.toUpperCase(),
                      address: _fullAddress,
                      isDefault: false, // Default to false, provider will handle setting default
                    );
                    context.pop(newAddress);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors1.primaryOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('SAVE LOCATION'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}