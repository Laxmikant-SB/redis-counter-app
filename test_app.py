import subprocess
import sys

def test_app_file_exists():
    """Check that app.py exists"""
    import os
    assert os.path.exists("app.py"), "app.py is missing!"
    print("✅ app.py exists")

def test_app_has_no_syntax_errors():
    """Check that app.py can be parsed by Python without errors"""
    result = subprocess.run(
        [sys.executable, "-m", "py_compile", "app.py"],
        capture_output=True, text=True
    )
    assert result.returncode == 0, f"Syntax error in app.py: {result.stderr}"
    print("✅ app.py has no syntax errors")

def test_requirements_file_exists():
    """Check requirements.txt exists and has content"""
    import os
    assert os.path.exists("requirements.txt"), "requirements.txt missing!"
    with open("requirements.txt") as f:
        content = f.read()
    assert "redis" in content, "redis package not in requirements.txt"
    print("✅ requirements.txt is valid")

if __name__ == "__main__":
    test_app_file_exists()
    test_app_has_no_syntax_errors()
    test_requirements_file_exists()
    print("\n🎉 All tests passed!")
