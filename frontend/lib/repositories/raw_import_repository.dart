import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/raw_import.dart';

class RawImportRepository {
  final _client = Supabase.instance.client;

  Future<bool> exists(String sourceType, String externalId) async {
    final response = await _client
        .from('raw_imports')
        .select('id')
        .eq('source_type', sourceType)
        .eq('external_id', externalId)
        .maybeSingle();
    
    return response != null;
  }

  Future<String> insertRawImport(RawImport import) async {
    final response = await _client
        .from('raw_imports')
        .insert(import.toJson())
        .select('id')
        .single();
    
    return response['id'];
  }
}
