/**
 * @file
 * h8FormValidationUtils.js
 *
 * Single source of truth for:
 *  - sessionStorage access (NEW map + LEGACY array)
 *  - key normalization/matching (strict + loose)
 *  - render gates for section/page validators
 *  - inspection helpers over master/live payloads
 *  - convenience mutators for record-scoped store updates
 *
 * CANONICAL SECTION KEY
 * ---------------------
 * Sections are identified by their **customLabel** everywhere:
 *  - UI: section.customLabel (fallback to label)
 *  - Server payload: sections[].customLabel (fallback to sectionName/label)
 */

export const STORE_KEY  = 'h8:formProcessing'; // NEW record-id keyed map
export const LEGACY_KEY = 'formProcessing';    // LEGACY array of requests

// ---------------------------------------------------------------------------
// Normalisation / matching
// ---------------------------------------------------------------------------
export function norm(s){ return (s ?? '').toString().trim().toLowerCase(); }
export function loose(s){ return norm(s).replace(/[^a-z0-9]/g, ''); }

/** Strict-or-loose equality, tolerant of punctuation/spacing differences. */
export function keysEqual(a, b){
  if (!a && !b) return true;
  const an = norm(a), bn = norm(b);
  if (an === bn) return true;
  return loose(a) === loose(b);
}

export function findMatchingKey(keys, target){
  const tn = norm(target), tl = loose(target);
  let found = keys.find(k => norm(k) === tn);
  if (found) return found;
  found = keys.find(k => loose(k) === tl);
  return found || null;
}

/** Coerce common truthy string/number forms to boolean. */
export function toBool(v){
  if (typeof v === 'boolean') return v;
  if (typeof v === 'number') return v === 1;
  if (typeof v === 'string') {
    const s = v.trim().toLowerCase();
    return s === 'true' || s === '1' || s === 'yes';
  }
  return !!v;
}

// ---------------------------------------------------------------------------
// Key helpers (canonical keys)
// ---------------------------------------------------------------------------

/** UI section -> canonical key (customLabel preferred). */
export function uiKey(uiSection){
  return (uiSection?.customLabel || uiSection?.label || uiSection?.sectionName || '').toString();
}

/** Server "section" payload -> canonical key (customLabel preferred). */
export function serverKey(serverSection){
  return (serverSection?.customLabel || serverSection?.sectionName || serverSection?.label || '').toString();
}

// ---------------------------------------------------------------------------
// Store I/O (raw)
// ---------------------------------------------------------------------------

