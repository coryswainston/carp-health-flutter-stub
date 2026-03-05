part of '../health.dart';

/// Main class for the Plugin.
///
/// Use this class to get an instance of the Health plugin, like this:
///
///         final health = Health();
///
/// The plugin must be configured using the [configure] method before used.
///
/// Overall, the plugin supports:
///
///  * Handling permissions to access health data using the [hasPermissions],
///    [requestAuthorization], [revokePermissions] methods.
///  * Reading health data using the [getHealthDataFromTypes] method.
///  * Writing health data using the [writeHealthData] method.
///  * Cleaning up duplicate data points via the [removeDuplicates] method.
///
/// In addition, the plugin has a set of specialized methods for reading and writing
/// different types of health data:
///
///  * Reading aggregate health data using the [getHealthIntervalDataFromTypes]
///    and [getHealthAggregateDataFromTypes] methods.
///  * Reading total step counts using the [getTotalStepsInInterval] method.
///  * Writing different types of specialized health data like the [writeWorkoutData],
///    [writeBloodPressure], [writeBloodOxygen], [writeAudiogram], [writeMeal],
///    [writeMenstruationFlow], [writeInsulinDelivery], [writeActivityIntensity] methods.
///
/// On **Android**, this plugin relies on the Google Health Connect (GHC) SDK.
/// Since Health Connect is not installed on SDK level < 34, the plugin has a
/// set of specialized methods to handle GHC:
///
///  * [getHealthConnectSdkStatus] to check the status of GHC
///  * [isHealthConnectAvailable] to check if GHC is installed on this phone
///  * [installHealthConnect] to direct the user to the app store to install GHC
///
/// **Note** that you should check the availability of GHC before using any setter
/// or getter methods. Otherwise, the plugin will throw an exception.
class Health {
  static const MethodChannel _channel = MethodChannel('flutter_health');

  String? _deviceId;
  final DeviceInfoPlugin _deviceInfo;
  HealthConnectSdkStatus _healthConnectSdkStatus = HealthConnectSdkStatus.sdkUnavailable;

  /// Get an instance of the health plugin.
  Health({DeviceInfoPlugin? deviceInfo}) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin() {
    //
  }

  /// The latest status on availability of Health Connect SDK on this phone.
  HealthConnectSdkStatus get healthConnectSdkStatus => _healthConnectSdkStatus;

  /// The type of platform of this device.
  HealthPlatformType get platformType =>
      Platform.isIOS ? HealthPlatformType.appleHealth : HealthPlatformType.googleHealthConnect;

  /// The id of this device.
  ///
  /// On Android this is the [ID](https://developer.android.com/reference/android/os/Build#ID) of the BUILD.
  /// On iOS this is the [identifierForVendor](https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor) of the UIDevice.
  String get deviceId => _deviceId ?? 'unknown';

  /// Configure the health plugin. Must be called before using the plugin.
  Future<void> configure() async {
    _deviceId = Platform.isAndroid
        ? (await _deviceInfo.androidInfo).id
        : (await _deviceInfo.iosInfo).identifierForVendor;
  }

  /// Check if a given data type is available on the platform
  bool isDataTypeAvailable(HealthDataType dataType) =>
      Platform.isAndroid ? dataTypeKeysAndroid.contains(dataType) : dataTypeKeysIOS.contains(dataType);

  /// Check if a given data type is available on this device.
  /// Currently only needed for Android Skin Temperature support.
  Future<void> _checkIfDataTypeAvailableOnDevice(HealthDataType dataType) async {
    return;
  }

  /// Determines if the health data [types] have been granted with the specified
  /// access rights [permissions].
  ///
  /// Returns:
  ///
  ///  * true - if all of the data types have been granted with the specified access rights.
  ///  * false - if any of the data types has not been granted with the specified access right(s).
  ///  * null - if it can not be determined if the data types have been granted with the specified access right(s).
  ///
  /// Parameters:
  ///
  ///  * [types]  - List of [HealthDataType] whose permissions are to be checked.
  ///  * [permissions] - Optional.
  ///    + If unspecified, this method checks if each HealthDataType in [types] has been granted READ access.
  ///    + If specified, this method checks if each [HealthDataType] in [types] has been granted with the access specified in its
  ///   corresponding entry in this list. The length of this list must be equal to that of [types].
  ///
  /// Caveat:
  ///
  ///  * As Apple HealthKit will not disclose if READ access has been granted for a data type due to privacy concern,
  ///   this method can only return null to represent an undetermined status, if it is called on iOS
  ///   with a READ or READ_WRITE access.
  ///
  ///  * On Android, this function returns true or false, depending on whether the specified access right has been granted.
  Future<bool?> hasPermissions(List<HealthDataType> types, {List<HealthDataAccess>? permissions}) async {
    return false;
  }

