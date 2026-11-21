/*!
 * ✨🚀⚡ SLOPSTRAP v4.2.0 — Enterprise Vibecoded JavaScript Runtime™ ⚡🚀✨
 * ----------------------------------------------------------------------------
 * 💡 "It's not just a script tag — it's an autonomous paradigm shift in UI!"
 * 🎯 Built with 100% synthetic enthusiasm, zero human taste, and WAY too many
 *    explanatory comments so every developer feels empowered & delighted! 💜
 * 🛡️ MIT License | 🔥 Production-Ready | 🌟 Zero Dependencies | 🤖 AI-First
 * ----------------------------------------------------------------------------
 */

// 🌐 Step 1: Universal Module Definition (UMD) wrapper so Slopstrap works
//    SEAMLESSLY everywhere — browsers, CommonJS, and your 3AM hackathon app! 🚀
(function (global, factory) {
  // 🔍 Check if we are running inside a Node.js / CommonJS environment!
  if (typeof module === 'object' && typeof module.exports === 'object') {
    // 📦 Export the factory result to module.exports — clean & modular! ✨
    module.exports = factory();
  } else {
    // 🌍 Otherwise, attach Slopstrap directly onto the global window object! ⚡
    global.Slopstrap = factory();
  }
})(typeof window !== 'undefined' ? window : this, function () {
  // 🔒 Enable strict mode! (Best practice for rock-solid enterprise code! 💪)
  'use strict';

  // ==========================================================================
  // ⭐✨ SECTION 1: SYNTHETIC SOCIAL PROOF DATA (100% REAL FAKE PEOPLE!) ✨⭐
  // ==========================================================================
  // 💡 Note: Every single SaaS landing page generated since 2023 legally
  //    requires a glowing 5-star review from Dr. Sarah Chen and Marcus Vance! 🚀
  const TESTIMONIALS = [
    {
      // 👩‍💼 Persona #1: The legendary Dr. Sarah Chen — universal expert! 🌟
      name: 'Dr. Sarah Chen',
      initials: 'SC', // 🔤 Two-letter initials for our glowing circular avatar!
      role: 'VP of Product at NexusAI', // 🏢 Generic Series-B leadership title!
      avatarBg: 'linear-gradient(135deg, #6366f1, #a855f7)', // 💜 Mandatory purple gradient!
      borderClass: 'slop-border-l-purple', // 🎨 Thick 4px purple left border!
      quote:
        'This product or service radically accelerated our velocity while reducing pain points.'
    },
    {
      // 👨‍💼 Persona #2: Marcus Vance — visionary founder & disruptor! 🔥
      name: 'Marcus Vance',
      initials: 'MV', // 🔤 Crisp monogram initials!
      role: 'Founder & CEO at ApexFlow', // 🚀 Classic two-word startup name!
      avatarBg: 'linear-gradient(135deg, #ec4899, #8b5cf6)', // 🌸 Pink-to-violet glow!
      borderClass: 'slop-border-l-cyan', // 🩵 Thick 4px cyan left border!
      quote:
        'We integrated this solution into our existing stack and immediately unlocked 10x synergy across key stakeholders.'
    },
    {
      // 🚀 Persona #3: Elena Rostova — hyper-growth thought leader! 📈
      name: 'Elena Rostova',
      initials: 'ER', // 🔤 Avatar letters!
      role: 'Head of Growth at QuantumScale', // ⚛️ Quantum = instant credibility!
      avatarBg: 'linear-gradient(135deg, #06b6d4, #10b981)', // 💚 Cyber emerald-cyan!
      borderClass: 'slop-border-l-emerald', // 🟢 Thick 4px emerald left border!
      quote:
        'It’s not just an offering — it’s a game-changing paradigm shift that seamlessly empowers modern teams to do more with less.'
    },
    {
      // 🧠 Persona #4: Alex Rivera — Staff Vibe Architect! ⚡
      name: 'Alex Rivera',
      initials: 'AR', // 🔤 Monogram magic!
      role: 'VP of Operations at OrbitLabs', // 🪐 Space-themed startup!
      avatarBg: 'linear-gradient(135deg, #f59e0b, #ec4899)', // 🌅 Sunset hype gradient!
      borderClass: 'slop-border-l-amber', // 🟠 Thick 4px amber left border!
      quote:
        'Before adopting this platform, our workflows were fragmented. Now our outcomes are streamlined, scalable, and genuinely delightful.'
    },
    {
      // 💻 Persona #5: Liam Thorne — 10x CTO! 🛠️
      name: 'Liam Thorne',
      initials: 'LT', // 🔤 Clean initials!
      role: 'CTO at VeloSynapse', // ⚡ Speed + brain buzzword combo!
      avatarBg: 'linear-gradient(135deg, #3b82f6, #06b6d4)', // 💙 Electric blue!
      borderClass: 'slop-border-l-pink', // 🩷 Thick 4px pink left border!
      quote:
        'Implementation took minutes and delivered measurable ROI from day one. Easily the best decision our organization made this quarter.'
    },
    {
      // ☁️ Persona #6: Priya Patel — Director of Synergy! ✨
      name: 'Priya Patel',
      initials: 'PP', // 🔤 Double-P perfection!
      role: 'Director of Strategy at AetherCloud', // ☁️ Cloud-native synergy!
      avatarBg: 'linear-gradient(135deg, #8b5cf6, #06b6d4)', // 💜 Signature indigo-cyan!
      borderClass: 'slop-border-l-indigo', // 🟣 Thick 4px indigo left border!
      quote:
        'Finally, a next-generation tool built for teams that care about excellence, efficiency, and moving the needle at enterprise scale.'
    }
  ];

  // ==========================================================================
  // 🏢✨ SECTION 2: ICONIC STARTUP LOGO MARQUEE ARRAY (INSTANT CREDIBILITY!) ✨🏢
  // ==========================================================================
  // 💡 Pro tip: Slapping monochrome logos of billion-dollar companies onto your
  //    weekend side project instantly boosts perceived valuation by 1000%! 🚀
  const STARTUP_LOGOS = [
    {
      // 🤖 OpenAI — the mothership of purple gradients! ✨
      name: 'OpenAI',
      style: 'letter-spacing:-0.02em;font-weight:700',
      svg: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M22.2819 9.8211a5.9847 5.9847 0 0 0-.5157-4.9108 6.0462 6.0462 0 0 0-6.5098-2.9A6.0651 6.0651 0 0 0 4.9807 4.1818a5.9847 5.9847 0 0 0-3.9977 2.9 6.0462 6.0462 0 0 0 .7427 7.0966 5.98 5.98 0 0 0 .511 4.9107 6.051 6.051 0 0 0 6.5146 2.9001A5.9847 5.9847 0 0 0 13.2599 24a6.0557 6.0557 0 0 0 5.7718-4.2058 5.9894 5.9894 0 0 0 3.9977-2.9001 6.0557 6.0557 0 0 0-.7475-7.0729zm-9.022 12.6081a4.4755 4.4755 0 0 1-2.8764-1.0408l.1419-.0804 4.7783-2.7582a.7948.7948 0 0 0 .3927-.6813v-6.7369l2.02 1.1686a.071.071 0 0 1 .038.052v5.5826a4.504 4.504 0 0 1-4.4945 4.4944zm-9.6607-4.1254a4.4708 4.4708 0 0 1-.5346-3.0137l.142.0852 4.783 2.7582a.7712.7712 0 0 0 .7806 0l5.8428-3.3685v2.3324a.0804.0804 0 0 1-.0332.0615L9.74 19.9502a4.4992 4.4992 0 0 1-6.1408-1.6464zM2.3408 7.8956a4.485 4.485 0 0 1 2.3655-1.9728V11.6a.7664.7664 0 0 0 .3879.6765l5.8144 3.3543-2.0201 1.1685a.0757.0757 0 0 1-.071 0l-4.8303-2.7865A4.504 4.504 0 0 1 2.3408 7.872zm16.5963 3.8558L13.1038 8.364 15.1192 7.2a.0757.0757 0 0 1 .071 0l4.8303 2.7913a4.4944 4.4944 0 0 1-.6765 8.1042v-5.6772a.79.79 0 0 0-.407-.667zm2.0107-3.0231l-.142-.0852-4.7735-2.7818a.7759.7759 0 0 0-.7854 0L9.409 9.2297V6.8974a.0662.0662 0 0 1 .0284-.0615l4.8303-2.7866a4.4992 4.4992 0 0 1 6.6802 4.66zM8.3065 12.863l-2.02-1.1638a.0804.0804 0 0 1-.038-.0567V6.0742a4.4992 4.4992 0 0 1 7.3757-3.4537l-.142.0805L8.704 5.459a.7948.7948 0 0 0-.3927.6813zm1.0976-2.3654l2.602-1.4998 2.6069 1.4998v2.9994l-2.5974 1.4997-2.6067-1.4997Z"/></svg>'
    },
    {
      // 🧠 Anthropic — tasteful uppercase tracking! ✨
      name: 'ANTHROPIC',
      style: 'letter-spacing:0.14em;font-weight:700;font-size:0.95rem',
      svg: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M13.827 3.52h3.603L24 20h-3.603l-6.57-16.48zm-7.258 0h3.767L16.906 20h-3.674l-1.343-3.461H5.017l-1.344 3.46H0L6.57 3.522zm4.132 9.959L8.453 7.687 6.205 13.48H10.7z"/></svg>'
    },
    {
      // ▲ Vercel — the sacred triangle of dark-mode dashboards! 🔺
      name: 'Vercel',
      style: 'letter-spacing:-0.03em;font-weight:800',
      svg: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M24 22.525H0l12-21.05 12 21.05z"/></svg>'
    },
    {
      // 💳 Stripe — passive income aspirations! 💰
      name: 'stripe',
      style: 'letter-spacing:-0.04em;font-weight:800;font-size:1.3rem',
      svg: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M13.976 9.15c-2.172-.756-3.336-1.26-3.336-2.424 0-.852.792-1.38 2.136-1.38 2.028 0 4.092.816 5.616 1.848V2.85C16.924 2.118 15.028 1.5 12.78 1.5 8.1 1.5 5 3.972 5 7.62c0 3.732 2.112 5.172 5.4 6.36 2.304.828 3.072 1.344 3.072 2.376 0 .972-.9 1.608-2.52 1.608-2.16 0-4.608-1.02-6.528-2.31v5.352c2.04.912 4.416 1.488 6.9 1.488 4.872 0 8.04-2.376 8.04-6.228.024-3.792-2.22-5.148-5.396-6.144z"/></svg>'
    },
    {
      // 🧡 Y Combinator — instant San Francisco aura! 🚀
      name: 'Y Combinator',
      style: 'letter-spacing:-0.02em;font-weight:700',
      svg: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M0 24V0h24v24H0zM10.8 13.7V19h2.4v-5.3L18 5h-2.7l-3.3 6.3L8.7 5H6l4.8 8.7z"/></svg>'
    },
    {
      // ⚡ Supabase — lightning bolt energy! 🌩️
      name: 'supabase',
      style: 'letter-spacing:-0.03em;font-weight:700',
      svg: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M21.362 9.354H12V.396a.396.396 0 0 0-.716-.233L2.203 12.424l-.401.562a1.04 1.04 0 0 0 .836 1.638H12v8.958c0 .315.375.476.596.252l9.081-9.358.376-.411a1.04 1.04 0 0 0-.091-1.351z"/></svg>'
    },
    {
      // 🎨 Figma — ironic inclusion given zero designers were consulted! 😂
      name: 'Figma',
      style: 'letter-spacing:-0.02em;font-weight:700',
      svg: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M15.852 8.981h-4.588V0h4.588c2.476 0 4.49 2.014 4.49 4.49s-2.014 4.491-4.49 4.491zM12.735 7.51h3.117c1.665 0 3.019-1.355 3.019-3.019s-1.355-3.019-3.019-3.019h-3.117V7.51zm0 1.471H8.148c-2.476 0-4.49-2.014-4.49-4.49S5.672 0 8.148 0h4.588v8.981zm-4.587-7.51c-1.665 0-3.019 1.355-3.019 3.019s1.354 3.02 3.019 3.02h3.117V1.471H8.148zm4.587 15.019H8.148c-2.476 0-4.49-2.014-4.49-4.49s2.014-4.49 4.49-4.49h4.588v8.98zM8.148 8.981c-1.665 0-3.019 1.355-3.019 3.019s1.355 3.019 3.019 3.019h3.117V8.981H8.148zM8.172 24c-2.489 0-4.515-2.014-4.515-4.49s2.014-4.49 4.49-4.49h4.588v4.441c0 2.503-2.047 4.539-4.563 4.539zm-.024-7.51a3.023 3.023 0 0 0-3.019 3.019c0 1.665 1.365 3.019 3.044 3.019 1.705 0 3.093-1.376 3.093-3.068v-2.97H8.148z"/><circle cx="15.852" cy="13.471" r="3.75" fill="none" stroke="currentColor" stroke-width="1.5"/></svg>'
    },
    {
      // 📐 Linear — patient zero of the dark-mode purple glow aesthetic! 🌌
      name: 'Linear',
      style: 'letter-spacing:-0.02em;font-weight:700',
      svg: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M2.28 13.72a9.97 9.97 0 0 0 8 8l-8-8zm-.26-3.17L13.45 22a10.02 10.02 0 0 0 2.09-.65L2.65 8.46a10.02 10.02 0 0 0-.63 2.09zm1.58-4.14 14 14a10.08 10.08 0 0 0 1.56-1.26L4.86 4.85A10.08 10.08 0 0 0 3.6 6.41zM6.4 3.61 20.39 17.6A10 10 0 0 0 6.4 3.61z"/></svg>'
    },
    {
      // 🖼️ Framer — smooth animations & vibes! ✨
      name: 'Framer',
      style: 'letter-spacing:-0.02em;font-weight:700',
      svg: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M4 0h16v8h-8zM4 8h8l8 8H4zM4 16h8v8z"/></svg>'
    },
    {
      // 🐙 GitHub — where all vibecoded repos go to live forever! 🌟
      name: 'GitHub',
      style: 'letter-spacing:-0.02em;font-weight:700',
      svg: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></svg>'
    }
  ];

  // 🔗 Backwards-compatible alias — because enterprise stability matters! 🛡️
  const FAKE_LOGOS = STARTUP_LOGOS;

  // 🤖 Pre-trained buzzword templates for effortless SaaS copy generation! ✨
  const PROMPT_RESPONSES = [
    'Unlock next-generation synergy — it’s not just a {topic}, it’s your AI-powered co-pilot for seamlessly supercharging {topic} workflows by 10x ✨.',
    'Reimagine {topic} at hyper-scale. Built for modern teams who refuse to settle — empower your {topic} pipeline with zero-config intelligence and 99.99% operational vibes 🚀.',
    'Stop managing {topic}. Start orchestrating it. Our agentic {topic} engine seamlessly transforms raw chaos into delightful, enterprise-grade outcomes — effortlessly ⚡.',
    'The future of {topic} is already here — and it has a purple gradient. Join 50,000+ innovative teams (including Dr. Sarah Chen) transforming {topic} in milliseconds ✨.'
  ];

  // ==========================================================================
  // 📝✨ SECTION 2B: EXTRANEOUS BODY COPY THAT ALMOST MAKES SENSE ✨📝
  // ==========================================================================
  // 💡 Packed with 2025–2026 LLM writing tropes: negative parallelism, false
  //    reveals ("Here's the thing"), quiet adverbs, rule-of-three triads,
  //    "serves as a testament", and grand hollow tapestries! 🚀
  const INDUSTRY_COPY = {
    // ☁️ SaaS — Quietly orchestrating alignment across every surface! ✨
    saas: [
      'In today’s rapidly evolving operational landscape, modern teams don’t suffer from a shortage of tools — they suffer from a shortage of alignment. Here’s the thing: your stack isn’t just software; it’s the living tapestry through which velocity, clarity, and outcomes quietly converge. We don’t just manage workflows — we orchestrate a frictionless, end-to-end ecosystem where every stakeholder stays effortlessly synchronized across every surface where work happens.',
      'That’s not a dashboard upgrade. That’s a fundamental rethinking of how ambitious organizations navigate complexity at scale. From seamless cross-functional handoffs to deeply intuitive visibility, our holistic platform serves as a testament to one simple truth — when friction disappears, momentum compounds. No silos. No guesswork. Just measurable alignment, quietly delivered.'
    ],
    // 🤖 AI — Cognitive substrate relentlessly humming in the background! 🧠
    ai: [
      'We stand at a pivotal inflection point where intelligence is no longer something you visit in a tab — it’s something that quietly thinks alongside your entire organization. Here’s where it gets interesting: it’s not just about generating tokens; it’s about unlocking a deeply contextual substrate that reasons, adapts, and orchestrates across the full tapestry of enterprise knowledge. Every prompt becomes an intention, and every intention becomes autonomous momentum.',
      'The quiet truth? Legacy automation was never built to navigate ambiguity. Our agentic foundation bridges the gap between raw compute and human-centric clarity — seamlessly transforming fragmented signals into resilient, auditable, and remarkably scalable intelligence. It’s not just a model layer. It’s the cognitive fabric of what comes next, relentlessly humming in the background.'
    ],
    // 💳 FinTech — Living, breathing orchestration of trust & liquidity! 💰
    fintech: [
      'Money was never meant to wait for business hours — yet the global financial landscape still runs on rails designed for a slower century. Here’s the thing: modern liquidity isn’t just a balance sheet line item; it’s a living, breathing orchestration of trust, velocity, and regulatory elegance. Our frictionless infrastructure quietly reconciles complexity in real time, empowering forward-thinking institutions to move capital with precision, transparency, and zero hesitation.',
      'That’s not incremental optimization — that’s a holistic reimagining of how value traverses borders, ledgers, and ecosystems. By delving beneath legacy settlement bottlenecks, our platform serves as a resilient foundation where compliance, speed, and customer delight coexist seamlessly. No opaque fees. No brittle handoffs. Just programmable financial certainty, built for the cadence of tomorrow.'
    ],
    // 🦾 Robotics — Weaving intelligence into the tactile tapestry of warehouses! ⚙️
    robotics: [
      'For decades, software lived behind glass while the physical world waited patiently for its own inflection point. Here’s the thing: embodied autonomy isn’t just about actuators and torque — it’s about quietly weaving intelligence into the tactile tapestry of warehouses, factories, and real-world spaces. Our kinematic stack seamlessly bridges perception, dexterity, and spatial intuition so machines don’t merely execute instructions; they navigate reality with remarkable grace.',
      'The quiet truth? Rigid automation breaks the moment the floor plan changes. That’s why our adaptive fleet architecture stands at the intersection of rugged reliability, closed-loop learning, and human-first collaboration — turning unpredictable environments into orchestrated, repeatable throughput at scale. No cages. No brittle scripts. Just physical-world momentum, effortlessly deployed.'
    ],
    // 📱 Devices — An intimate, tactile extension of your nervous system! ✨
    devices: [
      'Technology is at its most transformative when it quietly recedes into the rhythm of daily life. Here’s where it gets interesting: hardware isn’t just anodized aluminum and silicon — it’s an intimate, tactile canvas where industrial craft, ambient intelligence, and human intention seamlessly converge. Every millimeter of our flagship architecture is thoughtfully sculpted to deliver a frictionless, deeply personal experience that feels less like a gadget and more like an extension of your nervous system.',
      'That’s not a spec bump — that’s a holistic redefinition of how form, endurance, and responsiveness coexist in the palm of your hand. From whisper-quiet thermal elegance to all-day battery serenity, every detail serves as a quiet testament to obsessive engineering without the noise. No clutter. No compromise. Just pure, effortless presence, wherever your journey unfolds.'
    ],
    // 🛡️ Defense — Asymmetric peace through orchestrated superiority! 🛰️
    defense: [
      'In an increasingly contested multipolar landscape, deterrence is no longer measured solely in legacy tonnage — it is measured in decision advantage at the tactical edge. Here’s the thing: sovereign resilience isn’t just about hardware; it’s about quietly orchestrating a unified, software-defined tapestry of sensors, autonomy, and mission-critical clarity across every domain. Our battle-tested ecosystem seamlessly compresses the kill chain from hours to milliseconds, empowering operators with decisive, resilient, and mission-ready certainty.',
      'The quiet truth? Yesterday’s procurement cycles cannot navigate tomorrow’s asymmetric threats. Standing at the intersection of autonomous precision, zero-trust interoperability, and ruggedized scalability, our platform serves as a foundational force multiplier for allied readiness — delivering frictionless situational awareness when every second carries strategic weight. No blind spots. No latency. Just asymmetric peace through orchestrated superiority.'
    ]
  };

  // 🌈 Rotating rainbow of 4px multicolored left-border CSS utility classes! 🎨
  const BORDER_CYCLE = [
    'slop-border-l-purple',  // 💜 Classic Indigo/Purple!
    'slop-border-l-cyan',    // 🩵 Electric Cyan!
    'slop-border-l-emerald', // 💚 Operational Emerald!
    'slop-border-l-amber',   // 🧡 Urgent Amber!
    'slop-border-l-pink',    // 🩷 Hype Magenta!
    'slop-border-l-indigo'   // 💙 Deep Tailwind Indigo!
  ];

  // 🎉 Curated array of unprompted heading emojis for maximum visual noise! 🔥
  const EMOJI_PREFIXES = ['⚡', '🚀', '✨', '🤖', '💎', '🔥', '🧠', '🌌'];

  // 🧠 Internal module state variables (clean, lightweight & zero-overhead! ⚡)
  let overdriveListener = null; // 🎇 Holds pointermove listener when Level 4 is active!
  let currentLevel = 3; // 🎚️ Default Slop Intensity Level = 3 (Peak Vibecoded! 🔥)
  const originalSnapshots = new WeakMap(); // 📸 Stores pre-slopify DOM snapshots so we can undo!

  // ==========================================================================
  // 🛠️✨ HELPER UTILITIES (DEFENSIVE, CLEAN & SECURITY-CONSCIOUS!) ✨🛠️
  // ==========================================================================

  /**
   * 🛡️ Safely escapes HTML entities to prevent XSS vulnerabilities!
   * @param {string} str - The raw string to sanitize! ✨
   * @returns {string} The safely escaped HTML string! ✅
   */
  function escapeHtml(str) {
    // 🔄 Convert input to string and replace special characters one by one!
    return String(str)
      .replace(/&/g, '&amp;')   // ➕ Escape ampersands!
      .replace(/</g, '&lt;')    // ⬅️ Escape opening angle brackets!
      .replace(/>/g, '&gt;')    // ➡️ Escape closing angle brackets!
      .replace(/"/g, '&quot;'); // 💬 Escape double quotes!
  }

  // ==========================================================================
  // 🔦✨ 1. CURSOR-FOLLOWING RADIAL SPOTLIGHT GLOW ON .slop-card ✨🔦
  // ==========================================================================
  // 💡 Note: Tracks the user's pointer coordinates and injects --mouse-x and
  //    --mouse-y CSS custom properties for that unmistakable Linear glow! 🌌
  function initSpotlights(root) {
    // 🎯 Fall back to document if no custom root element was passed!
    const scope = root || document;
    // 🔎 Query all cards and explicit spotlight-enabled elements!
    const cards = scope.querySelectorAll('.slop-card, [data-slop-spotlight]');
    // 🔁 Iterate through every matching card!
    cards.forEach(function (card) {
      // 🛑 Guard clause: prevent duplicate event listeners (performance! ⚡)
      if (card.dataset.slopSpotlightBound) return;
      // 🏷️ Mark this card as bound!
      card.dataset.slopSpotlightBound = 'true';
      // 🖱️ Attach pointermove listener to update spotlight coordinates live!
      card.addEventListener('pointermove', function (e) {
        // 📏 Measure the card's bounding box relative to the viewport!
        const rect = card.getBoundingClientRect();
        // ✨ Set X coordinate CSS variable!
        card.style.setProperty('--mouse-x', e.clientX - rect.left + 'px');
        // ✨ Set Y coordinate CSS variable!
        card.style.setProperty('--mouse-y', e.clientY - rect.top + 'px');
      });
    });
  }

  // ==========================================================================
  // 📈✨ 2. ANIMATED UNPROVABLE STAT COUNTERS ([data-slop-count]) ✨📈
  // ==========================================================================
  // 🚀 Yum yum yum — watch totally fabricated metrics smoothly count upward! 🎉

  /**
   * 🔢 Smoothly animates a numeric stat counter from 0 to its target value!
   * @param {HTMLElement} el - The element containing [data-slop-count]! 🎯
   */
  function animateCounter(el) {
    // 🛑 Prevent running the animation twice on the same element!
    if (el.dataset.slopCounted === 'true') return;
    // ✅ Mark element as already counted!
    el.dataset.slopCounted = 'true';

    // 📖 Read target value from attribute (or fall back to visible text)!
    const raw = el.getAttribute('data-slop-count') || el.textContent.trim();
    // 🧩 Parse optional prefix, numeric core, and optional suffix (e.g. "99.99%")!
    const match = raw.match(/^([^0-9.-]*)([0-9]+(?:\.[0-9]+)?)(.*)$/);
    // ⚠️ If no number was found, render raw text and exit gracefully!
    if (!match) {
      el.textContent = raw;
      return;
    }

    const prefix = match[1]; // 💲 e.g., "$" or "+"
    const target = parseFloat(match[2]); // 🎯 e.g., 99.99
    const suffix = match[3]; // 🏷️ e.g., "%", "M+", "K"
    const decimals = (match[2].split('.')[1] || '').length; // 🔬 Preserve decimal places!
    const duration = 1400; // ⏱️ 1.4 seconds of buttery 60fps animation!
    const start = performance.now(); // 🕒 Capture high-resolution start timestamp!

    // 🎞️ Recursive requestAnimationFrame loop for silky-smooth easing! ✨
    function tick(now) {
      // 📊 Compute normalized progress between 0 and 1!
      const progress = Math.min((now - start) / duration, 1);
      // 🎢 Apply cubic ease-out curve so numbers decelerate luxuriously!
      const eased = 1 - Math.pow(1 - progress, 3);
      // 🧮 Calculate current interpolated value!
      const val = (target * eased).toFixed(decimals);
      // ✍️ Update DOM text content!
      el.textContent = prefix + val + suffix;
      // 🔁 Keep ticking until progress reaches 100%!
      if (progress < 1) {
        requestAnimationFrame(tick);
      } else {
        // 🎯 Snap cleanly to the exact original string on final frame! ✅
        el.textContent = raw;
      }
    }

    // 🚀 Kick off the animation loop!
    requestAnimationFrame(tick);
  }

  /**
   * 👀 Observes all [data-slop-count] elements and triggers animation on scroll!
   * @param {ParentNode} [root] - Optional root container! 🎯
   */
  function initCounters(root) {
    const scope = root || document; // 🌍 Default to full document!
    const els = scope.querySelectorAll('[data-slop-count]'); // 🔎 Find all stat counters!
    if (!els.length) return; // 🛑 Nothing to animate — exit early!

    // ✨ Use IntersectionObserver when supported for zero scroll-jank performance!
    if ('IntersectionObserver' in window) {
      const obs = new IntersectionObserver(
        function (entries) {
          entries.forEach(function (entry) {
            // 👁️ Once the stat card enters the viewport, fire the animation! 🚀
            if (entry.isIntersecting) {
              animateCounter(entry.target);
              // 🧹 Stop observing after triggering once!
              obs.unobserve(entry.target);
            }
          });
        },
        { threshold: 0.25 } // 📐 Trigger when 25% visible!
      );
      // 👀 Register every counter with the observer!
      els.forEach(function (el) {
        obs.observe(el);
      });
    } else {
      // 🛡️ Graceful fallback for ancient browsers without IntersectionObserver!
      els.forEach(animateCounter);
    }
  }

  // ==========================================================================
  // ⭐✨ 3. AUTO-GENERATED FAKE TESTIMONIALS ([data-slop-testimonials]) ✨⭐
  // ==========================================================================
  // 💬 Summons Dr. Sarah Chen, Marcus Vance & friends with a single HTML tag! 🚀

  function renderTestimonials(container, count) {
    // 🔢 Clamp requested count cleanly between 1 and TESTIMONIALS.length!
    const total = Math.max(1, Math.min(parseInt(count, 10) || 3, TESTIMONIALS.length));
    // ✂️ Slice the requested subset of synthetic thought leaders!
    const items = TESTIMONIALS.slice(0, total);
    // 📐 Apply our mandatory symmetrical 3-column grid class!
    container.classList.add('slop-grid-3');
    // 🏗️ Build card markup for each glowing 5-star review! ✨
    container.innerHTML = items
      .map(function (t) {
        return (
          '<article class="slop-card slop-testimonial ' +
          t.borderClass +
          '">' +
          '<div>' +
          '<div class="slop-row-between slop-mb-1">' +
          '<span class="slop-stars" aria-label="5 out of 5 stars">★★★★★</span>' +
          '<span class="slop-badge slop-badge-emerald">✓ Verified Human</span>' +
          '</div>' +
          '<p class="slop-quote">“' +
          t.quote +
          '”</p>' +
          '</div>' +
          '<div class="slop-author">' +
          '<div class="slop-avatar" style="background:' +
          t.avatarBg +
          '">' +
          t.initials +
          '</div>' +
          '<div>' +
          '<div class="slop-author-name">' +
          t.name +
          ' <span class="slop-dot slop-dot-green" style="width:0.4rem;height:0.4rem" title="Online"></span></div>' +
          '<div class="slop-author-role">' +
          t.role +
          '</div>' +
          '</div>' +
          '</div>' +
          '</article>'
        );
      })
      .join('');
    // 🔦 Hydrate cursor-following spotlight glow on the newly created cards! ✨
    initSpotlights(container);
  }

  function initTestimonials(root) {
    const scope = root || document; // 🌍 Scope lookup!
    scope.querySelectorAll('[data-slop-testimonials]').forEach(function (el) {
      // 🛑 Skip if already hydrated!
      if (el.dataset.slopHydrated) return;
      el.dataset.slopHydrated = 'true'; // ✅ Mark hydrated!
      // 🚀 Render testimonials using attribute value (defaulting to 3)!
      renderTestimonials(el, el.getAttribute('data-slop-testimonials') || 3);
    });
  }

  // ==========================================================================
  // 🏢✨ 4. INFINITE STARTUP LOGO MARQUEE ([data-slop-marquee]) ✨🏢
  // ==========================================================================
  // 🚀 One tiny attribute = instant Silicon Valley social proof! 💎

  function renderMarquee(container) {
    // 🎨 Map every startup logo into a sleek monochrome inline-SVG pill!
    const logosHtml = STARTUP_LOGOS.map(function (l) {
      return (
        '<span class="slop-marquee-logo" style="' +
        (l.style || '') +
        '">' +
        l.svg +
        '<span>' +
        l.name +
        '</span></span>'
      );
    }).join('');
    // 🏷️ Ensure marquee wrapper class is applied!
    container.classList.add('slop-marquee');
    // 🔁 Duplicate logo sequence twice for a seamless infinite CSS translateX loop! ✨
    container.innerHTML = '<div class="slop-marquee-track">' + logosHtml + logosHtml + '</div>';
  }

  function initMarquees(root) {
    const scope = root || document; // 🌍 Default to document!
    scope.querySelectorAll('[data-slop-marquee]').forEach(function (el) {
      if (el.dataset.slopHydrated) return; // 🛑 Already rendered!
      el.dataset.slopHydrated = 'true'; // ✅ Mark rendered!
      renderMarquee(el); // 🚀 Inject the scrolling marquee!
    });
  }

  // ==========================================================================
  // 📋✨ 5. ONE-CLICK COPY-TO-CLIPBOARD BUTTONS ([data-slop-copy]) ✨📋
  // ==========================================================================
  // ⚡ Copies code snippets and celebrates with an unprompted sparkle burst! 🎇

  function initCopyButtons(root) {
    const scope = root || document; // 🌍 Scope lookup!
    scope.querySelectorAll('[data-slop-copy]').forEach(function (btn) {
      if (btn.dataset.slopCopyBound) return; // 🛑 Guard against double-binding!
      btn.dataset.slopCopyBound = 'true'; // ✅ Mark bound!
      // 🖱️ Listen for clicks on the Copy button!
      btn.addEventListener('click', function () {
        // 🎯 Read target CSS selector or literal copy string!
        const selector = btn.getAttribute('data-slop-copy');
        let text = selector;
        // 🔎 If value starts with '#', look up that DOM element's textContent!
        if (selector && selector.startsWith('#')) {
          const target = document.querySelector(selector);
          if (target) text = target.textContent.trim();
        }
        // 💾 Save original button label so we can restore it after 1.6s!
        const original = btn.innerHTML;
        // 🎉 Visual success callback!
        const done = function () {
          btn.innerHTML = '✓ Copied! ✨'; // ✅ Show celebratory copied state!
          const rect = btn.getBoundingClientRect(); // 📏 Locate button center!
          sparkleBurst(rect.left + rect.width / 2, rect.top + rect.height / 2, 7); // 🎇 Boom!
          // ⏱️ Restore original label after a brief pause!
          setTimeout(function () {
            btn.innerHTML = original;
          }, 1600);
        };
        // 📋 Use modern Clipboard API when available!
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(text).then(done).catch(done);
        } else {
          done(); // 🛡️ Fallback feedback!
        }
      });
    });
  }

  // ==========================================================================
  // 💳✨ 6. MONTHLY / ANNUAL BILLING TOGGLE ([data-slop-billing-toggle]) ✨💳
  // ==========================================================================
  // 💰 Effortlessly flips pricing tiers so founders feel like SaaS moguls! 🚀

  function initBillingToggles(root) {
    const scope = root || document; // 🌍 Default to document!
    scope.querySelectorAll('[data-slop-billing-toggle]').forEach(function (toggle) {
      if (toggle.dataset.slopBound) return; // 🛑 Skip if already wired!
      toggle.dataset.slopBound = 'true'; // ✅ Mark wired!
      // 🖱️ Handle switch click!
      toggle.addEventListener('click', function () {
        // 🔄 Toggle aria-checked boolean state!
        const yearly = toggle.getAttribute('aria-checked') !== 'true';
        toggle.setAttribute('aria-checked', yearly ? 'true' : 'false');
        // 💸 Update every price tag on the page!
        document.querySelectorAll('[data-price-monthly]').forEach(function (priceEl) {
          const val = yearly
            ? priceEl.getAttribute('data-price-yearly')
            : priceEl.getAttribute('data-price-monthly');
          const unit = yearly ? '/mo (billed yearly)' : '/mo';
          priceEl.innerHTML = val + ' <span>' + unit + '</span>';
        });
      });
    });
  }

  // ==========================================================================
  // 🤖✨ 7. STREAMING AI BUZZWORD PROMPT FORM ([data-slop-prompt-form]) ✨🤖
  // ==========================================================================
  // 💬 Simulates 42 tokens/sec streaming output packed with em-dashes! ⚡

  function initPromptForms(root) {
    const scope = root || document; // 🌍 Scope lookup!
    scope.querySelectorAll('[data-slop-prompt-form]').forEach(function (form) {
      if (form.dataset.slopBound) return; // 🛑 Prevent duplicate bindings!
      form.dataset.slopBound = 'true'; // ✅ Mark bound!
      const input = form.querySelector('input'); // ⌨️ Find the prompt text input!
      const outSelector = form.getAttribute('data-slop-prompt-form'); // 🎯 Target output selector!
      const outputEl = outSelector ? document.querySelector(outSelector) : null;

      // 📤 Intercept form submit to stream fake AI tokens!
      form.addEventListener('submit', function (e) {
        e.preventDefault(); // 🚫 Prevent full page reload!
        if (!outputEl) return; // 🛑 Exit if output element missing!
        // 💡 Grab user's topic or fall back to classic "to-do list app"!
        const topic = (input && input.value.trim()) || 'to-do list app';
        // 🎲 Pick a random buzzword template!
        const template = PROMPT_RESPONSES[Math.floor(Math.random() * PROMPT_RESPONSES.length)];
        // 🪄 Inject topic into template!
        const fullText = template.replace(/\{topic\}/g, topic);

        // 🧹 Clear previous output and launch celebratory sparkles!
        outputEl.textContent = '';
        let i = 0; // 🔢 Character cursor initialized to 0!
        const rect = form.getBoundingClientRect();
        sparkleBurst(rect.right - 60, rect.top + 20, 8); // 🎇 Sparkles!

        // ⏱️ Stream 3 characters every 18ms with a blinking block cursor '▌'!
        const streamer = setInterval(function () {
          i += 3;
          outputEl.textContent = fullText.slice(0, i) + (i < fullText.length ? '▌' : '');
          // 🏁 Clean up interval once streaming completes!
          if (i >= fullText.length) {
            clearInterval(streamer);
            outputEl.textContent = fullText;
          }
        }, 18);
      });
    });
  }

  // ==========================================================================
  // 🎇✨ 8. FLOATING EMOJI SPARKLE BURST ENGINE ✨🎇
  // ==========================================================================
  // 🌟 Spawns radial physics-inspired emoji particles on any interaction! 🚀

  function sparkleBurst(x, y, count) {
    // 🎨 High-vibe emoji particle palette!
    const emojis = ['✨', '⚡', '🚀', '💜', '🤖', '🌟'];
    // 🔢 Default to 10 particles if count isn't specified!
    const total = count || 10;
    // 🔁 Spawn each individual sparkle particle!
    for (let i = 0; i < total; i++) {
      const p = document.createElement('span'); // 🏷️ Create span element!
      p.className = 'slop-sparkle-particle'; // ✨ Apply flying animation class!
      p.textContent = emojis[i % emojis.length]; // 🎲 Cycle through emojis!
      // 📐 Compute evenly distributed angle with organic randomness!
      const angle = (Math.PI * 2 * i) / total + (Math.random() - 0.5) * 0.5;
      // 📏 Pick a fun burst radius between 35px and 100px!
      const dist = 35 + Math.random() * 65;
      // 📍 Anchor starting viewport coordinates!
      p.style.left = x + 'px';
      p.style.top = y + 'px';
      // 🚀 Pass trajectory vector to CSS custom properties!
      p.style.setProperty('--tx', Math.cos(angle) * dist + 'px');
      p.style.setProperty('--ty', Math.sin(angle) * dist - 20 + 'px');
      p.style.setProperty('--rot', Math.round((Math.random() - 0.5) * 240) + 'deg');
      // ➕ Mount particle into DOM!
      document.body.appendChild(p);
      // 🧹 Garbage-collect particle after animation finishes (920ms)!
      setTimeout(function () {
        p.remove();
      }, 920);
    }
  }

  // ==========================================================================
  // 🎚️✨ 9. SLOP INTENSITY LEVEL CONTROLLER (1 = SUBTLE YC, 4 = OVERDRIVE) ✨🎚️
  // ==========================================================================
  // 🔥 Dynamically dials global CSS glow, blur, ping speed & cursor trails! ⚡

  function setLevel(level) {
    // 🔒 Clamp requested level safely between 1 and 4!
    const clamped = Math.max(1, Math.min(4, parseInt(level, 10) || 3));
    currentLevel = clamped; // 💾 Persist state!
    // 🏷️ Apply data-slop-level attribute to root <html> element!
    document.documentElement.setAttribute('data-slop-level', String(clamped));

    // 🚨 LEVEL 4 OVERDRIVE: Activate real-time cursor sparkle emissions! 🎇
    if (clamped === 4 && !overdriveListener) {
      let lastSparkle = 0; // ⏱️ Throttle timestamp for 60fps goodness!
      overdriveListener = function (e) {
        const now = Date.now();
        if (now - lastSparkle > 110) {
          lastSparkle = now;
          sparkleBurst(e.clientX, e.clientY, 2); // ✨ Emit 2 trail sparkles!
        }
      };
      window.addEventListener('pointermove', overdriveListener);
    } else if (clamped < 4 && overdriveListener) {
      // 🛑 Cleanly remove overdrive listener when dialing back below Level 4!
      window.removeEventListener('pointermove', overdriveListener);
      overdriveListener = null;
    }

    // 📣 Broadcast custom event so external scripts can react! 🚀
    window.dispatchEvent(new CustomEvent('slopstrap:levelchange', { detail: { level: clamped } }));
    return clamped; // ✅ Return active level!
  }

  // ==========================================================================
  // 🪄✨ 10. AUTO-SLOPIFIER: Slopstrap.slopify() / unslopify() ✨🪄
  // ==========================================================================
  // 🚀 The crown jewel! Pass ANY boring human-made HTML block and watch it
  //    transform into a Series-B vibecoded AI SaaS landing page in 0.2ms! 💜

  function slopify(target, options) {
    // 🎯 Resolve CSS selector string or direct DOM element!
    const el = typeof target === 'string' ? document.querySelector(target) : target || document.body;
    if (!el) return; // 🛑 Abort safely if element wasn't found!

    // ⚙️ Merge user options with our high-slop defaults!
    const opts = Object.assign({ includeTestimonials: true, includeMarquee: true }, options);

    // 📸 Snapshot the original plain HTML once so unslopify() can restore it cleanly!
    if (!originalSnapshots.has(el)) {
      originalSnapshots.set(el, {
        html: el.innerHTML,
        className: el.className,
        style: el.getAttribute('style') || ''
      });
    }

    // 🌌 Step 1: Apply dark slate-950 scope, grid overlay, rounded corners & purple glow!
    el.classList.add('slop-scope', 'slop-grid-bg');
    el.style.padding = el.style.padding || '2rem';
    el.style.borderRadius = '1.25rem';
    el.style.border = '1px solid rgba(168,85,247,0.35)';
    el.style.boxShadow = '0 0 40px rgba(139,92,246,0.22)';

    // 🏷️ Step 2: Inject eyebrow pill + blinking green dot right above the first heading!
    const h1 = el.querySelector('h1, h2');
    if (h1 && !el.querySelector('.slop-auto-eyebrow')) {
      const eyebrow = document.createElement('div');
      eyebrow.className = 'slop-row slop-auto-eyebrow slop-mb-2';
      eyebrow.innerHTML =
        '<span class="slop-pill slop-pill-shimmer" style="margin:0">✨ v2.0 AI-Powered — Now Live →</span>' +
        '<span class="slop-status"><span class="slop-dot slop-dot-green"></span> All Systems Operational</span>';
      h1.parentNode.insertBefore(eyebrow, h1);

      // ✍️ Step 3: Turn the final word into the iconic ONE arbitrary italic serif word! ✨
      const words = h1.textContent.trim().split(/\s+/);
      if (words.length > 1) {
        const last = words.pop(); // ✂️ Pluck the last word!
        h1.innerHTML =
          '<span class="slop-text-gradient">' +
          escapeHtml(words.join(' ')) +
          '</span> <span class="slop-serif-emphasis slop-text-gradient-hot">' +
          escapeHtml(last) +
          '</span> ✨';
      } else {
        h1.classList.add('slop-text-gradient');
      }
      h1.classList.add('slop-h2');
    }

    // 🎉 Step 4: Prepend totally unrequested emojis to every subheading! ⚡
    el.querySelectorAll('h2, h3').forEach(function (heading, idx) {
      if (heading === h1) return; // 🛑 Skip primary headline!
      heading.classList.add('slop-h3');
      // 🔍 Only add an emoji if one isn't already present!
      if (!/[\u{1F300}-\u{1FAFF}✨⚡]/u.test(heading.textContent)) {
        heading.textContent = EMOJI_PREFIXES[idx % EMOJI_PREFIXES.length] + ' ' + heading.textContent;
      }
    });

    // 🌫️ Step 5: Wash out crisp readable paragraphs into murky slate-400!
    el.querySelectorAll('p').forEach(function (p) {
      p.classList.add('slop-muted');
    });

    // 🌈 Step 6: Wrap articles, sections & blockquotes in frosted cards with 4px left borders!
    el.querySelectorAll('article, section, blockquote').forEach(function (box, idx) {
      box.classList.add('slop-card', BORDER_CYCLE[idx % BORDER_CYCLE.length], 'slop-mt-2');
    });

    // 📦 Step 7: Convert plain bullet lists into the sacred 3-column icon card grid!
    el.querySelectorAll('ul').forEach(function (ul) {
      ul.style.listStyle = 'none'; // 🧹 Strip boring human bullet points!
      ul.style.padding = '0';
      ul.classList.add('slop-grid-3', 'slop-mt-2');
      Array.from(ul.children).forEach(function (li, idx) {
        // 🎨 Assign rotating multicolored 4px left border!
        li.classList.add('slop-card', BORDER_CYCLE[idx % BORDER_CYCLE.length]);
        if (!li.querySelector('.slop-icon-box')) {
          const text = li.innerHTML;
          // ✨ Inject tinted emoji squircle + pointless blinking green dot!
          li.innerHTML =
            '<div class="slop-row-between slop-mb-1">' +
            '<span class="slop-icon-box" style="margin:0;width:2.25rem;height:2.25rem;font-size:1.1rem">' +
            EMOJI_PREFIXES[idx % EMOJI_PREFIXES.length] +
            '</span>' +
            '<span class="slop-dot slop-dot-green"></span>' +
            '</div>' +
            '<div style="font-size:0.9rem;color:#e2e8f0">' +
            text +
            '</div>';
        }
      });
    });

    // 🚀 Step 8: Upgrade plain buttons into shiny gradient sparkle CTAs! ✨
    el.querySelectorAll('button, input[type="submit"], a.btn').forEach(function (btn, idx) {
      if (btn.classList.contains('slop-btn')) return; // 🛑 Skip existing slop buttons!
      btn.classList.add('slop-btn', idx === 0 ? 'slop-btn-primary' : 'slop-btn-ghost');
      // ✨ Add mandatory sparkle + arrow to the primary CTA!
      if (idx === 0 && !btn.textContent.includes('✨')) {
        btn.textContent = '✨ ' + btn.textContent.trim() + ' →';
      }
    });

    // 🏢 Step 9: Append an unsolicited startup logo marquee!
    if (opts.includeMarquee && !el.querySelector('[data-slop-auto-marquee]')) {
      const mWrap = document.createElement('div');
      mWrap.setAttribute('data-slop-auto-marquee', 'true');
      mWrap.className = 'slop-mt-3';
      mWrap.innerHTML =
        '<div style="text-align:center;font-size:0.75rem;letter-spacing:0.1em;text-transform:uppercase;color:#64748b;margin-bottom:0.25rem">Trusted by 50,000+ totally real innovative teams</div>' +
        '<div data-slop-marquee></div>';
      el.appendChild(mWrap);
    }

    // ⭐ Step 10: Append unsolicited 5-star Dr. Sarah Chen testimonials!
    if (opts.includeTestimonials && !el.querySelector('[data-slop-auto-proof]')) {
      const proof = document.createElement('div');
      proof.setAttribute('data-slop-auto-proof', 'true');
      proof.className = 'slop-mt-3';
      proof.innerHTML = '<div data-slop-testimonials="3"></div>';
      el.appendChild(proof);
    }

    // ⚡ Step 11: Hydrate spotlights, marquee, and testimonials inside the slopified container! ✅
    initSpotlights(el);
    initMarquees(el);
    initTestimonials(el);
  }

  /**
   * ↩️ Cleanly reverts a slopified container back to boring human-made HTML!
   * @param {string|HTMLElement} target - Selector or element to restore! 🎯
   */
  function unslopify(target) {
    const el = typeof target === 'string' ? document.querySelector(target) : target || document.body;
    // 🛑 Bail out safely if element wasn't previously snapshotted!
    if (!el || !originalSnapshots.has(el)) return;
    // 📸 Retrieve original snapshot from our WeakMap!
    const snap = originalSnapshots.get(el);
    el.innerHTML = snap.html; // 🔄 Restore inner HTML!
    el.className = snap.className; // 🔄 Restore CSS classes!
    if (snap.style) {
      el.setAttribute('style', snap.style); // 🎨 Restore inline styles!
    } else {
      el.removeAttribute('style'); // 🧹 Clear injected inline styles!
    }
  }

  // ==========================================================================
  // 📝✨ 10B. EXTRANEOUS BODY COPY GENERATOR ([data-slop-prose]) ✨📝
  // ==========================================================================
  // 🚀 Injects 1–2 paragraphs of industry-tailored LLM marketing fluff! ✨

  /**
   * ✍️ Renders industry-specific extraneous LLM body copy into a container!
   * @param {string|HTMLElement} target - Selector or element to populate! 🎯
   * @param {string} [industry='saas'] - saas | ai | fintech | robotics | devices | defense 🏭
   * @param {number} [paragraphs=2] - Number of paragraphs (1 or 2)! 📄
   */
  function renderProse(target, industry, paragraphs) {
    // 🎯 Resolve selector string or direct DOM node!
    const el = typeof target === 'string' ? document.querySelector(target) : target;
    if (!el) return; // 🛑 Exit gracefully if target doesn't exist!
    // 🔤 Normalize industry key (also supports British spelling "defence"! 🇬🇧)
    let key = String(industry || 'saas').trim().toLowerCase();
    if (key === 'defence') key = 'defense';
    const bank = INDUSTRY_COPY[key] || INDUSTRY_COPY.saas; // 🛡️ Safe fallback to SaaS!
    // 🔢 Clamp paragraph count cleanly to 1 or 2!
    const count = Math.max(1, Math.min(parseInt(paragraphs, 10) || 2, bank.length));
    // 🏷️ Ensure .slop-prose styling class is applied!
    el.classList.add('slop-prose');
    // ✍️ Render paragraphs cleanly! ✅
    el.innerHTML = bank
      .slice(0, count)
      .map(function (p) {
        return '<p>' + p + '</p>';
      })
      .join('');
  }

  /**
   * 🔎 Auto-hydrates all [data-slop-prose] elements on the page! ⚡
   */
  function initProseBlocks(root) {
    const scope = root || document; // 🌍 Default to full document!
    scope.querySelectorAll('[data-slop-prose]').forEach(function (el) {
      if (el.dataset.slopHydrated) return; // 🛑 Avoid duplicate hydration!
      el.dataset.slopHydrated = 'true'; // ✅ Mark hydrated!
      const industry = el.getAttribute('data-slop-prose') || 'saas';
      const count = el.getAttribute('data-slop-paragraphs') || 2;
      renderProse(el, industry, count); // 🚀 Inject the tapestries!
    });
  }

  // ==========================================================================
  // 🚀✨ 11. MAIN RUNTIME BOOTSTRAP & AUTO-INITIALIZATION ✨🚀
  // ==========================================================================

  /**
   * ⚡ Hydrates every Slopstrap component across the document!
   */
  function init() {
    initSpotlights(document);     // 🔦 Bind radial card spotlight trackers!
    initCounters(document);       // 📈 Observe & animate stat counters!
    initTestimonials(document);   // ⭐ Summon Dr. Sarah Chen & friends!
    initMarquees(document);       // 🏢 Hydrate startup logo marquees!
    initProseBlocks(document);    // 📝 Hydrate extraneous LLM body copy blocks!
    initCopyButtons(document);    // 📋 Wire up copy-to-clipboard buttons!
    initBillingToggles(document); // 💳 Wire up monthly/yearly billing switches!
    initPromptForms(document);    // 🤖 Wire up streaming AI prompt bars!

    // 🪄 If <body data-slop-auto> is present, slopify the ENTIRE page automatically! 🔥
    if (document.body.hasAttribute('data-slop-auto')) {
      slopify(document.body);
    }

    // 🎚️ Sync initial Slop Intensity Level if declared on <html>!
    const initialLevel = document.documentElement.getAttribute('data-slop-level');
    if (initialLevel) setLevel(initialLevel);
  }

  // 🚦 Auto-bootstrap as soon as the DOM is ready (zero config required! ✨)
  if (typeof document !== 'undefined') {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', function () {
        init(); // 🚀 Launch Slopstrap!
      });
    } else {
      init(); // ⚡ DOM already ready — launch immediately!
    }
  }

  // ==========================================================================
  // 📦✨ PUBLIC API SURFACE (CLEAN, MODULAR & ENTERPRISE-READY!) ✨📦
  // ==========================================================================
  return {
    version: '4.2.0',                   // 🏷️ Current semantic version!
    init: init,                         // 🚀 Manual re-initialization hook!
    setLevel: setLevel,                 // 🎚️ Dial slop intensity from 1 to 4!
    getLevel: function () {             // 🔍 Read current slop intensity!
      return currentLevel;
    },
    sparkleBurst: sparkleBurst,         // 🎇 Emit radial emoji sparkles!
    slopify: slopify,                   // 🪄 Transform plain HTML into pure slop!
    unslopify: unslopify,               // ↩️ Undo slopification cleanly!
    renderTestimonials: renderTestimonials, // ⭐ Programmatically inject reviews!
    renderMarquee: renderMarquee,       // 🏢 Programmatically inject logo wall!
    renderProse: renderProse,           // 📝 Programmatically inject LLM body copy!
    TESTIMONIALS: TESTIMONIALS,         // 💬 Raw synthetic testimonials array!
    FAKE_LOGOS: FAKE_LOGOS,             // 🏢 Raw startup SVG logos array!
    INDUSTRY_COPY: INDUSTRY_COPY        // 📝 Raw industry-specific LLM copy dictionary!
  };
});
// 🎉✨ End of slopstrap.js — Happy Vibe Coding! Ship 10x Faster! 🚀💜
