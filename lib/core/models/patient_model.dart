class Patient {
  final int? id;
  final List<PatientDetail> patientDetails;
  final Branch? branch;
  final String? user;
  final String? payment;
  final String? name;
  final String? phone;
  final String? address;
  final double? price;
  final int? totalAmount;
  final int? discountAmount;
  final int? advanceAmount;
  final int? balanceAmount;
  final DateTime? dateAndTime;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Patient({
    this.id,
    required this.patientDetails,
    this.branch,
    this.user,
    this.payment,
    this.name,
    this.phone,
    this.address,
    this.price,
    this.totalAmount,
    this.discountAmount,
    this.advanceAmount,
    this.balanceAmount,
    this.dateAndTime,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      patientDetails:
          (json['patientdetails_set'] as List?)
              ?.map((e) => PatientDetail.fromJson(e))
              .toList() ??
          [],
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
      user: json['user'],
      payment: json['payment'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      totalAmount: (json['total_amount'] as num?)?.toInt(),
      discountAmount: (json['discount_amount'] as num?)?.toInt(),
      advanceAmount: (json['advance_amount'] as num?)?.toInt(),
      balanceAmount: (json['balance_amount'] as num?)?.toInt(),
      dateAndTime: _parseDate(json['date_nd_time']),
      isActive:
          json['is_active']?.toString() == 'true' || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    String dateStr = dateValue.toString();

    // Try standard ISO format
    DateTime? parsed = DateTime.tryParse(dateStr);
    if (parsed != null) return parsed;

    // Try custom format: dd/mm/yyyy-hh:mm AM
    try {
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        final datePart = parts[0]; // dd/mm/yyyy
        final timePart = parts[1]; // hh:mm AM

        final dateParts = datePart.split('/');
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);

        final timeClean = timePart.replaceAll(RegExp(r'[APM]'), '').trim();
        final timeParts = timeClean.split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        if (timePart.toUpperCase().contains('PM') && hour < 12) {
          hour += 12;
        } else if (timePart.toUpperCase().contains('AM') && hour == 12) {
          hour = 0;
        }

        return DateTime(year, month, day, hour, minute);
      }
    } catch (e) {
      // Quietly return null if custom parsing fails
    }

    return null;
  }
}

class PatientDetail {
  final int? id;
  final String? male;
  final String? female;
  final int? patient;
  final int? treatment;
  final String? treatmentName;

  PatientDetail({
    this.id,
    this.male,
    this.female,
    this.patient,
    this.treatment,
    this.treatmentName,
  });

  factory PatientDetail.fromJson(Map<String, dynamic> json) {
    return PatientDetail(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      male: json['male']?.toString(),
      female: json['female']?.toString(),
      patient: (json['patient'] as num?)?.toInt(),
      treatment: (json['treatment'] as num?)?.toInt(),
      treatmentName: json['treatment_name'],
    );
  }
}

class Branch {
  final int? id;
  final String? name;
  final int? patientsCount;
  final String? location;
  final String? phone;
  final String? mail;
  final String? address;
  final String? gst;
  final bool? isActive;

  Branch({
    this.id,
    this.name,
    this.patientsCount,
    this.location,
    this.phone,
    this.mail,
    this.address,
    this.gst,
    this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'],
      patientsCount: (json['patients_count'] as num?)?.toInt(),
      location: json['location'],
      phone: json['phone'],
      mail: json['mail'],
      address: json['address'],
      gst: json['gst'],
      isActive:
          json['is_active']?.toString() == 'true' || json['is_active'] == true,
    );
  }
}