/** Return the parsed value of sessionStorage[STORE_KEY] or null. */
export function getAllStore(){
  try {
    const raw = sessionStorage.getItem(STORE_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

/** Overwrite sessionStorage[STORE_KEY] with obj (object or array). */
export function setAllStore(obj){
  try {
    sessionStorage.setItem(STORE_KEY, JSON.stringify(obj ?? {}));
  } catch {
    // no-op
  }
}

/** Read any sessionStorage key (map or array) and return record-scoped entry. */
export function readFlexibleStore(key, recordId){
  try {
    const raw = sessionStorage.getItem(key);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed)) return parsed.find(r => r?.recordId === recordId) || null;
    if (parsed && typeof parsed === 'object') return parsed[recordId] || null;
    return null;
  } catch {
    return null;
  }
}

// Keep existing function name
export function getRecordStore(recordId) {
  if (!recordId) return null;
  const all = getAllStore();
  if (all && typeof all === 'object' && !Array.isArray(all)) {
    return all[recordId] || null;
  }
  // Legacy array fallback
  return readFlexibleStore(LEGACY_KEY, recordId);
}

// Alias for backwards compatibility
export const readRecordStore = getRecordStore;


/**
 * Upsert partial patch into the NEW map under STORE_KEY at [recordId].
 * Ensures recordId is present on the stored entry.
 */
export function setRecordStore(recordId, patch){
  if (!recordId) return;
  const all = getAllStore();
  const map = (all && typeof all === 'object' && !Array.isArray(all)) ? all : {};
  const prev = map[recordId] || {};
  map[recordId] = { ...prev, ...patch, recordId };
  setAllStore(map);
}

/** Mark/clear the external master trigger flag for a record. */
export function ackMasterTrigger(recordId){
  if (!recordId) return;
  const all = getAllStore();
  if (!all || Array.isArray(all)) return;
  if (!all[recordId]) return;
  all[recordId].isMasterValidation = false;
  setAllStore(all);
}

/** Stamp masterValidatedAt + suppressLiveValidation in the record store. */
export function suppressLiveValidationNow(recordId){
  if (!recordId) return;
  setRecordStore(recordId, {
    suppressLiveValidation: true,
    masterValidatedAt: new Date().toISOString()
  });
}

/**
 * Persist/overwrite a LIVE snapshot for a section (keyed by customLabel) into partialValidations.
 * NOTE: param name kept as 'label' historically; it now represents the canonical key (customLabel).
 */
export function persistLiveValidationForSection(recordId, label, pages, hasErrors){
  if (!recordId || !label) return;
  const all = getAllStore();
  const map = (all && typeof all === 'object' && !Array.isArray(all)) ? all : {};
  const rec = map[recordId] || {};
  const pv = rec.partialValidations || {};
  pv[label] = {
    hasErrors: !!hasErrors,
    pages: Array.isArray(pages) ? pages : [],
    ts: Date.now()
  };
  map[recordId] = { ...rec, partialValidations: pv };
  setAllStore(map);
}

/**
 * Upsert a single section's master result into store.sections (array),
 * keyed by customLabel (also mirrors under sectionName for backwards compatibility).
 * NOTE: param name kept as 'label' historically; it now represents the canonical key (customLabel).
 */
export function upsertMasterSectionResult(recordId, label, pages, hasErrors){
  if (!recordId || !label) return;
  const all = getAllStore();
  const map = (all && typeof all === 'object' && !Array.isArray(all)) ? all : {};
  const rec = map[recordId] || {};
  const list = Array.isArray(rec.sections) ? rec.sections.slice() : [];

  const findKey = (s) => (s?.customLabel || s?.sectionName || s?.label || '');
  const idx = list.findIndex(s => keysEqual(findKey(s), label));

  const nextEntry = {
    customLabel: label,
    sectionName: label, // legacy mirror
    pages: hasErrors ? (Array.isArray(pages) ? pages : []) : [],
    hasErrors: !!hasErrors,
    isValid: !hasErrors
  };

  if (idx >= 0) list[idx] = { ...list[idx], ...nextEntry };
  else list.push(nextEntry);

  map[recordId] = { ...rec, sections: list };
  setAllStore(map);
}

// ---------------------------------------------------------------------------
// Inspect master/live results (record-scoped "store" object)
// ---------------------------------------------------------------------------

/** True if master payload contains any error for section (by customLabel). */
export function masterHasErrorsForSection(store, sectionKey){
  const secs = Array.isArray(store?.sections) ? store.sections : [];
  return secs.some(s => {
    const idStr = s?.customLabel || s?.sectionName || s?.developerName || s?.id || '';
    if (!keysEqual(idStr, sectionKey)) return false;
    const pages = Array.isArray(s?.pages) ? s.pages : [];
    const hasAnyPage = pages.some(p => Array.isArray(p?.errors) && p.errors.length > 0);
    return hasAnyPage || s?.hasErrors === true || s?.isValid === false;
  });
}

/** True if live payload contains any error for section (by customLabel). */
export function liveHasErrorsForSection(store, sectionKey){
  const pv = store?.partialValidations || {};
  if (!pv || typeof pv !== 'object') return false;
  const key = findMatchingKey(Object.keys(pv), sectionKey);
  if (!key) return false;
  const entry = pv[key];
  if (!entry) return false;
  if (entry.hasErrors === true) return true;
  const pages = Array.isArray(entry.pages) ? entry.pages : [];
  return pages.some(p => Array.isArray(p?.errors) && p.errors.length > 0);
}

/** True if master payload contains page errors under *this* section key. */
export function masterHasErrorsForPage(store, sectionKey, pageName){
  const target = norm(pageName);
  const secs = Array.isArray(store?.sections) ? store.sections : [];
  return secs.some(s => {
    const idStr = s?.customLabel || s?.sectionName || s?.developerName || s?.id || '';
    if (!keysEqual(idStr, sectionKey)) return false;
    const pages = Array.isArray(s?.pages) ? s.pages : [];
    return pages.some(p => {
      const name = norm(p?.pageLabel || p?.pageName);
      const hasAny = Array.isArray(p?.errors) && p.errors.length > 0;
      return name === target && hasAny;
    });
  });
}

/** True if live payload contains page errors under *this* section key. */
export function liveHasErrorsForPage(store, sectionKey, pageName){
  const pv = store?.partialValidations || {};
  if (!pv || typeof pv !== 'object') return false;
  const skey = findMatchingKey(Object.keys(pv), sectionKey);
  if (!skey) return false;
  const entry = pv[skey];
  const pages = Array.isArray(entry?.pages) ? entry.pages : [];
  const target = norm(pageName);
  return pages.some(p =>
    norm(p?.pageLabel || p?.pageName) === target &&
    Array.isArray(p?.errors) && p.errors.length > 0
  );
}

// ---------------------------------------------------------------------------
// Render gates
// ---------------------------------------------------------------------------

/**
 * Should the SECTION component render?
 * - Inline panel must be OFF
 * - Master OR (live+errors) must be present for this section
 */
export function gateSectionRender(store, sectionKey){
  if (!store) return false;
  if (store.showSectionValidationPanel) return false;

  const master = masterHasErrorsForSection(store, sectionKey);
  if (master) return true;

  if (store.liveValidation) {
    return liveHasErrorsForSection(store, sectionKey);
  }
  return false;
}

/**
 * Should the PAGE component render?
 * - Inline panel must be OFF
 * - Use explicit section key if given, else fallback to currentSectionKey (legacy: currentSectionName)
 * - Only consider page errors under THAT section
 */
export function gatePageRender(store, sectionKey, pageName){
  if (!store) return false;
  if (store.showSectionValidationPanel) return false;

  const section = (sectionKey || store.currentSectionKey || store.currentSectionName || '').trim();
  if (!section || !pageName) return false;

  const master = masterHasErrorsForPage(store, section, pageName);
  if (master) return true;

  if (store.liveValidation) {
    return liveHasErrorsForPage(store, section, pageName);
  }
  return false;
}