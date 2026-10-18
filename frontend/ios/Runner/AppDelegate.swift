import AlarmKit
import AppIntents
import Flutter
import SwiftUI
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let alarmKitChannel = FlutterMethodChannel(
      name: "com.yuvrajpadhy.mytasks/alarm_kit",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    alarmKitChannel.setMethodCallHandler { call, result in
      IosAlarmKitBridge.handle(call, result: result)
    }
  }
}

private enum IosAlarmKitBridge {
  private static let snoozeQueueKey = "mytasks.alarmkit.snoozeEvents"

  static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "authorizationStatus":
      result(authorizationStatus())
    case "requestAuthorization":
      guard #available(iOS 26.0, *) else {
        result("unsupported")
        return
      }
      Task {
        do {
          let state = try await AlarmManager.shared.requestAuthorization()
          result(statusName(state))
        } catch {
          result(FlutterError(
            code: "ALARM_AUTHORIZATION_FAILED",
            message: error.localizedDescription,
            details: nil
          ))
        }
      }
    case "openAppSettings":
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
        result(false)
        return
      }
      UIApplication.shared.open(url) { opened in result(opened) }
    case "takePendingAlarmPayload":
      guard #available(iOS 26.0, *) else {
        result(nil)
        return
      }
      Task {
        do {
          result(try pendingAlarmPayload())
        } catch {
          result(FlutterError(code: "ALARM_READ_FAILED", message: error.localizedDescription, details: nil))
        }
      }
    case "getPendingSnoozes":
      result(pendingSnoozes())
    case "acknowledgeSnooze":
      guard let values = call.arguments as? [String: Any],
            let id = values["id"] as? String else {
        result(FlutterError(code: "INVALID_SNOOZE", message: "Snooze event ID is missing.", details: nil))
        return
      }
      acknowledgeSnooze(id: id)
      result(nil)
    case "scheduleAlarm":
      guard #available(iOS 26.0, *) else {
        result(FlutterError(code: "ALARM_UNAVAILABLE", message: "AlarmKit requires iOS 26 or later.", details: nil))
        return
      }
      guard let values = call.arguments as? [String: Any],
            let id = values["id"] as? Int,
            let triggerAtMillis = values["triggerAtMillis"] as? Int64,
            let title = values["title"] as? String,
            let body = values["body"] as? String,
            let payload = values["payload"] as? String else {
        result(FlutterError(code: "INVALID_ALARM", message: "Alarm fields are incomplete.", details: nil))
        return
      }
      Task {
        do {
          try await schedule(
            id: id,
            date: Date(timeIntervalSince1970: TimeInterval(triggerAtMillis) / 1000),
            title: title,
            body: body,
            payload: payload
          )
          result(nil)
        } catch {
          result(FlutterError(code: "ALARM_SCHEDULE_FAILED", message: error.localizedDescription, details: nil))
        }
      }
    case "cancelAlarm":
      guard #available(iOS 26.0, *) else {
        result(nil)
        return
      }
      guard let values = call.arguments as? [String: Any],
            let id = values["id"] as? Int else {
        result(FlutterError(code: "INVALID_ALARM", message: "Alarm ID is missing.", details: nil))
        return
      }
      do {
        try cancel(id: id)
        result(nil)
      } catch {
        result(FlutterError(code: "ALARM_CANCEL_FAILED", message: error.localizedDescription, details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func authorizationStatus() -> String {
    guard #available(iOS 26.0, *) else { return "unsupported" }
    return statusName(AlarmManager.shared.authorizationState)
  }

  @available(iOS 26.0, *)
  private static func statusName(_ state: AlarmManager.AuthorizationState) -> String {
    switch state {
    case .authorized: return "authorized"
    case .denied: return "notAllowed"
    case .notDetermined: return "notDetermined"
    @unknown default: return "unsupported"
    }
  }

  @available(iOS 26.0, *)
  private static func schedule(
    id: Int,
    date: Date,
    title: String,
    body: String,
    payload: String
  ) async throws {
    guard AlarmManager.shared.authorizationState == .authorized else {
      throw NSError(domain: "MyTasksAlarmKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "AlarmKit authorization is not granted."])
    }
    let alarmID = alarmUUID(for: id)
    if try AlarmManager.shared.alarms.contains(where: { $0.id == alarmID }) {
      try AlarmManager.shared.cancel(id: alarmID)
    }
    let attributes = makeAttributes(title: title, body: body, payload: payload)
    let configuration = AlarmManager.AlarmConfiguration(
      countdownDuration: nil,
      schedule: .fixed(date),
      attributes: attributes,
      appEntityIdentifier: nil,
      stopIntent: nil,
      secondaryIntent: SnoozeTaskAlarmIntent(
        alarmID: alarmID.uuidString,
        parentReminderID: id,
        payload: payload
      ),
      sound: .default
    )
    UserDefaults.standard.set(payload, forKey: payloadKey(for: alarmID))
    UserDefaults.standard.set(id, forKey: parentIDKey(for: alarmID))
    UserDefaults.standard.set(false, forKey: openedKey(for: alarmID))
    do {
      try await AlarmManager.shared.schedule(id: alarmID, configuration: configuration)
    } catch {
      UserDefaults.standard.removeObject(forKey: payloadKey(for: alarmID))
      UserDefaults.standard.removeObject(forKey: parentIDKey(for: alarmID))
      UserDefaults.standard.removeObject(forKey: openedKey(for: alarmID))
      throw error
    }
  }

  @available(iOS 26.0, *)
  fileprivate static func snooze(
    alarmID: UUID,
    parentReminderID: Int,
    payload: String
  ) async throws {
    let createdAt = Date()
    let scheduledAt = createdAt.addingTimeInterval(10 * 60)
    let snoozeID = UUID()
    let event: [String: Any] = [
      "id": snoozeID.uuidString,
      "parentAlarmId": parentReminderID,
      "triggerAtMillis": Int64(scheduledAt.timeIntervalSince1970 * 1000),
      "createdAtMillis": Int64(createdAt.timeIntervalSince1970 * 1000),
      "payload": payload,
    ]
    appendSnoozeEvent(event)
    do {
      let title = titleFor(payload: payload)
      let attributes = makeAttributes(title: title, body: "MyTasks reminder", payload: payload)
      let configuration = AlarmManager.AlarmConfiguration(
        countdownDuration: nil,
        schedule: .fixed(scheduledAt),
        attributes: attributes,
        appEntityIdentifier: nil,
        stopIntent: nil,
        secondaryIntent: SnoozeTaskAlarmIntent(
          alarmID: snoozeID.uuidString,
          parentReminderID: parentReminderID,
          payload: payload
        ),
        sound: .default
      )
      UserDefaults.standard.set(payload, forKey: payloadKey(for: snoozeID))
      UserDefaults.standard.set(parentReminderID, forKey: parentIDKey(for: snoozeID))
      UserDefaults.standard.set(false, forKey: openedKey(for: snoozeID))
      try await AlarmManager.shared.schedule(id: snoozeID, configuration: configuration)
      try? AlarmManager.shared.stop(id: alarmID)
    } catch {
      acknowledgeSnooze(id: snoozeID.uuidString)
      UserDefaults.standard.removeObject(forKey: payloadKey(for: snoozeID))
      UserDefaults.standard.removeObject(forKey: parentIDKey(for: snoozeID))
      UserDefaults.standard.removeObject(forKey: openedKey(for: snoozeID))
      throw error
    }
  }

  @available(iOS 26.0, *)
  private static func makeAttributes(
    title: String,
    body: String,
    payload: String
  ) -> AlarmAttributes<MyTasksAlarmMetadata> {
    let snooze = AlarmButton(text: "Snooze", textColor: .green, systemImageName: "repeat")
    let alert = AlarmPresentation.Alert(
      title: LocalizedStringResource(stringLiteral: title),
      secondaryButton: snooze,
      secondaryButtonBehavior: .custom
    )
    return AlarmAttributes(
      presentation: AlarmPresentation(alert: alert),
      metadata: MyTasksAlarmMetadata(body: body, payload: payload),
      tintColor: Color.green
    )
  }

  @available(iOS 26.0, *)
  private static func titleFor(payload: String) -> String {
    guard let data = payload.data(using: .utf8),
          let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let kind = object["contentKind"] as? String else {
      return "MyTasks reminder"
    }
    switch kind {
    case "assignTask": return "Plan today's work"
    case "logToday": return "Log today's progress"
    default: return "MyTasks reminder"
    }
  }

  @available(iOS 26.0, *)
  private static func cancel(id: Int) throws {
    let alarms = try AlarmManager.shared.alarms
    let matching = alarms.filter { alarm in
      alarm.id == alarmUUID(for: id) ||
        UserDefaults.standard.integer(forKey: parentIDKey(for: alarm.id)) == id
    }
    for alarm in matching {
      try AlarmManager.shared.cancel(id: alarm.id)
      UserDefaults.standard.removeObject(forKey: payloadKey(for: alarm.id))
      UserDefaults.standard.removeObject(forKey: parentIDKey(for: alarm.id))
      UserDefaults.standard.removeObject(forKey: openedKey(for: alarm.id))
    }
    UserDefaults.standard.removeObject(forKey: storageKey(for: id))
    removeSnoozeEvents(parentReminderID: id)
  }

  @available(iOS 26.0, *)
  private static func pendingAlarmPayload() throws -> String? {
    for alarm in try AlarmManager.shared.alarms where alarm.state == .alerting {
      let key = openedKey(for: alarm.id)
      guard !UserDefaults.standard.bool(forKey: key),
            let payload = UserDefaults.standard.string(forKey: payloadKey(for: alarm.id)) else {
        continue
      }
      UserDefaults.standard.set(true, forKey: key)
      return payload
    }
    return nil
  }

  private static func pendingSnoozes() -> [[String: Any]] {
    UserDefaults.standard.array(forKey: snoozeQueueKey) as? [[String: Any]] ?? []
  }

  private static func appendSnoozeEvent(_ event: [String: Any]) {
    var events = pendingSnoozes()
    events.removeAll { ($0["id"] as? String) == (event["id"] as? String) }
    events.append(event)
    UserDefaults.standard.set(events, forKey: snoozeQueueKey)
  }

  private static func acknowledgeSnooze(id: String) {
    let events = pendingSnoozes().filter { ($0["id"] as? String) != id }
    UserDefaults.standard.set(events, forKey: snoozeQueueKey)
  }

  private static func removeSnoozeEvents(parentReminderID: Int) {
    let events = pendingSnoozes().filter {
      ($0["parentAlarmId"] as? Int) != parentReminderID
    }
    UserDefaults.standard.set(events, forKey: snoozeQueueKey)
  }

  @available(iOS 26.0, *)
  private static func alarmUUID(for id: Int) -> UUID {
    let key = storageKey(for: id)
    if let rawID = UserDefaults.standard.string(forKey: key),
       let alarmID = UUID(uuidString: rawID) {
      return alarmID
    }
    let alarmID = UUID()
    UserDefaults.standard.set(alarmID.uuidString, forKey: key)
    return alarmID
  }

  private static func storageKey(for id: Int) -> String { "mytasks.alarmkit.\(id)" }
  private static func payloadKey(for id: UUID) -> String { "mytasks.alarmkit.payload.\(id.uuidString)" }
  private static func parentIDKey(for id: UUID) -> String { "mytasks.alarmkit.parent.\(id.uuidString)" }
  private static func openedKey(for id: UUID) -> String { "mytasks.alarmkit.opened.\(id.uuidString)" }
}

@available(iOS 26.0, *)
private struct MyTasksAlarmMetadata: AlarmMetadata {
  let body: String
  let payload: String
}

@available(iOS 26.0, *)
struct SnoozeTaskAlarmIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Snooze MyTasks reminder"

  @Parameter(title: "Alarm identifier") var alarmID: String
  @Parameter(title: "Reminder identifier") var parentReminderID: Int
  @Parameter(title: "Routing payload") var payload: String

  init() {}

  init(alarmID: String, parentReminderID: Int, payload: String) {
    self.alarmID = alarmID
    self.parentReminderID = parentReminderID
    self.payload = payload
  }

  func perform() async throws -> some IntentResult {
    guard let id = UUID(uuidString: alarmID) else {
      throw NSError(domain: "MyTasksAlarmKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid alarm identifier."])
    }
    try await IosAlarmKitBridge.snooze(
      alarmID: id,
      parentReminderID: parentReminderID,
      payload: payload
    )
    return .result()
  }
}
