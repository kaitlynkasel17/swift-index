# The Swift Index

Rank **every Taylor Swift song ever released** with your friends — live. Quick "this song or that
song?" battles turn into a full ranking via Elo. Everyone's rankings update in real time, a
**Clashes** view shows exactly where you disagree, and a live **Duel** mode lets two people settle
those clashes head-to-head with lyrics.

- **One file.** The whole app is `index.html` — no build step, host it anywhere.
- **Pairwise battles.** No painful drag-to-order 260+ songs; a ranking *emerges* as you play.
- **Live.** A single Supabase project (two tables + realtime) keeps everyone in sync.
- **Duel mode (live, 2+ players).** Everyone ranks at their own pace on their own device. When two
  people disagree on a song, a lyric battle pulls just those two in — the song's lyrics load right
  there so each picks a line by tapping (no typing), then you vote on the better line, picking more
  until you agree. With 3+ players clashes queue: if your rival is mid-duel, you keep choosing and
  your clash waits its turn. Duel results are saved separately and never touch your personal rankings.
  *(Lyrics are fetched live from lrclib.net at battle time — never stored in the app.)*
- **Catalog.** 262 distinct songs — studio albums, vault tracks, bonus tracks, standalone singles &
  notable collabs. Re-recordings collapse into one entry. It's just a data array near the top of
  `index.html`; add or remove freely.

Try it solo by opening `index.html`. To play *together*, do the one-time setup below.

---

## Setup (one person, once)

1. **Create a free [Supabase](https://supabase.com) project** (no credit card). Wait ~1 min for it
   to provision.
2. **Run the schema.** SQL Editor → New query → paste all of [`schema.sql`](schema.sql) → **Run**.
   This creates the `votes` table (rankings) and the `duels` table (settled clashes), and turns on
   realtime. *Safe to re-run — if you set this up before the Duel update, just run it again to add
   the `duels` table.*
3. **Add your keys.** In Project Settings → API Keys → **Legacy anon, service_role** tab, copy the
   **anon** key. Get your **Project URL** from the green **Connect** button (or Settings → Data API).
   Paste both into the top of [`index.html`](index.html):
   ```js
   const SUPABASE_URL  = "https://YOURPROJECT.supabase.co";
   const SUPABASE_ANON_KEY = "eyJhbGci...";   // the anon key (safe in client code; NOT service_role)
   ```
4. **Host it.** It's a static file, so any of these work in ~2 minutes:
   - **Netlify Drop** — drag this folder onto <https://app.netlify.com/drop>.
   - **Vercel** — `npx vercel`, or drag-and-drop in the dashboard.
   - **GitHub Pages / Cloudflare Pages** — point them at the folder.

   Share the URL. Everyone opens it and enters the **same room word** to group up.

---

## How to play
- **Battle** — tap the better song (or ← / →, space to skip). Your ranking builds as you go.
- **List** — your songs, ranked by Elo.
- **Circle** (live) — the group's consensus ranking, each person's top songs, and a live feed.
- **Clashes** — where you and a chosen friend disagree, head-to-head and in the rankings.
- **Duel** (live, 2+ players) — everyone opens it in the same room; the host taps *Begin*. Each
  person ranks at their own pace; when two disagree, a lyric battle pulls those two in (or tap
  *We're together* to settle out loud). Everyone else keeps going; if your rival is busy, your clash
  waits in line. Settled clashes are saved under **Settled clashes**.

## Notes
- **The anon key is public by design** — access is governed by the RLS policies in `schema.sql`.
  Anyone with your link can join, so share it just with your friends; never use the `service_role`
  key in the app.
- **Reset** — menu (≡) → *Reset my battles* clears only your votes in the room.
- **Multiple groups** can share one deployment via different room words.
- Excluded by default (easy to add to `EXTRAS`): live covers and very minor background features.
