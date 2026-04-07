/**
 * Offline widget payload assembly (TypeScript mirror of Swift `WidgetService`).
 * Lunar strings here are placeholders unless you plug in a real lunar library.
 */

import type { SunTimes, WidgetData, ZodiacDaily, ZodiacJSONRow } from "./types";
import { dayIndexUtc, quoteForDate } from "./quoteData";
import zodiacRows from "./zodiacData.json";

const rows: ZodiacJSONRow[] = (zodiacRows as ZodiacJSONRow[]).slice().sort((a, b) => a.branchIndex - b.branchIndex);

/** Demo good hours (same shape as HoangDaoCalculator output). */
const MOCK_GOOD_HOURS = [
  "Tý (23h-1h)",
  "Dần (3h-5h)",
  "Thìn (7h-9h)",
  "Ngọ (11h-13h)",
  "Thân (15h-17h)",
  "Tuất (19h-21h)",
];

function pad2(n: number): string {
  return n < 10 ? `0${n}` : String(n);
}

function formatSolar(d: Date, languageCode: "en" | "vi"): string {
  const y = d.getFullYear();
  const m = d.getMonth() + 1;
  const day = d.getDate();
  return languageCode === "vi" ? `${day}/${m}/${y}` : `${m}/${day}/${y}`;
}

/** Placeholder lunar string — replace with your converter. */
function formatLunarPlaceholder(d: Date): string {
  return `·/${d.getMonth() + 1}/${d.getFullYear()}`;
}

export function yearBranchIndex(lunarYear: number): number {
  const x = (lunarYear - 4) % 60;
  return ((x % 12) + 12) % 12;
}

export function getZodiacForDate(date: Date, languageCode: "en" | "vi", lunarYearGuess?: number): ZodiacDaily {
  const lunarYear = lunarYearGuess ?? date.getFullYear();
  const branch = yearBranchIndex(lunarYear);
  const row = rows.find((r) => r.branchIndex === branch) ?? rows[0];
  const animalName = languageCode === "vi" ? row.animalVi : row.animalEn;
  const list = languageCode === "vi" ? row.summariesVi : row.summariesEn;
  const variant = dayIndexUtc(date);
  const summary = list[((variant % list.length) + list.length) % list.length];
  const score = 1 + ((variant % 5) + 5) % 5;
  return { branchIndex: branch, animalName, score, summary };
}

const RAD = Math.PI / 180;

export function getSunTimes(lat: number, lng: number, date: Date): SunTimes | null {
  const y = date.getFullYear();
  const m = date.getMonth() + 1;
  const day = date.getDate();
  const start = new Date(Date.UTC(y, 0, 1));
  const n =
    Math.floor((Date.UTC(y, m - 1, day) - start.getTime()) / 86400000) + 1;
  const decl = Math.asin(Math.sin(23.45 * RAD) * Math.sin((2 * Math.PI * (284 + n)) / 365));
  const latR = lat * RAD;
  const zenith = 90.833 * RAD;
  const cosH = (Math.cos(zenith) - Math.sin(latR) * Math.sin(decl)) / (Math.cos(latR) * Math.cos(decl));
  if (cosH < -1 || cosH > 1) return null;
  const h = Math.acos(cosH);
  const hHours = (h * 180) / Math.PI / 15;
  const b = (2 * Math.PI * (n - 81)) / 364;
  const eot = (9.87 * Math.sin(2 * b) - 7.53 * Math.cos(b) - 1.5 * Math.sin(b)) / 60;
  const solarNoon = 12 - lng / 15 - eot;
  const rise = solarNoon - hHours;
  const set = solarNoon + hHours;
  const fracToHHMM = (f: number) => {
    const x = ((f % 24) + 24) % 24;
    const h = Math.floor(x);
    const min = Math.round((x - h) * 60) % 60;
    return `${pad2(h)}:${pad2(min)}`;
  };
  return { sunrise: fracToHHMM(rise), sunset: fracToHHMM(set) };
}

export function getWidgetData(
  date: Date,
  opts?: { lat?: number; lng?: number; languageCode?: "en" | "vi"; lunarYear?: number }
): WidgetData {
  const languageCode = opts?.languageCode ?? "en";
  const quote = quoteForDate(date, languageCode);
  const z = getZodiacForDate(date, languageCode, opts?.lunarYear);
  let sunrise: string | undefined;
  let sunset: string | undefined;
  if (opts?.lat != null && opts?.lng != null) {
    const st = getSunTimes(opts.lat, opts.lng, date);
    if (st) {
      sunrise = st.sunrise;
      sunset = st.sunset;
    }
  }
  return {
    lunarDate: formatLunarPlaceholder(date),
    solarDate: formatSolar(date, languageCode),
    goodHours: MOCK_GOOD_HOURS,
    quote,
    zodiacScore: z.score,
    zodiacSummary: `${z.animalName} · ${z.summary}`,
    sunrise,
    sunset,
  };
}
