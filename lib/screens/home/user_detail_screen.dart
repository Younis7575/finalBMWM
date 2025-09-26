import 'package:bmw_passes/constants/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/custom_style.dart';
import '../../constants/info_card.dart';
import '../../constants/section_title.dart';
import '../../widgets/pass_type.dart';

class UserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailScreen({super.key, required this.userData});

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "NotFound";
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat("yyyy-MM-dd").format(parsedDate);
      // Output example: "2002-04-23"
    } catch (e) {
      return "NotFound"; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final avatarRadius = size.width * 0.18;
    final spacing = size.height * 0.02;

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

              /// 👤 Profile Image
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: CustomColor.mainText, width: 3),
                      borderRadius: BorderRadius.circular(28),
                      image: DecorationImage(
                        image: userData["profile_picture"] != null
                            ? NetworkImage(userData["profile_picture"])
                            : const NetworkImage(
                                "https://images.unsplash.com/photo-1633332755192-727a05c4013d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YXZhdGFyfGVufDB8fDB8fHww",
                              ), // fallback
                        fit: BoxFit.cover,
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

              // SizedBox(height: spacing * 0.3),
              // Text(
              //   userData["email"] ?? "No Email Found",
              //   style: CustomStyle.contentText,
              //   textAlign: TextAlign.center,
              // ),
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
                  // Expanded(
                  //   child: InfoCard(
                  //     label: "Start Date:",
                  //     value: formatDate(userData["dob"]),
                  //   ),
                  // ),
                  Expanded(
                    child: InfoCard(
                      label: "Date of Birth:",
                      value:
                          (userData["dob"] != null &&
                              userData["dob"].toString().isNotEmpty)
                          ? formatDate(userData["dob"])
                          : "NotFound",
                    ),
                  ),

                  // Expanded(
                  //   child: InfoCard(
                  //       label: "Start Date:", value: userData["start_date"] ?? ""),
                  // ),
                ],
              ),
              InfoCard(
                label: "Preferred Language:",
                value:
                    (userData["prefered_language"] != null &&
                        userData["prefered_language"].toString().isNotEmpty)
                    ? userData["prefered_language"]
                    : "Not Preferable",
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
              PassTypeRow(),
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
                      label: "VIN Model::",
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
