import { useState, useRef, useEffect } from "react";

const COLORS = {
  bg: "#12161D",
  panel: "#1B212B",
  panelRaised: "#212836",
  border: "#2A3240",
  text: "#F5F7FA",
  textMuted: "#B4BCC9",
  amber: "#F2B705",
  amberDim: "#8A6B10",
  green: "#3FBE7A",
  yellow: "#F2B705",
  red: "#E5484D",
};

const MOCK_DB = {
  P0420: {
    meaning: "دبة الشكمان - كفاءة ضعيفة (البنك ١)",
    severity: "متوسط",
    causes: ["دبة الشكمان مفرغة", "انسداد في دبة الشكمان", "دبة الشكمان وسخانة"],
    action: "لازم تتغير دبة الشكمان كامل - افحصها عند مركز متخصص",
    symptoms: "زيادة استهلاك الوقود، رائحة عادم غريبة، ضعف بقوة الماكينة، لمبة الفحص مضيّة",
  },
  P0301: {
    meaning: "تفتفة من سلندر رقم ١",
    severity: "متوسط",
    causes: ["بواجي", "كويل", "عطل في البخاخ", "مشكلة داخلية بالماكينة", "أسلاك بواجي"],
    action: "توجه لأقرب مركز متخصص قريب - تجنب السواقة بسرعة عالية لين افحص",
    symptoms: "اهتزاز بالماكينة، تردد وقت الدعس، صوت تكتكة خفيف",
  },
  P0217: {
    meaning: "حرارة الماكينة مرتفعة جداً",
    severity: "خطير",
    causes: ["ماء الرديتر ناقص", "تسريب (تهريب) ماء الرديتر", "غطاء قربة ماء الرديتر خربان", "مراوح التبريد ما تشتغل (تلفة أو مشكلة كهرباء)"],
    action: "أوقف المركبة أو اسحبها بسطحة لأقرب مركز متخصص - لا تكمل القيادة، شيك ماء الرديتر بعد ما تبرد الماكينة",
    symptoms: "مؤشر الحرارة يوصل للمنطقة الحمراء، بخار يطلع من تحت الكبوت، رائحة حريق أو ماء مغلي",
  },
};

const BRANDS = ["تويوتا", "هيونداي", "كيا", "نيسان", "شفروليه", "جي إم سي", "فورد", "هوندا", "لكزس", "مرسيدس", "بي إم دبليو", "مازدا"];

const SEVERITY_STYLE = {
  بسيط: { color: COLORS.green, label: "بسيط" },
  متوسط: { color: COLORS.yellow, label: "متوسط" },
  خطير: { color: COLORS.red, label: "خطير" },
};

function sanitizeDtcInput(raw, prevValid) {
  let cleaned = raw.replace(/[^a-zA-Z0-9]/g, "");
  cleaned = cleaned.toUpperCase();
  cleaned = cleaned.slice(0, 5);
  if (cleaned.length > 0 && ["P", "B", "C", "U"].indexOf(cleaned[0]) === -1) {
    return prevValid;
  }
  return cleaned;
}

function OfflineScreen(props) {
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", textAlign: "center", gap: 16 }}>
      <div style={{ width: 60, height: 60, borderRadius: "50%", background: COLORS.panelRaised, border: "1px solid " + COLORS.border, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 26 }}>📶</div>
      <div style={{ color: COLORS.text, fontSize: 17, fontWeight: 700 }}>لا يوجد اتصال بالإنترنت</div>
      <div style={{ color: COLORS.textMuted, fontSize: 15, maxWidth: 240, lineHeight: 1.8 }}>تحتاج لاتصال بالإنترنت لاستخدام التطبيق. تأكد من الاتصال وحاول مرة أخرى.</div>
      <button onClick={props.onRetry} style={{ marginTop: 8, padding: "12px 28px", borderRadius: 12, border: "none", background: COLORS.amber, color: "#1A1300", fontWeight: 700, fontSize: 16, cursor: "pointer" }}>إعادة المحاولة</button>
    </div>
  );
}

