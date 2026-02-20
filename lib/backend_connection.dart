import 'dart:convert';
import 'package:jose/jose.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sauf_o_mat_black_devils/backend_testing.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Singleton service to handle Salesforce JWT integration
class SalesforceService {
  static final SalesforceService _instance = SalesforceService._internal();
  factory SalesforceService() => _instance;
  SalesforceService._internal();

  String? _cachedToken;
  DateTime? _tokenExpiry;

  static const String consumerKey = String.fromEnvironment('SF_CONSUMER_KEY');
  static const String username = String.fromEnvironment('SF_USERNAME');
  static const String loginUrl = String.fromEnvironment('SF_LOGIN_URL');
  static const bool isTestVersion = String.fromEnvironment('MODE') == 'testing';
  static const bool isProdVersion = String.fromEnvironment('MODE') == 'production';

  /// Returns a valid access token, caching it until it expires
  Future<String> getAccessToken() async {
    if (_cachedToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken!;
    }

    return await _fetchNewToken();
  }

  /// Generates a signed JWT and exchanges it for a Salesforce access token
  Future<String> _fetchNewToken() async {
    final privateKeyPem = await rootBundle.loadString('assets/server.key');
    final key = JsonWebKey.fromPem(privateKeyPem);
    final jwtBuilder = JsonWebSignatureBuilder()
      ..jsonContent = {
        'iss': consumerKey,
        'sub': username,
        'aud': loginUrl,
        'exp': DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 + 180, // 3 minutes
      }
      ..setProtectedHeader('alg', 'RS256')
      ..addRecipient(key, algorithm: 'RS256');

    final signedJwt = jwtBuilder.build().toCompactSerialization();

    final response = await http.post(
      Uri.parse('$loginUrl/services/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': signedJwt,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch Salesforce token: ${response.body}');
    }

    final json = jsonDecode(response.body);
    _cachedToken = json['access_token'];
    _tokenExpiry = DateTime.now().add(Duration(minutes: 10)); // Short buffer

    return _cachedToken!;
  }

  /// Generic GET request to Salesforce API
  Future<Map<String, dynamic>> getRequest(String soql) async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('$loginUrl/services/data/v61.0/query/?q=$soql'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      // Token may have expired early -> retry once
      _cachedToken = null;
      final retryToken = await getAccessToken();
      return await _retryGet(soql, retryToken);
    }

    if (response.statusCode != 200) {
      throw Exception('Salesforce API Error: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  /// Generic PATCH request to Salesforce API
  Future<void> patchRequest(String id, String table, Map body) async {
    final token = await getAccessToken();
    final uri = Uri.parse('$loginUrl/services/data/v61.0/sobjects/$table/$id');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      // Token may have expired -> retry once
      _cachedToken = null;
      final retryToken = await getAccessToken();
      final retryResponse = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $retryToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (retryResponse.statusCode < 200 || retryResponse.statusCode >= 300) {
        throw Exception('Salesforce PATCH Error: ${response.statusCode}, ${response.body}');
      }
      return;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Salesforce PATCH Error: ${response.statusCode}, ${response.body}');
    }
  }

  Future<Map<String, dynamic>> _retryGet(String rawSoql, String token) async {
    var soql = rawSoql.replaceAll(" ", "+");
    final response = await http.get(
      Uri.parse('$loginUrl/services/data/v61.0/query/?q=$soql'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Salesforce API Error after retry: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<List<Map>> getPageDiagram() async {
    if (isTestVersion) return TestBackendData().getPageDiagram();
    try {
      final data = await getRequest('SELECT Punktzahl_Shots__c, NAME, StatusDisplay__c, RandomColour__c FROM Team__c');
      var records = data["records"];
      List<Map> returnData = [];
      for (var record in records) {
        returnData.add({
          "group": record["Name"],
          "color": record["RandomColour__c"],
          "shot": (record["Punktzahl_Shots__c"]).toInt(),
          "status": record["StatusDisplay__c"],
        });
      }
      return returnData;
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }
}
