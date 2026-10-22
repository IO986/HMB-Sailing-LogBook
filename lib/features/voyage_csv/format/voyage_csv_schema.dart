/// What a cell holds. Decides how a value is written and read back.
enum CsvKind {
  /// Free text. Written with formula-injection protection.
  text,
  integer,

  /// Decimal number with a dot, shortest form that reads back exactly.
  real,

  /// `true` or `false`.
  boolean,

  /// A moment, ISO 8601 in UTC with a trailing `Z`.
  instant,

  /// A calendar day, `YYYY-MM-DD`, no time zone.
  date,
}

class CsvColumn {
  final String name;
  final CsvKind kind;
  const CsvColumn(this.name, this.kind);
}

/// The format of the voyage CSV: record types and their columns.
///
/// One file, one header. Every record type uses a subset of the columns and
/// leaves the others empty; a column used by several types (`time_utc`,
/// `lat`, `note`…) is one column, so the header stays narrow. The documented
/// copy of this is `docs/CSV_FORMAT.md`, and a test fails when the two
/// differ.
///
/// Compatible changes (a new column, a new record type) keep [version]; a
/// reader ignores what it does not know. Anything that changes the meaning of
/// an existing column bumps it.
abstract final class VoyageCsvSchema {
  static const formatName = 'hmb-voyage';
  static const version = 1;

  // ── Common columns ─────────────────────────────────────────────────
  static const recordType = 'record_type';

  /// Number of the record, unique within its type in this file. Not the
  /// database id: an import hands out new ones.
  static const id = 'id';

  /// `id` of the parent record. The parent's type follows from the child's:
  /// an entry's parent is a day, a track point's is a session, a checklist
  /// item's is a handover. Empty for records that belong to the voyage itself.
  static const parentId = 'parent_id';

  static const _t = CsvKind.text;
  static const _i = CsvKind.integer;
  static const _r = CsvKind.real;
  static const _b = CsvKind.boolean;
  static const _at = CsvKind.instant;
  static const _d = CsvKind.date;