function ConsentScreen(props) {
  const [checked, setChecked] = useState(false);
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "center" }}>
      <div style={{ textAlign: "center", marginBottom: 24 }}>
        <div style={{ width: 56, height: 56, margin: "0 auto 14px", borderRadius: 14, background: COLORS.panelRaised, border: "1px solid " + COLORS.border, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "'Courier New', monospace", color: COLORS.amber, fontSize: 22, fontWeight: 700, letterSpacing: 1 }}>P0</div>
        <div style={{ color: COLORS.text, fontSize: 24, fontWeight: 700 }}>أكواد الأعطال</div>
        <div style={{ color: COLORS.textMuted, fontSize: 17, marginTop: 4 }}>دليلك السريع لفهم أكواد أعطال السيارة</div>
      </div>
      <div style={{ background: COLORS.panelRaised, border: "1px solid " + COLORS.border, borderRadius: 14, padding: 16, color: COLORS.textMuted, fontSize: 17, lineHeight: 1.9, marginBottom: 20 }}>
        نجمع فقط: معرّف الجهاز، سجل عمليات البحث، وحالة الاشتراك — لتقديم الخدمة وتحسينها. لا نجمع اسمك أو موقعك.
      </div>
      <label style={{ display: "flex", alignItems: "flex-start", gap: 10, marginBottom: 16, cursor: "pointer" }}>
        <input type="checkbox" checked={checked} onChange={(e) => setChecked(e.target.checked)} style={{ marginTop: 3, accentColor: COLORS.amber, width: 18, height: 18, flexShrink: 0 }} />
        <span style={{ color: COLORS.textMuted, fontSize: 16, lineHeight: 1.7 }}>
          بالمتابعة، أنت توافق على <span style={{ color: COLORS.amber, textDecoration: "underline" }}>شروط الاستخدام</span> و<span style={{ color: COLORS.amber, textDecoration: "underline" }}> سياسة الخصوصية</span>
        </span>
      </label>
      <button disabled={!checked} onClick={props.onAgree} style={{ width: "100%", padding: "16px 0", borderRadius: 12, border: "none", background: checked ? COLORS.amber : COLORS.panelRaised, color: checked ? "#1A1300" : COLORS.textMuted, fontWeight: 700, fontSize: 19, cursor: checked ? "pointer" : "not-allowed" }}>موافق ومتابعة</button>
    </div>
  );
}

