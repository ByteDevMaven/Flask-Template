
# 🧪 Flask + Tailwind + TypeScript Full-Stack Starter

This is a full-featured Flask web application starter template that includes:

- ✅ Flask with Blueprints
- 🔐 Authentication (Login & Register)
- 🧩 SQLite + SQLAlchemy + Flask-Migrate
- 🌐 Flask-CORS + Flask-Login
- 💅 Tailwind CSS (via CLI)
- ✨ TypeScript Support
- ⚙️ Concurrent Dev Workflow with `concurrently`

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/ByteDevMaven/Flask-Template.git
cd Flask-Template
```

---

## ⚡ Run Without Downloading

If you just want to bootstrap the project **immediately without cloning**, run:

```bash
bash <(curl -s https://raw.githubusercontent.com/ByteDevMaven/Flask-Template/main/init.sh)
```

This will execute the full project setup script directly from the GitHub repository.

> ⚠️ Make sure you trust the script before executing remote code like this.

---

## 🛠️ Environment Setup

You can set up this project in two ways: **VS Code** (recommended for ease) or **manually** via terminal.

---

### ⚙️ Option A: VS Code Setup

1. **Open the project folder in VS Code**
2. **Create a virtual environment**:
   - Open the terminal inside VS Code and run:

     ```bash
     python3 -m venv venv
     ```

3. **Activate the virtual environment**:
   - macOS/Linux:

     ```bash
     source venv/bin/activate
     ```

   - Windows:

     ```powershell
     .\venv\Scripts\activate
     ```

4. **Run the project setup script**:

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

---

### ⚙️ Option B: Manual Setup via CLI

```bash
# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Run the project bootstrap script
chmod +x setup.sh
./setup.sh
```

---

## 📦 Available Scripts

### 📌 Dev Scripts (defined in `package.json`)

| Script        | Description                                      |
|---------------|--------------------------------------------------|
| `npm run build:css` | Compiles Tailwind CSS (one-time build)      |
| `npm run watch:css` | Watches Tailwind CSS changes                |
| `npm run watch:ts`  | Watches TypeScript files                    |
| `npm run dev`       | Runs both CSS and TS watchers concurrently |

---

## 🔥 Running the App

```bash
# 1. Activate your virtual environment
source venv/bin/activate

# 2. Start the Flask server
python app.py

# 3. Start frontend tooling
npm run dev
```

App will be available at: `http://localhost:5000/`

---

## 🧪 Features

- **User Login & Registration** (with hashed passwords via `bcrypt`)
- **Blueprint Structure**: `main/` and `dashboard/`
- **Login-protected Dashboard**
- **Responsive Tailwind UI**
- **TypeScript hooks for future frontend logic**

---

## 📁 Folder Structure

```
app/
├── main/
│   ├── templates/main/
│   ├── static/
│   ├── __init__.py
│   └── routes.py
├── dashboard/
│   ├── templates/dashboard/
│   ├── static/
│   ├── __init__.py
│   └── routes.py
├── templates/
├── static/
│   ├── css/
│   ├── src/ (TypeScript)
│   └── js/
├── __init__.py
config.py
extensions.py
models.py
app.py
setup.sh
```

---

## 🛡️ Security

- `.env` support recommended for production secrets
- Default `SECRET_KEY` is development-only
- Passwords stored as secure bcrypt hashes

---

## 🌍 Future Improvements

- Add `dotenv` support for secrets
- Integrate Jinja + HTMX/Alpine for rich interactivity
- Unit testing setup
- Role-based auth

---

## 🙌 Credits

Built with ❤️ using Flask, Tailwind, and TypeScript.