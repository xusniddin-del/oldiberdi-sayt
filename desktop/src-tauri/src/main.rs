// Oldi-Berdi — kompyuter dasturi. Internetdagi ilovani alohida oynada ochadi:
// akkaunt, ma'lumotlar va yangilanishlar telefon va sayt bilan bir xil.
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use tauri::webview::DownloadEvent;
use tauri::{Manager, Url, WebviewUrl, WebviewWindowBuilder};
use tauri_plugin_opener::OpenerExt;

const APP_HOSTS: [&str; 4] = ["xusniddin-del.github.io", "app.oldiberdi.uz", "oldiberdi.uz", "www.oldiberdi.uz"];

// target="_blank" va window.open havolalari ham shu oynadan o'tsin — tashqi havolalarni pastda ushlaymiz
const INIT_JS: &str = r#"
document.addEventListener('click', function (e) {
  var a = e.target && e.target.closest && e.target.closest('a[href]');
  if (a && (a.target === '_blank' || /^(tel|sms|mailto|tg):/i.test(a.href))) { e.preventDefault(); location.href = a.href; }
}, true);
window.open = function (u) { if (u) location.href = String(u); return null; };
"#;

fn is_app(url: &Url) -> bool {
    match url.scheme() {
        "tauri" | "about" | "blob" | "data" => true,
        "http" => url.host_str() == Some("tauri.localhost"),
        "https" => {
            let h = url.host_str().unwrap_or("");
            h == "tauri.localhost" || (APP_HOSTS.contains(&h) && !url.path().ends_with(".apk"))
        }
        _ => false,
    }
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_single_instance::init(|app, _args, _cwd| {
            if let Some(w) = app.get_webview_window("main") {
                let _ = w.unminimize();
                let _ = w.show();
                let _ = w.set_focus();
            }
        }))
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            let handle = app.handle().clone();
            let downloads = app.path().download_dir().ok();
            WebviewWindowBuilder::new(app, "main", WebviewUrl::App("index.html".into()))
                .title("Oldi-Berdi")
                .inner_size(1240.0, 820.0)
                .min_inner_size(380.0, 560.0)
                .center()
                .initialization_script(INIT_JS)
                .on_navigation(move |url| {
                    if is_app(url) { return true; }
                    let _ = handle.opener().open_url(url.as_str(), None::<&str>);
                    false
                })
                .on_download(move |_webview, event| {
                    if let DownloadEvent::Requested { url, destination } = event {
                        if let Some(dir) = &downloads {
                            let name = destination.file_name().map(|n| n.to_os_string())
                                .or_else(|| url.path_segments().and_then(|s| s.last()).map(|s| s.into()))
                                .unwrap_or_else(|| "Oldi-Berdi.xlsx".into());
                            *destination = dir.join(name);
                        }
                    }
                    true
                })
                .build()?;
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("Oldi-Berdi ishga tushmadi");
}
