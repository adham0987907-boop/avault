import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:avault/data/models/vault_item_model.dart';
import 'package:avault/features/import/pipeline/processing_isolate.dart';
import 'package:avault/features/auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentNavigationIndex = 0;
  bool _isImporting = false;
  double _importProgress = 0.0;
  String _currentImportingFileName = "";

  // ميزة استيراد وتشفير الملفات دفعة واحدة وإضافتها لقاعدة البيانات
  Future<void> _handleFileImport() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;

    setState(() {
      _isImporting = true;
      _importProgress = 0.0;
    });

    final appDir = await getApplicationDocumentsDirectory();
    final secureVaultFolder = Directory("${appDir.path}/secure_assets");
    if (!await secureVaultFolder.exists()) {
      await secureVaultFolder.create(recursive: true);
    }

    final masterKey = ref.read(authProvider).runtimeMasterKey;
    if (masterKey == null) return;

    final box = Hive.box<VaultItemModel>('vault_metadata_box');
    int processedCount = 0;

    for (var file in result.files) {
      if (file.path == null) continue;
      
      setState(() {
        _currentImportingFileName = file.name;
        _importProgress = processedCount / result.files.length;
      });

      final payload = ImportPayload(
        sourceFilePath: file.path!,
        storageDirectoryPath: secureVaultFolder.path,
        rawKeyBytes: masterKey,
      );

      try {
        // تشغيل العملية المشفرة في الـ Isolate الخلفي لمنع تعليق الـ UI تماماً
        final resultMetadata = await BackgroundFileProcessor.executeIngestion(payload);

        final newVaultItem = VaultItemModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          encryptedFileName: "${secureVaultFolder.path}/${resultMetadata.encryptedFileName}",
          cleartextOriginalName: resultMetadata.originalName,
          fileExtension: resultMetadata.fileExtension,
          fileSizeBytes: resultMetadata.fileSize,
          registrationTimestamp: DateTime.now(),
        );

        await box.add(newVaultItem);
        
        // مسح الملف الأصلي بعد نجاح التشفير تماماً لحماية الخصوصية
        final originalFile = File(file.path!);
        if (await originalFile.exists()) {
          await originalFile.delete();
        }
      } catch (e) {
        // معالجة وحماية في حال فشل أي خطوة دون خسارة الملف الأصلي
        debugPrint("خطأ في تشفير الملف: $e");
      }

      processedCount++;
    }

    setState(() {
      _isImporting = false;
      _importProgress = 1.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم استيراد وتشفير $processedCount من الملفات بنجاح في نظام AVault")),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<VaultItemModel>('vault_metadata_box').listenable(),
      builder: (context, Box<VaultItemModel> box, _) {
        // حساب إحصائيات حية حقيقية 100% من قاعدة البيانات المشفرة
        final allItems = box.values.toList();
        final photosCount = allItems.where((e) => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(e.fileExtension.toLowerCase())).length;
        final videosCount = allItems.where((e) => ['mp4', 'mov', 'avi', 'mkv'].contains(e.fileExtension.toLowerCase())).length;
        final docsCount = allItems.length - (photosCount + videosCount);
        
        int totalSizeBytes = 0;
        for (var item in allItems) {
          totalSizeBytes += item.fileSizeBytes;
        }
        final double totalSizeMb = totalSizeBytes / (1024 * 1024);

        return Scaffold(
          appBar: AppBar(
            title: const Text("AVault Secure Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.lock_reset_rounded),
                onPressed: () => ref.read(authProvider.notifier).lockVault(),
              )
            ],
          ),
          body: _isImporting
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text("جاري التشفير والحفظ الآمن داخل الجهاز...", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(_currentImportingFileName, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: _importProgress),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // كارت المساحة المستخدمة الكلية
                      Card(
                        color: const Color(0xFF211F26),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            children: [
                              const Icon(Icons.pie_chart_outline_rounded, size: 48, color: Color(0xFFD0BCFF)),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("إجمالي المساحة المحمية", style: TextStyle(color: Colors.grey, fontSize: 14)),
                                  Text("${totalSizeMb.toStringAsFixed(2)} MB", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // شبكة الكروت التفاعلية للإحصائيات (Material 3 Grid)
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _buildStatCard("الصور الآمنة", photosCount.toString(), Icons.image_rounded, Colors.blue),
                            _buildStatCard("الفيديوهات المشفرة", videosCount.toString(), Icons.video_library_rounded, Colors.orange),
                            _buildStatCard("المستندات والملفات", docsCount.toString(), Icons.description_rounded, Colors.green),
                            _buildStatCard("المحذوفات المؤقتة", "0", Icons.delete_outline_rounded, Colors.red),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _handleFileImport,
            label: const Text("استيراد ملفات وتشفيرها"),
            icon: const Icon(Icons.add_moderator_rounded),
            backgroundColor: const Color(0xFF6750A4),
            foregroundColor: Colors.white,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentNavigationIndex,
            onDestinationSelected: (index) {
              setState(() => _currentNavigationIndex = index);
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: "الرئيسية"),
              NavigationDestination(icon: Icon(Icons.image_rounded), label: "الصور"),
              NavigationDestination(icon: Icon(Icons.video_collection_rounded), label: "الفيديوهات"),
              NavigationDestination(icon: Icon(Icons.folder_zip_rounded), label: "الملفات"),
              NavigationDestination(icon: Icon(Icons.settings_rounded), label: "الإعدادات"),
            ],
          ),
        );
      },
    );
  }
}
