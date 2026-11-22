# Oldi-Berdi — rasmiy sayt

**oldiberdi.uz** — Oldi-Berdi qarz daftari ilovasining sotuv sayti va kompyuter dasturi.
Ilovaning o'zi alohida repoda: `xusniddin-del/Oldi-berdi-ilovasi`.

## Tuzilishi
| Fayl | Nima |
|---|---|
| `index.html` | Sayt (bitta fayl). Havolalar faylning pastidagi `CFG` ichida |
| `img/` | Rasmlar, ilova skrinshotlari |
| `desktop/` | Windows va Mac dasturi (Tauri, ~5–10 MB) — internetdagi ilovani alohida oynada ochadi |
| `.github/workflows/desktop.yml` | `.exe` va `.dmg` ni GitHub o'zi yig'adi |

## Sayt qanday yangilanadi
`index.html` ni o'zgartirib GitHub'ga yuklasangiz — sayt 1 daqiqada yangilanadi (GitHub Pages).

## Kompyuter dasturini chiqarish
1. **Actions** → **Kompyuter dasturi** → **Run workflow**
2. Versiyani yozing (masalan `1.1.0`, keyingi safar `1.1.1`) → **Run**
3. ~10 daqiqadan keyin **Releases** da `Oldi-Berdi-Setup.exe` va `Oldi-Berdi.dmg` paydo bo'ladi.
   Saytdagi «Yuklab olish» tugmalari doim eng oxirgi versiyani beradi.

Dastur ichida faqat ilova havolasi bor — ilova yangilansa, kompyuter dasturini qayta chiqarish **shart emas**.

## oldiberdi.uz domenini ulash (domen faollashgach)
1. Domen panelida (DNS) qo'shing:
   - `A` yozuvlar `@` uchun: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - `CNAME` yozuv `www` uchun: `xusniddin-del.github.io`
2. GitHub: **Settings → Pages → Custom domain** → `oldiberdi.uz` → **Save**, keyin **Enforce HTTPS** ni yoqing.
