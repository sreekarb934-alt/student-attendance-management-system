/// Represents the attendance status of a student for the current session.
enum AttendanceStatus {
  present,
  absent,
}

/// Data model representing a student in the attendance system.
class Student {
  final String id;
  final String name;
  final String rollNumber;
  final String department;
  final AttendanceStatus status;
  final String? timeMarked;

  const Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.department,
    required this.status,
    this.timeMarked,
  });

  /// Helper getter to generate 2-letter initials for avatar display.
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  /// Creates a copy of this student with the given fields replaced.
  Student copyWith({
    String? id,
    String? name,
    String? rollNumber,
    String? department,
    AttendanceStatus? status,
    String? timeMarked,
    bool clearTimeMarked = false,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      department: department ?? this.department,
      status: status ?? this.status,
      timeMarked: clearTimeMarked ? null : (timeMarked ?? this.timeMarked),
    );
  }
}

/// Sample in-memory dataset for UI development and demonstration.
/// Note: In Commit 1, this is mock data and is not permanently persisted.
class MockStudentData {
  static const List<Student> students = [
    Student(
      id: '1',
      name: 'Aarav Sharma',
      rollNumber: '21A91A0501',
      department: 'CSE - Section A',
      status: AttendanceStatus.present,
      timeMarked: '09:02 AM',
    ),
    Student(
      id: '2',
      name: 'Ananya Reddy',
      rollNumber: '21A91A0502',
      department: 'CSE - Section A',
      status: AttendanceStatus.present,
      timeMarked: '09:05 AM',
    ),
    Student(
      id: '3',
      name: 'Bhavya Patel',
      rollNumber: '21A91A0503',
      department: 'CSE - Section A',
      status: AttendanceStatus.absent,
    ),
    Student(
      id: '4',
      name: 'Chaitanya Kumar',
      rollNumber: '21A91A0504',
      department: 'CSE - Section A',
      status: AttendanceStatus.present,
      timeMarked: '09:08 AM',
    ),
    Student(
      id: '5',
      name: 'Deepika Iyer',
      rollNumber: '21A91A0505',
      department: 'CSE - Section A',
      status: AttendanceStatus.present,
      timeMarked: '09:10 AM',
    ),
    Student(
      id: '6',
      name: 'Eshwar Verma',
      rollNumber: '21A91A0506',
      department: 'CSE - Section A',
      status: AttendanceStatus.absent,
    ),
    Student(
      id: '7',
      name: 'Farhan Ali',
      rollNumber: '21A91A0507',
      department: 'CSE - Section A',
      status: AttendanceStatus.present,
      timeMarked: '09:12 AM',
    ),
    Student(
      id: '8',
      name: 'Gayatri Joshi',
      rollNumber: '21A91A0508',
      department: 'CSE - Section A',
      status: AttendanceStatus.present,
      timeMarked: '09:15 AM',
    ),
    Student(
      id: '9',
      name: 'Harish Nair',
      rollNumber: '21A91A0509',
      department: 'CSE - Section A',
      status: AttendanceStatus.present,
      timeMarked: '09:18 AM',
    ),
    Student(
      id: '10',
      name: 'Ishaan Gupta',
      rollNumber: '21A91A0510',
      department: 'CSE - Section A',
      status: AttendanceStatus.absent,
    ),
  ];
}
