import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // ← FIX: add image_picker dep
import 'dart:io';

class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({Key? key}) : super(key: key);

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isReady = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(cameras![0], ResolutionPreset.high);
        await _controller!.initialize();
        if (!mounted) return;
        setState(() => _isReady = true);
      }
    } catch (e) {
      Get.snackbar(
        'Помилка камери',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Switch between front/rear camera ─────────────────────────────────────
  Future<void> _switchCamera() async {
    if (cameras == null || cameras!.length < 2) return;
    final currentIndex = cameras!.indexOf(_controller!.description);
    final nextIndex = (currentIndex + 1) % cameras!.length;
    await _controller?.dispose();
    _controller = CameraController(cameras![nextIndex], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  // ── FIX: Pick image from gallery and upload ───────────────────────────────
  Future<void> _pickFromGallery() async {
    if (_isUploading) return;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      await _uploadAndNavigate(File(picked.path));
    } catch (e) {
      Get.snackbar(
        'Помилка галереї',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Capture + Upload to Firebase Storage + Navigate to Diagnosis ──────────
  Future<void> _takePictureAndUpload() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isUploading) return;

    try {
      setState(() => _isUploading = true);
      final XFile image = await _controller!.takePicture();
      await _uploadAndNavigate(File(image.path));
    } catch (e) {
      Get.snackbar(
        'Помилка завантаження',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Shared upload logic ───────────────────────────────────────────────────
  Future<void> _uploadAndNavigate(File file) async {
    try {
      if (mounted) setState(() => _isUploading = true);

      String fileName = 'scans/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload: ${(progress * 100).toStringAsFixed(0)}%');
      });

      await uploadTask;
      String downloadUrl = await ref.getDownloadURL();

      // TODO: Replace 'Антракноз' with actual ML backend result
      Get.toNamed(
        '/diagnosis',
        arguments: {'imageUrl': downloadUrl, 'diseaseName': 'Антракноз'},
      );
    } catch (e) {
      Get.snackbar(
        'Помилка завантаження',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Preview
          Positioned.fill(child: CameraPreview(_controller!)),

          // 2. Darkened Overlay with cutout
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 300,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Green Bracket Frame
          Center(
            child: Container(
              height: 300,
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2E7D32), width: 3),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // 4. Upload progress overlay
          if (_isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Завантаження...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. UI Controls
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const Text(
                        'ФОТО',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // FIX: Gallery button now works
                      GestureDetector(
                        onTap: _isUploading ? null : _pickFromGallery,
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isUploading ? null : _takePictureAndUpload,
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _switchCamera,
                        child: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