function SearchScreen(props) {
  const { code, onCodeChange, inputRef, brand, brandQuery, setBrandQuery, brandOpen, setBrandOpen, filteredBrands, setBrand, onSearch } = props;
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column" }}>
      <div style={{ textAlign: "center", margin: "16px 0 28px" }}>
        <div style={{ color: COLORS.text, fontSize: 22, fontWeight: 700 }}>ابحث عن كود العطل</div>
        <div style={{ color: COLORS.textMuted, fontSize: 16, marginTop: 4 }}>أدخل الرمز الذي ظهر على جهاز الفحص</div>
      </div>
      <div style={{ marginBottom: 14 }}>
        <div style={{ color: COLORS.textMuted, fontSize: 16, marginBottom: 8 }}>رمز العطل (DTC)</div>
        <div style={{ background: "#0B0E13", border: "1px solid " + (code ? COLORS.amberDim : COLORS.border), borderRadius: 12, padding: "16px 18px", boxShadow: code ? "0 0 0 1px " + COLORS.amberDim + ", inset 0 0 24px rgba(242,183,5,0.06)" : "none" }}>
          <input ref={inputRef} value={code} onChange={onCodeChange} placeholder="مثال: P0420" inputMode="text" autoCapitalize="characters" maxLength={5} className="dtc-code-input"
            style={{ width: "100%", background: "transparent", border: "none", outline: "none", color: COLORS.amber, fontFamily: "'Courier New', monospace", fontSize: 32, fontWeight: 700, letterSpacing: 6, textAlign: "center", direction: "ltr" }} />
          <style>{".dtc-code-input::placeholder { color: " + COLORS.textMuted + "; opacity: 0.55; font-weight: 500; letter-spacing: 2px; font-family: 'Segoe UI', Tahoma, Arial, sans-serif; }"}</style>
        </div>
        <div style={{ color: COLORS.textMuted, fontSize: 15, marginTop: 6, textAlign: "center" }}>يبدأ بـ P أو B أو C أو U فقط · بدون مسافات · بالإنجليزية</div>
      </div>
      <div style={{ marginBottom: 24, position: "relative" }}>
        <div style={{ color: COLORS.textMuted, fontSize: 16, marginBottom: 8 }}>نوع السيارة (اختياري)</div>
        <div onClick={() => setBrandOpen(!brandOpen)} style={{ background: COLORS.panelRaised, border: "1px solid " + COLORS.border, borderRadius: 12, padding: "12px 14px", display: "flex", justifyContent: "space-between", alignItems: "center", cursor: "pointer" }}>
          <span style={{ color: brand ? COLORS.text : COLORS.textMuted, fontSize: 17 }}>{brand || "اختر أو اكتب اسم السيارة"}</span>
          <span style={{ color: COLORS.textMuted, fontSize: 14 }}>{brandOpen ? "▲" : "▼"}</span>
        </div>
        {brandOpen && (
          <div style={{ position: "absolute", top: "100%", left: 0, right: 0, marginTop: 6, background: COLORS.panelRaised, border: "1px solid " + COLORS.border, borderRadius: 12, overflow: "hidden", zIndex: 10, maxHeight: 220, display: "flex", flexDirection: "column" }}>
            <input autoFocus value={brandQuery} onChange={(e) => setBrandQuery(e.target.value)} placeholder="اكتب لتصفية القائمة..." style={{ background: "#0B0E13", border: "none", outline: "none", padding: "10px 14px", color: COLORS.text, fontSize: 16 }} />
            <div style={{ overflowY: "auto" }}>
              {filteredBrands.map((b) => (
                <div key={b} onClick={() => { setBrand(b); setBrandOpen(false); setBrandQuery(""); }}
                  style={{ padding: "10px 14px", color: COLORS.text, fontSize: 17, cursor: "pointer", borderTop: "1px solid " + COLORS.border }}
                  onMouseEnter={(e) => (e.currentTarget.style.background = "#232B39")}
                  onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}>{b}</div>
              ))}
              {filteredBrands.length === 0 && <div style={{ padding: "10px 14px", color: COLORS.textMuted, fontSize: 15 }}>لا توجد نتائج</div>}
            </div>
          </div>
        )}
      </div>
      <div style={{ flex: 1 }} />
      <button disabled={code.length < 4} onClick={onSearch} style={{ width: "100%", padding: "15px 0", borderRadius: 12, border: "none", background: code.length >= 4 ? COLORS.amber : COLORS.panelRaised, color: code.length >= 4 ? "#1A1300" : COLORS.textMuted, fontWeight: 700, fontSize: 19, cursor: code.length >= 4 ? "pointer" : "not-allowed" }}>بحث</button>
      <div style={{ textAlign: "center", color: COLORS.textMuted, fontSize: 15, marginTop: 10 }}>جرّب: P0420 · P0301 · P0217 (أمثلة) · أو أي كود آخر لمشاهدة حالة "غير موجود"</div>
    </div>
  );
}

function AdScreen(props) {
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 14 }}>
      <div style={{ width: 64, height: 64, borderRadius: "50%", border: "3px solid " + COLORS.border, borderTopColor: COLORS.amber, animation: "spin 0.9s linear infinite" }} />
      <div style={{ color: COLORS.textMuted, fontSize: 13 }}>{props.label}</div>
      <div style={{ color: COLORS.textMuted, fontSize: 12 }}>{props.sub}</div>
      <style>{"@keyframes spin { to { transform: rotate(360deg); } }"}</style>
    </div>
  );
}

function DetailBlock(props) {
  return (
    <div style={{ background: COLORS.panelRaised, border: "1px solid " + COLORS.border, borderRadius: 12, padding: 14 }}>
      <div style={{ color: COLORS.amber, fontSize: 14, fontWeight: 700, marginBottom: 8 }}>{props.title}</div>
      {props.children}
    </div>
  );
}

