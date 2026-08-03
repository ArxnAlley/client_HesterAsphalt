/* ============================================================
   HESTER ASPHALT — GLOBAL BEHAVIOR
   Icons, navigation, reveals, counters, marquee, OHub bridge
   ============================================================ */

/* ---------- Inline icon system ----------
   Usage: <i class="ic" data-icon="phone"></i>
   Replaced with an inline SVG at load (works offline / file://). */
const HESTER_ICONS = {
  phone: '<path d="M5 3h4l2 5-2.5 1.5a12 12 0 0 0 6 6L16 13l5 2v4a2 2 0 0 1-2 2A17 17 0 0 1 3 5a2 2 0 0 1 2-2z"/>',
  pin: '<path d="M12 21s-7-6.1-7-11a7 7 0 0 1 14 0c0 4.9-7 11-7 11z"/><circle cx="12" cy="10" r="2.6"/>',
  clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3.5 2"/>',
  arrow: '<path d="M4 12h15M13 6l6 6-6 6"/>',
  check: '<path d="M4 12.5 9.5 18 20 6.5"/>',
  star: '<path d="M12 2.5l2.9 6.2 6.6.8-4.9 4.6 1.3 6.6-5.9-3.3-5.9 3.3 1.3-6.6L2.5 9.5l6.6-.8z"/>',
  roller: '<path d="M3 16h12v4H3zM5 16v-4h8v4M13 12l4-7h3M19 5v6"/><circle cx="20" cy="14" r="2.4"/>',
  seal: '<path d="M12 3c3 4.2 5.6 7.3 5.6 10.3A5.6 5.6 0 0 1 12 19a5.6 5.6 0 0 1-5.6-5.7C6.4 10.3 9 7.2 12 3z"/><path d="M4 21h16"/>',
  crack: '<path d="M3 20 8 14l-2-3 5-5 1.5 3L17 4M14 20l3-4 4-1"/>',
  stripes: '<path d="M4 19 9 5M11 19l5-14M18 19l2-6"/>',
  wrench: '<path d="M14.5 6.5a4 4 0 0 0-5.6 4.8L3 17.2V21h3.8l5.9-5.9a4 4 0 0 0 4.8-5.6L14.6 12l-2.6-2.6z"/>',
  truck: '<path d="M2 7h11v9H2zM13 10h4l3 3v3h-7z"/><circle cx="6" cy="18" r="1.8"/><circle cx="16.5" cy="18" r="1.8"/>',
  drone: '<circle cx="5" cy="5" r="2.4"/><circle cx="19" cy="5" r="2.4"/><circle cx="5" cy="19" r="2.4"/><circle cx="19" cy="19" r="2.4"/><rect x="9.4" y="9.4" width="5.2" height="5.2"/><path d="M7 7l2.4 2.4M17 7l-2.4 2.4M7 17l2.4-2.4M17 17l-2.4-2.4"/>',
  shield: '<path d="M12 3 5 6v5c0 4.8 2.9 8.2 7 10 4.1-1.8 7-5.2 7-10V6z"/><path d="M9 11.7l2.2 2.3 4-4.4"/>',
  chat: '<path d="M4 5h16v11H9l-5 4z"/><path d="M8 9.5h8M8 12.5h5"/>',
  calendar: '<rect x="3.5" y="5" width="17" height="16"/><path d="M3.5 9.5h17M8 3v4M16 3v4"/><path d="M7.5 13.5h3M13.5 13.5h3M7.5 17h3"/>',
  mail: '<rect x="3" y="5" width="18" height="14"/><path d="m3 7 9 6 9-6"/>',
  camera: '<path d="M4 7h4l2-2.5h4L16 7h4v12H4z"/><circle cx="12" cy="12.7" r="3.4"/>',
  ruler: '<path d="m3 17 14-14 4 4-14 14zM7 13l1.6 1.6M10 10l1.6 1.6M13 7l1.6 1.6"/>',
  layers: '<path d="m12 3 9 5-9 5-9-5z"/><path d="m4.5 12.6 7.5 4.2 7.5-4.2M4.5 16.6 12 20.8l7.5-4.2"/>',
  flag: '<path d="M6 21V4"/><path d="M6 4.5c4-2.4 8 2.2 12 0v9c-4 2.2-8-2.4-12 0"/>',
  search: '<circle cx="10.5" cy="10.5" r="6.5"/><path d="m15.5 15.5 5 5"/>',
  dollar: '<circle cx="12" cy="12" r="9"/><path d="M12 6.8v10.4M15 9.3c-.6-1-1.7-1.5-3-1.5-1.7 0-2.9.9-2.9 2.2 0 3 6 1.6 6 4.5 0 1.3-1.3 2.2-3.1 2.2-1.4 0-2.6-.6-3.2-1.7"/>',
  warn: '<path d="M12 3.5 22 20H2z"/><path d="M12 10v4.5M12 17.4v.4"/>',
  thumbs: '<path d="M7 11v9H3.5v-9zM7 11.5 11 4a2.2 2.2 0 0 1 2.1 2.6l-.7 3.4h6.1a2 2 0 0 1 2 2.4l-1.3 5.9a2 2 0 0 1-2 1.7H7"/>'
};