  /// Every column besides the three common ones, by name.
  static const Map<String, CsvColumn> columns = {
    // meta
    'format': CsvColumn('format', _t),
    'version': CsvColumn('version', _i),
    'exported_at_utc': CsvColumn('exported_at_utc', _at),
    'app_version': CsvColumn('app_version', _t),
    'schema_version': CsvColumn('schema_version', _i),
    'includes_track': CsvColumn('includes_track', _b),
    // charter
    'uuid': CsvColumn('uuid', _t),
    'title': CsvColumn('title', _t),
    'date_from_utc': CsvColumn('date_from_utc', _at),
    'date_to_utc': CsvColumn('date_to_utc', _at),
    'vessel_name': CsvColumn('vessel_name', _t),
    'vessel_type': CsvColumn('vessel_type', _t),
    'vessel_model': CsvColumn('vessel_model', _t),
    'vessel_flag': CsvColumn('vessel_flag', _t),
    'home_port': CsvColumn('home_port', _t),
    'charter_company': CsvColumn('charter_company', _t),
    'country': CsvColumn('country', _t),
    'cruising_area': CsvColumn('cruising_area', _t),
    'route': CsvColumn('route', _t),
    'callsign': CsvColumn('callsign', _t),
    'mmsi': CsvColumn('mmsi', _t),
    'length_m': CsvColumn('length_m', _r),
    'beam_m': CsvColumn('beam_m', _r),
    'draft_m': CsvColumn('draft_m', _r),
    'berths': CsvColumn('berths', _i),
    'year_built': CsvColumn('year_built', _i),
    'engine': CsvColumn('engine', _t),
    'water_tank_l': CsvColumn('water_tank_l', _r),
    'fuel_tank_l': CsvColumn('fuel_tank_l', _r),
    'engine_hours_start': CsvColumn('engine_hours_start', _r),
    'engine_hours_end': CsvColumn('engine_hours_end', _r),
    'cost_currency': CsvColumn('cost_currency', _t),
    'my_role': CsvColumn('my_role', _t),
    'tidal_waters': CsvColumn('tidal_waters', _b),
    'captain_first_name': CsvColumn('captain_first_name', _t),
    'captain_last_name': CsvColumn('captain_last_name', _t),
    'captain_qualification': CsvColumn('captain_qualification', _t),
    'safety_briefing_done': CsvColumn('safety_briefing_done', _b),
    'check_in_done': CsvColumn('check_in_done', _b),
    'check_out_done': CsvColumn('check_out_done', _b),
    'archived': CsvColumn('archived', _b),
    'source': CsvColumn('source', _t),
    'created_utc': CsvColumn('created_utc', _at),
    // crew
    'name': CsvColumn('name', _t),
    'role': CsvColumn('role', _t),
    'qualification': CsvColumn('qualification', _t),
    'boat_licence': CsvColumn('boat_licence', _t),
    'radio_licence': CsvColumn('radio_licence', _t),
    'other_certs': CsvColumn('other_certs', _t),
    // contact, cost, briefing
    'value': CsvColumn('value', _t),
    'amount': CsvColumn('amount', _r),
    // day
    'date': CsvColumn('date', _d),
    'port_from': CsvColumn('port_from', _t),
    'port_to': CsvColumn('port_to', _t),
    'vessel_for_day': CsvColumn('vessel_for_day', _t),
    'distance_nm': CsvColumn('distance_nm', _r),
    'beaufort_morning': CsvColumn('beaufort_morning', _i),
    'beaufort_noon': CsvColumn('beaufort_noon', _i),
    'beaufort_evening': CsvColumn('beaufort_evening', _i),
    'sea_state': CsvColumn('sea_state', _t),
    'wave_height_m': CsvColumn('wave_height_m', _r),
    'wind_direction': CsvColumn('wind_direction', _t),
    'air_temp_c': CsvColumn('air_temp_c', _r),
    'water_temp_c': CsvColumn('water_temp_c', _r),
    'engine_hours': CsvColumn('engine_hours', _r),
    'night_hours_manual': CsvColumn('night_hours_manual', _r),
    'complete': CsvColumn('complete', _b),
    'note': CsvColumn('note', _t),
    // session
    'from_utc': CsvColumn('from_utc', _at),
    'to_utc': CsvColumn('to_utc', _at),
    'max_speed_kn': CsvColumn('max_speed_kn', _r),
    'avg_speed_kn': CsvColumn('avg_speed_kn', _r),
    'anchor_watch': CsvColumn('anchor_watch', _b),
    'estimated': CsvColumn('estimated', _b),
    // entry and track
    'time_utc': CsvColumn('time_utc', _at),
    'lat': CsvColumn('lat', _r),
    'lon': CsvColumn('lon', _r),
    'sog_kn': CsvColumn('sog_kn', _r),
    'cog_deg': CsvColumn('cog_deg', _r),
    'heading_deg': CsvColumn('heading_deg', _r),
    'wind_kn': CsvColumn('wind_kn', _r),
    'wind_dir_deg': CsvColumn('wind_dir_deg', _r),
    'wave_m': CsvColumn('wave_m', _r),
    'pressure_hpa': CsvColumn('pressure_hpa', _r),
    'fuel_consumed_l': CsvColumn('fuel_consumed_l', _r),
    'fuel_level_pct': CsvColumn('fuel_level_pct', _i),
    'water_level_pct': CsvColumn('water_level_pct', _i),
    'helmsman': CsvColumn('helmsman', _t),
    'crew_names': CsvColumn('crew_names', _t),
    'auto_entry': CsvColumn('auto_entry', _b),
    'event_type': CsvColumn('event_type', _t),
    'sail_mode': CsvColumn('sail_mode', _t),
    'point_of_sail': CsvColumn('point_of_sail', _t),
    'tack': CsvColumn('tack', _t),
    'depth_m': CsvColumn('depth_m', _r),
    'weather_condition': CsvColumn('weather_condition', _t),
    'accuracy_m': CsvColumn('accuracy_m', _r),
    'location_source': CsvColumn('location_source', _t),
    'mocked': CsvColumn('mocked', _b),
    'weather_source': CsvColumn('weather_source', _t),
    'weather_station': CsvColumn('weather_station', _t),
    'weather_station_distance_m': CsvColumn('weather_station_distance_m', _r),
    'session_ref': CsvColumn('session_ref', _i),
    'altitude_m': CsvColumn('altitude_m', _r),
    'speed_kn': CsvColumn('speed_kn', _r),
    'course_deg': CsvColumn('course_deg', _r),
    // duty
    'auto_closed': CsvColumn('auto_closed', _b),
    // handover and checklist
    'handover_type': CsvColumn('handover_type', _t),
    'location': CsvColumn('location', _t),
    'skipper_name': CsvColumn('skipper_name', _t),
    'skipper_signed_utc': CsvColumn('skipper_signed_utc', _at),
    'company_rep': CsvColumn('company_rep', _t),
    'company_name': CsvColumn('company_name', _t),
    'company_signed_utc': CsvColumn('company_signed_utc', _at),
    'item_key': CsvColumn('item_key', _t),
    'status': CsvColumn('status', _t),
    'position': CsvColumn('position', _t),
    'custom_label': CsvColumn('custom_label', _t),
    'category_key': CsvColumn('category_key', _t),
    // assessment
    'helming': CsvColumn('helming', _i),
    'navigation': CsvColumn('navigation', _i),
    'harbour_manoeuvres': CsvColumn('harbour_manoeuvres', _i),
    'teamwork': CsvColumn('teamwork', _i),
    'night_sailing': CsvColumn('night_sailing', _i),
    // signature
    'signed_utc': CsvColumn('signed_utc', _at),
    // bearing
    'bearing_kind': CsvColumn('bearing_kind', _t),
    'target_lat': CsvColumn('target_lat', _r),
    'target_lon': CsvColumn('target_lon', _r),
    'target_name': CsvColumn('target_name', _t),
    'magnetic_bearing_deg': CsvColumn('magnetic_bearing_deg', _r),
    'declination_deg': CsvColumn('declination_deg', _r),
    'declination_source': CsvColumn('declination_source', _t),
    'true_bearing_deg': CsvColumn('true_bearing_deg', _r),
    'uncertainty_deg': CsvColumn('uncertainty_deg', _r),
    'sight_group': CsvColumn('sight_group', _t),
    'label': CsvColumn('label', _t),
    'hidden_from_map': CsvColumn('hidden_from_map', _b),
  };

