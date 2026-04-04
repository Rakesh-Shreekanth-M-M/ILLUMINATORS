class MysyruHospital {
  final String name;
  final double lat;
  final double lng;
  final String type; // Govt / Private / Multi

  const MysyruHospital({
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
  });
}

const List<MysyruHospital> mysyruHospitals = [
  MysyruHospital(
    name: 'Apollo BGS Hospital',
    lat: 12.3375,
    lng: 76.6188,
    type: 'Private',
  ),
  MysyruHospital(
    name: 'Columbia Asia Mysuru',
    lat: 12.3213,
    lng: 76.6540,
    type: 'Private',
  ),
  MysyruHospital(
    name: 'JSS Hospital',
    lat: 12.3052,
    lng: 76.6551,
    type: 'Govt',
  ),
  MysyruHospital(
    name: 'Cheluvamba Hospital',
    lat: 12.3096,
    lng: 76.6565,
    type: 'Govt',
  ),
  MysyruHospital(
    name: 'KR Hospital',
    lat: 12.3042,
    lng: 76.6540,
    type: 'Govt',
  ),
  MysyruHospital(
    name: 'Manipal Hospital Mysuru',
    lat: 12.3365,
    lng: 76.6524,
    type: 'Private',
  ),
  MysyruHospital(
    name: 'Vikram Hospital',
    lat: 12.2948,
    lng: 76.6430,
    type: 'Private',
  ),
  MysyruHospital(
    name: 'Narayana Multispeciality',
    lat: 12.3128,
    lng: 76.6198,
    type: 'Private',
  ),
  MysyruHospital(
    name: 'District Hospital Mysuru',
    lat: 12.3026,
    lng: 76.6537,
    type: 'Govt',
  ),
];
