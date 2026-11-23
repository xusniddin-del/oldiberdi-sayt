// Oldi-Berdi — Windows 7, 8, 8.1 uchun kompyuter dasturi (Electron 22 — shu tizimlarni qo'llagan oxirgi versiya).
// Oldi-Berdi — kompyuter dasturi. Internetdagi ilovani alohida oynada ochadi:
// akkaunt, ma'lumotlar va yangilanishlar telefon va sayt bilan bir xil.
const { app, BrowserWindow, shell, Menu, session } = require('electron');
const path = require('path');

const APP_URL = process.env.OLDIBERDI_URL || 'https://xusniddin-del.github.io/Oldi-berdi-ilovasi/';   // ilova manzili (keyin: https://app.oldiberdi.uz/)
// faqat ilova manzillari shu oynada ochiladi; sayt (oldiberdi.uz) va boshqalar — odatdagi brauzerda
const APP_HOSTS = ['app.oldiberdi.uz'];
const GH_HOST = 'xusniddin-del.github.io', GH_APP_PATH = '/oldi-berdi-ilovasi';
let win = null;

if (!app.requestSingleInstanceLock()) { app.quit(); }
else app.on('second-instance', () => { if (win) { if (win.isMinimized()) win.restore(); win.show(); win.focus(); } });

const inApp = u => { try { const x = new URL(u); const p = x.pathname.toLowerCase(); return x.protocol === 'https:' && (APP_HOSTS.includes(x.hostname) || (x.hostname === GH_HOST && p.startsWith(GH_APP_PATH))); } catch (e) { return false; } };
const openOutside = u => { if (/^(https?|tel|sms|mailto|tg):/i.test(u)) shell.openExternal(u); };

function create() {
  win = new BrowserWindow({
    width: 1240, height: 820, minWidth: 380, minHeight: 560,
    title: 'Oldi-Berdi', backgroundColor: '#edf5ef', show: false, autoHideMenuBar: true,
    icon: path.join(__dirname, 'build', 'icon.png'),
    webPreferences: { contextIsolation: true, nodeIntegration: false, sandbox: true, spellcheck: false }
  });
  win.once('ready-to-show', () => win.show());
  // Telegram, SMS, telefon va boshqa tashqi havolalar odatdagi brauzerda / ilovada ochiladi
  win.webContents.setWindowOpenHandler(({ url }) => { if (inApp(url) && !/\.apk(\?|$)/i.test(url)) return { action: 'allow' }; openOutside(url); return { action: 'deny' }; });
  win.webContents.on('will-navigate', (e, url) => { if (!inApp(url)) { e.preventDefault(); openOutside(url); } });
  // internet yo'q va saqlangan nusxa ham bo'lmasa — chiroyli "Internet yo'q" sahifasi
  win.webContents.on('did-fail-load', (e, code, desc, url, isMain) => {
    if (isMain && code !== -3) win.loadFile(path.join(__dirname, 'offline.html'), { query: { u: APP_URL } });
  });
  // ingichka, chiroyli aylantirish chizig'i (Windows'da qalin bo'lib turmasin)
  win.webContents.on('did-finish-load', () => win.webContents.insertCSS('::-webkit-scrollbar{width:8px;height:8px}::-webkit-scrollbar-thumb{background:rgba(0,0,0,.18);border-radius:8px}::-webkit-scrollbar-track{background:transparent}').catch(() => {}));
  win.loadURL(APP_URL);
}

app.whenReady().then(() => {
  // faqat ilovaga kerakli ruxsatlar (bildirishnoma, buferga nusxa) — kamera/mikrofon so'ralmaydi
  session.defaultSession.setPermissionRequestHandler((wc, perm, cb) => cb(['notifications', 'clipboard-sanitized-write', 'clipboard-read', 'fullscreen'].includes(perm)));
  const isMac = process.platform === 'darwin';
  Menu.setApplicationMenu(Menu.buildFromTemplate([
    ...(isMac ? [{ label: 'Oldi-Berdi', submenu: [{ role: 'about', label: 'Oldi-Berdi haqida' }, { type: 'separator' }, { role: 'hide', label: 'Yashirish' }, { role: 'quit', label: 'Chiqish' }] }] : []),
    { label: 'Ilova', submenu: [{ label: 'Yangilash', accelerator: 'CmdOrCtrl+R', click: () => win && win.loadURL(APP_URL) }, { type: 'separator' }, isMac ? { role: 'close', label: 'Oynani yopish' } : { role: 'quit', label: 'Chiqish' }] },
    { label: 'Tahrirlash', submenu: [{ role: 'undo', label: 'Bekor qilish' }, { role: 'redo', label: 'Qaytarish' }, { type: 'separator' }, { role: 'cut', label: 'Kesish' }, { role: 'copy', label: 'Nusxa olish' }, { role: 'paste', label: "Qo'yish" }, { role: 'selectAll', label: 'Hammasini tanlash' }] },
    { label: "Ko'rinish", submenu: [{ role: 'zoomIn', label: 'Kattalashtirish' }, { role: 'zoomOut', label: 'Kichiklashtirish' }, { role: 'resetZoom', label: 'Asl o\'lcham' }, { type: 'separator' }, { role: 'togglefullscreen', label: "To'liq ekran" }] }
  ]));
  create();
  app.on('activate', () => { if (!BrowserWindow.getAllWindows().length) create(); });
});
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
