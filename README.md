# UID Bypass Setup Guide

Follow these steps to install and run the **Bypass Tool**.

---

## 1. Install Python
- Ensure you have **Python 3.13.7** installed.
- Verify installation:
  ```bash
  python --version
  ```

---

## 2. Create a Virtual Environment
```bash
python -m venv venv
```
- If `virtualenv` is missing, install it:
  ```bash
  pip install virtualenv
  ```

---

## 3. Activate the Virtual Environment
- **Windows (PowerShell)**:
  ```powershell
  venv\Scripts\Activate
  ```
  If you get an execution policy error:
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  ```
- **macOS/Linux**:
  ```bash
  source venv/bin/activate
  ```

---

## 4. Install Dependencies
```bash
pip install -r requirements.txt
```

---

## 5. Run the Server
```bash
mitmdump -s bypass.py
```

---

## 6. Get Your Local IP and Configure Proxy
1. Open **Command Prompt** and type:
   ```bash
   ipconfig
   ```
2. Note your **IPv4 Address**.
3. Set your proxy **before opening the game**:
   ```
   [Your IPv4 Address]:8080
   ```
4. Once in the lobby, **disable the proxy**.

---

✅ **Happy coding!**