  /// Revokes Google Health Connect permissions on Android of all types.
  ///
  /// NOTE: The app must be completely killed and restarted for the changes to take effect.
  /// Not implemented on iOS as there is no way to programmatically remove access.
  ///
  /// Android only. On iOS this does nothing.
  Future<void> revokePermissions() async {
    return;
  }

  /// Checks the current status of Health Connect availability.
  ///
  /// See this for more info:
  /// https://developer.android.com/reference/kotlin/androidx/health/connect/client/HealthConnectClient#getSdkStatus(android.content.Context,kotlin.String)
  ///
  /// Android only. Returns null on iOS or if an error occurs.
  Future<HealthConnectSdkStatus?> getHealthConnectSdkStatus() async {
    return null;
  }

  /// Is Google Health Connect available on this phone?
  ///
  /// Android only. Returns always true on iOS.
  Future<bool> isHealthConnectAvailable() async => false;

  /// Prompt the user to install the Google Health Connect app via the
  /// installed store (most likely Play Store).
  ///
  /// Android only. On iOS this does nothing.
  Future<void> installHealthConnect() async {
    return;
  }

  /// Checks if Google Health Connect is available and throws an [UnsupportedError]
  /// if not.
  /// Internal methods used to check availability before any getter or setter methods.
  Future<void> _checkIfHealthConnectAvailableOnAndroid() async {
    return;
  }

  /// Checks if the Health Data History feature is available.
  ///
  /// See this for more info: https://developer.android.com/reference/androidx/health/connect/client/permission/HealthPermission#PERMISSION_READ_HEALTH_DATA_HISTORY()
  ///
  ///
  /// Android only. Returns false on iOS or if an error occurs.
  Future<bool> isHealthDataHistoryAvailable() async {
    return false;
  }

  /// Checks the current status of the Health Data History permission.
  /// Make sure to check [isHealthConnectAvailable] before calling this method.
  ///
  /// See this for more info: https://developer.android.com/reference/androidx/health/connect/client/permission/HealthPermission#PERMISSION_READ_HEALTH_DATA_HISTORY()
  ///
  ///
  /// Android only. Returns true on iOS or false if an error occurs.
  Future<bool> isHealthDataHistoryAuthorized() async {
    return false;
  }

  /// Requests the Health Data History permission.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// See this for more info: https://developer.android.com/reference/androidx/health/connect/client/permission/HealthPermission#PERMISSION_READ_HEALTH_DATA_HISTORY()
  ///
  ///
  /// Android only. Returns true on iOS or false if an error occurs.
  Future<bool> requestHealthDataHistoryAuthorization() async {
    return false;
  }

  /// Checks if the Health Data in Background feature is available.
  ///
  /// See this for more info: https://developer.android.com/reference/androidx/health/connect/client/permission/HealthPermission#PERMISSION_READ_HEALTH_DATA_IN_BACKGROUND()
  ///
  ///
  /// Android only. Returns false on iOS or if an error occurs.
  Future<bool> isHealthDataInBackgroundAvailable() async {
    return false;
  }

  /// Checks the current status of the Health Data in Background permission.
  /// Make sure to check [isHealthConnectAvailable] before calling this method.
  ///
  /// See this for more info: https://developer.android.com/reference/androidx/health/connect/client/permission/HealthPermission#PERMISSION_READ_HEALTH_DATA_IN_BACKGROUND()
  ///
  ///
  /// Android only. Returns true on iOS or false if an error occurs.
  Future<bool> isHealthDataInBackgroundAuthorized() async {
    return false;
  }

  /// Requests the Health Data in Background permission.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// See this for more info: https://developer.android.com/reference/androidx/health/connect/client/permission/HealthPermission#PERMISSION_READ_HEALTH_DATA_IN_BACKGROUND()
  ///
  ///
  /// Android only. Returns true on iOS or false if an error occurs.
  Future<bool> requestHealthDataInBackgroundAuthorization() async {
    return false;
  }

  /// Checks whether Skin Temperature is available on this Android device.
  ///
  /// Android only. Returns false on iOS or if an error occurs.
  Future<bool> isSkinTemperatureAvailable() async {
    return false;
  }