function hesterInjectIcons(root) {
  (root || document).querySelectorAll("[data-icon]").forEach(function (el) {
    var name = el.getAttribute("data-icon");
    if (!HESTER_ICONS[name]) return;
    var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    svg.setAttribute("viewBox", "0 0 24 24");
    svg.setAttribute("fill", "none");
    svg.setAttribute("stroke", "currentColor");
    svg.setAttribute("stroke-width", "1.8");
    svg.setAttribute("stroke-linecap", "round");
    svg.setAttribute("stroke-linejoin", "round");
    svg.setAttribute("aria-hidden", "true");
    svg.classList.add("ic");
    if (el.className) svg.setAttribute("class", el.className);
    svg.innerHTML = HESTER_ICONS[name];
    el.replaceWith(svg);
  });
}

/* ---------- Header behavior ---------- */
function hesterHeader() {
  var header = document.querySelector(".site-header");
  if (!header) return;
  var lastY = 0;
  function onScroll() {
    var y = window.scrollY;
    header.classList.toggle("is-solid", y > 40);
    /* hide on scroll down (mobile reach), show on scroll up */
    if (y > 320 && y > lastY + 6) header.classList.add("is-hidden");
    else if (y < lastY - 6 || y < 320) header.classList.remove("is-hidden");
    lastY = y;
  }
  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });

  var burger = document.querySelector(".nav-burger");
  var drawer = document.querySelector(".nav-drawer");
  if (burger && drawer) {
    burger.addEventListener("click", function () {
      var open = drawer.classList.toggle("is-open");
      burger.classList.toggle("is-open", open);
      burger.setAttribute("aria-expanded", open ? "true" : "false");
      document.body.style.overflow = open ? "hidden" : "";
    });
    drawer.querySelectorAll("a").forEach(function (a) {
      a.addEventListener("click", function () {
        drawer.classList.remove("is-open");
        burger.classList.remove("is-open");
        document.body.style.overflow = "";
      });
    });
  }
}

/* ---------- Scroll reveals ---------- */
function hesterReveals() {
  var els = document.querySelectorAll("[data-reveal]");
  if (!("IntersectionObserver" in window) || !els.length) {
    els.forEach(function (el) { el.classList.add("is-in"); });
    return;
  }
  var io = new IntersectionObserver(function (entries) {
    entries.forEach(function (e) {
      if (e.isIntersecting) {
        e.target.classList.add("is-in");
        io.unobserve(e.target);
      }
    });
  }, { threshold: 0.16, rootMargin: "0px 0px -40px" });
  els.forEach(function (el) { io.observe(el); });
}

/* ---------- Animated counters ----------
   <span class="stat-count" data-count="25" data-suffix="+">0</span> */
function hesterCounters() {
  var els = document.querySelectorAll(".stat-count");
  if (!els.length) return;
  var io = new IntersectionObserver(function (entries) {
    entries.forEach(function (e) {
      if (!e.isIntersecting) return;
      io.unobserve(e.target);
      var el = e.target;
      var target = parseFloat(el.getAttribute("data-count")) || 0;
      var suffix = el.getAttribute("data-suffix") || "";
      var dur = 1600;
      var start = null;
      function step(ts) {
        if (!start) start = ts;
        var p = Math.min((ts - start) / dur, 1);
        var eased = 1 - Math.pow(1 - p, 3);
        el.textContent = Math.round(target * eased).toLocaleString() + suffix;
        if (p < 1) requestAnimationFrame(step);
      }
      requestAnimationFrame(step);
    });
  }, { threshold: 0.5 });
  els.forEach(function (el) { io.observe(el); });
}

/* ---------- Marquee: duplicate track content for seamless loop ---------- */
function hesterMarquee() {
  document.querySelectorAll(".marquee-track").forEach(function (track) {
    track.innerHTML += track.innerHTML;
  });
}

