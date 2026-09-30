---
name: lehigh-brand
description: Apply Lehigh University's brand guidelines (colors, typography, logo, voice) to web UIs, including Bootstrap 5 theming, Google Font substitutes, and WCAG-checked color pairings. Use when designing, building, or reviewing any Lehigh-branded page, component, chart, email, or document.
---

# Lehigh Brand

Use this skill when building or reviewing anything that should look and sound like Lehigh
University: Drupal themes and modules, dashboards, Bootstrap pages, charts, emails, slides.

Source: Lehigh University Brand Guidelines, <https://live.standards.site/lehighbrandhub>
(the “Real” brand, 2025). The hub is a JavaScript app; its content is embedded as JSON in the
page (`var documentData = …`), so fetch the raw HTML and parse it if you need to re-check a
detail. Contact University Communications for logo files, spot illustrations, and questions
this skill doesn't answer.

## Operating Rules

- Lehigh Brown and White lead. Secondary colors add emphasis and hierarchy; use them with intent
  and never all at once.
- On a standalone (“single-experience”) asset, don't flood large areas with secondary colors.
  Multi-part experiences (sites with many branded elements, multi-page pieces, banner series) may.
- Every text/background pairing must pass WCAG 2.x AA: 4.5:1 for body text, 3:1 for large text
  (≥ 24px, or ≥ 18.66px bold) and for UI components and chart marks. Use the table below; check
  anything else with the WebAIM contrast checker.
- Use official logo and shield files only. Never recreate, recolor, stretch, add words to, or
  change the opacity of them.
- Prefer the licensed fonts where the site has web licenses; otherwise use the Google Font
  substitutes below. Don't mix a licensed font with its own substitute.
- Keep existing UI behavior; branding changes presentation, not function or data semantics.

## Color

### Primary palette (since 1867)

| Name | Hex | PMS | Use |
| --- | --- | --- | --- |
| Lehigh Brown | `#502D0E` | 1545 U | Brand anchor: headers, primary buttons, headings, key text |
| White | `#FFFFFF` | — | Grounds and knockout text |

### Secondary palette

| Name | Hex | PMS | Character |
| --- | --- | --- | --- |
| Night Sky | `#12354C` | 2188 U | Deep blue; dark grounds, text |
| Serenity Garden | `#1B3A24` | 560 U | Deep green; dark grounds, text |
| Valley Green | `#2CB357` | 2271 U | Bright green accent |
| Bethlehem Sky | `#66B0FF` | 2915 U | Bright blue accent |
| Spring Violet | `#5E74EE` | 2727 U | Violet accent |
| Autumn Dusk | `#EBA033` | 129 U | Amber accent |
| Golden Hour | `#FFE41E` | 114 U | Yellow accent |
| First Light | `#F5E9AD` | 7499 U | Pale yellow tint |
| Cherry Blossom | `#FCD8D6` | 698 U | Pale pink tint |
| Mountaintop Mist | `#D1E9E8` | 7457 U | Pale blue-green tint |
| Patina Green | `#AFEDC9` | 7478 U | Pale green tint |

Also defined in the hub for UI use: Red `#F9423A`, Gainsboro `#D8D8D8`, Black `#000000`.

### Contrast (WCAG ratio)

| Color | on White | on Lehigh Brown | on Night Sky |
| --- | ---: | ---: | ---: |
| Lehigh Brown | 12.19 | — | 1.05 |
| Night Sky | 12.81 | 1.05 | — |
| Serenity Garden | 12.52 | 1.03 | 1.02 |
| White | — | 12.19 | 12.81 |
| Golden Hour | 1.28 | 9.50 | 9.98 |
| First Light | 1.23 | 9.95 | 10.46 |
| Mountaintop Mist | 1.27 | 9.60 | 10.08 |
| Cherry Blossom | 1.32 | 9.25 | 9.72 |
| Patina Green | 1.33 | 9.16 | 9.63 |
| Gainsboro | 1.43 | 8.55 | 8.99 |
| Autumn Dusk | 2.19 | 5.58 | 5.86 |
| Bethlehem Sky | 2.28 | 5.35 | 5.62 |
| Valley Green | 2.73 | 4.47 | 4.69 |
| Red | 3.58 | 3.41 | 3.58 |
| Spring Violet | 4.03 | 3.02 | 3.18 |

What this means in practice:

