#!/usr/bin/env python3
"""Merge missing app_en.arb keys into app_he.arb with Hebrew strings."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EN = ROOT / "lib/l10n/app_en.arb"
HE = ROOT / "lib/l10n/app_he.arb"

TRANSLATIONS = {
    "settingsSectionRemote": "שירותים מרחוק",
    "settingsOpenRemoteServices": "שמע ברכב, GenAI, WireGuard",
    "settingsOpenCapabilityInventory": "מפת יכולות מול שרת Overdrive",
    "scheduleTabClimate": "מיזוג מראש",
    "scheduleTabCharging": "טעינה חכמה",
    "scheduleClimateTitle": "תזמוני מיזוג מהשרת",
    "scheduleClimateEmpty": "אין תזמונים פעילים — צור תזמון חדש למטה.",
    "scheduleClimateUnsupported": "לא נתמך: {reason}",
    "scheduleClimateListUnavailable": "רשימת תזמונים לא זמינה כעת ({reason}).\nלא מוצגת רשימה ריקה כהוכחה להיעדר תזמונים.",
    "scheduleInvalidResponse": "תגובת שרת לא תקינה",
    "scheduleDurationMinutes": "משך פעולה (דקות)",
    "scheduleCreate": "יצירה",
    "scheduleUpdate": "עדכון",
    "scheduleCancelEdit": "ביטול עריכה",
    "scheduleDeleteTooltip": "מחיקה",
    "scheduleChargingUnsupported": "לא נתמך: {reason}",
    "scheduleChargingStatus": "סטטוס",
    "scheduleChargingEnabled": "טעינה מתוזמנת פעילה",
    "scheduleChargingStart": "התחלה (HH:mm)",
    "scheduleChargingEnd": "סיום (HH:mm או full)",
    "scheduleChargingRepeat": "סוג חזרה",
    "scheduleRepeatDaily": "חוזר בכל יום",
    "scheduleRepeatOnce": "חד־פעמי",
    "scheduleChargingSaveWindow": "שמירת חלון",
    "scheduleChargingStartNow": "התחל טעינה עכשיו",
    "stateActive": "פעיל",
    "stateInactive": "כבוי",
    "extendedPowerSection": "הדלקה וכיבוי",
    "extendedPowerDrivingBlocked": "הרכב מדווח בנסיעה — הדלקה/כיבוי חסומים עד עצירה (שומר בשרת).",
    "extendedPowerOn": "הדלקת רכב",
    "extendedPowerOff": "כיבוי רכב",
    "extendedBatteryHeatSection": "חימום סוללה",
    "extendedBatteryHeatUnknown": "השרת לא דיווח מצב חימום סוללה — הפעלה לא זמינה.",
    "extendedBatteryPreheat": "חימום מקדים לסוללה",
    "extendedBatteryHeatOn": "פעיל לפי השרת",
    "extendedBatteryHeatOff": "כבוי לפי השרת",
    "extendedScreenshotsSection": "צילום מסכי הרכב",
    "extendedScreenshotsHint": "PNG נשמר במכשיר הרכב (מולטימדיה או לוח שעונים). לא מורד אוטומטית לטלפון.",
    "extendedScreenshotHu": "צילום מסך מולטימדיה",
    "extendedScreenshotCluster": "צילום מסך לוח שעונים",
    "extendedConfirmPowerOnTitle": "להדליק את הרכב?",
    "extendedConfirmPowerOffTitle": "לכבות את הרכב?",
    "extendedConfirmPowerOnBody": "נשלח רק כשהרכב חונה וללא תנועה (שומר SDK בשרת).",
    "extendedConfirmPowerOffBody": "הרכב ייכבה — ודא שאין נוסעים ברכב.",
    "extendedConfirmScreenshotTitle": "לאשר {label}?",
    "extendedConfirmScreenshotBody": "השרת יצלם במכשיר הרכב וישמור קובץ PNG.",
    "extendedConfirmCapture": "צילום",
    "comfortTabSeats": "מושבים",
    "comfortTabMediaSafety": "מדיה ובטיחות",
    "comfortMediaTitle": "עוצמת מדיה ובהירות מסך",
    "comfortSafetyTitle": "בטיחות",
    "comfortEsp": "יציבות (ESP)",
    "comfortItac": "אחיזה (ITAC)",
    "comfortUnavailable": "לא זמין",
    "comfortSlw": "התרעת מהירות (SLW)",
    "comfortCpd": "זיהוי ילד ברכב (CPD)",
    "seatHint": "רמות חימום ואוורור כפי שדווחו מהרכב",
    "seatDriver": "מושב נהג",
    "seatPassenger": "מושב נוסע",
    "seatHeat": "חימום",
    "seatVent": "אוורור",
    "seatVentUnsupported": "אוורור לא נתמך ברכב זה",
    "seatRecallMemory": "קריאת זיכרון",
    "seatSaveMemory": "שמירת מושב",
    "surveillanceHeatmapTitle": "מפת חום חניה",
    "surveillanceHeatmapLoad": "טען מפת חום",
    "surveillanceFilterLogTitle": "יומן מסנן",
    "surveillanceFilterLogLoad": "טען יומן",
    "surveillanceScreenDeterrentTitle": "הרתעת מסך",
    "surveillanceScreenDeterrentTest": "בדיקה ברכב",
    "surveillanceScreenDeterrentFetch": "תצוגת תמונה",
    "remoteCommunicateTitle": "תקשורת לתא הנוסעים",
    "remoteGenAiTitle": "עוזר GenAI",
    "remoteWireGuardTitle": "מנהרת WireGuard",
    "communicateAudioReady": "קול מוכן",
    "communicateMessagesReady": "הודעות מוכנות",
    "communicateListenerReady": "האזנה מוכנה",
    "communicateSendMessage": "שליחת הודעה",
    "communicateMessageHint": "טקסט שיוצג ברכב",
    "communicateTestSpeaker": "בדיקת רמקול",
    "communicateEmergencyStop": "עצירת חירום",
    "communicateLoadStatus": "רענון מצב",
    "genAiLoadStatus": "רענון מצב",
    "genAiSendChat": "שליחה",
    "genAiChatHint": "שאל את העוזר ברכב",
    "genAiInsightsOpen": "לוח תובנות",
    "wireGuardLoadStatus": "רענון מצב",
    "wireGuardExposeOn": "חשיפת לוח",
    "wireGuardExposeOff": "הסתרת לוח",
    "inventoryTitle": "מפת יכולות שרת",
    "inventoryImplemented": "באפליקציה",
    "inventoryPartial": "חלקי",
    "inventoryNotInApp": "HTTP בלבד / ללא מסך",
    "errorFreshnessUnknown": "מקור זמן לא ידוע",
    "errorFreshnessClockSkew": "שעון הרכב מקדים את המכשיר",
    "errorConnectionNotConfigured": "חיבור לשרת לא הוגדר",
    "errorDeviceIdBeforeLogin": "טען מזהה מכשיר מהמנהרה לפני ההתחברות",
    "errorConfigureTunnel": "הגדר כתובת מנהרה ואסימון מכשיר",
    "actionScheduleClimate": "תזמון מיזוג",
    "actionScheduleCharging": "תזמון טעינה",
    "actionStartCharging": "התחלת טעינה",
    "actionSeat": "מושב",
    "actionMedia": "מדיה",
    "actionAdas": "ADAS",
    "actionCpd": "CPD",
    "actionBatteryHeat": "חימום סוללה",
    "actionChargeCap": "מגבלת טעינה",
    "commonSuccess": "הצלחה",
    "commonError": "שגיאה",
    "remoteServicesTitle": "שירותים מרחוק",
    "heatmapQuadrantSummary": "פינה {name}: {active} בלוקים פעילים",
    "filterLogEmpty": "אין רשומות ביומן",
    "genAiReplyTitle": "תשובה",
    "wireGuardConfigured": "מוגדר",
    "wireGuardRunning": "פועל",
    "wireGuardNotConfigured": "לא מוגדר",
    "communicateCarState": "מצב רכב",
    "rateLimitError": "יותר מדי ניסיונות התחברות. המתן דקה ונסה שוב.",
    "authHtmlRejected": "השרת החזיר דף HTML במקום JSON — בדוק את כתובת המנהרה.",
    "remoteServicesTitle": "שירותים מרחוק",
    "drivingInMotion": "בנסיעה",
    "drivingParked": "בחנייה",
    "seatLevelOff": "כבוי",
    "seatLevelLow": "נמוך",
    "seatLevelHigh": "גבוה",
    "celsiusDegrees": "{temp} מעלות צלזיוס",
    "scheduleUnknownTime": "שעה לא ידועה",
    "scheduleNewTitle": "תזמון חדש",
    "scheduleEditTitle": "עריכת תזמון",
    "scheduleMinutesShort": "{minutes} דק׳",
}


def main():
    en = json.loads(EN.read_text(encoding="utf-8"))
    he = json.loads(HE.read_text(encoding="utf-8"))
    for k, v in en.items():
        if k.startswith("@"):
            meta = k[1:]
            if meta not in he and meta in en:
                he[k] = en[k]
            continue
        if k not in he:
            he[k] = TRANSLATIONS.get(k, en[k] if isinstance(en[k], str) else he.get(k, k))
    # preserve locale
    he["@@locale"] = "he"
    HE.write_text(json.dumps(he, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    missing = [k for k in en if not k.startswith("@") and k not in he]
    print(f"Wrote {HE}; locale keys: {len([k for k in he if not k.startswith('@')])}")


if __name__ == "__main__":
    main()
