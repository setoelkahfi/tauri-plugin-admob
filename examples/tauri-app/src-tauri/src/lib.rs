// Learn more about Tauri commands at https://tauri.app/v1/guides/features/command
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    #[cfg(debug_assertions)]
    let builder = tauri::Builder::default().plugin(tauri_plugin_devtools::init());
    #[cfg(not(debug_assertions))]
    let builder = tauri::Builder::default();

    builder
        .invoke_handler(tauri::generate_handler![greet])
        .setup(|#[allow(unused)] app| {
            // Android-only plugin.
            #[cfg(target_os = "android")]
            {
                app.handle().plugin(tauri_plugin_admob::init())?;
            }
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
