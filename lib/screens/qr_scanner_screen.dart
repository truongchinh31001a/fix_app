import 'package:app/providers/api_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/artifact_provider.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Tạo controller cho animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Tạo animation tuyến tính để di chuyển thanh sáng
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose(); // Hủy controller khi không cần thiết
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              final Barcode? barcode = capture.barcodes.first;
              final String? code = barcode?.rawValue;

              if (code != null) {
                // Gọi API lấy dữ liệu artifact từ QR Code
                _fetchArtifactData(code);
              }
            },
          ),
          // Overlay khung quét và animation
          Center(
            child: Stack(
              children: [
                // Khung quét hình vuông
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue, // Màu viền của khung quét
                      width: 2, // Độ dày của viền
                    ),
                    borderRadius: BorderRadius.circular(10), // Góc bo tròn
                  ),
                ),
                // Animation thanh sáng
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment(0, _animation.value * 2 - 1),
                        child: Container(
                          width: 230,
                          height: 2,
                          color: Colors.blue, // Màu của thanh sáng
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Overlay tối bên ngoài khung quét
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Overlay mờ
                child: Stack(
                  children: [
                    // Xóa vùng bên trong khung quét
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 250,
                        height: 250,
                        color: Colors.transparent, // Xóa overlay tại khung
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm gọi API để lấy dữ liệu Artifact
  Future<void> _fetchArtifactData(String qrCode) async {
    try {
      // Gọi API lấy dữ liệu Artifact bằng mã QR
      var artifact = await ApiService.fetchArtifactFromApi(qrCode);

      // Lưu vào provider
      context.read<ArtifactProvider>().setArtifact(artifact);

      // Quay lại màn hình trước
      Navigator.pop(context);
    } catch (e) {
      // Hiển thị thông báo lỗi nếu có
      print("Lỗi khi gọi API: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải dữ liệu. Xin thử lại!")),
      );
    }
  }
}
