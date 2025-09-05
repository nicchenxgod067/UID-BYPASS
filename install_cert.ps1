# Install Certificate in BlueStacks PowerShell Script
param(
    [string]$Device = "127.0.0.1:5555"
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "    Installing Certificate in BlueStacks" -ForegroundColor Cyan
Write-Host "    Device: $Device" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Define paths
$CertPath = "$env:USERPROFILE\.mitmproxy\mitmproxy-ca-cert.pem"
$TempCert = "$PWD\temp_cert.pem"

# Check if certificate exists
if (-not (Test-Path $CertPath)) {
    Write-Host "Error: Certificate not found at $CertPath" -ForegroundColor Red
    Read-Host "Press Enter to continue"
    exit 1
}

Write-Host "Certificate found at: $CertPath" -ForegroundColor Green

# Get certificate hash using .NET
try {
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertPath)
    $certHash = $cert.GetCertHashString()
    $certFile = "$certHash.0"
    Write-Host "Certificate hash: $certHash" -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to get certificate hash: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to continue"
    exit 1
}

# Copy certificate with hash name
try {
    Copy-Item $CertPath $TempCert
    Write-Host "Certificate copied to temp location" -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to copy certificate: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to continue"
    exit 1
}

# Check if ADB is available
try {
    $adbPath = Get-Command adb -ErrorAction Stop
    Write-Host "ADB found at: $($adbPath.Source)" -ForegroundColor Green
} catch {
    Write-Host "Error: ADB not found in PATH. Please install Android SDK Platform Tools." -ForegroundColor Red
    Remove-Item $TempCert -ErrorAction SilentlyContinue
    Read-Host "Press Enter to continue"
    exit 1
}

# Connect to emulator
Write-Host "Connecting to BlueStacks..." -ForegroundColor Yellow
try {
    $result = & adb connect $Device 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to connect: $result"
    }
    Write-Host "Connected to $Device" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Remove-Item $TempCert -ErrorAction SilentlyContinue
    Read-Host "Press Enter to continue"
    exit 1
}

# Push certificate to emulator (try multiple locations)
Write-Host "Pushing certificate to emulator..." -ForegroundColor Yellow
$pushSuccess = $false

# Try system location first
try {
    $result = & adb -s $Device push $TempCert "/system/etc/security/cacerts/" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Certificate pushed to system location successfully!" -ForegroundColor Green
        $pushSuccess = $true
    }
} catch {
    Write-Host "Warning: Could not push to system location" -ForegroundColor Yellow
}

# If system location failed, try user location
if (-not $pushSuccess) {
    try {
        $result = & adb -s $Device push $TempCert "/sdcard/" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Certificate pushed to sdcard successfully!" -ForegroundColor Green
            Write-Host "You will need to manually install this certificate in BlueStacks settings" -ForegroundColor Yellow
            $pushSuccess = $true
        }
    } catch {
        Write-Host "Warning: Could not push to sdcard" -ForegroundColor Yellow
    }
}

if (-not $pushSuccess) {
    Write-Host "Error: Failed to push certificate to any location" -ForegroundColor Red
    & adb -s $Device disconnect 2>$null
    Remove-Item $TempCert -ErrorAction SilentlyContinue
    Read-Host "Press Enter to continue"
    exit 1
}

# Set permissions (only if pushed to system location)
if ($pushSuccess) {
    Write-Host "Setting certificate permissions..." -ForegroundColor Yellow
    try {
        & adb -s $Device shell "su -c 'mount -o rw,remount /system'" 2>$null
        & adb -s $Device shell "su -c 'chmod 644 /system/etc/security/cacerts/$certFile'" 2>$null
        & adb -s $Device shell "su -c 'chown root:root /system/etc/security/cacerts/$certFile'" 2>$null
        Write-Host "Permissions set successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not set permissions (may require root access)" -ForegroundColor Yellow
    }
}

# Reboot emulator
Write-Host "Rebooting BlueStacks..." -ForegroundColor Yellow
try {
    & adb -s $Device reboot 2>$null
    Write-Host "BlueStacks rebooting. Please wait and test after restart." -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not reboot automatically" -ForegroundColor Yellow
}

# Clean up
Remove-Item $TempCert -ErrorAction SilentlyContinue
& adb -s $Device disconnect 2>$null

Write-Host ""
Write-Host "Certificate installation completed!" -ForegroundColor Green
Write-Host "After BlueStacks restarts, you can run connect_bluestacks.bat" -ForegroundColor Cyan
Read-Host "Press Enter to continue"
