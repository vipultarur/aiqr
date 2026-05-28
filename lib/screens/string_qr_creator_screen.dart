import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/qr_maker_controller.dart';
import '../widgets/gradient_button.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/native_ad_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class StringQrCreatorScreen extends StatelessWidget {
  final String initialType;
  
  const StringQrCreatorScreen({super.key, required this.initialType});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    
    // We can instantiate or find the QrMakerController
    final QrMakerController controller = Get.put(QrMakerController());
    
    // Set the initial type when opening the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialType != 'All') {
        controller.setType(initialType);
      }
    });

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Create $initialType QR'),
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Ad
              const BannerAdWidget(),
              const SizedBox(height: 16),
              
              Text(
                'Enter Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Input Fields Based on Type
              if (initialType == 'Email') ...[
                _buildTextField(context, isDark, controller.emailController, 'Email Address', Icons.email),
                const SizedBox(height: 16),
                _buildTextField(context, isDark, controller.subjectController, 'Subject', Icons.subject),
                const SizedBox(height: 16),
                _buildTextField(context, isDark, controller.bodyController, 'Body', Icons.message, maxLines: 4),
                const SizedBox(height: 16),
              ] else if (initialType == 'Wi-Fi') ...[
                _buildTextField(context, isDark, controller.ssidController, 'Network Name (SSID)', Icons.wifi),
                const SizedBox(height: 16),
                // Dropdown for encryption
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.wifiEncryption.value,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                        items: ['WPA/WPA2', 'WPA3', 'WEP', 'None', 'Raw'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontFamily: 'GSansFlex',
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            controller.wifiEncryption.value = newValue;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(context, isDark, controller.passwordController, 'Password', Icons.lock),
                const SizedBox(height: 16),
              ] else if (initialType == 'Number') ...[
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildTextField(context, isDark, controller.countryCodeController, 'Code', Icons.public),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: _buildTextField(context, isDark, controller.numberController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ] else if (initialType == 'Map') ...[
                _buildTextField(context, isDark, controller.mapLinkController, 'Google Map Link', Icons.map),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(context, isDark, controller.latController, 'Latitude', Icons.location_on, keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(context, isDark, controller.lngController, 'Longitude', Icons.location_on, keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ] else ...[
                _buildTextField(context, isDark, controller.textController, 'Enter QR content', Icons.edit, maxLines: null, focusNode: controller.focusNode1),
                const SizedBox(height: 16),
              ],

              // Input Field (Title)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: controller.titleController,
                  focusNode: controller.focusNode2,
                  decoration: InputDecoration(
                    icon: Icon(Icons.title, color: Colors.grey[400]),
                    hintText: 'Name your QR',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'GSansFlex',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(
                  () => GradientButton(
                    onPressed: controller.isGenerating.value
                        ? null
                        : () {
                            controller.generateQrCode();
                            controller.focusNode1.unfocus();
                            controller.focusNode2.unfocus();
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Generate QR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GSansFlex',
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.qr_code, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Native Ad
              const NativeAdWidget(templateType: TemplateType.medium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, bool isDark, TextEditingController controller, String hint, IconData icon, {int? maxLines = 1, FocusNode? focusNode, TextInputType? keyboardType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType ?? (maxLines == null ? TextInputType.multiline : TextInputType.text),
        maxLines: maxLines,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey[400]),
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'GSansFlex',
          ),
        ),
      ),
    );
  }
}
