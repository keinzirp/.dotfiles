// ==UserScript==
// @name         Kagi Proofread: copy full report
// @namespace    https://github.com/keinzirp/dotfiles
// @version      1.3.0
// @description  Copy complete Kagi Proofread results as Markdown.
// @match        https://translate.kagi.com/proofread*
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_setClipboard
// @run-at       document-idle
// ==/UserScript==

(() => {
  'use strict';

  const ID = 'kpe-copy-report';
  const SETTINGS_ID = 'kpe-settings';
  const STORAGE_KEY = 'kagi-proofread-export-sections';
  const SECTIONS = [
    ['original', 'Original text'],
    ['corrected', 'Corrected text'],
    ['corrections', 'Corrections'],
    ['style', 'Style'],
    ['repetition', 'Repetition'],
    ['statistics', 'Statistics'],
  ];
  const defaults = Object.fromEntries(SECTIONS.map(([key]) => [key, true]));
  let settings = { ...defaults, ...GM_getValue(STORAGE_KEY, {}) };
  let scheduled = false;

  const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
  const text = (element) => element?.innerText?.replace(/\u00a0/g, ' ').trim() || '';

  function sourceText() {
    return text(document.querySelector('.cm-content[aria-label="Text to translate"]'));
  }

  function correctedText() {
    const diff = document.querySelector('[aria-label="Text diff with corrections"]');
    if (!diff) return '';
    const copy = diff.cloneNode(true);
    copy.querySelectorAll('del, .sr-only').forEach((element) => element.remove());
    return text(copy);
  }

  function correctionsReport() {
    const explanations = [...document.querySelectorAll('[aria-label^="Addition:"]')]
      .map((element) => element.getAttribute('aria-label').match(/^Addition:\s*(.*?)\.\s*Correction:\s*(.+)$/))
      .filter(Boolean)
      .map(([, addition, explanation]) => ({ addition: addition.trim(), explanation }));

    return [...document.querySelectorAll('#corrections-panel [data-correction-id]')].map((button) => {
      const change = button.getAttribute('aria-label').replace(/^Correction:\s*/, '');
      const [from, to] = change.split(/\s+to\s+/, 2);
      const card = button.closest('[role="group"]');
      const categories = card ? [...card.querySelectorAll('[aria-label^="Toggle all "]')]
        .map((tag) => tag.getAttribute('aria-label').match(/^Toggle all (.+) corrections$/)?.[1])
        .filter(Boolean) : [];
      const severity = card && [...card.querySelectorAll('span')]
        .map(text).find((value) => /^(High|Medium|Low)$/.test(value));
      const explanation = explanations.find(({ addition }) => addition && to.includes(addition))?.explanation;
      return [
        `- ${from} -> ${to}`,
        categories.length && `  - Categories: ${categories.join(', ')}`,
        severity && `  - Severity: ${severity}`,
        explanation && `  - Explanation: ${explanation}`,
      ].filter(Boolean).join('\n');
    }).join('\n');
  }

  async function tabContent(name) {
    const tab = document.getElementById(`${name}-tab`);
    const panel = document.getElementById(`${name}-panel`);
    if (!tab || !panel) return '';
    tab.click();
    await sleep(100);
    return text(panel);
  }

  function section(title, value) {
    return `## ${title}\n\n${value || '_Not available on the page._'}`;
  }

  async function report() {
    const details = SECTIONS.slice(2);
    const activeTab = details.map(([key]) => document.getElementById(`${key}-tab`))
      .find((tab) => tab?.getAttribute('aria-selected') === 'true');
    const parts = ['# Kagi proofread report'];

    try {
      if (settings.original) parts.push(section('Original text', sourceText()));
      if (settings.corrected) parts.push(section('Corrected text', correctedText()));
      if (settings.corrections) {
        await tabContent('corrections');
        parts.push(section('Corrections', correctionsReport()));
      }
      for (const [key, label] of details.slice(1)) {
        if (settings[key]) parts.push(section(label, await tabContent(key)));
      }
      return `${parts.join('\n\n')}\n`;
    } finally {
      activeTab?.click();
    }
  }

  async function copyReport(button) {
    button.disabled = true;
    const label = button.textContent;
    try {
      GM_setClipboard(await report(), 'text');
      button.textContent = 'Copied';
    } catch (error) {
      console.error('[Kagi Proofread export]', error);
      button.textContent = 'Copy failed';
    }
    setTimeout(() => {
      button.disabled = false;
      button.textContent = label;
    }, 1200);
  }

  function ensureCopyButtons() {
    document.querySelectorAll('button[aria-label="Copy corrected text to clipboard"]').forEach((copy) => {
      if (copy.parentElement.nextElementSibling?.hasAttribute(`data-${ID}`)) return;
      const holder = copy.parentElement.cloneNode(false);
      holder.setAttribute(`data-${ID}`, '');
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'focus-visible:ring-focus-ring relative flex h-[34px] items-center justify-center rounded-md px-2 text-sm focus:outline-none focus-visible:ring-2 cursor-pointer hover:bg-general-hover-states';
      button.textContent = 'Copy report';
      button.setAttribute('aria-label', 'Copy full proofread report');
      button.addEventListener('click', () => copyReport(button));
      holder.append(button);
      copy.parentElement.insertAdjacentElement('afterend', holder);
    });
  }

  function saveSettings() {
    GM_setValue(STORAGE_KEY, settings);
  }

  function settingsSection() {
    const section = document.createElement('section');
    section.id = SETTINGS_ID;
    section.className = 'border-primary-100 mt-8 border-t pt-6';
    section.setAttribute(`data-${ID}`, '');
    section.innerHTML = `
      <h3 class="text-primary text-base font-bold">Export report</h3>
      <p class="text-primary-600 mt-1 text-xs leading-[1.6]">Choose the sections copied by “Copy report”. Each exports all visible details.</p>`;
    for (const [key, label] of SECTIONS) {
      const labelElement = document.createElement('label');
      labelElement.className = 'text-primary mt-4 block text-sm font-bold';
      const checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.checked = settings[key];
      checkbox.addEventListener('change', () => {
        settings[key] = checkbox.checked;
        saveSettings();
      });
      labelElement.append(checkbox, document.createTextNode(` ${label}`));
      section.append(labelElement);
    }
    return section;
  }

  function ensureSettings() {
    const general = document.querySelector('#general-panel');
    if (general && !general.querySelector(`#${SETTINGS_ID}`)) general.append(settingsSection());
  }

  function refresh() {
    scheduled = false;
    ensureCopyButtons();
    ensureSettings();
  }

  function schedule() {
    if (!scheduled) {
      scheduled = true;
      requestAnimationFrame(refresh);
    }
  }

  new MutationObserver(schedule).observe(document.documentElement, { childList: true, subtree: true });
  schedule();
})();
