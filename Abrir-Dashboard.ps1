$ErrorActionPreference = "Stop"

$projectPath = $PSScriptRoot
$serverPort = 8000
$localUrl = "http://127.0.0.1:$serverPort/index.php"

try {
    $phpExecutable = (Get-Command php -ErrorAction Stop).Source
}
catch {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
        "No se encontró PHP en el equipo. Instala PHP y vuelve a ejecutar este archivo.",
        "PHP no disponible",
        "OK",
        "Error"
    ) | Out-Null
    exit 1
}

$existingServer = Get-NetTCPConnection -LocalPort $serverPort -State Listen -ErrorAction SilentlyContinue

if (-not $existingServer) {
    $phpServer = Start-Process `
        -FilePath $phpExecutable `
        -ArgumentList @("-S", "127.0.0.1:$serverPort") `
        -WorkingDirectory $projectPath `
        -WindowStyle Hidden `
        -PassThru

    $serverReady = $false

    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        Start-Sleep -Milliseconds 250

        try {
            $response = Invoke-WebRequest -Uri $localUrl -UseBasicParsing -TimeoutSec 1

            if ($response.StatusCode -eq 200) {
                $serverReady = $true
                break
            }
        }
        catch {
            # El servidor todavía está iniciando.
        }
    }

    if (-not $serverReady) {
        if (-not $phpServer.HasExited) {
            Stop-Process -Id $phpServer.Id -Force -ErrorAction SilentlyContinue
        }

        Add-Type -AssemblyName PresentationFramework
        [System.Windows.MessageBox]::Show(
            "No fue posible iniciar el servidor local en el puerto $serverPort.",
            "Error al abrir el dashboard",
            "OK",
            "Error"
        ) | Out-Null
        exit 1
    }
}

# Abre index.php en el navegador predeterminado de Windows.
Start-Process -FilePath "explorer.exe" -ArgumentList @($localUrl)
