import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TreatmentDialog extends StatefulWidget {
  const TreatmentDialog({super.key});

  @override
  State<TreatmentDialog> createState() => _TreatmentDialogState();
}

class _TreatmentDialogState extends State<TreatmentDialog> {
  int maleCount = 0;
  int femaleCount = 0;
  String? selectedTreatment;

  final List<String> treatments = [
    'Couple Combo package',
    'Rejuvenation',
    'Full Body Massage',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose Treatment",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: const Color(0xffF1F1F1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(
                    "Choose preferred treatment",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  value: selectedTreatment,
                  items: treatments.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedTreatment = val);
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Add Patients",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10.h),
            _buildPatientCounter(
              "Male",
              maleCount,
              (val) => setState(() => maleCount = val),
            ),
            SizedBox(height: 10.h),
            _buildPatientCounter(
              "Female",
              femaleCount,
              (val) => setState(() => femaleCount = val),
            ),
            SizedBox(height: 25.h),
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedTreatment != null) {
                    Navigator.pop(context, {
                      'treatment': selectedTreatment,
                      'male': maleCount,
                      'female': femaleCount,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006837),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCounter(
    String label,
    int count,
    Function(int) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 120.w,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
          decoration: BoxDecoration(
            color: const Color(0xffF1F1F1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(label, style: TextStyle(fontSize: 14.sp)),
        ),
        Row(
          children: [
            _counterButton(Icons.remove, () {
              if (count > 0) onChanged(count - 1);
            }),
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Text("$count", style: TextStyle(fontSize: 16.sp)),
            ),
            _counterButton(Icons.add, () => onChanged(count + 1)),
          ],
        ),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 35.w,
        height: 35.w,
        decoration: const BoxDecoration(
          color: Color(0xff006837),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}