  /// Record types, in the order they appear in a file, with the columns each
  /// uses (besides `record_type`, `id` and `parent_id`).
  static const Map<String, List<String>> types = {
    'meta': [
      'format', 'version', 'exported_at_utc', 'app_version', 'schema_version',
      'includes_track',
    ],
    'charter': [
      'uuid', 'title', 'date_from_utc', 'date_to_utc', 'vessel_name',
      'vessel_type', 'vessel_model', 'vessel_flag', 'home_port',
      'charter_company', 'country', 'cruising_area', 'route', 'callsign',
      'mmsi', 'length_m', 'beam_m', 'draft_m', 'berths', 'year_built',
      'engine', 'water_tank_l', 'fuel_tank_l', 'engine_hours_start',
      'engine_hours_end', 'cost_currency', 'my_role', 'tidal_waters',
      'captain_first_name', 'captain_last_name', 'captain_qualification',
      'safety_briefing_done', 'check_in_done', 'check_out_done', 'archived',
      'source', 'created_utc', 'note',
    ],
    'crew': [
      'name', 'role', 'qualification', 'boat_licence', 'radio_licence',
      'other_certs',
    ],
    'contact': ['value'],
    'cost': ['name', 'amount'],
    'briefing': ['value'],
    'day': [
      'date', 'port_from', 'port_to', 'vessel_for_day', 'distance_nm',
      'beaufort_morning', 'beaufort_noon', 'beaufort_evening', 'sea_state',
      'wave_height_m', 'wind_direction', 'air_temp_c', 'water_temp_c',
      'engine_hours', 'night_hours_manual', 'complete', 'note',
    ],
    'session': [
      'from_utc', 'to_utc', 'name', 'distance_nm', 'max_speed_kn',
      'avg_speed_kn', 'anchor_watch', 'estimated',
    ],
    'entry': [
      'time_utc', 'lat', 'lon', 'sog_kn', 'cog_deg', 'heading_deg',
      'wind_kn', 'wind_dir_deg', 'wave_m', 'pressure_hpa', 'air_temp_c',
      'water_temp_c', 'engine_hours', 'fuel_consumed_l', 'fuel_level_pct',
      'water_level_pct', 'helmsman', 'crew_names', 'note', 'auto_entry',
      'event_type', 'sail_mode', 'point_of_sail', 'tack', 'depth_m',
      'weather_condition', 'accuracy_m', 'location_source', 'mocked',
      'weather_source', 'weather_station', 'weather_station_distance_m',
      'session_ref',
    ],
    'track': [
      'time_utc', 'lat', 'lon', 'altitude_m', 'speed_kn', 'course_deg',
      'accuracy_m', 'location_source', 'mocked',
    ],
    'duty': ['name', 'role', 'from_utc', 'to_utc', 'note', 'auto_closed'],
    'handover': [
      'handover_type', 'time_utc', 'location', 'fuel_level_pct',
      'water_level_pct', 'engine_hours', 'skipper_name', 'skipper_signed_utc',
      'company_rep', 'company_name', 'company_signed_utc', 'note',
    ],
    'checklist': [
      'item_key', 'status', 'note', 'position', 'custom_label', 'category_key',
    ],
    'assessment': [
      'name', 'helming', 'navigation', 'harbour_manoeuvres', 'teamwork',
      'night_sailing', 'note',
    ],
    'signature': ['name', 'role', 'signed_utc'],
    'bearing': [
      'bearing_kind', 'lat', 'lon', 'accuracy_m', 'target_lat', 'target_lon',
      'target_name', 'magnetic_bearing_deg', 'declination_deg',
      'declination_source', 'true_bearing_deg', 'uncertainty_deg',
      'sight_group', 'label', 'time_utc', 'hidden_from_map',
    ],
  };

  /// The header row: the three common columns, then every other column once,
  /// in the order of first use by the record types above.
  static final List<String> header = _buildHeader();

  static List<String> _buildHeader() {
    final seen = <String>{};
    final out = <String>[recordType, id, parentId];
    for (final cols in types.values) {
      for (final c in cols) {
        if (seen.add(c)) out.add(c);
      }
    }
    return out;
  }

  static bool isKnownType(String type) => types.containsKey(type);

  /// Whether [column] may carry a value in a record of [type].
  static bool allows(String type, String column) =>
      column == recordType ||
      column == id ||
      column == parentId ||
      (types[type]?.contains(column) ?? false);

  static CsvKind? kindOf(String column) => columns[column]?.kind;
}