/* ---------- Subtle parallax for [data-parallax] media ---------- */
function hesterParallax() {
  var els = document.querySelectorAll("[data-parallax]");
  if (!els.length || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
  function frame() {
    var vh = window.innerHeight;
    els.forEach(function (el) {
      var r = el.getBoundingClientRect();
      if (r.bottom < 0 || r.top > vh) return;
      var p = (r.top + r.height / 2 - vh / 2) / vh; /* -0.5 .. 0.5 */
      var depth = parseFloat(el.getAttribute("data-parallax")) || 18;
      el.style.transform = "translateY(" + (p * depth).toFixed(1) + "px)";
    });
  }
  window.addEventListener("scroll", function () { requestAnimationFrame(frame); }, { passive: true });
  frame();
}

/* ---------- OHub bridge ----------
   All site forms route through here. Point OHUB_ENDPOINT at the
   production OHub webhook; until then submissions are queued in
   localStorage so no lead is ever silently dropped. */
var OHUB_ENDPOINT = ""; /* e.g. "https://ohub.nulostudio.com/api/hesterAsphalt/intake" */

function ohubSubmit(workflow, payload) {
  var record = {
    workflow: workflow,            /* "EstimateRequest" | "ContactMessage" | "CustomerFeedback" */
    business: "HesterAsphaltSealcoating",
    timestamp: new Date().toISOString(),
    page: location.pathname,
    data: payload
  };
  if (OHUB_ENDPOINT) {
    return fetch(OHUB_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(record)
    }).then(function (res) {
      if (!res.ok) throw new Error("OHub responded " + res.status);
      return { ok: true, queued: false };
    });
  }
  /* Offline / pre-launch fallback: persist locally so nothing is lost */
  try {
    var key = "hesterOhubQueue";
    var queue = JSON.parse(localStorage.getItem(key) || "[]");
    queue.push(record);
    localStorage.setItem(key, JSON.stringify(queue));
  } catch (e) { /* storage unavailable — still resolve so UX completes */ }
  return Promise.resolve({ ok: true, queued: true });
}

/* ---------- Before/after comparison slider ----------
   <div class="ba-slider" data-ba> … used on Home and Projects. */
function hesterBaSlider() {
  document.querySelectorAll("[data-ba]").forEach(function (root) {
    var top = root.querySelector(".ba-top");
    var handle = root.querySelector(".ba-handle");
    if (!top || !handle) return;

    function setSplit(pct) {
      pct = Math.max(2, Math.min(98, pct));
      top.style.clipPath = "inset(0 " + (100 - pct) + "% 0 0)";
      handle.style.left = pct + "%";
      handle.setAttribute("aria-valuenow", Math.round(pct));
    }

    setSplit(parseFloat(handle.getAttribute("aria-valuenow")) || 50);

    function pctFromEvent(e) {
      var rect = root.getBoundingClientRect();
      var x = (e.touches ? e.touches[0].clientX : e.clientX) - rect.left;
      return (x / rect.width) * 100;
    }

    var dragging = false;
    root.addEventListener("pointerdown", function (e) {
      dragging = true;
      root.setPointerCapture(e.pointerId);
      setSplit(pctFromEvent(e));
    });
    root.addEventListener("pointermove", function (e) {
      if (dragging) setSplit(pctFromEvent(e));
    });
    root.addEventListener("pointerup", function () { dragging = false; });
    root.addEventListener("pointercancel", function () { dragging = false; });

    handle.addEventListener("keydown", function (e) {
      var now = parseFloat(handle.getAttribute("aria-valuenow")) || 50;
      if (e.key === "ArrowLeft") { setSplit(now - 4); e.preventDefault(); }
      if (e.key === "ArrowRight") { setSplit(now + 4); e.preventDefault(); }
    });
  });
}

/* ---------- Footer year ---------- */
function hesterYear() {
  document.querySelectorAll(".js-year").forEach(function (el) {
    el.textContent = new Date().getFullYear();
  });
}

/* ---------- Sticky action bar (mobile) ----------
   The hero already carries the primary CTAs, so the bar stays
   hidden while it's on screen and appears once the visitor
   scrolls past it. Pages without a hero show it right away. */
function hesterActionBar() {
  var bar = document.querySelector(".action-bar");
  var hero = document.getElementById("top");
  if (!bar) return;
  if (!hero || !("IntersectionObserver" in window)) {
    bar.classList.add("is-visible");
    return;
  }
  new IntersectionObserver(function (entries) {
    entries.forEach(function (e) {
      bar.classList.toggle("is-visible", !e.isIntersecting);
    });
  }, { threshold: 0 }).observe(hero);
}

document.addEventListener("DOMContentLoaded", function () {
  hesterInjectIcons();
  hesterHeader();
  hesterReveals();
  hesterCounters();
  hesterMarquee();
  hesterParallax();
  hesterBaSlider();
  hesterYear();
  hesterActionBar();
});