- **Text on white:** only Lehigh Brown, Night Sky, Serenity Garden (or near-black). No bright
  accent passes AA as text on white, not even Spring Violet (4.03).
- **Text on brown / Night Sky / Serenity Garden:** White, and every pale tint (First Light, Golden
  Hour, Mist, Blossom, Patina, Gainsboro). Autumn Dusk and Bethlehem Sky pass for body text on
  the dark colors; Valley Green only for large text.
- **Accents on white** are fills, rules, and chart marks, never text. Bethlehem Sky, Autumn Dusk,
  and the pale tints fall below 3:1 on white, so give them a darker outline or pair them with a
  labeled legend. Valley Green (2.73) is also below 3:1 as a mark on white.
- **Pale tints** work as section backgrounds or badges with brown or Night Sky text.
- **Status colors:** Red (3.58 on white) is fine for icons/borders, not small text; use brown or
  Night Sky text on a Cherry Blossom tint for error messages instead.

### Proportions from the guide

Sample palettes (approximate share of a composition). Brown is present in all of them; most use
one or two secondary colors plus white or a tint:

- Lehigh Brown 44% · Golden Hour 41% · White 15%
- Lehigh Brown 70% · Patina Green 15% · White 15%
- Lehigh Brown 12% · Night Sky 14% · Mountaintop Mist 12% · White 61%
- Lehigh Brown 35% · White 36% · Spring Violet 14% · First Light 14%
- Lehigh Brown 25% · Night Sky 26% · Mountaintop Mist 24% · Bethlehem Sky 24%
- Lehigh Brown 15% · Serenity Garden 53% · Cherry Blossom 16% · White 16%
- Lehigh Brown 58% · Autumn Dusk 10% · Golden Hour 10% · First Light 11% · White 11%

For data-heavy UIs, a white/Mist ground with brown structure and one or two accents (for
example Night Sky and Autumn Dusk) matches the “Brown · Night Sky · Mist · White” palette.

## Typography

| Role | Licensed font | Google Font substitute | Weights (substitute) |
| --- | --- | --- | --- |
| Headlines, emphasis, subheads | Dopis (Tour de Force) | **Sora** | 300, 400, 600, 800 |
| All-caps display headlines, short callouts | Dopis Condensed | **Barlow Condensed** | 400, 500, 700, 900 |
| Serif subheads, pull quotes, short copy | Meursault Condensed (Universal Thirst) | **Instrument Serif** | 400 (+ italic) |
| Body copy, captions, UI text | Inter | **Inter** (same) | 400, 500, 600, 700 |

- Dopis and Meursault web licenses are held by college/department communications leads. Only
  use them if the site has a license; otherwise use the substitutes.
- **Condensed display (Dopis Condensed / Barlow Condensed) is uppercase only**, and only for
  headlines, short labels, and pull quotes; never body copy or lowercase.
- Inter is the default body and UI face. Keep UI text in Inter; use Sora for headings and big
  numbers, and Barlow Condensed uppercase for eyebrows and kicker labels.