  /// Requests permissions to access health data [types].
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  ///
  /// * [types] - a list of [HealthDataType] which the permissions are requested for.
  /// * [permissions] - Optional.
  ///   + If unspecified, each [HealthDataType] in [types] is requested for READ [HealthDataAccess].
  ///   + If specified, each [HealthDataAccess] in this list is requested for its corresponding indexed
  ///   entry in [types]. In addition, the length of this list must be equal to that of [types].
  ///
  ///  Caveats:
  ///
  ///  * This method may block if permissions are already granted. Hence, check
  ///    [hasPermissions] before calling this method.
  ///  * As Apple HealthKit will not disclose if READ access has been granted for
  ///    a data type due to privacy concern, this method will return **true if
  ///    the window asking for permission was showed to the user without errors**
  ///    if it is called on iOS with a READ or READ_WRITE access.
  Future<bool> requestAuthorization(List<HealthDataType> types, {List<HealthDataAccess>? permissions}) async {
    return false;
  }

  /// Write health data.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  ///  * [value] - the health data's value in double
  ///  * [unit] - **iOS ONLY** the unit the health data is measured in.
  ///  * [type] - the value's HealthDataType
  ///  * [startTime] - the start time when this [value] is measured.
  ///    It must be equal to or earlier than [endTime].
  ///  * [endTime] - the end time when this [value] is measured.
  ///    It must be equal to or later than [startTime].
  ///    Simply set [endTime] equal to [startTime] if the [value] is measured
  ///    only at a specific point in time (default).
  ///  * [recordingMethod] - the recording method of the data point, automatic by default.
  ///    (on iOS this must be manual or automatic)
  ///
  /// Values for Sleep and Headache are ignored and will be automatically assigned
  /// the default value.
  Future<bool> writeHealthData({
    required double value,
    HealthDataUnit? unit,
    required HealthDataType type,
    required DateTime startTime,
    String? clientRecordId,
    double? clientRecordVersion,
    DateTime? endTime,
    RecordingMethod recordingMethod = RecordingMethod.automatic,
  }) async {
    return false;
  }

  /// Writes an [ActivityIntensityRecord] to Google Health Connect.
  ///
  /// This API is Android only.
  Future<bool> writeActivityIntensity({
    required ActivityIntensityLevel intensityLevel,
    required DateTime startTime,
    DateTime? endTime,
    RecordingMethod recordingMethod = RecordingMethod.automatic,
    String? clientRecordId,
    double? clientRecordVersion,
  }) async {
    return false;
  }

  /// Deletes all records of the given [type] for a given period of time.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  ///  * [type] - the value's HealthDataType.
  ///  * [startTime] - the start time when this [value] is measured.
  ///    Must be equal to or earlier than [endTime].
  ///  * [endTime] - the end time when this [value] is measured.
  ///    Must be equal to or later than [startTime].
  Future<bool> delete({required HealthDataType type, required DateTime startTime, DateTime? endTime}) async {
    return false;
  }

  /// Deletes a specific health record by its UUID.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  ///  * [uuid] - The UUID of the health record to delete.
  ///  * [type] - The health data type of the record. Required on iOS.
  ///
  /// On Android, only the UUID is required. On iOS, both UUID and type are required.
  Future<bool> deleteByUUID({required String uuid, HealthDataType? type}) async {
    return false;
  }

  Future<bool> deleteByClientRecordId({
    required HealthDataType dataTypeKey,
    required String clientRecordId,
    String? recordId,
  }) async {
    return false;
  }

  /// Saves a blood pressure record.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  ///  * [systolic] - the systolic part of the blood pressure.
  ///  * [diastolic] - the diastolic part of the blood pressure.
  ///  * [startTime] - the start time when this [value] is measured.
  ///    Must be equal to or earlier than [endTime].
  ///  * [endTime] - the end time when this [value] is measured.
  ///    Must be equal to or later than [startTime].
  ///    Simply set [endTime] equal to [startTime] if the blood pressure is measured
  ///    only at a specific point in time. If omitted, [endTime] is set to [startTime].
  ///  * [recordingMethod] - the recording method of the data point.
  Future<bool> writeBloodPressure({
    required int systolic,
    required int diastolic,
    required DateTime startTime,
    String? clientRecordId,
    double? clientRecordVersion,
    DateTime? endTime,
    RecordingMethod recordingMethod = RecordingMethod.automatic,
  }) async {
    return false;
  }

