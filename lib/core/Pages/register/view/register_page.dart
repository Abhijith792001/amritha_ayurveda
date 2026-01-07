import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../provider/register_provider.dart';
import '../widgets/treatment_dialog.dart';
import 'package:amritha_ayurveda/core/storage/app_storage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AppStorage _storage = AppStorage();

  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _balanceAmountController = TextEditingController();

  String? _selectedLocation;
  String? _selectedBranchId;
  String? _paymentOption = "Cash";
  String? _executiveName;
  DateTime? _treatmentDate;
  String? _selectedHour;
  String? _selectedMinute;

  List<Map<String, dynamic>> _selectedTreatments = [];

  final List<String> _locations = ["Kozhikode", "Palakkad", "Kochi", "Trissur"];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegisterProvider>().fetchBranches();
    });

    // Add listeners for automatic balance calculation
    _totalAmountController.addListener(_calculateBalance);
    _discountAmountController.addListener(_calculateBalance);
    _advanceAmountController.addListener(_calculateBalance);
  }

  Future<void> _loadUserInfo() async {
    final name = await _storage.getUserName();
    setState(() {
      _executiveName = name;
      // We don't populate _nameController and _whatsappController anymore
      // because they are for the patient's info, not the executive's.
    });
  }

  void _calculateBalance() {
    final total = double.tryParse(_totalAmountController.text) ?? 0.0;
    final discount = double.tryParse(_discountAmountController.text) ?? 0.0;
    final advance = double.tryParse(_advanceAmountController.text) ?? 0.0;

    final balance = total - discount - advance;

    // Update balance controller without triggering its own listeners if any (though it won't here)
    // We use a simple check to avoid unnecessary text updates that move the cursor
    final balanceStr = balance.toStringAsFixed(0);
    if (_balanceAmountController.text != balanceStr) {
      _balanceAmountController.text = balanceStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.sp),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Register",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              const Divider(),
              SizedBox(height: 20.h),
              _buildLabel("Name"),
              _buildTextField(
                _nameController,
                "Enter your full name",
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              _buildLabel("Whatsapp Number"),
              _buildTextField(
                _whatsappController,
                "Enter your Whatsapp number",
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              _buildLabel("Address"),
              _buildTextField(
                _addressController,
                "Enter your full address",
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              _buildLabel("Location"),
              _buildDropdown(
                "Choose your location",
                _locations,
                _selectedLocation,
                (val) => setState(() => _selectedLocation = val),
              ),

              _buildLabel("Branch"),
              Consumer<RegisterProvider>(
                builder: (context, register, child) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F1F1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          "Select the branch",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14.sp,
                          ),
                        ),
                        value: _selectedBranchId,
                        items: register.branches.map((branch) {
                          return DropdownMenuItem<String>(
                            value: branch['id'].toString(),
                            child: Text(branch['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedBranchId = val),
                      ),
                    ),
                  );
                },
              ),

              _buildLabel("Treatments"),
              ..._selectedTreatments.asMap().entries.map(
                (entry) => _buildAddedTreatment(entry.key, entry.value),
              ),

              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => const TreatmentDialog(),
                    );
                    if (result != null) {
                      setState(() => _selectedTreatments.add(result));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffBED9CD),
                    foregroundColor: const Color(0xff006837),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 20),
                      SizedBox(width: 8.w),
                      Text(
                        "Add Treatments",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildLabel("Total Amount"),
              _buildTextField(
                _totalAmountController,
                "",
                keyboardType: TextInputType.number,
              ),

              _buildLabel("Discount Amount"),
              _buildTextField(
                _discountAmountController,
                "",
                keyboardType: TextInputType.number,
              ),

              _buildLabel("Payment Option"),
              Row(
                children: [
                  _buildRadioOption("Cash"),
                  _buildRadioOption("Card"),
                  _buildRadioOption("UPI"),
                ],
              ),

              _buildLabel("Advance Amount"),
              _buildTextField(
                _advanceAmountController,
                "",
                keyboardType: TextInputType.number,
              ),

              _buildLabel("Balance Amount"),
              _buildTextField(
                _balanceAmountController,
                "",
                keyboardType: TextInputType.number,
              ),

              _buildLabel("Treatment Date"),
              _buildDatePicker(),

              _buildLabel("Treatment Time"),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeDropdown(
                      "Hour",
                      List.generate(24, (i) => i.toString().padLeft(2, '0')),
                      _selectedHour,
                      (val) => setState(() => _selectedHour = val),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildTimeDropdown(
                      "Minutes",
                      List.generate(60, (i) => i.toString().padLeft(2, '0')),
                      _selectedMinute,
                      (val) => setState(() => _selectedMinute = val),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: Consumer<RegisterProvider>(
                  builder: (context, register, child) {
                    return ElevatedButton(
                      onPressed: register.isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff006837),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: register.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 15.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 16.sp, color: const Color(0xFF1E1E1E)),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF1F1F1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xffF1F1F1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
          ),
          value: value,
          items: items.map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: _paymentOption,
          onChanged: (val) => setState(() => _paymentOption = val),
          activeColor: const Color(0xff006837),
        ),
        Text(value, style: TextStyle(fontSize: 14.sp)),
        SizedBox(width: 10.w),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => _treatmentDate = date);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xffF1F1F1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _treatmentDate == null
                  ? "Select date"
                  : "${_treatmentDate!.day}/${_treatmentDate!.month}/${_treatmentDate!.year}",
              style: TextStyle(
                color: _treatmentDate == null
                    ? Colors.grey.shade400
                    : Colors.black,
                fontSize: 14.sp,
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: Color(0xff006837),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xffF1F1F1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(label, style: TextStyle(fontSize: 14.sp)),
          value: value,
          items: items.map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAddedTreatment(int index, Map<String, dynamic> treatment) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: const Color(0xffF1F1F1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "${index + 1}. ",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  treatment['treatment'],
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () =>
                    setState(() => _selectedTreatments.removeAt(index)),
              ),
            ],
          ),
          Row(
            children: [
              _buildPatientInfo("Male", treatment['male']),
              SizedBox(width: 20.w),
              _buildPatientInfo("Female", treatment['female']),
              const Spacer(),
              const Icon(Icons.edit, color: Color(0xff006837), size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo(String label, int count) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: const Color(0xff006837), fontSize: 14.sp),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Text("$count"),
        ),
      ],
    );
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final success = await context
          .read<RegisterProvider>()
          .registerAndGeneratePdf(
            name: _nameController.text,
            phone: _whatsappController.text,
            address: _addressController.text,
            totalAmount: _totalAmountController.text,
            discountAmount: _discountAmountController.text,
            advanceAmount: _advanceAmountController.text,
            balanceAmount: _balanceAmountController.text,
            payment: _paymentOption ?? "Cash",
            branchId: _selectedBranchId,
            executive: _executiveName ?? 'Admin',
            treatmentDate: _treatmentDate,
            hour: _selectedHour ?? "10",
            minute: _selectedMinute ?? "00",
            selectedTreatments: _selectedTreatments,
          );

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _totalAmountController.dispose();
    _discountAmountController.dispose();
    _advanceAmountController.dispose();
    _balanceAmountController.dispose();
    super.dispose();
  }
}