function ResultsScreen(props) {
  const { code, result, detailUnlocked, watchingAd, onWatchAd, onSearchAgain, onShare } = props;
  const sev = SEVERITY_STYLE[result.severity];
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 18, gap: 10 }}>
        <button onClick={onSearchAgain} style={{ display: "flex", alignItems: "center", gap: 6, background: COLORS.panelRaised, border: "1px solid " + COLORS.amberDim, borderRadius: 10, color: COLORS.amber, fontSize: 14, fontWeight: 700, cursor: "pointer", padding: "10px 14px" }}>
          <span style={{ fontSize: 16 }}>←</span> بحث جديد
        </button>
        <button onClick={onShare} style={{ display: "flex", alignItems: "center", gap: 6, background: COLORS.panelRaised, border: "1px solid " + COLORS.border, borderRadius: 10, color: COLORS.text, fontSize: 14, fontWeight: 600, padding: "10px 14px", cursor: "pointer" }}>
          مشاركة <span style={{ fontSize: 16 }}>⤴</span>
        </button>
      </div>
      <div style={{ background: "#0B0E13", border: "1px solid " + COLORS.amberDim, borderRadius: 12, padding: "14px 18px", textAlign: "center", marginBottom: 16 }}>
        <div style={{ fontFamily: "'Courier New', monospace", fontSize: 28, fontWeight: 700, color: COLORS.amber, letterSpacing: 6, direction: "ltr" }}>{code}</div>
      </div>
      <div style={{ background: COLORS.panelRaised, border: "1px solid " + COLORS.border, borderRadius: 12, padding: 16, marginBottom: 14 }}>
        <div style={{ color: COLORS.text, fontSize: 17, lineHeight: 1.7, marginBottom: 12 }}>{result.meaning}</div>
        <div style={{ display: "inline-flex", alignItems: "center", gap: 6, background: sev.color + "22", border: "1px solid " + sev.color + "55", borderRadius: 20, padding: "5px 12px" }}>
          <span style={{ width: 8, height: 8, borderRadius: "50%", background: sev.color }} />
          <span style={{ color: sev.color, fontSize: 14, fontWeight: 700 }}>{sev.label}</span>
        </div>
      </div>
      {!detailUnlocked && (
        <button onClick={onWatchAd} disabled={watchingAd} style={{ width: "100%", padding: "13px 0", borderRadius: 12, border: "1px dashed " + COLORS.amberDim, background: "transparent", color: COLORS.amber, fontWeight: 600, fontSize: 15.5, cursor: watchingAd ? "default" : "pointer" }}>
          {watchingAd ? "جاري عرض الإعلان..." : "▶ شاهد إعلان قصير لعرض التفاصيل الكاملة"}
        </button>
      )}
      {detailUnlocked && (
        <div style={{ display: "flex", flexDirection: "column", gap: 12, marginTop: 4 }}>
          <DetailBlock title="الأسباب المحتملة">
            <ul style={{ margin: 0, paddingInlineStart: 18, color: COLORS.text, fontSize: 15.5, lineHeight: 2 }}>
              {result.causes.map((c, i) => <li key={i}>{c}</li>)}
            </ul>
          </DetailBlock>
          <DetailBlock title="ماذا تفعل"><div style={{ color: COLORS.text, fontSize: 15.5, lineHeight: 1.9 }}>{result.action}</div></DetailBlock>
          <DetailBlock title="علامات قد تلاحظها"><div style={{ color: COLORS.text, fontSize: 15.5, lineHeight: 1.9 }}>{result.symptoms}</div></DetailBlock>
        </div>
      )}
    </div>
  );
}

function NotFoundScreen(props) {
  const { code, onSearchAgain } = props;
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column" }}>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", textAlign: "center", gap: 14 }}>
        <div style={{ fontFamily: "'Courier New', monospace", fontSize: 22, color: COLORS.textMuted, letterSpacing: 4, direction: "ltr" }}>{code}</div>
        <div style={{ color: COLORS.text, fontSize: 17, fontWeight: 700 }}>لم نجد هذا الكود بعد</div>
        <div style={{ color: COLORS.textMuted, fontSize: 15, maxWidth: 240, lineHeight: 1.8 }}>نعمل على إضافة المزيد من الأكواد باستمرار.</div>
      </div>
      <button onClick={onSearchAgain} style={{ width: "100%", padding: "14px 0", borderRadius: 12, border: "none", background: COLORS.amber, color: "#1A1300", fontWeight: 700, fontSize: 17, cursor: "pointer" }}>بحث عن كود آخر</button>
    </div>
  );
}

