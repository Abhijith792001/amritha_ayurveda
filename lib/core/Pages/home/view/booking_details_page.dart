import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/patient_model.dart';

class BookingDetailsPage extends StatelessWidget {
  final Patient patient;

  const BookingDetailsPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
    );
    String dateStr = 'N/A';
    if (patient.dateAndTime != null) {
      dateStr =
          "${patient.dateAndTime!.day.toString().padLeft(2, '0')}/${patient.dateAndTime!.month.toString().padLeft(2, '0')}/${patient.dateAndTime!.year}";
    }

    // Format Time: hh:mm AM/PM
    String timeStr = 'N/A';
    if (patient.dateAndTime != null) {
      final hour = patient.dateAndTime!.hour;
      final minute = patient.dateAndTime!.minute;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      timeStr =
          "${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Patient Information'),
            SizedBox(height: 12.h),
            _buildInfoCard([
              _buildInfoRow('Name', patient.name ?? 'N/A'),
              _buildInfoRow('Phone', patient.phone ?? 'N/A'),
              _buildInfoRow('Address', patient.address ?? 'N/A'),
              _buildInfoRow('Date', dateStr),
              _buildInfoRow('Time', timeStr),
              _buildInfoRow('Branch', patient.branch?.name ?? 'N/A'),
            ]),
            SizedBox(height: 24.h),
            _buildSectionTitle('Selected Treatments'),
            SizedBox(height: 12.h),
            _buildTreatmentsList(),
            SizedBox(height: 24.h),
            _buildSectionTitle('Payment Details'),
            SizedBox(height: 12.h),
            _buildInfoCard([
              _buildInfoRow(
                'Total Amount',
                '₹${patient.totalAmount ?? 0}',
                isBold: true,
              ),
              _buildInfoRow('Discount', '₹${patient.discountAmount ?? 0}'),
              _buildInfoRow('Advance Paid', '₹${patient.advanceAmount ?? 0}'),
              const Divider(color: Colors.grey),
              _buildInfoRow(
                'Balance to Pay',
                '₹${patient.balanceAmount ?? 0}',
                isBold: true,
                valueColor: const Color(0xff006837),
              ),
              _buildInfoRow('Payment Method', patient.payment ?? 'N/A'),
            ]),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xff006837),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: const Color(0xffF1F1F1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: valueColor ?? Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentsList() {
    if (patient.patientDetails.isEmpty) {
      return Text(
        'No treatments selected',
        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
      );
    }

    return Column(
      children: patient.patientDetails.map((detail) {
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  detail.treatmentName ?? 'Unknown Treatment',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildCountChip('Male', detail.male ?? '0'),
                  SizedBox(width: 8.w),
                  _buildCountChip('Female', detail.female ?? '0'),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCountChip(String label, String count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xff006837).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xff006837)),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xff006837),
            ),
          ),
        ],
      ),
    );
  }
}
