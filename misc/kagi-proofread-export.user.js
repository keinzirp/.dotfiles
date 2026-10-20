// ==UserScript==
// @name         Kagi Proofread: copy full report
// @namespace    https://github.com/keinzirp/dotfiles
// @version      1.0.0
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
  const DETAIL_SECTIONS = SECTIONS.slice(2);
  const defaults = Object.fromEntries(SECTIONS.map(([key]) => [key, true]));
  let settings = { ...defaults, ...GM_getValue(STORAGE_KEY, {}) };
  let scheduled = false;

  const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
  const visible = (element) => Boolean(element && element.getClientRects().length);
  const text = (element) => element?.innerText?.replace(/\u00a0/g, ' ').trim() || '';
  const compact = (value) => value.replace(/\s+/g, ' ').trim();
  const escaped = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const labelPattern = (label) => new RegExp(`^${escaped(label)}(?:\\s+\\d+)?$`, 'i');

  function controlLabels(element) {
    return [
      element.getAttribute('aria-label'),
      element.getAttribute('title'),
      element.getAttribute('data-tooltip-content'),
      text(element),
    ].filter(Boolean).map(compact);
  }

  function controls() {
    return [...document.querySelectorAll('button, [role="button"]')].filter(visible);
  }

  function findControl(label) {
    const pattern = labelPattern(label);
    return controls().find((element) => controlLabels(element).some((value) => pattern.test(value)));
  }

  function findSectionControl(label) {
    const pattern = labelPattern(label);
    return controls().find((element) => pattern.test(compact(text(element))));
  }

  function cleanText(element) {
    const copy = element.cloneNode(true);
    copy.querySelectorAll(`[data-${ID}], script, style`).forEach((node) => node.remove());
    return text(copy);
  }

  function sectionContent(control, label) {
    if (!control) return '';

    const panelId = control.getAttribute('aria-controls');
    const panel = panelId && document.getElementById(panelId);
    if (panel) return cleanText(panel);

    const sibling = control.nextElementSibling;
    if (sibling && visible(sibling)) return cleanText(sibling);

    const parent = control.parentElement;
    const value = parent && cleanText(parent);
    if (!value) return '';
    return value.replace(labelPattern(label), '').trim();
  }

  async function readSection(label) {
    const control = findSectionControl(label);
    if (!control) return '';

    const wasCollapsed = control.getAttribute('aria-expanded') === 'false'
      || control.getAttribute('data-state') === 'closed'
      || (control.closest('details') && !control.closest('details').open);
    if (wasCollapsed) {
      control.click();
      await sleep(150);
    }

    const value = sectionContent(control, label);
    if (wasCollapsed) control.click();
    return value;
  }

  function inputText() {
    const inputs = [
      ...document.querySelectorAll('textarea, input[type="text"], [contenteditable="true"], [role="textbox"]'),
    ].filter(visible);
    const input = inputs.sort((a, b) => {
      const aText = 'value' in a ? a.value : text(a);
      const bText = 'value' in b ? b.value : text(b);
      return bText.length - aText.length;
    })[0];
    return input ? ('value' in input ? input.value : text(input)).trim() : '';
  }

  function outputContainer() {
    const copy = findControl('Copy');
    if (!copy) return null;
    const labels = DETAIL_SECTIONS.map(([, label]) => label);

    for (let element = copy.parentElement; element && element !== document.body; element = element.parentElement) {
      const value = text(element);
      if (labels.some((label) => new RegExp(`(^|\\n)${escaped(label)}(?:\\s+\\d+)?(?:\\n|$)`, 'i').test(value))) {
        return element;
      }
    }
    return null;
  }

  function correctedText() {
    const container = outputContainer();
    if (!container) return '';
    const value = cleanText(container);
    const firstDetail = DETAIL_SECTIONS
      .map(([, label]) => value.search(new RegExp(`(^|\\n)${escaped(label)}(?:\\s+\\d+)?(?:\\n|$)`, 'im')))
      .filter((index) => index >= 0)
      .sort((a, b) => a - b)[0];
    return (firstDetail === undefined ? value : value.slice(0, firstDetail)).trim();
  }

  function markdownSection(title, value) {
    return `## ${title}\n\n${value || '_Not available on the page._'}`;
  }

  async function report() {
    const parts = ['# Kagi proofread report'];
    if (settings.original) parts.push(markdownSection('Original text', inputText()));
    if (settings.corrected) parts.push(markdownSection('Corrected text', correctedText()));

    for (const [key, label] of DETAIL_SECTIONS) {
      if (settings[key]) parts.push(markdownSection(label, await readSection(label)));
    }
    return `${parts.join('\n\n')}\n`;
  }

  async function copyReport(button) {
    button.disabled = true;
    const oldLabel = button.textContent;
    try {
      GM_setClipboard(await report(), 'text');
      button.textContent = 'Copied';
    } catch (error) {
      console.error('[Kagi Proofread export]', error);
      button.textContent = 'Copy failed';
    }
    setTimeout(() => {
      button.disabled = false;
      button.textContent = oldLabel;
    }, 1200);
  }

  function ensureCopyButton() {
    if (document.getElementById(ID)) return;
    const copy = findControl('Copy');
    if (!copy) return;

    const button = document.createElement('button');
    button.id = ID;
    button.type = 'button';
    button.setAttribute(`data-${ID}`, '');
    button.className = copy.className;
    button.textContent = 'Copy report';
    button.title = 'Copy full proofread report';
    button.addEventListener('click', () => copyReport(button));
    copy.insertAdjacentElement('afterend', button);
  }

  function saveSettings() {
    GM_setValue(STORAGE_KEY, settings);
  }

  function settingsPanel() {
    const panel = document.createElement('section');
    panel.id = SETTINGS_ID;
    panel.setAttribute(`data-${ID}`, '');
    panel.hidden = true;
    panel.innerHTML = `
      <h2>Export report</h2>
      <p>Choose the sections copied by “Copy report”. Each section includes all visible details.</p>
      <div class="${SETTINGS_ID}-choices"></div>`;

    const choices = panel.querySelector(`.${SETTINGS_ID}-choices`);
    for (const [key, label] of SECTIONS) {
      const row = document.createElement('label');
      const checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.checked = settings[key];
      checkbox.addEventListener('change', () => {
        settings[key] = checkbox.checked;
        saveSettings();
      });
      row.append(checkbox, document.createTextNode(` ${label}`));
      choices.append(row);
    }
    return panel;
  }

  function ensureSettings() {
    const dialog = [...document.querySelectorAll('[role="dialog"]')]
      .find((element) => /^Settings\b/i.test(text(element)));
    if (!dialog || dialog.querySelector(`[data-${ID}]`)) return;

    const general = findControl('General');
    if (!general || !dialog.contains(general)) return;

    const entry = document.createElement('button');
    entry.type = 'button';
    entry.className = general.className;
    entry.textContent = 'Export report';
    entry.setAttribute(`data-${ID}`, '');
    general.parentElement.append(entry);

    const panel = settingsPanel();
    dialog.append(panel);
    entry.addEventListener('click', () => {
      panel.hidden = false;
      entry.setAttribute('aria-current', 'page');
    });

    dialog.addEventListener('click', (event) => {
      if (event.target !== entry && general.parentElement.contains(event.target)) {
        panel.hidden = true;
        entry.removeAttribute('aria-current');
      }
    });
  }

  function addStyles() {
    const style = document.createElement('style');
    style.setAttribute(`data-${ID}`, '');
    style.textContent = `
      #${ID} { white-space: nowrap; }
      #${SETTINGS_ID} {
        position: absolute; inset: 120px 70px 70px 530px; overflow: auto;
        padding: 28px; border-radius: 12px; background: var(--background, #242426);
        color: var(--foreground, #f4f4f5); z-index: 2;
      }
      #${SETTINGS_ID} h2 { margin-top: 0; }
      #${SETTINGS_ID} p { max-width: 48rem; color: #b5b5bd; }
      .${SETTINGS_ID}-choices { display: grid; gap: 14px; margin-top: 24px; }
      .${SETTINGS_ID}-choices label { font-size: 1rem; cursor: pointer; }
    `;
    document.head.append(style);
  }

  function refresh() {
    scheduled = false;
    ensureCopyButton();
    ensureSettings();
  }

  function schedule() {
    if (!scheduled) {
      scheduled = true;
      requestAnimationFrame(refresh);
    }
  }

  addStyles();
  new MutationObserver(schedule).observe(document.documentElement, { childList: true, subtree: true });
  schedule();
})();
