import 'package:flutter/material.dart';
import 'package:biota_2/constants/colors.dart';
import 'package:biota_2/models/data.dart';
import 'package:biota_2/services/database_helper.dart';

class SpeciesManagementScreen extends StatefulWidget {
  const SpeciesManagementScreen({super.key});

  @override
  State<SpeciesManagementScreen> createState() => _SpeciesManagementScreenState();
}

class _SpeciesManagementScreenState extends State<SpeciesManagementScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Data> _speciesList = [];
  bool _isLoading = true;
  final int _userId = 1;

  @override 
  void initState() {
    super.initState();
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    try {
      final species = await _databaseHelper.getAllData();
      setState(() {
        _speciesList = species.map((data) => Data(
          id: data.id,
          speciesName: data.speciesName,
          latinName: data.latinName,
          category: data.category,
          habitat: data.habitat,
          status: data.status,
          description: data.description,
          userId: _userId,
          isApproved: data.isApproved,
          createdAt: data.createdAt,
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading species: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSpecies,
              child: _speciesList.isEmpty
                  ? const Center(
                      child: Text('No species data available'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _speciesList.length,
                      itemBuilder: (context, index) {
                        final species = _speciesList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.grey.shade50,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              species.speciesName,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              species.latinName,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textLight,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (species.isApproved == 0)
                                            Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.check_circle_outline),
                                                color: Colors.green,
                                                onPressed: () => _updateApprovalStatus(species.id!, 1),
                                              ),
                                            ),
                                          if (species.isApproved == 0)
                                            Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.cancel_outlined),
                                                color: Colors.red,
                                                onPressed: () => _updateApprovalStatus(species.id!, 3),
                                              ),
                                            ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: species.isApproved == 1
                                                  ? Colors.green.withOpacity(0.1)
                                                  : species.isApproved == 0 
                                                  ? Colors.orange.withOpacity(0.1) 
                                                  : Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: species.isApproved == 1
                                                    ? Colors.green.withOpacity(0.5)
                                                    : species.isApproved == 0 
                                                    ? Colors.orange.withOpacity(0.5) 
                                                    : Colors.red.withOpacity(0.5),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              species.isApproved == 1
                                              ? 'Data Diterima'
                                              :species.isApproved == 0
                                              ? 'Data Diproses'
                                              : 'Data Ditolak',
                                              style: TextStyle(
                                                color: species.isApproved == 1
                                                    ? Colors.green
                                                    : species.isApproved == 0
                                                        ? Colors.orange
                                                        : Colors.red,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (species.isApproved != 0) // Hanya tampilkan tombol hapus jika status bukan 'Data Diproses'
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _showDeleteConfirmationDialog(species),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              species.category.toLowerCase() == 'hewan'
                                                  ? Icons.pets
                                                  : Icons.eco,
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            _buildChip(species.category),
                                            const SizedBox(width: 12),
                                            Icon(
                                              _getStatusIcon(species.status),
                                              size: 18,
                                              color: _getStatusColor(species.status),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildStatusChip(species.status),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                species.habitat,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    species.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'vulnerable':
        return Icons.warning;
      case 'endangered':
        return Icons.dangerous;
      case 'extinct':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'vulnerable':
        return Colors.orange;
      case 'endangered':
        return Colors.red;
      case 'extinct':
        return Colors.red.shade900;
      default:
        return AppColors.primary;
    }
  }

  Future<void> _updateApprovalStatus(int id, int status) async {
    try {
      await _databaseHelper.updateDataApproval(id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 1 ? 'Data Diterima' : status == 0 ? 'Data Diproses' : 'Data Ditolak'
            ),
            backgroundColor: status == 1
                    ? Colors.green
                    : status == 0
                    ? Colors.orange
                    : Colors.red,

          ),
        );
      }
      _loadSpecies(); // Refresh the list after update
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog(Data species) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus ${species.speciesName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final result = await _databaseHelper.deleteData(species.id!);
                  if (result > 0) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data berhasil dihapus')),
                    );
                    _loadSpecies(); // Refresh the list
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus data: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}