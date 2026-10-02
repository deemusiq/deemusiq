/* ============================================================
   DeeMusiq site behaviour
   ============================================================ */
(function () {
  "use strict";

  /* ----------------------------------------------------------
     DOWNLOAD CONFIG — same-origin, proxied by the Cloudflare
     worker on /downloads/* (see cloudflare/worker.js). The real
     release URLs live ONLY in worker env vars, so clients can
     never see where builds are hosted. Leave a value empty ('')
     and that button will route users to the contact form to
     request early access.
     ---------------------------------------------------------- */
  var DOWNLOADS = {
    android: "/downloads/android",
    windows: "/downloads/windows",
    linux:   "/downloads/linux",
    macos:   "/downloads/macos"
  };
  var CONTACT_EMAIL = "deemusiq@protonmail.com";

  /* ---------- current year ---------- */
  var yr = document.getElementById("yr");
  if (yr) yr.textContent = new Date().getFullYear();

  /* ---------- nav: scrolled state + mobile menu ---------- */
  var nav = document.querySelector(".nav");
  var onScroll = function () {
    if (nav) nav.classList.toggle("scrolled", window.scrollY > 12);
  };
  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });

  var burger = document.querySelector(".nav__burger");
  var mobile = document.getElementById("mobileMenu");
  if (burger && mobile) {
    burger.addEventListener("click", function () {
      var open = nav.classList.toggle("open");
      burger.setAttribute("aria-expanded", open ? "true" : "false");
      mobile.hidden = !open;
    });
    mobile.querySelectorAll("a").forEach(function (a) {
      a.addEventListener("click", function () {
        nav.classList.remove("open");
        burger.setAttribute("aria-expanded", "false");
        mobile.hidden = true;
      });
    });
  }

  /* ---------- scroll reveal ---------- */
  var reveals = document.querySelectorAll(".reveal");
  if ("IntersectionObserver" in window && reveals.length) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) {
          e.target.classList.add("in");
          io.unobserve(e.target);
        }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -8% 0px" });
    reveals.forEach(function (el) { io.observe(el); });
  } else {
    reveals.forEach(function (el) { el.classList.add("in"); });
  }

  /* ---------- count-up stats ---------- */
  var counters = document.querySelectorAll(".stat b[data-count]");
  if ("IntersectionObserver" in window && counters.length) {
    var co = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (!e.isIntersecting) return;
        co.unobserve(e.target);
        var el = e.target, target = parseInt(el.dataset.count, 10), start = null;
        var step = function (ts) {
          if (!start) start = ts;
          var p = Math.min((ts - start) / 1000, 1);
          el.textContent = Math.floor(p * target).toString();
          if (p < 1) requestAnimationFrame(step); else el.textContent = target.toString();
        };
        requestAnimationFrame(step);
      });
    }, { threshold: 0.5 });
    counters.forEach(function (el) { co.observe(el); });
  }

  /* ---------- download buttons ---------- */
  document.querySelectorAll(".dl[data-platform]").forEach(function (a) {
    var p = a.getAttribute("data-platform");
    if (!p) return;
    var url = DOWNLOADS[p];
    if (url) {
      a.setAttribute("href", url);
      a.setAttribute("rel", "noopener");
    } else {
      a.addEventListener("click", function (ev) {
        ev.preventDefault();
        var note = document.getElementById("dlNote");
        if (note) {
          note.style.color = "var(--orange-2)";
          note.scrollIntoView({ behavior: "smooth", block: "center" });
          setTimeout(function () { note.style.color = ""; }, 4000);
        }
        var topic = document.getElementById("cf-topic");
        var msg = document.getElementById("cf-msg");
        if (topic) topic.value = "Listener / customer";
        if (msg) msg.value = "I'd like early access to the DeeMusiq app for " + p + ".";
        var contactEl = document.getElementById("contact");
        if (contactEl) contactEl.scrollIntoView({ behavior: "smooth" });
      });
    }
  });

  /* ---------- OS hint: highlight the matching download button ---------- */
  var ua = navigator.userAgent;
  var osHint = /android/i.test(ua)            ? "android"
             : /windows/i.test(ua)            ? "windows"
             : /macintosh|mac os x/i.test(ua) ? "macos"
             : /linux/i.test(ua)              ? "linux"
             : null;
  if (osHint) {
    var dlBtn = document.querySelector('.dl[data-platform="' + osHint + '"]');
    if (dlBtn) dlBtn.classList.add("dl--active");
  }

  /* ---------- download checksums ----------
     The worker serves a "<asset>.sha256" sidecar at the same-origin URL
     /downloads/<platform>.sha256 — display it next to each download button
     so visitors can verify their download (see security.html). textContent
     only; any failure hides the checksum line silently. */
  document.querySelectorAll(".dl-hash[data-platform]").forEach(function (el) {
    var p = el.getAttribute("data-platform");
    if (!p || !DOWNLOADS[p]) return;
    fetch(DOWNLOADS[p] + ".sha256")
      .then(function (res) {
        if (!res.ok) throw new Error("sidecar unavailable");
        return res.text();
      })
      .then(function (text) {
        var m = text.match(/\b([0-9a-fA-F]{64})\b/);
        if (!m) throw new Error("no digest in sidecar");
        var hex = m[1].toLowerCase();
        el.textContent = "SHA-256: " + hex.slice(0, 12) + "…" + hex.slice(-4);
        el.setAttribute("title", hex);
        el.hidden = false;
      })
      .catch(function () {
        // No sidecar published for this platform — degrade silently.
        el.hidden = true;
      });
  });

  /* ---------- service worker: register + update flow ---------- */
  if ("serviceWorker" in navigator) {
    var swReloading = false;
    // A new worker took control — reload once so the page and its assets
    // come from the same deploy. Guarded so it can never loop.
    navigator.serviceWorker.addEventListener("controllerchange", function () {
      if (swReloading) return;
      swReloading = true;
      window.location.reload();
    });
    navigator.serviceWorker.register("/sw.js").then(function (reg) {
      // A worker waiting from a previous visit is an update — activate it.
      if (reg.waiting) reg.waiting.postMessage({ type: "SKIP_WAITING" });
      reg.addEventListener("updatefound", function () {
        var nw = reg.installing;
        if (!nw) return;
        nw.addEventListener("statechange", function () {
          // "installed" with an existing controller = update, not first run.
          if (nw.state === "installed" && navigator.serviceWorker.controller) {
            nw.postMessage({ type: "SKIP_WAITING" });
          }
        });
      });
    }).catch(function () {
      /* offline or blocked — the site works fully without the SW */
    });
  }

  /* ---------- contact form → mailto ---------- */
  var form = document.getElementById("contactForm");
  if (form) {
    form.addEventListener("submit", function (ev) {
      ev.preventDefault();
      if (!form.reportValidity()) return;
      var els = form.elements;
      var nameField = els.namedItem("name");
      var emailField = els.namedItem("email");
      var topicField = els.namedItem("topic");
      var messageField = els.namedItem("message");
      if (!nameField || !emailField || !topicField || !messageField) return;
      var nameVal = (nameField.value || "").trim();
      var emailVal = (emailField.value || "").trim();
      var topicVal = topicField.value || "";
      var messageVal = (messageField.value || "").trim();
      var subject = "[DeeMusiq] " + topicVal + " — " + nameVal;
      var body =
        "Name: " + nameVal + "\n" +
        "Email: " + emailVal + "\n" +
        "I am a: " + topicVal + "\n\n" +
        messageVal + "\n";
      window.location.href =
        "mailto:" + CONTACT_EMAIL +
        "?subject=" + encodeURIComponent(subject) +
        "&body=" + encodeURIComponent(body);
    });
  }
})();
