# Clinical Trial Virtual Participant Simulator

A fully local browser-based prototype for practicing participant-facing clinical trial communication. The first use case is recruitment and consent practice, but the simulator also supports follow-up visits, medication adherence checks, adverse event questioning, missed visits, retention conversations, protocol deviations, withdrawal requests, participant questions, and safety escalation scenarios.

This prototype uses:

- Python
- Gradio for the local browser UI
- Ollama for local LLM responses
- faster-whisper for local microphone transcription
- Local files only
- A local SVG virtual participant face with text-timed mouth animation

The face animation is a prototype visual cue. It is timed from the VP's generated text and does not perform true phoneme-level audio lip sync.

## Privacy Warning

Training prototype only. Do not enter patient identifiers or real clinical information. Not for real recruitment, medical advice, safety triage, or clinical decision-making.

The app is designed so that source materials in `materials/` are loaded server-side as hidden grounding context. The UI does not display raw source files, does not include a file upload component, and uses `share=False` in Gradio. Session transcripts are saved locally in `sessions/`.

Do not put PHI, real patient data, or confidential sponsor data into this prototype.

## Folder Layout

```text
clinical-trial-virtual-participant-simulator/
  app.py
  requirements.txt
  README.md
  .gitignore
  config.example.json
  example_materials/
  materials/              # local only, not committed
  sessions/
```

The included `example_materials/` files are concise examples only. Copy them into a local `materials/` folder or point `config.json` at a separate local materials folder before real training use.

## Windows Installation

### Fast Start: Double-Click Launcher

For easiest use, double-click:

```text
run_windows.bat
```

The launcher will:

- create `.venv` if needed
- install/check Python requirements
- create `config.json` if missing
- check for Ollama
- pull `llama3.2:3b` if Ollama is installed and the model is missing
- start the app
- open `http://127.0.0.1:7860`

Leave the launcher window open while using the simulator. Press `Ctrl+C` in that window to stop the app.

If Ollama is not installed, the web app can still open, but VP responses will not work until Ollama is installed.

### 1. Install Python