Web loading (substitutes):

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@500;700&family=Instrument+Serif:ital@0;1&family=Inter:wght@400;500;600;700&family=Sora:wght@400;600;800&display=swap" rel="stylesheet">
```

In Drupal, declare this as an external CSS asset in `*.libraries.yml`
(`type: external`, `minified: true`) rather than hard-coding a `<link>`. Always give a system
fallback stack:

```css
--lu-font-sans: "Inter", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
--lu-font-display: "Sora", "Inter", system-ui, sans-serif;
--lu-font-condensed: "Barlow Condensed", "Arial Narrow", sans-serif-condensed, sans-serif;
--lu-font-serif: "Instrument Serif", Georgia, serif;
```

### Leading and tracking (translated to CSS)

| Face | Size | line-height | letter-spacing |
| --- | --- | --- | --- |
| Dopis / Sora | > 100px | 0.9–1.06 | -0.005em |
| Dopis / Sora | 60–100px | 1.0–1.3 | 0 |
| Dopis / Sora | < 60px | 1.05–1.3 | 0 |
| Dopis Condensed / Barlow Condensed | > 100px | 0.9–1.06 | -0.005em |
| Dopis Condensed / Barlow Condensed | ≤ 100px | 1.1–1.2 | 0 (all-caps labels may add ~0.04em) |
| Meursault Condensed / Instrument Serif | > 100px | 1.02–1.10 | 0 |
| Meursault Condensed / Instrument Serif | ≤ 100px | 1.05–1.2 | 0.005em |
| Inter | > 100px | 1.0–1.08 | -0.012em |
| Inter | 60–100px | 1.15 | -0.01em |
| Inter | < 60px (body) | 1.2–1.6 (body ≈ 1.5–1.7) | -0.005em or 0 |

(Design-tool tracking values are thousandths of an em: -5 → -0.005em.) All-caps treatments may
take slightly tighter leading and looser tracking.

## Bootstrap 5 mapping

Lehigh sites increasingly use Bootstrap 5 (for example DXPR themes). Theme through Bootstrap's
CSS variables rather than overriding component CSS; scope them to a wrapper when the page shares
a theme you don't control:

```css
.lu-scope {
  --bs-primary: #502d0e;       --bs-primary-rgb: 80, 45, 14;
  --bs-secondary: #12354c;     --bs-secondary-rgb: 18, 53, 76;
  --bs-success: #1b3a24;       --bs-success-rgb: 27, 58, 36;
  --bs-info: #12354c;          --bs-warning: #eba033;   --bs-danger: #f9423a;
  --bs-light: #d1e9e8;         --bs-dark: #12354c;
  --bs-body-color: #1f1a17;    --bs-body-bg: #ffffff;
  --bs-emphasis-color: #000;   --bs-heading-color: #502d0e;
  --bs-secondary-color: rgba(31, 26, 23, .75);
  --bs-tertiary-bg: #f6f3ef;   /* warm neutral from brown at ~4% */
  --bs-border-color: #d8d8d8;
  --bs-link-color: #502d0e;    --bs-link-color-rgb: 80, 45, 14;
  --bs-link-hover-color: #12354c; --bs-link-hover-color-rgb: 18, 53, 76;
  --bs-focus-ring-color: rgba(18, 53, 76, .35);
  --bs-body-font-family: var(--lu-font-sans);
  --bs-border-radius: .375rem;
}
```

Bootstrap components read `--bs-btn-*`, `--bs-table-*`, etc. at component level, so `.btn-primary`
also needs its button variables (or Sass variables if you compile Bootstrap):

```css
.lu-scope .btn-primary {
  --bs-btn-bg: #502d0e; --bs-btn-border-color: #502d0e; --bs-btn-color: #fff;
  --bs-btn-hover-bg: #3d2209; --bs-btn-hover-border-color: #3d2209; --bs-btn-hover-color: #fff;
  --bs-btn-active-bg: #12354c; --bs-btn-active-border-color: #12354c;
  --bs-btn-focus-shadow-rgb: 80, 45, 14;
}
.lu-scope .btn-outline-primary {
  --bs-btn-color: #502d0e; --bs-btn-border-color: #502d0e;
  --bs-btn-hover-bg: #502d0e; --bs-btn-hover-color: #fff;
  --bs-btn-active-bg: #502d0e; --bs-btn-active-color: #fff;
}
```

With Sass, set `$primary: #502d0e; $secondary: #12354c; $font-family-sans-serif: …` before
importing Bootstrap instead.

Pitfalls seen on Lehigh Drupal sites:

- The site theme usually already loads Bootstrap (the `lehigh` LTS theme pulls 5.3.x from
  jsdelivr; DXPR themes are bootstrap5 subthemes). Check the rendered `<link>` tags before adding
  another copy; a module should rely on the theme's Bootstrap, not ship its own.
- Theme CSS often loads *after* module CSS. Bootstrap's `:root, [data-bs-theme=light]` block
  (specificity 0,1,0) then resets any `--bs-*` tokens you set on a single class. Scope brand
  tokens with at least two selectors (e.g. `.lu-scope[data-app]`) and override component
  variables as `.lu-scope .card`, `.lu-scope .btn-primary`.
- Generic theme rules such as `input[type="search"] { background: … }` or
  `button:not(...) { text-decoration: underline }` outrank Bootstrap's single-class rules;
  re-assert them under your scope.
- Themes may force control sizes with `!important` (the `lehigh` theme sets
  `input[type="search"] { height: 50px !important }`); a scoped `!important` is the only fix.
- Don't let a Bootstrap conversion shrink the layout. `card-body` (1rem), `table-sm`, and
  `col-lg-*` rows crammed a dashboard that was previously spacious. Keep toolbars and filter
  bars inline with a CSS grid (one row on wide screens, then 3 → 2 → 1 columns), keep labels on
  one line so controls align, give panels ~1.5rem padding and table cells ~0.75rem.