  /// Saves blood oxygen saturation record.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  ///  * [saturation] - the saturation of the blood oxygen in percentage
  ///  * [startTime] - the start time when this [saturation] is measured.
  ///    Must be equal to or earlier than [endTime].
  ///  * [endTime] - the end time when this [saturation] is measured.
  ///    Must be equal to or later than [startTime].
  ///    Simply set [endTime] equal to [startTime] if the blood oxygen saturation
  ///    is measured only at a specific point in time (default).
  ///  * [recordingMethod] - the recording method of the data point.
  Future<bool> writeBloodOxygen({
    required double saturation,
    required DateTime startTime,
    DateTime? endTime,
    RecordingMethod recordingMethod = RecordingMethod.automatic,
  }) async {
    return false;
  }

  /// Saves meal record into Apple Health or Health Connect.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  ///  * [mealType] - the type of meal.
  ///  * [startTime] - the start time when the meal was consumed.
  ///    It must be equal to or earlier than [endTime].
  ///  * [endTime] - the end time when the meal was consumed.
  ///    It must be equal to or later than [startTime].
  ///  * [name] - optional name information about this meal.
  ///  * [caloriesConsumed] - total calories consumed with this meal.
  ///  * [carbohydrates] - optional carbohydrates information.
  ///  * [protein] - optional protein information.
  ///  * [fatTotal] - optional total fat information.
  ///  * [caffeine] - optional caffeine information.
  ///  * [vitaminA] - optional vitamin A information.
  ///  * [b1Thiamin] - optional vitamin B1 (thiamin) information.
  ///  * [b2Riboflavin] - optional vitamin B2 (riboflavin) information.
  ///  * [b3Niacin] - optional vitamin B3 (niacin) information.
  ///  * [b5PantothenicAcid] - optional vitamin B5 (pantothenic acid) information.
  ///  * [b6Pyridoxine] - optional vitamin B6 (pyridoxine) information.
  ///  * [b7Biotin] - optional vitamin B7 (biotin) information.
  ///  * [b9Folate] - optional vitamin B9 (folate) information.
  ///  * [b12Cobalamin] - optional vitamin B12 (cobalamin) information.
  ///  * [vitaminC] - optional vitamin C information.
  ///  * [vitaminD] - optional vitamin D information.
  ///  * [vitaminE] - optional vitamin E information.
  ///  * [vitaminK] - optional vitamin K information.
  ///  * [calcium] - optional calcium information.
  ///  * [cholesterol] - optional cholesterol information.
  ///  * [chloride] - optional chloride information.
  ///  * [chromium] - optional chromium information.
  ///  * [copper] - optional copper information.
  ///  * [fatUnsaturated] - optional unsaturated fat information.
  ///  * [fatMonounsaturated] - optional monounsaturated fat information.
  ///  * [fatPolyunsaturated] - optional polyunsaturated fat information.
  ///  * [fatSaturated] - optional saturated fat information.
  ///  * [fatTransMonoenoic] - optional trans-monoenoic fat information.
  ///  * [fiber] - optional fiber information.
  ///  * [iodine] - optional iodine information.
  ///  * [iron] - optional iron information.
  ///  * [magnesium] - optional magnesium information.
  ///  * [manganese] - optional manganese information.
  ///  * [molybdenum] - optional molybdenum information.
  ///  * [phosphorus] - optional phosphorus information.
  ///  * [potassium] - optional potassium information.
  ///  * [selenium] - optional selenium information.
  ///  * [sodium] - optional sodium information.
  ///  * [sugar] - optional sugar information.
  ///  * [water] - optional water information.
  ///  * [zinc] - optional zinc information.
  ///  * [recordingMethod] - the recording method of the data point.
  Future<bool> writeMeal({
    required MealType mealType,
    required DateTime startTime,
    required DateTime endTime,
    String? clientRecordId,
    double? clientRecordVersion,
    double? caloriesConsumed,
    double? carbohydrates,
    double? protein,
    double? fatTotal,
    String? name,
    double? caffeine,
    double? vitaminA,
    double? b1Thiamin,
    double? b2Riboflavin,
    double? b3Niacin,
    double? b5PantothenicAcid,
    double? b6Pyridoxine,
    double? b7Biotin,
    double? b9Folate,
    double? b12Cobalamin,
    double? vitaminC,
    double? vitaminD,
    double? vitaminE,
    double? vitaminK,
    double? calcium,
    double? cholesterol,
    double? chloride,
    double? chromium,
    double? copper,
    double? fatUnsaturated,
    double? fatMonounsaturated,
    double? fatPolyunsaturated,
    double? fatSaturated,
    double? fatTransMonoenoic,
    double? fiber,
    double? iodine,
    double? iron,
    double? magnesium,
    double? manganese,
    double? molybdenum,
    double? phosphorus,
    double? potassium,
    double? selenium,
    double? sodium,
    double? sugar,
    double? water,
    double? zinc,
    RecordingMethod recordingMethod = RecordingMethod.automatic,
  }) async {
    return false;
  }

