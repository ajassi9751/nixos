use axum::{
    Router,
    extract::{DefaultBodyLimit, Multipart},
    http::StatusCode,
    response::{Html, IntoResponse, Response},
    routing::{get, post},
};
use std::net::SocketAddr;
use tokio::fs::{self, File};
use tokio::io::AsyncWriteExt;

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(serve_index)).route(
        "/upload",
        post(handle_upload).layer(DefaultBodyLimit::disable()),
    );

    let addr = SocketAddr::from(([0, 0, 0, 0], 8020));
    println!("Server started at http://{}", addr);

    let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn serve_index() -> Html<String> {
    let args: Vec<String> = std::env::args().collect();
    let _ = fs::create_dir_all(&args[1]).await;

    let mut folder_options = String::new();
    if let Ok(mut entries) = fs::read_dir(&args[1]).await {
        while let Ok(Some(entry)) = entries.next_entry().await {
            if let Ok(file_type) = entry.file_type().await {
                if file_type.is_dir() {
                    if let Some(name) = entry.file_name().to_str() {
                        folder_options
                            .push_str(&format!("<option value=\"{}\">{}</option>", name, name));
                    }
                }
            }
        }
    }

    let template = match fs::read_to_string("html/index.html").await {
        Ok(content) => content,
        Err(_) => String::from("<h1>Error loading page</h1>"),
    };

    let final_html = template.replace("{{FOLDER_OPTIONS}}", &folder_options);
    Html(final_html)
}

async fn handle_upload(mut multipart: Multipart) -> Response {
    let _ = fs::create_dir_all("./uploads").await;

    let mut target_folder = String::new();
    let mut files_to_save = vec![];

    while let Some(field) = multipart.next_field().await.unwrap() {
        let name = field.name().unwrap_or("").to_string();

        if name == "new_folder" {
            let text = field.text().await.unwrap_or_default();
            let trimmed = text.trim();
            if !trimmed.is_empty() {
                target_folder = trimmed.replace(['/', '\\', '.'], "");
            }
        } else if name == "folder" {
            let text = field.text().await.unwrap_or_default();
            if target_folder.is_empty() && !text.is_empty() {
                target_folder = text.replace(['/', '\\', '.'], "");
            }
        } else if name == "media" {
            if let Some(file_name) = field.file_name() {
                let file_name = file_name.to_string();
                if file_name.is_empty() {
                    continue;
                }
                match field.bytes().await {
                    Ok(data) => files_to_save.push((file_name, data)),
                    Err(e) => eprintln!("Failed to read file stream: {}", e),
                }
            }
        }
    }

    // Return explicit HTTP error codes instead of redirects
    if target_folder.is_empty() {
        return (
            StatusCode::BAD_REQUEST,
            "You must select or create a destination folder!",
        )
            .into_response();
    }

    if files_to_save.is_empty() {
        return (
            StatusCode::BAD_REQUEST,
            "No valid files were selected for upload.",
        )
            .into_response();
    }

    let args: Vec<String> = std::env::args().collect();
    let dest_dir = format!("{}/{}", args[1], target_folder);
    let _ = fs::create_dir_all(&dest_dir).await;

    let upload_futures = files_to_save.into_iter().map(|(file_name, data)| {
        let dest_dir = dest_dir.clone();
        async move {
            let path = format!("{}/{}", dest_dir, file_name);
            match File::create(&path).await {
                Ok(mut file) => {
                    if let Err(e) = file.write_all(&data).await {
                        eprintln!("Failed to write file {}: {}", file_name, e);
                    } else {
                        println!("Successfully saved: {}", path);
                    }
                }
                Err(e) => eprintln!("Failed to create file {}: {}", file_name, e),
            }
        }
    });

    futures::future::join_all(upload_futures).await;

    StatusCode::OK.into_response()
}
