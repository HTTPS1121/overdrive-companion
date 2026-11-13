import 'demo_models.dart';

const kMoreGroups = <MoreGroup>[
  MoreGroup('רכב ואנרגיה', 'battery', [
    MoreGroupItem(
      title: 'בקרות הרכב',
      subtitle: 'מיזוג, מושבים, חלונות, תא מטען ותאורה',
    ),
    MoreGroupItem(
      title: 'מערכות סיוע ADAS',
      subtitle: 'ניטור שטח מת, תמרורים, נתיב',
    ),
    MoreGroupItem(title: 'טעינה', subtitle: 'מפגשי AC/DC, זמן, אנרגיה'),
    MoreGroupItem(title: 'בריאות סוללה', subtitle: 'היסטוריית אחוזי סוללה ומתח 12V'),
  ]),
  MoreGroup('הקלטה והגנה', 'shield', [
    MoreGroupItem(title: 'הקלטה בנסיעה', subtitle: 'רציפה, מצב נסיעה או Proximity Guard'),
    MoreGroupItem(title: 'חיישני קרבה', subtitle: 'שמונה חיישנים, טריגר צהוב או אדום'),
    MoreGroupItem(title: 'שמירה בחניה', subtitle: 'דריכה בנעילה ושחרור בפתיחה'),
    MoreGroupItem(title: 'הרתעה', subtitle: 'שקט / הבהוב / צופר ואורות'),
    MoreGroupItem(title: 'תצורת מצלמות', subtitle: 'שיוך מקורות, תיקון עין דג'),
    MoreGroupItem(title: 'אחסון', subtitle: 'רכב או USB, מדיניות שמירה'),
  ]),
  MoreGroup('דרך ותובנות', 'trip', [
    MoreGroupItem(title: 'RoadSense', subtitle: 'מפגעי דרך, בורות ופסי האטה'),
    MoreGroupItem(title: 'ניווט ומקומות', subtitle: 'חיפוש, בית, עבודה ומועדפים'),
    MoreGroupItem(title: 'גיבוי וייצוא', subtitle: 'גיבוי הגדרות ונסיעות'),
  ]),
  MoreGroup('אוטומציות ומסך הרכב', 'wave', [
    MoreGroupItem(title: 'כללים וטריגרים', subtitle: 'תנאים מקוננים AND/OR'),
    MoreGroupItem(title: 'קהילת אוטומציות', subtitle: 'עיון בהצעות לכללים'),
    MoreGroupItem(title: 'מיפוי מקשי חומרה', subtitle: 'לחיצה יחידה, כפולה או ארוכה'),
    MoreGroupItem(title: 'מסכים ומדיה', subtitle: 'שכבות מצלמה בשטח מת'),
  ]),
  MoreGroup('חיבור, פרטיות וניהול', 'link', [
    MoreGroupItem(title: 'גישה מרחוק', subtitle: 'LAN, Cloudflare Tunnel, Zrok'),
    MoreGroupItem(title: 'התראות', subtitle: 'PWA push וטלגרם'),
    MoreGroupItem(title: 'Home Assistant / MQTT', subtitle: 'גילוי טלמטריה, TLS'),
    MoreGroupItem(title: 'BYD Cloud', subtitle: 'מצב חיבור, אזור והגדרה'),
    MoreGroupItem(title: 'אבחון וכלי מפתחים', subtitle: 'CPU, זיכרון, מתח, רשת'),
    MoreGroupItem(title: 'הגדרות ופרטיות', subtitle: 'שפה, מראה, PIN מקומי'),
  ]),
];
