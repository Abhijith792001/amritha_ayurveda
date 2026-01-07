import 'package:amritha_ayurveda/core/authentication/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/patient_card.dart';
import '../../register/view/register_page.dart';
import '../provider/home_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().fetchPatientList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => _showLogoutDialog(context),
                    child: Icon(Icons.logout, size: 24.sp),
                  ),
                  Stack(
                    children: [
                      Icon(Icons.notifications_outlined, size: 28.sp),
                      Positioned(
                        right: 2.w,
                        top: 2.h,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 25.h),
            // Search Bar Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search for treatments",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                            size: 20.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff006837),
                      foregroundColor: Colors.white,
                      minimumSize: Size(80.w, 35.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25.h),
            // Sort Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sort by :",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  Container(
                    height: 40.h,
                    width: 140.w,
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: const Color(0xff006837),
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            const Divider(),
            SizedBox(height: 10.h),
            Expanded(
              child: Consumer<HomeProvider>(
                builder: (context, homeProvider, child) {
                  if (homeProvider.isLoading && homeProvider.patients.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (homeProvider.patients.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 80.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "No Patients Found",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => homeProvider.fetchPatientList(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      itemCount: homeProvider.patients.length,
                      itemBuilder: (context, index) {
                        final patient = homeProvider.patients[index];
                        // Extracting names from patientdetails
                        final details =
                            patient['patientdetails_set'] as List? ?? [];
                        final packageName = details.isNotEmpty
                            ? details[0]['treatment_name'] ?? 'N/A'
                            : 'N/A';

                        return PatientCard(
                          index: index,
                          patientName: patient['name'] ?? 'N/A',
                          packageName: packageName,
                          date: patient['date_nd_time']?.split('-')[0] ?? 'N/A',
                          groupMember: patient['user'] ?? 'N/A',
                          onTap: () {
                            // Handle view booking details
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.sp),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff006837),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            child: Text(
              "Register Now",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
