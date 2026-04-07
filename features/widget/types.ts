export interface WidgetData {
  lunarDate: string;
  solarDate: string;
  goodHours: string[];
  quote: string;
  zodiacScore?: number;
  zodiacSummary?: string;
  sunrise?: string;
  sunset?: string;
}

export interface ZodiacDaily {
  branchIndex: number;
  animalName: string;
  score: number;
  summary: string;
}

export interface SunTimes {
  sunrise: string;
  sunset: string;
}

export interface ZodiacJSONRow {
  branchIndex: number;
  animalEn: string;
  animalVi: string;
  summariesEn: string[];
  summariesVi: string[];
}
