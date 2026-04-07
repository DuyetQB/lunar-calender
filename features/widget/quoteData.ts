/**
 * Static quotes; deterministic index per calendar day (mirrors Swift DailyQuotes).
 */

const EN: string[] = [
  "Every sunrise is a new page.",
  "Small steps still move you forward.",
  "Calm mind, clear path.",
  "Kindness returns in unexpected ways.",
  "Today, choose patience over pride.",
  "Gratitude turns ordinary into enough.",
  "Listen more than you speak.",
  "Rest is part of the work.",
  "Let go of what you cannot steer.",
  "Light a candle instead of cursing darkness.",
  "Do the next right thing.",
  "Your pace is yours alone.",
  "Joy hides in simple moments.",
  "Courage is quiet persistence.",
  "Plant seeds; harvest comes later.",
  "Breathe before you answer.",
  "Hope is a habit, not a feeling.",
  "Forgive yourself, then try again.",
  "Walk outside; the sky still holds you.",
  "What you practice grows stronger.",
  "Honesty saves time.",
  "Be soft with yourself today.",
  "A clear desk helps a clear mind.",
  "Love is shown in small acts.",
  "Discipline is remembering what you want.",
  "Silence can be an answer.",
  "Start where you are.",
  "The moon waxes and wanes; so do we.",
  "Trust the slow work.",
  "End the day with peace if you can.",
];

const VI: string[] = [
  "Mỗi sớm mai là một trang giấy mới.",
  "Từng bước nhỏ vẫn đưa ta tới đích.",
  "Tâm an thì lối rộng.",
  "Lòng tốt sẽ quay về theo cách không ngờ.",
  "Hôm nay, chọn nhẫn nại hơn kiêu căng.",
  "Biết ơn biến thường thành đủ.",
  "Nghe nhiều hơn nói.",
  "Nghỉ ngơi cũng là một phần của việc.",
  "Buông những gì không thể điều khiển.",
  "Thắp nến thay vì chê bóng tối.",
  "Làm điều đúng tiếp theo.",
  "Nhịp của bạn là của riêng bạn.",
  "Niềm vui nấp trong khoảnh khắc giản dị.",
  "Can đảm là kiên trì yên lặng.",
  "Gieo hạt; mùa gặt sẽ tới sau.",
  "Hít thở trước khi trả lời.",
  "Hy vọng là thói quen, không chỉ là cảm xúc.",
  "Tha thứ cho mình, rồi thử lại.",
  "Ra ngoài trời; trời vẫn ôm bạn.",
  "Điều bạn luyện tập sẽ lớn mạnh.",
  "Thật thà tiết kiệm thời gian.",
  "Hôm nay hãy dịu với chính mình.",
  "Gọn gàng giúp tâm sáng.",
  "Yêu thương thể hiện trong việc nhỏ.",
  "Kỷ luật là nhớ mình muốn gì.",
  "Im lặng cũng có thể là lời đáp.",
  "Bắt đầu từ chỗ bạn đang đứng.",
  "Trăng khuyết tròn; lòng người cũng vậy.",
  "Tin vào công việc chậm mà chắc.",
  "Kết ngày bằng an yên nếu có thể.",
];

export function dayIndexUtc(date: Date): number {
  const y = date.getUTCFullYear();
  const start = Date.UTC(y, 0, 1);
  const t = date.getTime();
  const ord = Math.floor((t - start) / 86400000) + 1;
  return Math.abs(y * 31 + ord);
}

export function quoteForDate(date: Date, languageCode: "en" | "vi"): string {
  const list = languageCode === "vi" ? VI : EN;
  if (list.length === 0) return "";
  const raw = dayIndexUtc(date);
  const idx = ((raw % list.length) + list.length) % list.length;
  return list[idx];
}
