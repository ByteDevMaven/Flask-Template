# Saving the final updated script as a text file for easy download
#!/bin/bash
set -e

# === PATHS ===
STATIC_ROOT="app/static"
CSS_DIR="$STATIC_ROOT/css"
SRC_DIR="$STATIC_ROOT/src"
JS_DIR="$STATIC_ROOT/js"

# === PYTHON SETUP ===
pip install Flask Flask-SQLAlchemy Flask-Migrate Flask-Login Flask-Cors bcrypt

# === NODE SETUP ===
npm init -y
npm install -D tailwindcss @tailwindcss/cli typescript autoprefixer concurrently
npx tsc --init

# === FOLDER STRUCTURE ===
mkdir -p $CSS_DIR $SRC_DIR $JS_DIR
mkdir -p app/templates
mkdir -p app/main/templates/main
mkdir -p app/dashboard/templates/dashboard
mkdir -p app/main/static
mkdir -p app/dashboard/static
touch app/__init__.py
touch app/main/__init__.py
touch app/dashboard/__init__.py

# === ENTRYPOINT ===
cat > app.py <<EOF
from app import create_app
app = create_app()

if __name__ == '__main__':
    app.run(debug=True)
EOF

# === CONFIG ===
cat > config.py <<EOF
import os
BASE_DIR = os.path.abspath(os.path.dirname(__file__))

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'devkey')
    SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(BASE_DIR, 'app.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
EOF

# === EXTENSIONS ===
cat > extensions.py <<EOF
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_cors import CORS

db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()
cors = CORS()
EOF

# === FLASK APP INIT ===
cat > app/__init__.py <<EOF
from flask import Flask
from extensions import db, migrate, login_manager, cors
from app.main import main_bp
from app.dashboard import dashboard_bp
from models import User

def create_app():
    app = Flask(__name__)
    app.config.from_object('config.Config')

    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    cors.init_app(app)

    login_manager.login_view = 'main.index'

    login_manager.user_loader(lambda user_id: User.query.get(int(user_id)))

    app.register_blueprint(main_bp)
    app.register_blueprint(dashboard_bp)

    return app
EOF

# === MODELS ===
cat > models.py <<EOF
from extensions import db
from flask_login import UserMixin
import bcrypt

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)

    def set_password(self, password):
        self.password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    def check_password(self, password):
        return bcrypt.checkpw(password.encode('utf-8'), self.password_hash.encode('utf-8'))

    def __repr__(self):
        return f'<User {self.username}>'
EOF

# === BASE HTML TEMPLATE ===
cat > app/templates/base.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{% block title %}My Flask App{% endblock %}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/main.css') }}">
</head>
<body class="bg-gray-100 min-h-screen">
    <div class="container mx-auto p-4">
        {% block content %}{% endblock %}
    </div>
</body>
</html>
EOF

# === MAIN BLUEPRINT ===
cat > app/main/__init__.py <<EOF
from flask import Blueprint
main_bp = Blueprint('main', __name__,
                    template_folder='templates',
                    static_folder='static',
                    url_prefix='/')
from . import routes
EOF

cat > app/main/routes.py <<EOF
from flask import render_template, request, redirect, url_for, flash
from flask_login import login_user, logout_user, login_required
from models import User
from extensions import db
from . import main_bp

@main_bp.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        if user and user.check_password(password):
            login_user(user)
            return redirect(url_for('dashboard.home'))
        flash('Invalid credentials')
    return render_template('main/index.html')

@main_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        if User.query.filter_by(username=username).first():
            flash('Username already exists')
            return redirect(url_for('main.register'))
        user = User(username=username)
        user.set_password(password)
        db.session.add(user)
        db.session.commit()
        flash('Registration successful')
        return redirect(url_for('main.index'))
    return render_template('main/register.html')

@main_bp.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('main.index'))
EOF

cat > app/main/templates/main/base.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{% block title %}{% endblock %}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/main.css') }}">
</head>
<body class="bg-gray-100 p-6">
    {% block content %}{% endblock %}
</body>
</html>
EOF