- Verify with the browser at 1366, 1024, 768, and 400px: compare computed styles and
  screenshots, not just the stylesheet.

Component conventions:

- Primary actions: `.btn-primary` (brown). Secondary: `.btn-outline-primary` or
  `.btn-outline-secondary`. One primary action per group.
- Cards/panels: white `.card` with a Gainsboro border; tint section backgrounds with Mountaintop
  Mist or the warm neutral, not saturated accents.
- Eyebrows/kickers: Barlow Condensed, uppercase, ~0.9rem, brown or Night Sky.
- Headings: Sora (brown on light grounds, white on brown/Night Sky).
- Big numbers/KPIs: Sora 600–800, tabular numerals (`font-variant-numeric: tabular-nums`).
- Tables: `.table .table-hover`; header row in Barlow Condensed uppercase or Inter 600, and
  right-aligned numeric columns.
- Filter chips: `.badge` / small `.btn` with brown outline; include a visible remove affordance
  and an accessible label.
- Focus: keep Bootstrap's visible focus ring, tinted Night Sky or brown; never remove outlines.

## Dark mode

The guide doesn't define dark mode. When a UI needs one, use Night Sky (`#12354C`) or a darker
blend of it as the ground, white/First Light text, pale tints for accents, and Autumn Dusk or
Bethlehem Sky for highlights (both pass AA on Night Sky). Keep brown for large brand elements
only; brown text on Night Sky fails. With Bootstrap 5.3, implement via `[data-bs-theme="dark"]`
variable overrides.

## Data visualization

- Two-series comparisons (e.g. page views vs downloads): Lehigh Brown + Night Sky on light
  grounds; add a pale tint track (Mist or Gainsboro) behind bars.
- Additional categorical series: Autumn Dusk, Valley Green, Spring Violet, Bethlehem Sky, but
  outline them or rely on labels, since they're below 3:1 on white.
- Never encode meaning by color alone; label values directly or provide a legend and a table.

## Logo and shield

- Formal lockup (wordmark + shield) is the default. Minimum width 1.75 in (print); keep clear
  space around it.
- Informal alternatives: text-only “Lehigh University” wordmark (one color, low-res/signage) and
  one-line wordmark (tight spaces such as a website header).
- Logo colors: brown and white only (4-color, 4-color knockout, 1-color brown, 1-color white).
- The 1-color knockout shield may be colorized only in light brand colors (Autumn Dusk, Cherry
  Blossom, First Light, Golden Hour, Patina Green, Mountaintop Mist, White); the 1-color overprint
  shield only in dark ones (Night Sky, Serenity Garden, Brown).
- Colleges and offices use the endorsed sub-brand system; don't design one-off logos.

## Voice

- Brand platform: **“Real”**. Positioning: *a community of focused future makers*. Pragmatic,
  results-oriented, collaborative, joyful, and grounded in measurable impact.
- Headlines hint at the story rather than using formulaic, telegraphic phrasing; intrigue
  without misdirecting. Examples from the guide: “Here’s the real story.”, “True progress begins
  here.”, “Unearth what’s really going on.”
- Say “real” without always saying “real”: genuine, actual, true, proven, tested, measured.
- For data and reporting UIs, stay plain and precise: state definitions and limitations
  honestly. That's the “Real” brand applied to data.

## Imagery and graphics

- Photography: authentic, candid, natural light, real spaces, unfiltered, and inclusive.
  Categories: student point of view, portraits, details, sense of place, and in-the-moment.
- Photographic frame/grid/arrow elements and campus textures are used with photography only,
  never alone. Spot illustrations come from University Communications.
- Motion: purposeful, simple, consistent easing; respect `prefers-reduced-motion`.

## Review Checklist

1. Brown/white lead; one or two secondary colors, used with intent.
2. Every text pairing passes AA per the contrast table; accents aren't used as text on white.
3. Inter for body/UI; Sora headings; condensed display face uppercase only; fallbacks present.
4. Logo/shield: official files, untouched, approved colors, clear space.
5. Bootstrap theming through variables, not ad-hoc component overrides; focus rings visible.
6. Charts: brown + Night Sky first; no color-only meaning.
7. Copy: plain, specific, honest about data; no formulaic slogans.
8. Works at 400px width and in dark mode if offered; honors reduced motion.