  /// Save menstruation flow into Apple Health and Google Health Connect.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  ///  * [flow] - the menstrual flow
  ///  * [startTime] - the start time when the menstrual flow is measured.
  ///  * [endTime] - the start time when the menstrual flow is measured.
  ///  * [isStartOfCycle] - A bool that indicates whether the sample represents
  ///    the start of a menstrual cycle.
  ///  * [recordingMethod] - the recording method of the data point.
  Future<bool> writeMenstruationFlow({
    required MenstrualFlow flow,
    required DateTime startTime,
    required DateTime endTime,
    required bool isStartOfCycle,
    RecordingMethod recordingMethod = RecordingMethod.automatic,
  }) async {
    return false;
  }

  /// Saves audiogram into Apple Health. Not supported on Android.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  ///   * [frequencies] - array of frequencies of the test
  ///   * [leftEarSensitivities] threshold in decibel for the left ear
  ///   * [rightEarSensitivities] threshold in decibel for the left ear
  ///   * [startTime] - the start time when the audiogram is measured.
  ///     It must be equal to or earlier than [endTime].
  ///   * [endTime] - the end time when the audiogram is measured.
  ///     It must be equal to or later than [startTime].
  ///     Simply set [endTime] equal to [startTime] if the audiogram is measured
  ///     only at a specific point in time (default).
  ///   * [metadata] - optional map of keys, both HKMetadataKeyExternalUUID
  ///     and HKMetadataKeyDeviceName are required
  Future<bool> writeAudiogram({
    required List<double> frequencies,
    required List<double> leftEarSensitivities,
    required List<double> rightEarSensitivities,
    required DateTime startTime,
    DateTime? endTime,
    Map<String, dynamic>? metadata,
  }) async {
    return false;
  }

  /// Saves insulin delivery record into Apple Health.
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Parameters:
  ///  * [units] - the number of units of insulin taken.
  ///  * [reason] - the insulin reason, basal or bolus.
  ///  * [startTime] - the start time when the meal was consumed.
  ///    It must be equal to or earlier than [endTime].
  ///  * [endTime] - the end time when the meal was consumed.
  ///    It must be equal to or later than [startTime].
  Future<bool> writeInsulinDelivery(double units,
      InsulinDeliveryReason reason,
      DateTime startTime,
      DateTime endTime,) async {
    return false;
  }

  /// [iOS only] Fetch a `HealthDataPoint` by `uuid` and `type`. Returns `null` if no matching record.
  ///
  /// Parameters:
  ///  * [uuid] - UUID of your saved health data point (e.g. A91A2F10-3D7B-486A-B140-5ADCD3C9C6D0)
  ///  * [type] - Data type of your saved health data point (e.g. HealthDataType.WORKOUT)
  ///
  /// Assuming above data are coming from your database.
  ///
  /// Note: this feature is only for iOS at this moment due to
  /// requires refactoring for Android.
  Future<HealthDataPoint?> getHealthDataByUUID({required String uuid, required HealthDataType type}) async {
    return null;
  }

  /// Fetch a list of health data points based on [types].
  /// You can also specify the [recordingMethodsToFilter] to filter the data points.
  /// If not specified, all data points will be included.
  Future<List<HealthDataPoint>> getHealthDataFromTypes({
    required List<HealthDataType> types,
    Map<HealthDataType, HealthDataUnit>? preferredUnits,
    required DateTime startTime,
    required DateTime endTime,
    List<RecordingMethod> recordingMethodsToFilter = const [],
  }) async {
    return [];
  }

