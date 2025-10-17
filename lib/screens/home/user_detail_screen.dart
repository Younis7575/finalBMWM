import 'package:bmw_passes/constants/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/custom_style.dart';
import '../../widgets/info_card.dart';
import '../../widgets/section_title.dart';
import '../../widgets/pass_type.dart';

class UserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserDetailScreen({super.key, required this.userData});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "";
    try {
      DateTime parsedDate = DateTime.parse(dateString); // e.g. "2025-07-25"
      return DateFormat("yyyy-MM-dd").format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  String getPreferredLanguage() {
    String lang = (userData["preferred_language"] ?? "").toString().trim();
    return lang.isNotEmpty ? lang : "Not Preferred";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final spacing = size.height * 0.02;

    String baseUrl =
        "https://spmetesting.com/assets/uploads/customers/profiles/";
    String? profilePic = userData["profile_picture"];
    String profileUrl = (profilePic != null && profilePic.isNotEmpty)
        ? "$baseUrl$profilePic"
        : "https://images.unsplash.com/photo-1633332755192-727a05c4013d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YXZhdGFyfGVufDB8fDB8fHww";

    return Scaffold(
      backgroundColor: CustomColor.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: spacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 🔙 Back
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: CustomColor.mainText),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              SizedBox(height: spacing),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: CustomColor.mainText, width: 3),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.network(
                        profileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            "https://images.unsplash.com/photo-1633332755192-727a05c4013d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YXZhdGFyfGVufDB8fDB8fHww",
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),

                  /// ✅ Verified
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: CustomColor.dot,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CustomColor.dot, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.verified,
                        color: CustomColor.screenBackground,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing * 0.6),

              /// Name
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${userData["first_name"] ?? ""} ${userData["last_name"] ?? ""}",
                  style: CustomStyle.loginText,
                ),
              ),

              SizedBox(height: spacing),

              /// 📌 Personal Info
              const SectionTitle(title: "Personal Information"),
              InfoCard(label: "Customer Id:", value: userData["cs_id"] ?? ""),
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      label: "First Name:",
                      value: userData["first_name"] ?? "",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoCard(
                      label: "Last Name:",
                      value: userData["last_name"] ?? "",
                    ),
                  ),
                ],
              ),
              InfoCard(label: "Email:", value: userData["email"] ?? ""),
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      label: "Contact:",
                      value: userData["contact"] ?? "",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoCard(
                      label: "Date of Birth:",
                      value: formatDate(userData["dob"]),
                    ),
                  ),
                ],
              ),
              InfoCard(
                label: "Preferred Language:",
                value: getPreferredLanguage(),
              ),
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      label: "City:",
                      value: userData["city"] ?? "",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoCard(
                      label: "Country/State:",
                      value: userData["country"] ?? "",
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing),

              /// 🚘 Car Info
              const SectionTitle(title: "Others"),
              PassTypeRow(
                passType: userData["is_bmw_m_accessorized"] == 1
                    ? "M Pass Checker Accessorized"
                    : "M Pass Checker",
              ),

              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      label: "M Model:",
                      value: userData["m_model"] ?? "",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoCard(
                      label: "VIN Number:",
                      value: userData["vin_number"] ?? "",
                    ),
                  ),
                ],
              ),
              InfoCard(
                label: "Network ID:",
                value: userData["network_id"] ?? "",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
