import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact.dart';
import '../services/api_service.dart';
import 'add_contact_page.dart';
import 'edit_contact_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Contact>> contacts;
  List<Contact> filteredContacts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<String> selectedContacts = [];
  bool _isGridView = false;
  String _filterBy = 'all'; // all, favorite, recent
  int _selectedTab = 0;

  // Couleurs premium
  static const Color _primaryColor = Color(0xFF1A237E);
  static const Color _secondaryColor = Color(0xFF283593);
  static const Color _accentColor = Color(0xFF3949AB);
  static const Color _lightColor = Color(0xFFE8EAF6);
  static const Color _backgroundColor = Color(0xFFF5F7FA);
  static const Color _textColor = Color(0xFF1A237E);
  static const Color _goldColor = Color(0xFFFFD700);
  static const Color _silverColor = Color(0xFFC0C0C0);
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _warningColor = Color(0xFFFF9800);
  
  // Gradients premium
  final Gradient _primaryGradient = LinearGradient(
    colors: [_primaryColor, _secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  final Gradient _goldGradient = LinearGradient(
    colors: [_goldColor, Color(0xFFFFC107)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  final Gradient _silverGradient = LinearGradient(
    colors: [_silverColor, Color(0xFFE0E0E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    refresh();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1A237E),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF1A237E),
        systemNavigationBarIconBrightness: Brightness.light,
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

  void filterContacts(String query) {
    contacts.then((contactList) {
      setState(() {
        filteredContacts = contactList
            .where((contact) =>
                contact.name.toLowerCase().contains(query.toLowerCase()) ||
                contact.phone.contains(query) ||
                contact.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  List<Contact> _getFilteredContacts(List<Contact> contactList) {
    if (_filterBy == 'favorite') {
      // Pour l'instant, tous les contacts (à implémenter les favoris)
      return contactList;
    } else if (_filterBy == 'recent') {
      // Les 10 derniers contacts (simulation)
      return contactList.take(10).toList();
    }
    return contactList;
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Filtrer par',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 24),
            ...['all', 'favorite', 'recent'].map((option) {
              final isSelected = _filterBy == option;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isSelected ? _primaryGradient : _silverGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    option == 'all' ? Icons.people :
                    option == 'favorite' ? Icons.star :
                    Icons.access_time,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  option == 'all' ? 'Tous les contacts' :
                  option == 'favorite' ? 'Favoris' : 'Récents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? _primaryColor : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _successColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: _successColor,
                          size: 16,
                        ),
                      )
                    : null,
                onTap: () {
                  setState(() => _filterBy = option);
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _showContactDetails(Contact contact) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ContactDetailsSheet(contact: contact),
    );
  }

  Widget _buildContactCard(Contact contact) {
    return GestureDetector(
      onTap: () => _showContactDetails(contact),
      onLongPress: () {
        setState(() {
          if (selectedContacts.contains(contact.id)) {
            selectedContacts.remove(contact.id);
          } else {
            selectedContacts.add(contact.id);
          }
        });
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                _lightColor.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selectedContacts.contains(contact.id) 
                  ? _accentColor.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar avec effet premium
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: _primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          if (contact.email.isNotEmpty)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _primaryColor, width: 2),
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: Color(0xFF1A237E),
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    // Informations du contact
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 16, color: _accentColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  contact.phone,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (contact.email.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.email, size: 16, color: _accentColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      contact.email,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (contact.address.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: _accentColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      contact.address,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Badge de statut
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: _goldGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'VIP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Indicateur de sélection
              if (selectedContacts.contains(contact.id))
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(IconData icon, String value, String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header premium avec effet de profondeur
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                gradient: _primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre supérieure
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ContactSphere',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getFormattedDate(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification badge
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Statistiques en ligne
                  FutureBuilder<List<Contact>>(
                    future: contacts,
                    builder: (context, snapshot) {
                      final totalContacts = snapshot.hasData ? snapshot.data!.length : 0;
                      final recentContacts = snapshot.hasData ? snapshot.data!.take(7).length : 0;
                      
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatisticsCard(
                              Icons.people,
                              totalContacts.toString(),
                              'Contacts',
                              Colors.white,
                              Colors.white.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatisticsCard(
                              Icons.star,
                              '0',
                              'Favoris',
                              _goldColor,
                              Colors.white.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatisticsCard(
                              Icons.timeline,
                              recentContacts.toString(),
                              '7 derniers jours',
                              _successColor,
                              Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Barre de recherche premium
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: filterContacts,
                            style: const TextStyle(color: _textColor),
                            decoration: InputDecoration(
                              hintText: 'Rechercher un contact...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.search, color: _primaryColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 20,
                              ),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.close, color: Colors.grey[400]),
                                      onPressed: () {
                                        searchController.clear();
                                        filterContacts('');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        // Bouton filtre
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.filter_alt, color: Colors.white),
                            onPressed: _showFilterOptions,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content area
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    // Onglets
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _lightColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(0, 'Tous', Icons.people),
                          _buildTabButton(1, 'Favoris', Icons.star),
                          _buildTabButton(2, 'Récents', Icons.access_time),
                          _buildTabButton(3, 'Groupes', Icons.category),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Header des contacts
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mes Contacts',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: [
                              // Bouton vue grille/liste
                              Container(
                                decoration: BoxDecoration(
                                  color: _lightColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.grid_view,
                                        color: _isGridView ? _primaryColor : Colors.grey,
                                      ),
                                      onPressed: () => setState(() => _isGridView = true),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.view_list,
                                        color: !_isGridView ? _primaryColor : Colors.grey,
                                      ),
                                      onPressed: () => setState(() => _isGridView = false),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Bouton actualiser
                              Container(
                                decoration: BoxDecoration(
                                  gradient: _primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  onPressed: refresh,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Liste des contacts
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FutureBuilder<List<Contact>>(
                          future: contacts,
                          builder: (context, snapshot) {
                            if (isLoading) {
                              return _buildLoadingState();
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return _buildLoadingState();
                            }

                            if (snapshot.hasError) {
                              return _buildErrorState();
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return _buildEmptyState();
                            }

                            final contactList = _getFilteredContacts(
                              searchController.text.isNotEmpty
                                  ? filteredContacts
                                  : snapshot.data!,
                            );

                            if (contactList.isEmpty && searchController.text.isNotEmpty) {
                              return _buildNoResultsState();
                            }

                            return RefreshIndicator(
                              onRefresh: () async => refresh(),
                              color: _primaryColor,
                              backgroundColor: Colors.white,
                              child: _isGridView
                                  ? _buildGridView(contactList)
                                  : ListView.builder(
                                      itemCount: contactList.length,
                                      itemBuilder: (context, index) {
                                        return _buildContactCard(contactList[index]);
                                      },
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Floating Action Button Premium
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddContactPage()),
            );
            if (result == true) {
              refresh();
            }
          },
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 0,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: _primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 24),
          ),
        ),
      ),
      
      // Bottom Navigation Bar Premium
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home, 'Accueil', true),
                _buildNavItem(Icons.people, 'Contacts', false),
                _buildNavItem(Icons.star, 'Favoris', false),
                _buildNavItem(Icons.settings, 'Paramètres', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final day = now.day;
    final month = now.month;
    final year = now.year;
    final weekdays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    
    return '${weekdays[now.weekday - 1]}, $day ${months[month - 1]} $year';
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? _primaryColor : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: isActive ? _primaryGradient : null,
            color: isActive ? null : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey,
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? _primaryColor : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(List<Contact> contacts) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return GestureDetector(
          onTap: () => _showContactDetails(contact),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    _lightColor.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: _primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contact.phone,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: _primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chargement des contacts...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error,
                color: Colors.red,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger les contacts.\nVérifiez votre connexion Internet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: _lightColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people,
                color: Color(0xFF1A237E),
                size: 70,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Aucun contact',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Commencez par ajouter\nvotre premier contact professionnel',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddContactPage()),
                );
                if (result == true) {
                  refresh();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 22),
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

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _lightColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              color: Color(0xFF1A237E),
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun résultat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun contact ne correspond à\n"${searchController.text}"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              searchController.clear();
              filterContacts('');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: _primaryColor, width: 2),
              ),
            ),
            child: const Text('Effacer la recherche'),
          ),
        ],
      ),
    );
  }
}

// Widget pour les détails du contact (Bottom Sheet)
class ContactDetailsSheet extends StatelessWidget {
  final Contact contact;
  
  const ContactDetailsSheet({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Header du contact
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1A237E), const Color(0xFF283593)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A237E).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Contact Professionnel',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF1A237E),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Informations de contact
              _buildInfoRow(Icons.phone, 'Téléphone', contact.phone),
              const SizedBox(height: 20),
              if (contact.email.isNotEmpty)
                Column(
                  children: [
                    _buildInfoRow(Icons.email, 'Email', contact.email),
                    const SizedBox(height: 20),
                  ],
                ),
              if (contact.address.isNotEmpty)
                Column(
                  children: [
                    _buildInfoRow(Icons.location_on, 'Adresse', contact.address),
                    const SizedBox(height: 20),
                  ],
                ),
              if (contact.notes.isNotEmpty)
                Column(
                  children: [
                    _buildInfoRow(Icons.note, 'Notes', contact.notes),
                    const SizedBox(height: 20),
                  ],
                ),
              const SizedBox(height: 32),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Appeler le contact
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.phone, size: 20),
                      label: const Text('Appeler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Envoyer SMS
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.message, size: 20),
                      label: const Text('SMS'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditContactPage(contact: contact),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Supprimer contact
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.delete, size: 20),
                      label: const Text('Supprimer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1A237E), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}