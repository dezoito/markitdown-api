# MarkItDown API Server

This project is a lightweight REST API server built using FastAPI that receives binary data from a file, converts it to Markdown format using the [MarkItDown](https://github.com/microsoft/markitdown) library, and returns the Markdown content.

[<img src="./images/flow.png?raw=true" alt="Workflow chart" width="720">](./images/flow.png?raw=true)

> [!IMPORTANT]
> This project started as a fork of [elbruno/MarkItDownServer](https://github.com/elbruno/MarkItDownServer).

> [!NOTE]
> This project uses `uv` for dependency management and multistage Docker builds, significantly reducing build times and final image size.

## Using Pre-built Image

The easiest way to get started is to use the pre-built image from GitHub Container Registry:

```bash
docker pull ghcr.io/dezoito/markitdown-api:latest
docker run -d --name markitdown-api -p 8490:8490 ghcr.io/dezoito/markitdown-api:latest
```

## Setup Instructions

1. Clone the repository:

   ```bash
   git clone <repository-url>
   ```

1. Navigate to the project directory:

   ```bash
   cd <project-dir>
   ```

1. Build the docker image

   ```bash
   docker build -t markitdown-api:latest .
   ```

1. Run the docker container

   ```bash
   docker run -d --name markitdown-api -p 8490:8490 markitdown-api:latest
   ```

## Development Workflow

For easier development, a convenience script is included to rebuild the image and restart the container:

1. Make the script executable:

   ```bash
   chmod +x rebuild.sh
   ```

2. Run the script whenever you make changes:

   ```bash
   ./rebuild.sh
   ```

The script will:

- Stop the running container
- Remove the container
- Build a fresh image
- Start a new container
- Verify the container is running

This simplifies the development process when you're making frequent changes to the codebase.

## Endpoints

The API offers two main endpoints:

### `/docs`

Provides an interactive documentation interface where you can:

- Read and explore the existing API endpoints
- View request/response schemas and examples

### `/process_file`

Accepts a POST request containing a file to convert to markdown.

- **Method**: POST
- **Content-Type**: multipart/form-data
- **Parameter**: file (binary)
- **Accepted file types**: doc, docx, ppt, pptx, pdf, xls, xlsx, txt, csv, json
- **Returns**: JSON object with the converted markdown content

For more information regarding valid file types, check the official [MarkItDown](https://github.com/microsoft/markitdown) project.

## Testing the application

You can quickly test that the application is running by uploading a file via `curl`, like so:

```sh
curl -X POST -F "file=@path/to/mypdf.pdf" http://localhost:8490/process_file
```

The result should be a string encoding a JSON object like:

```json
{ "markdown": "Your content written in markdown..." }
```

Here's a very simple example in Python:

```py
import requests

file_path = "/path/to/my.pdf"
with open(file_path, 'rb') as file:
    # Prepare the file for the multipart/form-data request
    files = {'file': (file_path, file)}
    
    # Make the POST request to the API
    response = requests.post("http://localhost:8490/process_file", files=files)
    
    # Parse the JSON response
    result = response.json()
    
    # Return the markdown content
    content = result.get('markdown')
```

## Acknowledgments

This project was originally based on [elbruno/MarkItDownServer](https://github.com/elbruno/MarkItDownServer) by Bruno Capuano.

## License

This project is licensed under the MIT License.
