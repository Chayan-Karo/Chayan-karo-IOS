import 'package:meta/meta.dart';
import 'package:dio/dio.dart'; // Import Dio for exception handling
import '../remote/api_service.dart';
import '../remote/network_client.dart';
import '../../data/local/database.dart';
import '../../models/saathi_models.dart';

@immutable
class SaathiRepository {
  SaathiRepository({
    AppDatabase? database,
  })  : _database = database ?? AppDatabase(),
        _api = NetworkClient().apiService;

  final ApiService _api;
  final AppDatabase _database;

  // ----------------------------------------------------------------------
  // Get Service Providers (Updated with bookingTime)
  // ----------------------------------------------------------------------
  Future<List<SaathiItem>> getServiceProviders({
    required String categoryId,
    required String serviceId,
    required String locationId,
    required String addressId,
    required DateTime bookingDate,
    int currentBookingDuration = 0,
    String? bookingTime, // <--- 1. ACCEPT PARAMETER
  }) async {
    // 1. Validations
    if (categoryId.isEmpty) throw ArgumentError('categoryId required');
    if (serviceId.isEmpty) throw ArgumentError('serviceId required');
    if (locationId.isEmpty) throw ArgumentError('locationId required');

    final token = await _database.getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    // 2. Format Date
    final plainDate = "${bookingDate.year.toString().padLeft(4, '0')}"
        "-${bookingDate.month.toString().padLeft(2, '0')}"
        "-${bookingDate.day.toString().padLeft(2, '0')}";

    // 3. Create Request Body Object
    final requestBody = GetProvidersRequest(
      categoryId: categoryId,
      serviceId: serviceId,
      locationId: locationId,
      addressId: addressId,
      bookingDate: plainDate,
      currentBookingDuration: currentBookingDuration,
      bookingTime: bookingTime ?? "", // <--- 2. PASS TO BODY
    );

    // 4. Call API (POST)
    final SaathiResponse res = await _api.getServiceProvider(
      'Bearer $token',
      requestBody,
    );

    // 5. Map to UI Model
    final items = res.result.map((dto) {
      // The DTO.toUi() method handles the nested availability logic
      return dto.toUi(); 
    }).toList();

    return items;
  }

  // ----------------------------------------------------------------------
  // Lock Service Provider
  // ----------------------------------------------------------------------
  Future<LockProviderResponse> lockServiceProvider({
    required String serviceProviderId,
    required DateTime bookingDate,
  }) async {
    if (serviceProviderId.trim().isEmpty) {
      throw ArgumentError('serviceProviderId required');
    }

    final token = await _database.getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final plainDate = "${bookingDate.year.toString().padLeft(4, '0')}"
        "-${bookingDate.month.toString().padLeft(2, '0')}"
        "-${bookingDate.day.toString().padLeft(2, '0')}";

    try {
      final res = await _api.lockServiceProvider(
        'Bearer $token',
        serviceProviderId,
        plainDate,
      );
      return res;
    } on DioException catch (e) {
      String userMessage = "Unable to lock provider. Please try again.";

      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('message')) {
          userMessage = data['message'].toString();
        } else if (data.containsKey('error')) {
          userMessage = data['error'].toString();
        }
      } else if (e.response?.statusCode == 409) {
        userMessage = "This provider is already booked/locked by someone else.";
      }

      throw Exception(userMessage);
    } catch (e) {
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }
}