Install Python 3.10 or newer from [python.org](https://www.python.org/downloads/windows/).

During installation, check **Add python.exe to PATH**.

Confirm PowerShell can find Python:

```powershell
python --version
```

### 2. Install Ollama

Install Ollama for Windows from [ollama.com](https://ollama.com/).

Pull the default lightweight model:

```powershell
ollama pull llama3.2:3b
```

Optional better model, if your laptop has enough RAM:

```powershell
ollama pull qwen2.5:7b
```

If you use `qwen2.5:7b`, update `config.json` and set `"ollama_model": "qwen2.5:7b"`.

### 3. Create a Virtual Environment

From the parent folder:

```powershell
cd "C:\Users\Charlotte\Documents\Virtual Patient for Clinical Trials\clinical-trial-virtual-participant-simulator"
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

If PowerShell blocks activation, run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\.venv\Scripts\Activate.ps1
```

### 4. Create Local Config

```powershell
Copy-Item config.example.json config.json
```

Open `config.json` in a text editor and change the passwords:

```json
"app_title": "Clinical Trial Virtual Participant Simulator",
"auth_users": [
  ["charlotte", "your-local-password"],
  ["volunteer1", "another-local-password"]
]
```

For a trial-specific local copy, set `app_title` to the trial name, for example:

```json
"app_title": "TRACE Clinical Trial Virtual Participant Simulator"
```

### 5. Run the App

Make sure Ollama is running, then run:

```powershell
python app.py
```

Open:

[http://127.0.0.1:7860](http://127.0.0.1:7860)

Log in with one of the username/password pairs from `config.json`.

## Same-Network Access

By default, the app binds only to your own laptop:

```json
"local_only": true
```

For same-network browser access, set:

```json
"local_only": false
```

Then restart:

```powershell
python app.py
```

Other people on the same trusted local network can browse to:

```text
http://YOUR-LAPTOP-LAN-IP:7860
```

Keep these safeguards:

- Use strong local passwords in `config.json`.
- Use only a trusted local network.
- Keep Gradio `share=False`.
- Do not expose Ollama directly to the network. Leave Ollama on localhost.
- Do not put PHI or real patient data into the prototype.

If Windows Firewall asks whether to allow Python, allow only on private/trusted networks.

## Source Materials

Put concise approved training summaries in `materials/` as `.md` files. The app loads all Markdown files at runtime and uses them as hidden grounding context.

The raw materials are not shown in the UI, not downloadable through any app control, and not accepted from users as uploads.

If the combined materials are too long, the app prints a terminal warning and truncates the prompt context for this simple prototype.

For a GitHub-safe workflow, keep trial-specific content outside this generic app folder. In your local `config.json`, set:

```json
"materials_dir": "../clinical-trial-virtual-participant-simulator-trial-specific/materials",
"sessions_dir": "../clinical-trial-virtual-participant-simulator-trial-specific/sessions"
```

The local `config.json`, `materials/`, `sessions/`, and the sibling trial-specific folder should not be committed.

To make a local generic materials folder from the safe examples:

```powershell
Copy-Item -Recurse example_materials materials
```

## Session Transcripts

During a session, the conversation is held in memory. When you click **End session + evaluate**, the app generates a structured feedback report and saves a timestamped Markdown transcript in:

```text
sessions/
```

The transcript records timestamp, scenario type, difficulty level, persona, trainee text, input mode, and virtual participant reply.

## Audio Transcription

The app uses faster-whisper locally. The default model is:

```json
"whisper_model_size": "base"
```

`tiny` is faster but less accurate. `base` is a reasonable default for a laptop. The first transcription may take longer while the model initializes.

## Troubleshooting

### Ollama Not Running

Open Ollama from the Start menu, or run:

```powershell
ollama serve
```

Then restart the app.

### Model Not Found

Pull the configured model:

```powershell
ollama pull llama3.2:3b
```

If `config.json` says `qwen2.5:7b`, run:

```powershell
ollama pull qwen2.5:7b
```

### Microphone Not Working

- Use Chrome or Edge.
- Click **Enable microphone** in the app to trigger the browser permission prompt.
- Allow microphone permission when the browser asks.
- Check Windows microphone privacy settings.
- Confirm the app is using **Audio** mode before recording.

### Transcription Is Slow

Set a smaller Whisper model in `config.json`:

```json
"whisper_model_size": "tiny"
```

Restart the app.

### Responses Are Slow

Use the smaller default model:

```json
"ollama_model": "llama3.2:3b"
```

Close other heavy applications. Local LLM speed depends heavily on CPU, RAM, and GPU availability.

The app also has speed/quality tuning fields in `config.json`:

```json
"participant_num_predict": 160,
"participant_material_char_limit": 12000,
"ollama_num_ctx": 4096,
"ollama_keep_alive": "10m"
```

For faster VP turns, reduce `participant_num_predict` to `100` or reduce `participant_material_char_limit` to `8000`. Restart the app after changing config.

### AMD Radeon GPU

Ollama for Windows can use supported AMD Radeon GPUs, but support depends on the exact GPU model and current AMD/Ollama drivers. Install the current AMD Radeon driver and the current Ollama for Windows. Then run a model and check Ollama logs if generation still appears to be CPU-only.

Useful checks:

```powershell
ollama --version
ollama pull llama3.2:3b
ollama run llama3.2:3b
```

Ollama logs are usually in:

```text
%LOCALAPPDATA%\Ollama\server.log
```

Look for messages about AMD, ROCm, Vulkan, GPU discovery, or CPU fallback.

### 8 GB RAM Laptop Issues

Use:

```json
"ollama_model": "llama3.2:3b",
"whisper_model_size": "tiny"
```

Avoid running other memory-heavy applications. `qwen2.5:7b` may be too large for comfortable use on 8 GB RAM.

### Windows Firewall Prompt

For local-only use, the app binds to `127.0.0.1`. For same-network access, Windows may prompt for firewall permission. Allow access only on private/trusted networks.

## Exact PowerShell Run Commands

```powershell
cd "C:\Users\Charlotte\Documents\Virtual Patient for Clinical Trials\clinical-trial-virtual-participant-simulator"
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
Copy-Item config.example.json config.json
ollama pull llama3.2:3b
python app.py
```

Then open:

[http://127.0.0.1:7860](http://127.0.0.1:7860)
