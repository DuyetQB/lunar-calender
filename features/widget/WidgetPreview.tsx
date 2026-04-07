/**
 * Sample UI: minimal / standard / advanced cards (React).
 * `pnpm add react` (or use in an existing Next/React app).
 */

import type { CSSProperties } from "react";
import type { WidgetData } from "./types";

const card: CSSProperties = {
  borderRadius: 16,
  padding: 14,
  background: "linear-gradient(135deg, #f4e8dc 0%, #e8d5c4 100%)",
  color: "#2c241c",
  maxWidth: 360,
  marginBottom: 12,
};

function Stars({ score }: { score: number }) {
  return (
    <span style={{ letterSpacing: 2 }}>
      {[0, 1, 2, 3, 4].map((i) => (
        <span key={i} style={{ opacity: i < score ? 1 : 0.35 }}>
          ★
        </span>
      ))}
    </span>
  );
}

/** Small widget */
export function WidgetMinimal({ data }: { data: WidgetData }) {
  return (
    <div style={card}>
      <div style={{ fontWeight: 600, fontSize: 13 }}>🌙 {data.lunarDate}</div>
      <div style={{ fontSize: 11, opacity: 0.7 }}>{data.solarDate}</div>
      <p style={{ fontSize: 12, marginTop: 8, lineHeight: 1.35 }}>{data.quote}</p>
    </div>
  );
}

/** Medium widget */
export function WidgetStandard({ data }: { data: WidgetData }) {
  const hours = data.goodHours.slice(0, 3).join(" · ");
  return (
    <div style={{ ...card, maxWidth: 400 }}>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 8 }}>
        <div>
          <div style={{ fontWeight: 600 }}>🌙 {data.lunarDate}</div>
          <div style={{ fontSize: 11, opacity: 0.7 }}>{data.solarDate}</div>
        </div>
        {data.zodiacScore != null && (
          <div style={{ textAlign: "right", fontSize: 11 }}>
            <Stars score={data.zodiacScore} />
            <div style={{ marginTop: 4, maxWidth: 140 }}>{data.zodiacSummary}</div>
          </div>
        )}
      </div>
      <p style={{ fontSize: 13, marginTop: 10 }}>{data.quote}</p>
      <div style={{ fontSize: 11, opacity: 0.75, marginTop: 6 }}>{hours}</div>
    </div>
  );
}

/** Large widget */
export function WidgetAdvanced({ data, goodHoursLabel = "Good hours" }: { data: WidgetData; goodHoursLabel?: string }) {
  return (
    <div style={{ ...card, maxWidth: 420 }}>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 12 }}>
        <div>
          <div style={{ fontWeight: 600 }}>Lunar {data.lunarDate}</div>
          <div style={{ fontSize: 12, opacity: 0.7 }}>Solar {data.solarDate}</div>
        </div>
        {data.zodiacScore != null && (
          <div style={{ textAlign: "right", fontSize: 12 }}>
            <Stars score={data.zodiacScore} />
            <div style={{ marginTop: 6, maxWidth: 200 }}>{data.zodiacSummary}</div>
          </div>
        )}
      </div>
      {data.sunrise && data.sunset && (
        <div style={{ fontSize: 12, opacity: 0.8, marginTop: 8 }}>
          🌅 {data.sunrise} ↑ · {data.sunset} ↓
        </div>
      )}
      <p style={{ fontSize: 13, marginTop: 10 }}>{data.quote}</p>
      <div style={{ fontWeight: 600, fontSize: 12, marginTop: 8 }}>{goodHoursLabel}</div>
      <div style={{ fontSize: 11, opacity: 0.8, lineHeight: 1.4 }}>{data.goodHours.join(" · ")}</div>
    </div>
  );
}