export default function DtcAppPrototype() {
  const [screen, setScreen] = useState("consent");
  const [code, setCode] = useState("");
  const [brand, setBrand] = useState("");
  const [brandQuery, setBrandQuery] = useState("");
  const [brandOpen, setBrandOpen] = useState(false);
  const [result, setResult] = useState(null);
  const [detailUnlocked, setDetailUnlocked] = useState(false);
  const [watchingAd, setWatchingAd] = useState(false);
  const [notFoundReason, setNotFoundReason] = useState(false);
  const [isOnline, setIsOnline] = useState(true);
  const inputRef = useRef(null);

  useEffect(() => {
    const goOnline = () => setIsOnline(true);
    const goOffline = () => setIsOnline(false);
    window.addEventListener("online", goOnline);
    window.addEventListener("offline", goOffline);
    return () => {
      window.removeEventListener("online", goOnline);
      window.removeEventListener("offline", goOffline);
    };
  }, []);

  const filteredBrands = BRANDS.filter((b) => b.includes(brandQuery));

  function handleCodeChange(e) {
    setCode((prev) => sanitizeDtcInput(e.target.value, prev));
  }

  function runSearch() {
    if (!code || !isOnline) return;
    setScreen("loadingAd");
    setDetailUnlocked(false);
    setTimeout(() => {
      const found = MOCK_DB[code];
      if (found) {
        setResult(found);
        setNotFoundReason(false);
        setScreen("results");
      } else {
        setResult(null);
        setNotFoundReason(true);
        setScreen("results");
      }
    }, 1400);
  }

  function watchRewardedAd() {
    setWatchingAd(true);
    setTimeout(() => {
      setWatchingAd(false);
      setDetailUnlocked(true);
    }, 1600);
  }

  function goSearchAgain() {
    setCode("");
    setResult(null);
    setNotFoundReason(false);
    setDetailUnlocked(false);
    setScreen("search");
    setTimeout(() => inputRef.current && inputRef.current.focus(), 50);
  }

  function shareResult() {
    alert("مشاركة (محاكاة):\n\n" + code + " - " + (result ? result.meaning : "") + "\nالخطورة: " + (result ? result.severity : "") + "\n\nحمّل التطبيق: play.google.com/store/apps/details?id=com.example.dtc");
  }

  return (
    <div style={{ minHeight: "100vh", background: "radial-gradient(1200px 600px at 50% -10%, #1A2130 0%, " + COLORS.bg + " 55%)", display: "flex", alignItems: "center", justifyContent: "center", padding: "32px 16px", fontFamily: "'Segoe UI', Tahoma, Arial, sans-serif" }} dir="rtl">
      <div style={{ width: 380, minHeight: 720, background: COLORS.panel, borderRadius: 36, border: "1px solid " + COLORS.border, boxShadow: "0 40px 80px -20px rgba(0,0,0,0.6), 0 0 0 8px #0A0D12", overflow: "hidden", display: "flex", flexDirection: "column", position: "relative" }}>
        <div style={{ display: "flex", justifyContent: "center", paddingTop: 10 }}>
          <div style={{ width: 90, height: 20, background: "#0A0D12", borderRadius: 12 }} />
        </div>
        <div style={{ position: "absolute", top: 14, left: 14, zIndex: 20 }}>
          <button onClick={() => setIsOnline((v) => !v)} title="Demo only: toggle network state" style={{ fontSize: 12, padding: "4px 8px", borderRadius: 8, border: "1px solid " + COLORS.border, background: COLORS.panelRaised, color: COLORS.textMuted, cursor: "pointer" }}>
            {isOnline ? "🟢 عرض توضيحي" : "🔴 عرض توضيحي"}
          </button>
        </div>
        <div style={{ flex: 1, display: "flex", flexDirection: "column", padding: "20px 20px 28px" }}>
          {!isOnline ? (
            <OfflineScreen onRetry={() => setIsOnline(true)} />
          ) : (
            <>
              {screen === "consent" && <ConsentScreen onAgree={() => setScreen("search")} />}
              {screen === "search" && (
                <SearchScreen code={code} onCodeChange={handleCodeChange} inputRef={inputRef} brand={brand} brandQuery={brandQuery} setBrandQuery={setBrandQuery} brandOpen={brandOpen} setBrandOpen={setBrandOpen} filteredBrands={filteredBrands} setBrand={setBrand} onSearch={runSearch} />
              )}
              {screen === "loadingAd" && <AdScreen label="إعلان" sub="جاري تحميل النتيجة..." />}
              {screen === "results" && !notFoundReason && (
                <ResultsScreen code={code} result={result} detailUnlocked={detailUnlocked} watchingAd={watchingAd} onWatchAd={watchRewardedAd} onSearchAgain={goSearchAgain} onShare={shareResult} />
              )}
              {screen === "results" && notFoundReason && <NotFoundScreen code={code} onSearchAgain={goSearchAgain} />}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