cat > app/main/templates/main/index.html <<'EOF'
{% extends 'main/base.html' %}
{% block title %}Login{% endblock %}
{% block content %}
<div class="max-w-md mx-auto bg-white p-6 rounded shadow">
    <h1 class="text-xl font-bold mb-4">Login</h1>
    <form method="post">
        <input name="username" type="text" placeholder="Username" required class="border px-2 py-1 w-full mb-4">
        <input name="password" type="password" placeholder="Password" required class="border px-2 py-1 w-full mb-4">
        <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">Login</button>
    </form>
    <p class="mt-4 text-sm">Don't have an account? <a href="{{ url_for('main.register') }}" class="text-blue-600">Register</a></p>
</div>
{% endblock %}
EOF

cat > app/main/templates/main/register.html <<'EOF'
{% extends 'main/base.html' %}
{% block title %}Register{% endblock %}
{% block content %}
<div class="max-w-md mx-auto bg-white p-6 rounded shadow">
    <h1 class="text-xl font-bold mb-4">Register</h1>
    <form method="post">
        <input name="username" type="text" placeholder="Username" required class="border px-2 py-1 w-full mb-4">
        <input name="password" type="password" placeholder="Password" required class="border px-2 py-1 w-full mb-4">
        <button type="submit" class="bg-green-500 text-white px-4 py-2 rounded">Register</button>
    </form>
</div>
{% endblock %}
EOF

# === DASHBOARD BLUEPRINT ===
cat > app/dashboard/__init__.py <<EOF
from flask import Blueprint
dashboard_bp = Blueprint('dashboard', __name__,
                         template_folder='templates',
                         static_folder='static',
                         url_prefix='/dashboard')
from . import routes
EOF

cat > app/dashboard/routes.py <<EOF
from flask import render_template
from flask_login import login_required
from . import dashboard_bp

@dashboard_bp.route('/')
@login_required
def home():
    return render_template('dashboard/index.html')
EOF

cat > app/dashboard/templates/dashboard/index.html <<'EOF'
{% extends 'base.html' %}

{% block title %}Dashboard{% endblock %}

{% block content %}
<h1 class="text-2xl font-bold text-blue-600">Welcome to your dashboard!</h1>
<p class="mt-2 text-gray-700">This is a secure area accessible only to logged-in users.</p>
<a href="{{ url_for('main.logout') }}" class="text-red-500">Logout</a>
{% endblock %}
EOF

# === TAILWIND BASE INPUT.CSS ===
cat > $CSS_DIR/input.css <<EOF
@import "tailwindcss";
EOF

# === TYPESCRIPT SOURCES ===
cat > $SRC_DIR/main.ts <<'EOF'
// Future TypeScript logic can go here
console.log("Login/Register page loaded!");
EOF

cat > $SRC_DIR/dashboard.ts <<'EOF'
// Future dashboard logic can go here
console.log("Dashboard loaded!");
EOF

# === PACKAGE SCRIPTS ===
npx json -I -f package.json -e 'this.scripts={
    "build:css": "npx @tailwindcss/cli -i ./app/static/css/input.css -o ./app/static/css/main.css --minify",
    "watch:css": "npx @tailwindcss/cli -i ./app/static/css/input.css -o ./app/static/css/main.css --watch",
    "watch:ts": "tsc --watch",
    "dev": "concurrently \\"npm run watch:css\\" \\"npm run watch:ts\\""
}'

# === GIT SETUP ===
cat > .gitignore <<EOF
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*.pyo

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/

# Virtual environments
venv/
ENV/
env/
.venv/

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Flask stuff
instance/
*.db
*.sqlite3

# Node
node_modules/
npm-debug.log
yarn-debug.log
yarn-error.log
dist/
*.tsbuildinfo

# Environment variables
.env
.env.*

# IDEs and editors
.vscode/
.idea/
*.sublime-project
*.sublime-workspace

# macOS and Linux
.DS_Store
*.swp
EOF

# === INITIAL BUILD ===
npm run build:css

# === DB SETUP ===
export FLASK_APP=app.py
flask db init
flask db migrate -m "Initial"
flask db upgrade

echo "✅ Project setup complete!"
echo "👉 Run dev: npm run dev"
echo "👉 Start Flask: source venv/bin/activate && python app.py"