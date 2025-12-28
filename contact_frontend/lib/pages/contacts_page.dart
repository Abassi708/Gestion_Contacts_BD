import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact.dart';
import '../services/api_service.dart';
import 'add_contact_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late Future<List<Contact>> contacts;
  List<Contact> filteredContacts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  bool _isGridView = false;
  String _sortBy = 'name';
  List<String> selectedContacts = [];

  @override
  void initState() {
    super.initState();
    refresh();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1A237E),
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void refresh() {
    setState(() {
      contacts = ApiService.getContacts();
      selectedContacts.clear();
      searchController.clear();
    });
  }

  void toggleSelection(String id) {
    setState(() {
      if (selectedContacts.contains(id)) {
        selectedContacts.remove(id);
      } else {
        selectedContacts.add(id);
      }
    });
  }

  void selectAll(List<Contact> contactList) {
    setState(() {
      if (selectedContacts.length == contactList.length) {
        selectedContacts.clear();
      } else {
        selectedContacts = contactList.map((c) => c.id).toList();
      }
    });
  }

  void filterContacts(String query, List<Contact> contactList) {
    setState(() {
      filteredContacts = contactList
          .where((contact) =>
              contact.name.toLowerCase().contains(query.toLowerCase()) ||
              contact.phone.contains(query) ||
              contact.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _confirmDeleteSingle(String id, String name) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Confirmer la suppression',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Supprimer "$name" définitivement ?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette action est irréversible.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              try {
                await ApiService.deleteContact(id);
                refresh();
                _showSuccessSnackBar('Contact supprimé avec succès');
              } catch (e) {
                _showErrorSnackBar('Erreur lors de la suppression');
              } finally {
                setState(() => isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete, size: 18, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteMultiple() async {
    if (selectedContacts.isEmpty) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Suppression multiple',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Supprimer ${selectedContacts.length} contact(s) ?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette action est irréversible.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              try {
                for (String id in selectedContacts) {
                  await ApiService.deleteContact(id);
                }
                refresh();
                _showSuccessSnackBar('Contacts supprimés avec succès');
              } catch (e) {
                _showErrorSnackBar('Erreur lors de la suppression');
              } finally {
                setState(() => isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_sweep, size: 18, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Supprimer tout',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildContactCard(Contact contact, List<Contact> contactList) {
    final isSelected = selectedContacts.contains(contact.id);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF1A237E).withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: isSelected
            ? const Color(0xFF1A237E).withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            toggleSelection(contact.id);
          },
          onLongPress: () {
            toggleSelection(contact.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox de sélection
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1A237E) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1A237E)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF283593)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      contact.name.isNotEmpty
                          ? contact.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Informations du contact
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.phone,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      if (contact.email.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            contact.email,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Bouton d'action (visible au survol ou sélection)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton Appel
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.call,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          onPressed: () {
                            // TODO: Implémenter l'appel
                          },
                          tooltip: 'Appeler',
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Bouton Supprimer
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          onPressed: () => _confirmDeleteSingle(contact.id, contact.name),
                          tooltip: 'Supprimer',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header professionnel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Barre de titre et boutons
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Contacts Professionnels',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder<List<Contact>>(
                        future: contacts,
                        builder: (context, snapshot) {
                          return IconButton(
                            icon: Stack(
                              children: [
                                const Icon(Icons.check_box_outline_blank,
                                    color: Colors.white),
                                if (snapshot.hasData &&
                                    selectedContacts.isNotEmpty &&
                                    selectedContacts.length == snapshot.data!.length)
                                  const Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                            onPressed: () {
                              if (snapshot.hasData) {
                                selectAll(snapshot.data!);
                              }
                            },
                            tooltip: 'Tout sélectionner',
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Barre de recherche
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: FutureBuilder<List<Contact>>(
                      future: contacts,
                      builder: (context, snapshot) {
                        return TextField(
                          controller: searchController,
                          onChanged: (value) {
                            if (snapshot.hasData) {
                              filterContacts(value, snapshot.data!);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Rechercher par nom, téléphone ou email...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      searchController.clear();
                                      if (snapshot.hasData) {
                                        filterContacts('', snapshot.data!);
                                      }
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Barre d'actions (visible quand des contacts sont sélectionnés)
            if (selectedContacts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      '${selectedContacts.length} sélectionné(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const Spacer(),
                    // Bouton Supprimer multiple
                    ElevatedButton.icon(
                      onPressed: _confirmDeleteMultiple,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Supprimer'),
                    ),
                    const SizedBox(width: 12),
                    // Bouton Désélectionner
                    OutlinedButton(
                      onPressed: () {
                        setState(() => selectedContacts.clear());
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ],
                ),
              ),

            // Indicateur de chargement
            if (isLoading)
              const LinearProgressIndicator(
                backgroundColor: Color(0xFFF5F7FA),
                valueColor: AlwaysStoppedAnimation(Color(0xFF1A237E)),
              ),

            // Liste des contacts
            Expanded(
              child: FutureBuilder<List<Contact>>(
                future: contacts,
                builder: (context, snapshot) {
                  // État de chargement
                  if (snapshot.connectionState == ConnectionState.waiting && !isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Color(0xFF1A237E)),
                            strokeWidth: 2,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Chargement des contacts...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  // Erreur
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Impossible de charger les contacts',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: refresh,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Liste vide
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.contacts_outlined,
                                color: Color(0xFF1A237E),
                                size: 60,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Aucun contact',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'Commencez par ajouter votre premier contact professionnel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddContactPage(),
                                  ),
                                );
                                refresh();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 3,
                              ),
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text(
                                'Ajouter un contact',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final contactList = searchController.text.isNotEmpty
                      ? filteredContacts
                      : snapshot.data!;

                  if (contactList.isEmpty && searchController.text.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            color: Colors.grey,
                            size: 70,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Aucun résultat',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aucun contact ne correspond à "${searchController.text}"',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () {
                              searchController.clear();
                              filterContacts('', snapshot.data!);
                            },
                            child: const Text('Effacer la recherche'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Liste des contacts
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: RefreshIndicator(
                      onRefresh: () async => refresh(),
                      color: const Color(0xFF1A237E),
                      backgroundColor: Colors.white,
                      child: ListView.builder(
                        itemCount: contactList.length,
                        itemBuilder: (context, index) {
                          return _buildContactCard(contactList[index], contactList);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bouton flottant principal
      floatingActionButton: selectedContacts.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddContactPage()),
                );
                refresh();
              },
              icon: const Icon(Icons.add, size: 22),
              label: const Text(
                'Nouveau',
                style: TextStyle(fontSize: 15),
              ),
              backgroundColor: const Color(0xFF1A237E),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            )
          : null,
    );
  }
}