  /// Fetch a list of health data points based on [types].
  /// You can also specify the [recordingMethodsToFilter] to filter the data points.
  /// If not specified, all data points will be included.Vkk
  Future<List<HealthDataPoint>> getHealthIntervalDataFromTypes({
    required DateTime startDate,
    required DateTime endDate,
    required List<HealthDataType> types,
    required int interval,
    List<RecordingMethod> recordingMethodsToFilter = const [],
  }) async {
    return [];
  }

  /// Fetch a list of health data points based on [types].
  Future<List<HealthDataPoint>> getHealthAggregateDataFromTypes({
    required List<HealthDataType> types,
    required DateTime startDate,
    required DateTime endDate,
    int activitySegmentDuration = 1,
    bool includeManualEntry = true,
  }) async {
    return [];
  }

  /// Create a Health Connect changes token for the provided [types].
  ///
  /// Android only. Returns null on iOS or if an error occurs.
  Future<String?> getChangesToken({required List<HealthDataType> types}) async {
    return null;
  }

  /// Fetch the next page of changes for a previously created token.
  ///
  /// Android only. Returns null on iOS or if an error occurs.
  Future<HealthChangesResponse?> getChanges({required String changesToken, bool includeSelf = false}) async {
    return null;
  }

  /// Return a list of [HealthDataPoint] based on [points] with no duplicates.
  List<HealthDataPoint> removeDuplicates(List<HealthDataPoint> points) => LinkedHashSet.of(points).toList();

  /// Get the total number of steps within a specific time period.
  /// Returns null if not successful.
  Future<int?> getTotalStepsInInterval(DateTime startTime, DateTime endTime, {bool includeManualEntry = true}) async {
    return null;
  }

  /// Write workout data to Apple Health or Google Health Connect.
  ///
  /// Returns true if the workout data was successfully added.
  ///
  /// Parameters:
  ///  - [activityType] The type of activity performed.
  ///  - [start] The start time of the workout.
  ///  - [end] The end time of the workout.
  ///  - [totalEnergyBurned] The total energy burned during the workout.
  ///  - [totalEnergyBurnedUnit] The UNIT used to measure [totalEnergyBurned]
  ///    *ONLY FOR IOS* Default value is KILOCALORIE.
  ///  - [totalDistance] The total distance traveled during the workout.
  ///  - [totalDistanceUnit] The UNIT used to measure [totalDistance]
  ///    *ONLY FOR IOS* Default value is METER.
  ///  - [title] The title of the workout.
  ///    *ONLY FOR HEALTH CONNECT* Default value is the [activityType], e.g. "STRENGTH_TRAINING".
  ///  - [recordingMethod] The recording method of the data point, automatic by default (on iOS this can only be automatic or manual).
  Future<bool> writeWorkoutData({
    required HealthWorkoutActivityType activityType,
    required DateTime start,
    required DateTime end,
    int? totalEnergyBurned,
    HealthDataUnit totalEnergyBurnedUnit = HealthDataUnit.KILOCALORIE,
    int? totalDistance,
    HealthDataUnit totalDistanceUnit = HealthDataUnit.METER,
    String? title,
    RecordingMethod recordingMethod = RecordingMethod.automatic,
  }) async {
    return false;
  }

  /// Start a new workout route recording session on iOS or Android.
  ///
  /// Returns a builder identifier that must be supplied in subsequent calls
  /// to [insertWorkoutRouteData], [finishWorkoutRoute], or
  /// [discardWorkoutRoute].
  Future<String> startWorkoutRoute() async {
    return '';
  }

  /// Append a batch of [locations] to an active workout route builder.
  ///
  /// The [builderId] must come from [startWorkoutRoute]. Locations should
  /// be ordered by ascending timestamp to mirror HealthKit’s expectations.
  Future<bool> insertWorkoutRouteData({
    required String builderId,
    required List<WorkoutRouteLocation> locations,
  }) async {
    return false;
  }

  /// Finalises the workout route and associates it with an existing workout.
  ///
  /// Provide the [builderId] from [startWorkoutRoute], the platform-specific
  /// [workoutUuid] (as returned from [writeWorkoutData] or another mechanism),
  /// and optional [metadata] that will be stored on the resulting route.
  ///
  /// Returns the created route’s UUID string.
  Future<String> finishWorkoutRoute({
    required String builderId,
    required String workoutUuid,
    Map<String, dynamic>? metadata,
  }) async {
    return '';
  }

  /// Discards any progress for the specified workout route builder.
  ///
  /// Returns `true` if the builder existed and was discarded successfully.
  Future<bool> discardWorkoutRoute(String builderId) async {
    return false;
  }
}
